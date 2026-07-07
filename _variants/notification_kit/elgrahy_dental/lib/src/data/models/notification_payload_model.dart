import '../../domain/entities/notification_payload.dart';

/// Data model for notification payloads with JSON serialization support.
///
/// This class extends [NotificationPayload] to provide JSON serialization
/// and deserialization capabilities for notification navigation data.
/// It handles the conversion between domain entities and storage/transmission formats.
///
/// ## Supported Deep Link Types
/// - **product**: Navigate to product detail pages
/// - **category**: Navigate to category listing pages
/// - **order**: Navigate to order detail pages
/// - **promotion**: Navigate to promotional content
/// - **profile**: Navigate to user profile pages
/// - **cart**: Navigate to shopping cart
/// - **checkout**: Navigate to checkout process
/// - **custom**: Custom app-specific navigation
/// - **external**: Navigate to external websites
///
/// ## Usage
/// ```dart
/// // Create from JSON
/// final payload = NotificationPayloadModel.fromJson({
///   'type': 'order',
///   'targetId': '12345',
///   'route': '/order/12345',
///   'parameters': {'source': 'notification'},
/// });
///
/// // Convert to JSON
/// final json = payload.toJson();
///
/// // Convert from domain entity
/// final model = NotificationPayloadModel.fromEntity(domainPayload);
/// ```
class NotificationPayloadModel extends NotificationPayload {
  /// Creates a new notification payload model.
  ///
  /// ## Parameters
  /// - [type]: The deep link type for navigation
  /// - [targetId]: Optional target identifier (product ID, order ID, etc.)
  /// - [route]: Optional navigation route path
  /// - [parameters]: Optional navigation parameters
  /// - [externalUrl]: Optional external URL for external type
  const NotificationPayloadModel({
    required super.type,
    super.targetId,
    super.route,
    super.parameters,
    super.externalUrl,
  });

  /// Creates a [NotificationPayloadModel] from JSON data.
  ///
  /// Parses a JSON map and creates a notification payload model.
  /// Handles enum parsing with fallback to custom type for unknown values.
  ///
  /// ## Parameters
  /// - [json]: JSON map containing payload data
  ///
  /// ## Returns
  /// A [NotificationPayloadModel] populated with data from JSON
  ///
  /// ## JSON Format
  /// ```json
  /// {
  ///   "type": "order",
  ///   "targetId": "12345",
  ///   "route": "/order/12345",
  ///   "parameters": {
  ///     "source": "notification",
  ///     "showDetails": true
  ///   },
  ///   "externalUrl": "https://example.com"
  /// }
  /// ```
  ///
  /// ## Example
  /// ```dart
  /// final json = {
  ///   'type': 'product',
  ///   'targetId': 'prod_123',
  ///   'route': '/product/prod_123',
  /// };
  ///
  /// final payload = NotificationPayloadModel.fromJson(json);
  /// print(payload.type); // DeepLinkType.product
  /// print(payload.targetId); // 'prod_123'
  /// ```
  factory NotificationPayloadModel.fromJson(Map<String, dynamic> json) {
    return NotificationPayloadModel(
      type: DeepLinkType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DeepLinkType.custom,
      ),
      targetId: json['targetId'] as String?,
      route: json['route'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
      externalUrl: json['externalUrl'] as String?,
    );
  }

  /// Converts the notification payload to JSON format.
  ///
  /// Serializes all payload properties to a JSON map that can be
  /// stored, transmitted, or used for navigation logic.
  ///
  /// ## Returns
  /// A JSON map representation of the notification payload
  ///
  /// ## Example
  /// ```dart
  /// final payload = NotificationPayloadModel(
  ///   type: DeepLinkType.order,
  ///   targetId: '12345',
  ///   route: '/order/12345',
  /// );
  ///
  /// final json = payload.toJson();
  /// print(json['type']); // 'order'
  /// print(json['targetId']); // '12345'
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'targetId': targetId,
      'route': route,
      'parameters': parameters,
      'externalUrl': externalUrl,
    };
  }

  /// Creates a [NotificationPayloadModel] from a domain entity.
  ///
  /// Converts a [NotificationPayload] domain entity to its corresponding
  /// data model. This is useful when you need to serialize domain entities
  /// or when working with data layers that expect model objects.
  ///
  /// ## Parameters
  /// - [entity]: The domain entity to convert
  ///
  /// ## Returns
  /// A [NotificationPayloadModel] with the same data as the entity
  ///
  /// ## Example
  /// ```dart
  /// final domainPayload = NotificationPayload(
  ///   type: DeepLinkType.product,
  ///   targetId: 'prod_123',
  ///   route: '/product/prod_123',
  /// );
  ///
  /// final model = NotificationPayloadModel.fromEntity(domainPayload);
  /// final json = model.toJson(); // Now serializable
  /// ```
  factory NotificationPayloadModel.fromEntity(NotificationPayload entity) {
    return NotificationPayloadModel(
      type: entity.type,
      targetId: entity.targetId,
      route: entity.route,
      parameters: entity.parameters,
      externalUrl: entity.externalUrl,
    );
  }
}
