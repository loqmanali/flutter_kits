import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'config.dart';
import 'fcm_service.dart';
import 'local_service.dart';
import 'models.dart';

/// The single public entry point of notify_kit.
///
/// Call [init] once, after `Firebase.initializeApp()`. The package owns all
/// FCM / local-notification subscriptions; a second [init] is a no-op, so
/// duplicate listeners are impossible by construction.
class NotifyKit {
  NotifyKit._();

  static bool _initialized = false;
  static NotifyConfig? _config;
  static LocalService _local = LocalService();
  static FcmService _fcm = FcmService();

  // In-flight init future. A second call made while one is already running
  // awaits the same attempt instead of starting a concurrent second one —
  // that would double-run `_local.init`/`_fcm.init` and create duplicate
  // subscriptions, defeating the "impossible by construction" guarantee.
  static Future<void>? _initializing;

  /// Idempotent. Throws [StateError] if Firebase is not initialized.
  ///
  /// [firebaseReady] is a test seam; production callers never pass it.
  ///
  /// A failed attempt (Firebase not ready, or either service throwing) does
  /// NOT latch [_initialized] — call [init] again (e.g. after login) to
  /// retry. Only a genuinely successful init makes further calls a no-op.
  static Future<void> init(
    NotifyConfig config, {
    bool Function()? firebaseReady,
  }) {
    if (_initialized) {
      debugPrint('notify_kit: init() already called — ignoring');
      return Future.value();
    }
    final inFlight = _initializing;
    if (inFlight != null) return inFlight;

    // Assign the guard *before* `_doInit` runs. `_doInit` is `async`, so a
    // throw before its first `await` never propagates synchronously here —
    // it comes back as an already-failed Future — but `.then`'s callbacks
    // are always scheduled for later regardless, so clearing `_initializing`
    // inside them can never run before this assignment does.
    final completer = Completer<void>();
    _initializing = completer.future;
    unawaited(
      _doInit(config, firebaseReady).then(
        (_) {
          _initialized = true;
          _initializing = null;
          completer.complete();
        },
        onError: (Object error, StackTrace stackTrace) {
          _initializing = null;
          completer.completeError(error, stackTrace);
        },
      ),
    );
    return completer.future;
  }

  static Future<void> _doInit(
    NotifyConfig config,
    bool Function()? firebaseReady,
  ) async {
    final ready = firebaseReady ?? () => Firebase.apps.isNotEmpty;
    if (!ready()) {
      throw StateError(
        'notify_kit: call Firebase.initializeApp() before NotifyKit.init()',
      );
    }
    // Breadcrumbs so a hang inside init is attributable to an exact phase
    // from the console alone.
    debugPrint('notify_kit: init: local notifications…');
    // Local taps also report campaign opens (remote taps report inside
    // FcmService); the wrapper stays non-null when only tracking is needed.
    final onTap = config.onTap;
    await _local.init(
      config.androidChannel,
      (onTap == null && config.backend == null)
          ? null
          : (message, source) {
              _fcm.reportOpened(config, message);
              onTap?.call(message, source);
            },
      onError: config.onError,
    );
    debugPrint('notify_kit: init: FCM…');
    await _fcm.init(config);
    debugPrint('notify_kit: init: done');
    _config = config;
  }

  /// Current FCM token, or null on failure (never throws). On iOS this
  /// waits for the APNS token first.
  static Future<String?> getToken() => _fcm.getToken();

  /// Shows the system permission prompt (iOS always; Android 13+).
  static Future<bool> requestPermission() => _fcm.requestPermission();

  /// Foreground messages as a broadcast stream. Emits once [init] has run;
  /// safe to listen before that.
  static Stream<NotifyMessage> get foregroundMessages =>
      _fcm.foregroundMessages;

  /// Fires whenever the FCM token rotates.
  static Stream<String> get onTokenRefresh =>
      FirebaseMessaging.instance.onTokenRefresh;

  /// Subscribes to raw FCM topics (e.g. `all_users`). Waits for the iOS APNS
  /// token first. Distinct from the notify-hub slugs in [subscribeToTopics].
  static Future<void> subscribeToFcmTopics(List<String> topics) =>
      _fcm.subscribeToFcmTopics(topics);

  /// Unsubscribes from raw FCM topics.
  static Future<void> unsubscribeFromFcmTopics(List<String> topics) =>
      _fcm.unsubscribeFromFcmTopics(topics);

  /// Registers the current FCM token with notify-hub using the configured
  /// backend. Call this after login/profile changes if user data was not
  /// available during [init].
  static Future<void> registerDevice({
    NotifyUserProfile? user,
    NotifyDeviceProfile? device,
  }) {
    _ensureInitialized('registerDevice');
    final config = _config;
    if (config == null || config.backend == null) {
      return Future.value();
    }

    return _fcm.registerDevice(config, user: user, device: device);
  }

  /// Removes the current device from notify-hub. Call on logout so the user
  /// stops receiving pushes. No-op when no backend is configured.
  static Future<void> unregisterDevice() {
    _ensureInitialized('unregisterDevice');
    final config = _config;
    if (config == null || config.backend == null) {
      return Future.value();
    }
    return _fcm.unregisterDevice(config);
  }

  /// Lists the app's subscribable topics for a subscription screen. Returns
  /// an empty list when no backend is configured; throws
  /// [NotifyBackendException] on network/HTTP failure so the UI can retry.
  static Future<List<NotifyTopic>> fetchTopics() {
    _ensureInitialized('fetchTopics');
    final config = _config;
    if (config == null || config.backend == null) {
      return Future.value(const []);
    }
    return _fcm.fetchTopics(config);
  }

  /// Subscribes the current device to notify-hub [topics] (slugs). No-op
  /// when no backend is configured.
  static Future<void> subscribeToTopics(List<String> topics) =>
      _setTopics(topics, subscribe: true);

  /// Unsubscribes the current device from notify-hub [topics] (slugs).
  static Future<void> unsubscribeFromTopics(List<String> topics) =>
      _setTopics(topics, subscribe: false);

  static Future<void> _setTopics(
    List<String> topics, {
    required bool subscribe,
  }) {
    _ensureInitialized('setTopics');
    final config = _config;
    if (config == null || config.backend == null) {
      return Future.value();
    }
    return _fcm.setTopics(config, topics, subscribe: subscribe);
  }

  /// Immediate local notification. The payload map comes back via
  /// [NotifyConfig.onTap] with [NotifyTapSource.local] when tapped.
  static Future<void> showLocal({
    int id = 0,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
  }) {
    _ensureInitialized('showLocal');
    return _local.show(id: id, title: title, body: body, payload: payload);
  }

  /// Schedules a local notification that repeats daily at (hour, minute). Used
  /// for offline reminders (e.g. missed-reading nudges). Taps arrive at the
  /// same [NotifyConfig.onTap] with [NotifyTapSource.local].
  static Future<void> scheduleDaily({
    required int id,
    String? title,
    String? body,
    required int hour,
    required int minute,
    Map<String, dynamic>? payload,
  }) {
    _ensureInitialized('scheduleDaily');
    return _local.scheduleDaily(
      id: id,
      title: title,
      body: body,
      hour: hour,
      minute: minute,
      payload: payload,
    );
  }

  /// Schedules a one-shot local notification at an absolute [when]. Offline.
  static Future<void> scheduleAt({
    required int id,
    String? title,
    String? body,
    required DateTime when,
    Map<String, dynamic>? payload,
  }) {
    _ensureInitialized('scheduleAt');
    return _local.scheduleAt(
      id: id,
      title: title,
      body: body,
      when: when,
      payload: payload,
    );
  }

  static Future<void> cancelLocal(int id) {
    _ensureInitialized('cancelLocal');
    return _local.cancel(id);
  }

  static Future<void> cancelAllLocal() {
    _ensureInitialized('cancelAllLocal');
    return _local.cancelAll();
  }

  /// Registers an FCM background-isolate handler.
  ///
  /// FCM requires [handler] to be a TOP-LEVEL or static function in YOUR app,
  /// annotated with `@pragma('vm:entry-point')` — the background isolate
  /// starts with fresh statics, so the package cannot trampoline a stored
  /// callback for you. See the README for a copy-paste example.
  static void registerBackgroundHandler(BackgroundMessageHandler handler) {
    FirebaseMessaging.onBackgroundMessage(handler);
  }

  static void _ensureInitialized(String method) {
    if (!_initialized) {
      throw StateError(
        'notify_kit: call NotifyKit.init() before NotifyKit.$method()',
      );
    }
  }

  @visibleForTesting
  static void resetForTest({LocalService? local, FcmService? fcm}) {
    _initialized = false;
    _initializing = null;
    _config = null;
    _local = local ?? LocalService();
    _fcm = fcm ?? FcmService();
  }
}
