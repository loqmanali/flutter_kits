import '../../domain/entities/notification_entity.dart';
import 'notification_action_model.dart';
import 'notification_payload_model.dart';

/// Data model for notifications with JSON serialization support.
///
/// This class extends [NotificationEntity] to provide comprehensive JSON
/// serialization and deserialization capabilities. It serves as the primary
/// data model for storing, transmitting, and persisting notification data.
///
/// ## Features
/// - Complete JSON serialization/deserialization
/// - Nested object support (actions, payload)
/// - Enum handling with fallback values
/// - DateTime parsing with ISO 8601 format
/// - Entity conversion methods
///
/// ## Usage
/// ```dart
/// // Create from JSON
/// final notification = NotificationModel.fromJson(jsonData);
///
/// // Convert to JSON
/// final json = notification.toJson();
///
/// // Convert from domain entity
/// final model = NotificationModel.fromEntity(domainNotification);
/// ```
class NotificationModel extends NotificationEntity {
  /// Creates a new notification model.
  ///
  /// ## Parameters
  /// - [id]: Unique identifier for the notification
  /// - [title]: Main title text
  /// - [body]: Body text content
  /// - [imageUrl]: Optional main image URL
  /// - [largeIconUrl]: Optional large icon URL
  /// - [payload]: Optional navigation/action payload
  /// - [actions]: List of notification actions
  /// - [priority]: Notification priority level
  /// - [status]: Current notification status
  /// - [channelId]: Optional channel identifier
  /// - [groupKey]: Optional group key for grouping
  /// - [tag]: Optional tag for identification
  /// - [createdAt]: Creation timestamp
  /// - [deliveredAt]: Optional delivery timestamp
  /// - [readAt]: Optional read timestamp
  /// - [isLocal]: Whether this is a local notification
  /// - [extraData]: Optional additional data
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    super.imageUrl,
    super.largeIconUrl,
    super.payload,
    super.actions,
    super.priority,
    super.status,
    super.channelId,
    super.groupKey,
    super.tag,
    required super.createdAt,
    super.deliveredAt,
    super.readAt,
    super.isLocal,
    super.extraData,
  });

  /// Creates a [NotificationModel] from JSON data.
  ///
  /// Parses a comprehensive JSON map and creates a notification model
  /// with all nested objects properly reconstructed. Handles missing or
  /// invalid data gracefully with sensible defaults.
  ///
  /// ## Parameters
  /// - [json]: JSON map containing notification data
  ///
  /// ## Returns
  /// A [NotificationModel] populated with data from JSON
  ///
  /// ## JSON Format
  /// ```json
  /// {
  ///   "id": "notification_123",
  ///   "title": "Order Update",
  ///   "body": "Your order has been shipped",
  ///   "imageUrl": "https://example.com/image.jpg",
  ///   "priority": "high",
  ///   "status": "delivered",
  ///   "createdAt": "2023-01-01T12:00:00Z",
  ///   "payload": {
  ///     "type": "order",
  ///     "targetId": "12345"
  ///   },
  ///   "actions": [
  ///     {
  ///       "id": "view",
  ///       "title": "View Order"
  ///     }
  ///   ]
  /// }
  /// ```
  ///
  /// ## Example
  /// ```dart
  /// final json = {
  ///   'id': 'msg_123',
  ///   'title': 'New Message',
  ///   'body': 'You have a new message',
  ///   'priority': 'defaultPriority',
  ///   'createdAt': '2023-01-01T12:00:00Z',
  /// };
  ///
  /// final notification = NotificationModel.fromJson(json);
  /// print(notification.title); // 'New Message'
  /// print(notification.priority); // NotificationPriority.defaultPriority
  /// ```
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] as String?,
      largeIconUrl: json['largeIconUrl'] as String?,
      payload: json['payload'] != null
          ? NotificationPayloadModel.fromJson(
              json['payload'] as Map<String, dynamic>,)
          : null,
      actions: (json['actions'] as List<dynamic>?)
              ?.map((e) =>
                  NotificationActionModel.fromJson(e as Map<String, dynamic>),)
              .toList() ??
          [],
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.defaultPriority,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NotificationStatus.sent,
      ),
      channelId: json['channelId'] as String?,
      groupKey: json['groupKey'] as String?,
      tag: json['tag'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      isLocal: json['isLocal'] as bool? ?? false,
      extraData: json['extraData'] as Map<String, dynamic>?,
    );
  }

  /// Converts the notification to JSON format.
  ///
  /// Serializes all notification properties including nested objects
  /// to a comprehensive JSON map. Uses ISO 8601 format for dates
  /// and enum names for enum values.
  ///
  /// ## Returns
  /// A JSON map representation of the notification
  ///
  /// ## Example
  /// ```dart
  /// final notification = NotificationModel(
  ///   id: 'msg_123',
  ///   title: 'New Message',
  ///   body: 'You have a new message',
  ///   createdAt: DateTime.now(),
  /// );
  ///
  /// final json = notification.toJson();
  /// print(json['title']); // 'New Message'
  /// print(json['priority']); // 'defaultPriority'
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'largeIconUrl': largeIconUrl,
      'payload': payload != null
          ? (payload as NotificationPayloadModel).toJson()
          : null,
      'actions':
          actions.map((e) => (e as NotificationActionModel).toJson()).toList(),
      'priority': priority.name,
      'status': status.name,
      'channelId': channelId,
      'groupKey': groupKey,
      'tag': tag,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isLocal': isLocal,
      'extraData': extraData,
    };
  }

  /// Creates a [NotificationModel] from a domain entity.
  ///
  /// Converts a [NotificationEntity] domain entity to its corresponding
  /// data model. This is essential for serializing domain entities
  /// when working with storage, APIs, or other data transport mechanisms.
  ///
  /// ## Parameters
  /// - [entity]: The domain entity to convert
  ///
  /// ## Returns
  /// A [NotificationModel] with the same data as the entity
  ///
  /// ## Example
  /// ```dart
  /// final domainNotification = NotificationEntity(
  ///   id: 'msg_123',
  ///   title: 'New Message',
  ///   body: 'You have a new message',
  ///   createdAt: DateTime.now(),
  /// );
  ///
  /// final model = NotificationModel.fromEntity(domainNotification);
  /// final json = model.toJson(); // Now serializable
  /// ```
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      imageUrl: entity.imageUrl,
      largeIconUrl: entity.largeIconUrl,
      payload: entity.payload,
      actions: entity.actions,
      priority: entity.priority,
      status: entity.status,
      channelId: entity.channelId,
      groupKey: entity.groupKey,
      tag: entity.tag,
      createdAt: entity.createdAt,
      deliveredAt: entity.deliveredAt,
      readAt: entity.readAt,
      isLocal: entity.isLocal,
      extraData: entity.extraData,
    );
  }
}
