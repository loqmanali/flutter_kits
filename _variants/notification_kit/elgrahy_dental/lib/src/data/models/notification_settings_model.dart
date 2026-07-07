import '../../domain/entities/notification_settings.dart';

/// Data model for notification settings with JSON serialization support.
///
/// This class extends [NotificationSettings] to provide comprehensive JSON
/// serialization and deserialization capabilities for user notification preferences.
/// It handles the conversion between domain entities and storage formats.
///
/// ## Features
/// - Complete JSON serialization/deserialization
/// - Nested map handling for channel and topic settings
/// - DateTime parsing for quiet hours
/// - Default value handling for missing fields
/// - Entity conversion methods
///
/// ## Usage
/// ```dart
/// // Create from JSON
/// final settings = NotificationSettingsModel.fromJson(jsonData);
///
/// // Convert to JSON
/// final json = settings.toJson();
///
/// // Convert from domain entity
/// final model = NotificationSettingsModel.fromEntity(domainSettings);
/// ```
class NotificationSettingsModel extends NotificationSettings {
  /// Creates a new notification settings model.
  ///
  /// ## Parameters
  /// - [enabled]: Global notifications toggle
  /// - [soundEnabled]: Sound notifications toggle
  /// - [vibrationEnabled]: Vibration notifications toggle
  /// - [badgeEnabled]: Badge count toggle
  /// - [inAppEnabled]: In-app notifications toggle
  /// - [promotionalEnabled]: Promotional notifications toggle
  /// - [orderUpdatesEnabled]: Order updates toggle
  /// - [newsEnabled]: News and updates toggle
  /// - [channelSettings]: Per-channel settings map
  /// - [topicSubscriptions]: Topic subscription preferences
  /// - [customSoundPath]: Custom notification sound file path
  /// - [quietHoursStart]: Quiet hours start time
  /// - [quietHoursEnd]: Quiet hours end time
  const NotificationSettingsModel({
    super.enabled,
    super.soundEnabled,
    super.vibrationEnabled,
    super.badgeEnabled,
    super.inAppEnabled,
    super.promotionalEnabled,
    super.orderUpdatesEnabled,
    super.newsEnabled,
    super.channelSettings,
    super.topicSubscriptions,
    super.customSoundPath,
    super.quietHoursStart,
    super.quietHoursEnd,
  });

  /// Creates a [NotificationSettingsModel] from JSON data.
  ///
  /// Parses a comprehensive JSON map and creates a notification settings model
  /// with all nested objects properly reconstructed. Provides sensible defaults
  /// for all optional fields to ensure robust parsing.
  ///
  /// ## Parameters
  /// - [json]: JSON map containing settings data
  ///
  /// ## Returns
  /// A [NotificationSettingsModel] populated with data from JSON
  ///
  /// ## JSON Format
  /// ```json
  /// {
  ///   "enabled": true,
  ///   "soundEnabled": true,
  ///   "vibrationEnabled": false,
  ///   "badgeEnabled": true,
  ///   "inAppEnabled": true,
  ///   "promotionalEnabled": false,
  ///   "orderUpdatesEnabled": true,
  ///   "newsEnabled": true,
  ///   "channelSettings": {
  ///     "orders": true,
  ///     "promotions": false
  ///   },
  ///   "topicSubscriptions": {
  ///     "news": true,
  ///     "updates": false
  ///   },
  ///   "customSoundPath": "/assets/sounds/notification.mp3",
  ///   "quietHoursStart": "2023-01-01T22:00:00Z",
  ///   "quietHoursEnd": "2023-01-01T08:00:00Z"
  /// }
  /// ```
  ///
  /// ## Example
  /// ```dart
  /// final json = {
  ///   'enabled': true,
  ///   'soundEnabled': false,
  ///   'promotionalEnabled': false,
  /// };
  ///
  /// final settings = NotificationSettingsModel.fromJson(json);
  /// print(settings.enabled); // true
  /// print(settings.soundEnabled); // false
  /// print(settings.promotionalEnabled); // false (default)
  /// ```
  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      enabled: json['enabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      badgeEnabled: json['badgeEnabled'] as bool? ?? true,
      inAppEnabled: json['inAppEnabled'] as bool? ?? true,
      promotionalEnabled: json['promotionalEnabled'] as bool? ?? true,
      orderUpdatesEnabled: json['orderUpdatesEnabled'] as bool? ?? true,
      newsEnabled: json['newsEnabled'] as bool? ?? true,
      channelSettings: (json['channelSettings'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as bool),
          ) ??
          {},
      topicSubscriptions:
          (json['topicSubscriptions'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(k, v as bool),
              ) ??
              {},
      customSoundPath: json['customSoundPath'] as String?,
      quietHoursStart: json['quietHoursStart'] != null
          ? DateTime.parse(json['quietHoursStart'] as String)
          : null,
      quietHoursEnd: json['quietHoursEnd'] != null
          ? DateTime.parse(json['quietHoursEnd'] as String)
          : null,
    );
  }

  /// Converts the notification settings to JSON format.
  ///
  /// Serializes all settings properties including nested maps to a
  /// comprehensive JSON map. Uses ISO 8601 format for dates.
  ///
  /// ## Returns
  /// A JSON map representation of the notification settings
  ///
  /// ## Example
  /// ```dart
  /// final settings = NotificationSettingsModel(
  ///   enabled: true,
  ///   soundEnabled: false,
  ///   promotionalEnabled: false,
  /// );
  ///
  /// final json = settings.toJson();
  /// print(json['enabled']); // true
  /// print(json['soundEnabled']); // false
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'badgeEnabled': badgeEnabled,
      'inAppEnabled': inAppEnabled,
      'promotionalEnabled': promotionalEnabled,
      'orderUpdatesEnabled': orderUpdatesEnabled,
      'newsEnabled': newsEnabled,
      'channelSettings': channelSettings,
      'topicSubscriptions': topicSubscriptions,
      'customSoundPath': customSoundPath,
      'quietHoursStart': quietHoursStart?.toIso8601String(),
      'quietHoursEnd': quietHoursEnd?.toIso8601String(),
    };
  }

  /// Creates a [NotificationSettingsModel] from a domain entity.
  ///
  /// Converts a [NotificationSettings] domain entity to its corresponding
  /// data model. This is essential for serializing domain entities
  /// when working with storage, APIs, or other data transport mechanisms.
  ///
  /// ## Parameters
  /// - [entity]: The domain entity to convert
  ///
  /// ## Returns
  /// A [NotificationSettingsModel] with the same data as the entity
  ///
  /// ## Example
  /// ```dart
  /// final domainSettings = NotificationSettings(
  ///   enabled: true,
  ///   soundEnabled: false,
  ///   promotionalEnabled: false,
  /// );
  ///
  /// final model = NotificationSettingsModel.fromEntity(domainSettings);
  /// final json = model.toJson(); // Now serializable
  /// ```
  factory NotificationSettingsModel.fromEntity(NotificationSettings entity) {
    return NotificationSettingsModel(
      enabled: entity.enabled,
      soundEnabled: entity.soundEnabled,
      vibrationEnabled: entity.vibrationEnabled,
      badgeEnabled: entity.badgeEnabled,
      inAppEnabled: entity.inAppEnabled,
      promotionalEnabled: entity.promotionalEnabled,
      orderUpdatesEnabled: entity.orderUpdatesEnabled,
      newsEnabled: entity.newsEnabled,
      channelSettings: entity.channelSettings,
      topicSubscriptions: entity.topicSubscriptions,
      customSoundPath: entity.customSoundPath,
      quietHoursStart: entity.quietHoursStart,
      quietHoursEnd: entity.quietHoursEnd,
    );
  }
}
