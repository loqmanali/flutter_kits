/// Global configuration settings for the notification module.
///
/// This class contains centralized configuration constants that control
/// the behavior and settings of the notification system throughout
/// the application.
///
/// ## Usage
/// ```dart
/// // Access configuration values
/// final timeout = NotificationConfig.requestTimeout;
/// final maxSize = NotificationConfig.maxHistorySize;
///
/// // Check debug mode
/// if (NotificationConfig.debugMode) {
///   print('Debug mode enabled');
/// }
/// ```
class NotificationConfig {
  /// Module identifier used for logging and debugging.
  ///
  /// Helps identify notification-related logs and errors
  /// in the application's logging system.
  static const String moduleName = 'NotificationModule';

  /// Maximum number of notifications to store in history.
  ///
  /// Limits the size of the notification history to prevent
  /// excessive memory usage. Older notifications are automatically
  /// removed when this limit is exceeded.
  static const int maxHistorySize = 100;

  /// Timeout duration for notification-related network requests.
  ///
  /// Applied to FCM token refresh, API calls, and other
  /// network operations within the notification module.
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Flag to enable/disable debug logging for notifications.
  ///
  /// When true, detailed logs are printed for notification events,
  /// errors, and state changes. Should be false in production builds.
  static const bool debugMode = true;

  /// Resource path for the notification icon.
  ///
  /// Specifies the icon to display in the status bar and
  /// notification shade. Uses Android's mipmap resource format.
  static const String notificationIcon = '@mipmap/ic_launcher';
}
