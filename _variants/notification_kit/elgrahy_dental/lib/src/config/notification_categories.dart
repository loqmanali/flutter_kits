import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Configuration for notification categories used in iOS notifications.
///
/// This class defines predefined notification categories with specific actions
/// that can be performed when a notification is received. Categories help
/// organize notifications and provide consistent user interactions.
///
/// ## Usage
/// ```dart
/// // Register categories during notification initialization
/// final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
/// await flutterLocalNotificationsPlugin.initialize(
///   InitializationSettings(iOS: DarwinInitializationSettings(
///     notificationCategories: NotificationCategories.categories,
///   ),
/// );
/// ```
class NotificationCategories {
  /// Category identifier for order-related notifications.
  ///
  /// Used for notifications about order status, delivery updates,
  /// and other order-specific information.
  static const String orderCategory = 'ORDER_CATEGORY';

  /// Category identifier for promotional notifications.
  ///
  /// Used for marketing messages, special offers, discounts,
  /// and promotional content.
  static const String promotionCategory = 'PROMOTION_CATEGORY';

  /// List of Darwin notification categories for iOS.
  ///
  /// Each category defines the available actions when a notification
  /// is displayed to the user. Actions appear as buttons beneath
  /// the notification banner.
  ///
  /// ## Categories Included:
  /// - **Order Category**: View Order, Track Order actions
  /// - **Promotion Category**: View Offer, Dismiss actions
  ///
  /// Returns a list of [DarwinNotificationCategory] objects configured
  /// with appropriate actions and options.
  static List<DarwinNotificationCategory> get categories => [
        DarwinNotificationCategory(
          orderCategory,
          actions: [
            /// Action to view detailed order information
            DarwinNotificationAction.plain('VIEW_ORDER', 'View Order'),

            /// Action to track order delivery status
            DarwinNotificationAction.plain('TRACK_ORDER', 'Track'),
          ],
          options: {
            /// Show title when notification is expanded but hide preview
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        ),
        DarwinNotificationCategory(
          promotionCategory,
          actions: [
            /// Action to view promotional offer details
            DarwinNotificationAction.plain('VIEW_PROMO', 'View Offer'),

            /// Action to dismiss promotional notification
            DarwinNotificationAction.plain(
              'DISMISS',
              'Dismiss',
              options: {
                /// Marks action as destructive (red color on iOS)
                DarwinNotificationActionOption.destructive,
              },
            ),
          ],
        ),
      ];
}
