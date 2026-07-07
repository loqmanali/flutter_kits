import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Configuration for Android notification channels.
///
/// This class defines predefined notification channels that organize
/// notifications by type and importance level. Channels are required
/// for Android 8.0 (API level 26) and above.
///
/// ## Usage
/// ```dart
/// // Create notification channels during app initialization
/// final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
/// await flutterLocalNotificationsPlugin
///     .resolvePlatformSpecificImplementation<
///         AndroidFlutterLocalNotificationsPlugin>()
///     ?.createNotificationChannels(NotificationChannels.channels);
/// ```
class NotificationChannels {
  /// Channel identifier for general notifications.
  ///
  /// Used for app-wide notifications that don't fit into specific categories.
  static const String generalChannelId = 'general';

  /// Channel identifier for order-related notifications.
  ///
  /// Used for order status updates, delivery notifications, and
  /// other order-specific communications.
  static const String ordersChannelId = 'orders';

  /// Channel identifier for promotional notifications.
  ///
  /// Used for marketing messages, special offers, discounts,
  /// and promotional campaigns.
  static const String promotionsChannelId = 'promotions';

  /// Channel identifier for app update notifications.
  ///
  /// Used for version updates, feature announcements, and
  /// application-related news.
  static const String updatesChannelId = 'updates';

  /// Channel identifier for critical alert notifications.
  ///
  /// Used for urgent notifications that require immediate user attention,
  /// such as security alerts or critical system messages.
  static const String alertsChannelId = 'alerts';

  // Sound Channels
  static const String sound1ChannelId = 'high_importance_channel_sound1';
  static const String sound2ChannelId = 'high_importance_channel_sound2';

  /// List of predefined Android notification channels.
  ///
  /// Each channel is configured with appropriate importance levels,
  /// descriptions, and behaviors for different types of notifications.
  ///
  /// ## Channels Included:
  /// - **General**: Default importance for general app notifications
  /// - **Orders**: High importance for order-related updates
  /// - **Promotions**: Default importance for marketing content
  /// - **Updates**: Low importance for app update announcements
  /// - **Alerts**: Maximum importance for critical notifications
  ///
  /// Returns a list of [AndroidNotificationChannel] objects configured
  /// with appropriate settings for each notification type.
  static const List<AndroidNotificationChannel> channels = [
    AndroidNotificationChannel(
      generalChannelId,
      'General Notifications',
      description: 'General notifications about the app',
    ),
    AndroidNotificationChannel(
      ordersChannelId,
      'Order Updates',
      importance: Importance.high,
      description: 'Notifications about your order status',
    ),
    AndroidNotificationChannel(
      promotionsChannelId,
      'Promotions & Offers',
      description: 'Special offers and discounts',
    ),
    AndroidNotificationChannel(
      updatesChannelId,
      'App Updates',
      importance: Importance.low,
      description: 'Updates about the application',
    ),
    AndroidNotificationChannel(
      alertsChannelId,
      'Important Alerts',
      importance: Importance.max,
      description: 'Critical alerts that require attention',
    ),
    // Sound Channels
    AndroidNotificationChannel(
      sound1ChannelId,
      'Notifications (Success Tone)',
      description: 'Important notifications with Success Tone',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification_sound_1'),
    ),
    AndroidNotificationChannel(
      sound2ChannelId,
      'Notifications (Bubble Pop)',
      description: 'Important notifications with Bubble Pop Sound',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification_sound_2'),
    ),
  ];

  static String getChannelIdForSound(String? soundName) {
    if (soundName == null || soundName.isEmpty) {
      return 'high_importance_channel';
    }
    switch (soundName) {
      case 'notification_sound_1':
        return sound1ChannelId;
      case 'notification_sound_2':
        return sound2ChannelId;
      default:
        return 'high_importance_channel';
    }
  }
}
