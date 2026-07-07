import 'dart:async';

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

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final NotifyBackendClient _backendClient;

  Future<void> init(NotifyConfig config) async {
    final messaging = FirebaseMessaging.instance;
    final onError = config.onError;

    await messaging.setAutoInitEnabled(true);

    if (config.requestPermissionOnInit) {
      await requestPermission();
    }

    if (config.showSystemBannerInForeground) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

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

    final onForeground = config.onForegroundMessage;
    if (onForeground != null) {
      _subscriptions.add(
        FirebaseMessaging.onMessage.listen(
          (message) => runSafely(
            'onForegroundMessage',
            () => onForeground(messageFromRemote(message)),
            onError: onError,
          ),
        ),
      );
    }

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
      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _handleRemoteTap(config, initial, NotifyTapSource.terminated);
      }
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
    _reportOpened(config, message);
  }

  /// Reports a campaign open when the tapped message carries a
  /// `notification_id` and a backend is configured. Fire-and-forget.
  void _reportOpened(NotifyConfig config, NotifyMessage message) {
    final backend = config.backend;
    final notificationId = message.data['notification_id'];
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

  /// Returns null on failure instead of throwing (spec §8).
  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (error) {
      debugPrint('notify_kit: getToken failed: $error');
      return null;
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
