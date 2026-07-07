import 'models.dart';

/// Configuration for [NotifyKit.init]. All UI decisions stay in the app:
/// the package displays nothing in the foreground by itself.
final class NotifyConfig {
  const NotifyConfig({
    required this.androidChannel,
    this.requestPermissionOnInit = true,
    this.showSystemBannerInForeground = true,
    this.backend,
    this.user,
    this.device,
    this.onToken,
    this.onForegroundMessage,
    this.onTap,
    this.onError,
  });

  /// The single Android notification channel used for local notifications.
  final AndroidChannelConfig androidChannel;

  /// Show the system permission prompt during init (iOS always,
  /// Android 13+ POST_NOTIFICATIONS).
  final bool requestPermissionOnInit;

  /// iOS only: show the system banner/badge/sound while the app is in
  /// the foreground (setForegroundNotificationPresentationOptions).
  final bool showSystemBannerInForeground;

  /// Optional notify-hub backend registration. When present, notify_kit
  /// sends the FCM token on init and every token refresh.
  final NotifyBackendConfig? backend;

  /// Optional user profile attached to the token registration.
  final NotifyUserProfile? user;

  /// Optional device/app metadata attached to the token registration.
  final NotifyDeviceProfile? device;

  /// Called with the initial FCM token during init AND on every refresh.
  final NotifyTokenHandler? onToken;

  /// Message received while the app is in the foreground. The app decides
  /// the UI (toast / dialog / ignore).
  final NotifyMessageHandler? onForegroundMessage;

  /// Unified tap handler for all sources — see [NotifyTapSource].
  final NotifyTapHandler? onTap;

  /// Called when one of the handlers above throws. Wire it to your crash
  /// reporter (e.g. Crashlytics `recordError`). When null, errors are only
  /// logged via debugPrint. The package never depends on a specific
  /// crash-reporting SDK.
  final NotifyErrorHandler? onError;
}

final class NotifyBackendConfig {
  const NotifyBackendConfig({
    required this.baseUrl,
    required this.apiKey,
  });

  /// notify-hub host, e.g. `https://notify.example.com`. The `/api/v1/devices`
  /// path is fixed by the notify-hub contract and appended by the package.
  final Uri baseUrl;

  /// The notify-hub app API key.
  final String apiKey;

  /// The full device-registration endpoint the package POSTs to.
  Uri get devicesEndpoint => _endpoint('api/v1/devices');

  /// Endpoint for a single device (unregister on logout).
  Uri deviceEndpoint(String token) =>
      _endpoint('api/v1/devices/${Uri.encodeComponent(token)}');

  /// Endpoint for a device's topic subscriptions.
  Uri deviceTopicsEndpoint(String token) =>
      _endpoint('api/v1/devices/${Uri.encodeComponent(token)}/topics');

  /// Endpoint for reporting a campaign notification as opened.
  Uri get openedEventEndpoint => _endpoint('api/v1/events/opened');

  /// Endpoint listing the app's subscribable topics.
  Uri get topicsEndpoint => _endpoint('api/v1/topics');

  /// Appends a fixed path to [baseUrl], tolerating a trailing slash or an
  /// existing base path (unlike [Uri.resolve], which drops a slash-less base).
  Uri _endpoint(String path) {
    final base = baseUrl.path.replaceAll(RegExp(r'/+$'), '');
    return baseUrl.replace(path: '$base/$path');
  }
}

/// Default Android channel primitives — string consts so they stay usable
/// inside const expressions (the background handler's notification details).
/// The id must stay in sync with
/// `com.google.firebase.messaging.default_notification_channel_id` in the
/// host app's AndroidManifest.xml.
const String kDefaultChannelId = 'high_importance_channel';
const String kDefaultChannelName = 'High Importance Notifications';
const String kDefaultChannelDescription =
    'This channel is used for important notifications.';
const String kDefaultNotificationIcon = '@mipmap/ic_launcher';

/// The default Android channel for [NotifyKit.init] callers.
const AndroidChannelConfig kDefaultAndroidChannel = AndroidChannelConfig(
  id: kDefaultChannelId,
  name: kDefaultChannelName,
  description: kDefaultChannelDescription,
  icon: kDefaultNotificationIcon,
);

final class AndroidChannelConfig {
  const AndroidChannelConfig({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
  });

  final String id;
  final String name;

  /// Android drawable name, e.g. 'ic_notification'.
  final String icon;

  final String? description;
}
