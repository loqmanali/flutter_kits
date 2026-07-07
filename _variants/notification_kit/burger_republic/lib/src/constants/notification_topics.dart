/// FCM topic constants for targeted notifications.
///
/// This class defines the topic names used for Firebase Cloud Messaging
/// to send targeted notifications to specific user groups.
///
/// ## Usage
/// ```dart
/// // Subscribe to a topic
/// await notificationRepository.subscribeToTopic(NotificationTopics.promotions);
///
/// // Get all available topics
/// final topics = NotificationTopics.allTopics;
/// ```
class NotificationTopics {
  /// Topic for all app users.
  ///
  /// Used for global announcements and app-wide notifications.
  static const String all = 'all_users';

  /// Topic for promotional notifications.
  ///
  /// Used for marketing campaigns, special offers, and discounts.
  static const String promotions = 'promotions';

  /// Topic for news and updates.
  ///
  /// Used for company news, blog posts, and informational content.
  static const String news = 'news';

  /// Topic for app updates.
  ///
  /// Used for version updates, new features, and maintenance notices.
  static const String updates = 'updates';

  /// Topic for Android users only.
  ///
  /// Used for Android-specific notifications and platform updates.
  static const String android = 'android_users';

  /// Topic for iOS users only.
  ///
  /// Used for iOS-specific notifications and platform updates.
  static const String ios = 'ios_users';

  /// List of all available notification topics.
  ///
  /// Returns a complete list of topic identifiers that can be used
  /// for subscription management and targeted messaging.
  static List<String> get allTopics => [
        all,
        promotions,
        news,
        updates,
        android,
        ios,
      ];
}
