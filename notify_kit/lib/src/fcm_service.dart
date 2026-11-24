import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'backend_client.dart';
import 'config.dart';
import 'mappers.dart';
import 'models.dart';
import 'safe.dart';

/// Internal: all firebase_messaging interaction. Not exported.
///
/// Subscriptions are created exactly once (the facade's init guard makes a
/// second init impossible), which fixes the duplicated-listener defect the
/// package was built to eliminate.
class FcmService {
  FcmService({NotifyBackendClient? backendClient})
      : _backendClient = backendClient ?? const NotifyBackendClient();

  /// Ceiling on [FirebaseMessaging.getInitialMessage].
  ///
  /// That call can never complete on iOS when no APNS token arrives — the
  /// normal case on a Simulator — which stalls `init()` forever and, for any
  /// caller awaiting it before `runApp`, freezes the app on its splash screen.
  /// Routing a cold-start tap is a nice-to-have; blocking startup is not, so
  /// the wait is bounded and a timeout is treated as "no initial message".
  static const Duration initialMessageTimeout = Duration(seconds: 5);

  /// Seam for the call above. Production always uses the default; tests
  /// substitute a future that never completes to prove init still finishes.
  @visibleForTesting
  Future<RemoteMessage?> Function() fetchInitialMessage =
      () => FirebaseMessaging.instance.getInitialMessage();

  /// The cold-start tap, or null if none arrived within
  /// [initialMessageTimeout]. Never throws and never outlives the window.
  @visibleForTesting
  Future<RemoteMessage?> initialMessageOrNull() => fetchInitialMessage()
          .timeout(
        initialMessageTimeout,
        onTimeout: () {
          debugPrint(
            'notify_kit: getInitialMessage timed out after '
            '${initialMessageTimeout.inSeconds}s — continuing without it',
          );
          return null;
        },
      );

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final NotifyBackendClient _backendClient;

  final StreamController<NotifyMessage> _foreground =
      StreamController<NotifyMessage>.broadcast();

  /// Foreground messages as a broadcast stream — for consumers beyond the
  /// single [NotifyConfig.onForegroundMessage] callback (auto-refresh, etc.).
  Stream<NotifyMessage> get foregroundMessages => _foreground.stream;

  Future<void> init(NotifyConfig config) async {
    final messaging = FirebaseMessaging.instance;
    final onError = config.onError;

    await messaging.setAutoInitEnabled(true);

    if (config.requestPermissionOnInit) {
      debugPrint('notify_kit: init: requesting permission…');
      final granted = await requestPermission();
      debugPrint('notify_kit: init: permission granted=$granted');
    }

    if (config.showSystemBannerInForeground) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Message subscriptions FIRST — they must never wait on network I/O.
    // (Token registration below POSTs to notify-hub; a slow backend used to
    // delay onMessage registration, leaving the app deaf in the foreground.)
    // Always subscribed: [foregroundMessages] must emit with or without the
    // onForegroundMessage callback.
    final onForeground = config.onForegroundMessage;
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen((message) {
        final mapped = messageFromRemote(message);
        _foreground.add(mapped);
        if (onForeground != null) {
          runSafely(
            'onForegroundMessage',
            () => onForeground(mapped),
            onError: onError,
          );
        }
      }),
    );

    // A remote tap is worth listening for if the app routes it (onTap) OR the
    // backend wants open-tracking — so open counts are recorded even when the
    // app itself ignores taps.
    final onTap = config.onTap;
    if (onTap != null || config.backend != null) {
      _subscriptions.add(
        FirebaseMessaging.onMessageOpenedApp.listen(
          (message) => _handleRemoteTap(
            config,
            message,
            NotifyTapSource.background,
          ),
        ),
      );

      // The fix for the classic discarded-getInitialMessage bug: a tap that
      // cold-started the app is awaited and routed like any other tap.
      debugPrint('notify_kit: init: checking initial message…');
      final initial = await initialMessageOrNull();
      if (initial != null) {
        _handleRemoteTap(config, initial, NotifyTapSource.terminated);
      }
    }

    // Token + backend registration LAST: getToken/POST can be slow and must
    // not gate the subscriptions above.
    if (config.backend != null || config.onToken != null) {
      final token = await getToken();
      if (token != null) {
        await _handleToken(config, token);
      }
      _subscriptions.add(
        messaging.onTokenRefresh.listen(
          (token) => _handleToken(config, token),
        ),
      );
    }
  }

  void _handleRemoteTap(
    NotifyConfig config,
    RemoteMessage remote,
    NotifyTapSource source,
  ) {
    final message = messageFromRemote(remote);
    final onTap = config.onTap;
    if (onTap != null) {
      runSafely(
        'onTap($source)',
        () => onTap(message, source),
        onError: config.onError,
      );
    }
    reportOpened(config, message);
  }

  /// Reports a campaign open when the tapped message carries the notify-hub
  /// `nh_notification_id` data key and a backend is configured.
  /// Fire-and-forget. Also called by the facade for local-notification taps,
  /// so foreground-displayed campaign pushes count as opened too.
  void reportOpened(NotifyConfig config, NotifyMessage message) {
    final backend = config.backend;
    final notificationId = message.data['nh_notification_id'];
    if (backend == null || notificationId is! String || notificationId.isEmpty) {
      return;
    }
    getToken().then((token) {
      if (token != null) {
        _backendClient.reportOpened(
          backend: backend,
          notificationId: notificationId,
          token: token,
        );
      }
    });
  }

  /// Returns null on failure instead of throwing (spec §8). On iOS, waits
  /// for the APNS token first — FCM cannot mint a token without it.
  Future<String?> getToken() async {
    if (!await waitForApnsToken()) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (error) {
      debugPrint('notify_kit: getToken failed: $error');
      return null;
    }
  }

  /// On iOS, FCM needs the APNS token before getToken / topic subscribe
  /// work. Polls with retries; false when it never shows up (e.g. some
  /// Simulators). Always true on Android.
  Future<bool> waitForApnsToken({
    int maxAttempts = 10,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    if (!Platform.isIOS) return true;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) return true;
      debugPrint(
        'notify_kit: waiting for APNS token (attempt $attempt/$maxAttempts)',
      );
      await Future.delayed(delay);
    }
    debugPrint('notify_kit: APNS token not available after $maxAttempts attempts');
    return false;
  }

  /// Subscribes to raw FCM topics (server-side broadcast targeting). Distinct
  /// from the notify-hub topic slugs in [setTopics]. Failures are logged,
  /// never thrown.
  Future<void> subscribeToFcmTopics(List<String> topics) async {
    if (!await waitForApnsToken()) return;
    for (final topic in topics) {
      try {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
        debugPrint('notify_kit: subscribed to FCM topic: $topic');
      } catch (error) {
        debugPrint('notify_kit: FCM topic subscribe failed ($topic): $error');
      }
    }
  }

  /// Unsubscribes from raw FCM topics. Failures are logged, never thrown.
  Future<void> unsubscribeFromFcmTopics(List<String> topics) async {
    for (final topic in topics) {
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
        debugPrint('notify_kit: unsubscribed from FCM topic: $topic');
      } catch (error) {
        debugPrint('notify_kit: FCM topic unsubscribe failed ($topic): $error');
      }
    }
  }

  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    return switch (settings.authorizationStatus) {
      AuthorizationStatus.authorized || AuthorizationStatus.provisional => true,
      _ => false,
    };
  }

  Future<void> registerDevice(
    NotifyConfig config, {
    NotifyUserProfile? user,
    NotifyDeviceProfile? device,
  }) async {
    final token = await getToken();
    if (token == null) {
      return;
    }

    await _registerBackendDevice(config, token, user: user, device: device);
  }

  Future<void> unregisterDevice(NotifyConfig config) async {
    final backend = config.backend;
    final token = await getToken();
    if (backend == null || token == null) {
      return;
    }
    await _backendClient.unregisterDevice(backend: backend, token: token);
  }

  Future<void> setTopics(
    NotifyConfig config,
    List<String> topics, {
    required bool subscribe,
  }) async {
    final backend = config.backend;
    final token = await getToken();
    if (backend == null || token == null || topics.isEmpty) {
      return;
    }
    await _backendClient.setTopics(
      backend: backend,
      token: token,
      topics: topics,
      subscribe: subscribe,
    );
  }

  Future<List<NotifyTopic>> fetchTopics(NotifyConfig config) async {
    final backend = config.backend;
    if (backend == null) {
      return const [];
    }
    return _backendClient.fetchTopics(backend: backend);
  }

  Future<void> _handleToken(NotifyConfig config, String token) async {
    final onToken = config.onToken;
    if (onToken != null) {
      runSafely('onToken', () => onToken(token), onError: config.onError);
    }

    await _registerBackendDevice(config, token);
  }

  Future<void> _registerBackendDevice(
    NotifyConfig config,
    String token, {
    NotifyUserProfile? user,
    NotifyDeviceProfile? device,
  }) async {
    final backend = config.backend;
    final platform = _platformValue();

    if (backend == null || platform == null) {
      return;
    }

    await _backendClient.registerDevice(
      backend: backend,
      token: token,
      platform: platform,
      user: user ?? config.user,
      device: device ?? config.device,
    );
  }

  String? _platformValue() => switch (defaultTargetPlatform) {
        TargetPlatform.android => 'android',
        TargetPlatform.iOS => 'ios',
        _ => null,
      };
}
