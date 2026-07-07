import 'package:equatable/equatable.dart';

/// Enumeration of supported deep link types for notifications.
///
/// Defines the different types of navigation targets that can be
/// triggered when a notification is tapped. Each type corresponds
/// to a specific app screen or external destination.
enum DeepLinkType {
  /// Deep link to a product detail page.
  ///
  /// Used for notifications about specific products.
  product,

  /// Deep link to a category listing page.
  ///
  /// Used for notifications about product categories.
  category,

  /// Deep link to an order detail page.
  ///
  /// Used for notifications about order status and updates.
  order,

  /// Deep link to a promotion or offer page.
  ///
  /// Used for notifications about special offers and discounts.
  promotion,

  /// Deep link to user profile page.
  ///
  /// Used for notifications about account-related information.
  profile,

  /// Deep link to shopping cart page.
  ///
  /// Used for notifications about cart updates or abandoned carts.
  cart,

  /// Deep link to checkout page.
  ///
  /// Used for notifications about checkout process or payment.
  checkout,

  /// Custom deep link type.
  ///
  /// Used for app-specific deep links not covered by other types.
  custom,

  /// External URL deep link.
  ///
  /// Used for notifications that navigate to external websites.
  external
}

/// Represents the payload data carried by a notification.
///
/// The payload contains navigation information that determines where
/// the user is taken when they tap on a notification. This enables
/// deep linking from notifications to specific app screens.
///
/// ## Usage
/// ```dart
/// final payload = NotificationPayload(
///   type: DeepLinkType.product,
///   targetId: '12345',
///   route: '/product/12345',
///   parameters: {'source': 'notification'},
/// );
///
/// // Add to notification
/// final notification = NotificationEntity(
///   // ... other properties
///   payload: payload,
/// );
/// ```
class NotificationPayload extends Equatable {
  /// The type of deep link navigation.
  ///
  /// Determines how the notification tap should be handled
  /// and which screen or destination to navigate to.
  final DeepLinkType type;

  /// Optional target identifier for the deep link.
  ///
  /// Used to identify specific entities like product IDs,
  /// order numbers, or category IDs.
  final String? targetId;

  /// Optional route path for navigation.
  ///
  /// Specifies the exact route to navigate to within the app.
  /// Can be used with Flutter Navigator or routing packages.
  final String? route;

  /// Optional parameters for the navigation.
  ///
  /// Additional data that can be passed to the destination screen
  /// such as filters, source information, or context.
  final Map<String, dynamic>? parameters;

  /// Optional external URL for navigation.
  ///
  /// Used when the notification should navigate to an external
  /// website instead of within the app. Only used with DeepLinkType.external.
  final String? externalUrl;

  const NotificationPayload({
    required this.type,
    this.targetId,
    this.route,
    this.parameters,
    this.externalUrl,
  });

  @override
  List<Object?> get props => [type, targetId, route, parameters, externalUrl];
}
