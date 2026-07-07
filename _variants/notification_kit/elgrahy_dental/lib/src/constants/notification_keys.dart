/// Storage keys used for persisting notification data.
///
/// This class defines the constant keys used to store and retrieve
/// notification-related data in local storage (SharedPreferences, SecureStorage, etc.).
///
/// ## Usage
/// ```dart
/// // Save FCM token to storage
/// await storage.setString(NotificationKeys.fcmToken, token);
///
/// // Retrieve notification settings
/// final settings = await storage.getString(NotificationKeys.settings);
/// ```
class NotificationKeys {
  /// Storage key for the FCM token.
  ///
  /// Used to store the Firebase Cloud Messaging token for push notifications.
  static const String fcmToken = 'notification_fcm_token';

  /// Storage key for notification settings.
  ///
  /// Used to store user notification preferences and settings as JSON.
  static const String settings = 'notification_settings';

  /// Storage key for notification history.
  ///
  /// Used to store the list of past notifications as JSON array.
  static const String history = 'notification_history';

  /// Storage key for unread notification count.
  ///
  /// Used to store the number of unread notifications.
  static const String unreadCount = 'notification_unread_count';

  /// Storage key for badge count.
  ///
  /// Used to store the current app icon badge count.
  static const String badgeCount = 'notification_badge_count';

  /// Storage key for subscribed topics.
  ///
  /// Used to store the list of FCM topics the user is subscribed to.
  static const String subscribedTopics = 'notification_subscribed_topics';

  /// Storage key for pending scheduled notifications.
  ///
  /// Used to store the list of notifications scheduled for future delivery.
  static const String pendingNotifications = 'notification_pending_list';
}
