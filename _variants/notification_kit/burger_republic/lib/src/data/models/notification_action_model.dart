import '../../domain/entities/notification_action.dart';

/// Data model for notification actions with JSON serialization support.
///
/// This class extends [NotificationAction] to provide JSON serialization
/// and deserialization capabilities. It acts as a bridge between the domain
/// entity and data storage/transport formats.
///
/// ## Usage
/// ```dart
/// // Create from JSON
/// final action = NotificationActionModel.fromJson({
///   'id': 'view_order',
///   'title': 'View Order',
///   'icon': 'shopping_cart',
///   'isDestructive': false,
///   'requiresForeground': true,
/// });
///
/// // Convert to JSON
/// final json = action.toJson();
///
/// // Convert from domain entity
/// final model = NotificationActionModel.fromEntity(domainAction);
/// ```
class NotificationActionModel extends NotificationAction {
  /// Creates a new notification action model.
  ///
  /// ## Parameters
  /// - [id]: Unique identifier for the action
  /// - [title]: Display title for the action button
  /// - [icon]: Optional icon resource identifier
  /// - [isDestructive]: Whether the action is destructive (red on iOS)
  /// - [requiresForeground]: Whether the action requires the app to be in foreground
  const NotificationActionModel({
    required super.id,
    required super.title,
    super.icon,
    super.isDestructive,
    super.requiresForeground,
  });

  /// Creates a [NotificationActionModel] from JSON data.
  ///
  /// Parses a JSON map and creates a notification action model.
  /// Provides default values for optional fields to ensure
  /// robust parsing even with incomplete data.
  ///
  /// ## Parameters
  /// - [json]: JSON map containing action data
  ///
  /// ## Returns
  /// A [NotificationActionModel] populated with data from JSON
  ///
  /// ## JSON Format
  /// ```json
  /// {
  ///   "id": "view_order",
  ///   "title": "View Order",
  ///   "icon": "shopping_cart",
  ///   "isDestructive": false,
  ///   "requiresForeground": true
  /// }
  /// ```
  ///
  /// ## Example
  /// ```dart
  /// final json = {
  ///   'id': 'view_order',
  ///   'title': 'View Order',
  ///   'icon': 'shopping_cart',
  /// };
  ///
  /// final action = NotificationActionModel.fromJson(json);
  /// print(action.title); // 'View Order'
  /// print(action.isDestructive); // false (default)
  /// ```
  factory NotificationActionModel.fromJson(Map<String, dynamic> json) {
    return NotificationActionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String?,
      isDestructive: json['isDestructive'] as bool? ?? false,
      requiresForeground: json['requiresForeground'] as bool? ?? true,
    );
  }

  /// Converts the notification action to JSON format.
  ///
  /// Serializes all action properties to a JSON map that can be
  /// stored in databases, sent over networks, or written to files.
  ///
  /// ## Returns
  /// A JSON map representation of the notification action
  ///
  /// ## Example
  /// ```dart
  /// final action = NotificationActionModel(
  ///   id: 'view_order',
  ///   title: 'View Order',
  ///   icon: 'shopping_cart',
  /// );
  ///
  /// final json = action.toJson();
  /// print(json['id']); // 'view_order'
  /// print(json['title']); // 'View Order'
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'isDestructive': isDestructive,
      'requiresForeground': requiresForeground,
    };
  }

  /// Creates a [NotificationActionModel] from a domain entity.
  ///
  /// Converts a [NotificationAction] domain entity to its corresponding
  /// data model. This is useful when you need to serialize domain entities
  /// or when working with data layers that expect model objects.
  ///
  /// ## Parameters
  /// - [entity]: The domain entity to convert
  ///
  /// ## Returns
  /// A [NotificationActionModel] with the same data as the entity
  ///
  /// ## Example
  /// ```dart
  /// final domainAction = NotificationAction(
  ///   id: 'view_order',
  ///   title: 'View Order',
  ///   isDestructive: false,
  /// );
  ///
  /// final model = NotificationActionModel.fromEntity(domainAction);
  /// final json = model.toJson(); // Now serializable
  /// ```
  factory NotificationActionModel.fromEntity(NotificationAction entity) {
    return NotificationActionModel(
      id: entity.id,
      title: entity.title,
      icon: entity.icon,
      isDestructive: entity.isDestructive,
      requiresForeground: entity.requiresForeground,
    );
  }
}
