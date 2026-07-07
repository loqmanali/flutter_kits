/// Default settings and values for the notification system.
///
/// This class contains default configuration values that determine
/// the initial behavior of notifications when the app is first installed
/// or when settings are reset to defaults.
///
/// ## Usage
/// ```dart
/// // Check if notifications are enabled by default
/// if (NotificationDefaults.enabled) {
///   // Initialize notification system
/// }
///
/// // Get default sound
/// final sound = NotificationDefaults.defaultSound;
/// ```
class NotificationDefaults {
  /// Default state for notifications on app installation.
  ///
  /// When true, notifications are enabled by default for new users.
  static const bool enabled = true;

  /// Default state for notification sounds.
  ///
  /// When true, notifications will play sound by default.
  static const bool soundEnabled = true;

  /// Default state for vibration on notifications.
  ///
  /// When true, device will vibrate when notifications are received.
  static const bool vibrationEnabled = true;

  /// Default state for badge count display.
  ///
  /// When true, notification badges will be shown on app icon.
  static const bool badgeEnabled = true;

  /// Default state for in-app notifications.
  ///
  /// When true, notifications will be displayed as banners within the app.
  static const bool inAppEnabled = true;

  /// Default state for promotional notifications.
  ///
  /// When true, marketing and promotional notifications are enabled.
  static const bool promotionalEnabled = true;

  /// Default state for order update notifications.
  ///
  /// When true, notifications about order status are enabled.
  static const bool orderUpdatesEnabled = true;

  /// Default state for news and update notifications.
  ///
  /// When true, app news and update notifications are enabled.
  static const bool newsEnabled = true;

  /// Default notification sound identifier.
  ///
  /// Uses the system default notification sound.
  static const String defaultSound = 'default';

  /// Default notification icon resource.
  ///
  /// Uses the app launcher icon as the default notification icon.
  static const String defaultIcon = '@mipmap/ic_launcher';

  /// Default notification channel identifier.
  ///
  /// Notifications without a specific channel will use this channel.
  static const String defaultChannelId = 'general';
}
