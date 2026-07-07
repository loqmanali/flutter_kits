import '../../domain/entities/notification_schedule.dart';

/// Data model for notification scheduling with JSON serialization support.
///
/// This class extends [NotificationSchedule] to provide JSON serialization
/// and deserialization capabilities for notification scheduling configuration.
/// It handles the conversion between domain entities and storage formats.
///
/// ## Supported Repeat Intervals
/// - **none**: One-time notification (default)
/// - **daily**: Repeats every 24 hours
/// - **weekly**: Repeats every 7 days
/// - **monthly**: Repeats every month on the same date
///
/// ## Features
/// - Complete JSON serialization/deserialization
/// - Enum handling with fallback values
/// - DateTime parsing with ISO 8601 format
/// - Entity conversion methods
/// - Scheduling precision control
///
/// ## Usage
/// ```dart
/// // Create from JSON
/// final schedule = NotificationScheduleModel.fromJson(jsonData);
///
/// // Convert to JSON
/// final json = schedule.toJson();
///
/// // Convert from domain entity
/// final model = NotificationScheduleModel.fromEntity(domainSchedule);
/// ```
class NotificationScheduleModel extends NotificationSchedule {
  /// Creates a new notification schedule model.
  ///
  /// ## Parameters
  /// - [scheduledDate]: The exact date and time for notification delivery
  /// - [repeatInterval]: How often the notification should repeat
  /// - [allowWhileIdle]: Whether to deliver during device Doze mode
  /// - [exact]: Whether to deliver at exact time (vs. batched for battery)
  const NotificationScheduleModel({
    required super.scheduledDate,
    super.repeatInterval,
    super.allowWhileIdle,
    super.exact,
  });

  /// Creates a [NotificationScheduleModel] from JSON data.
  ///
  /// Parses a JSON map and creates a notification schedule model.
  /// Handles enum parsing with fallback to none for unknown values.
  ///
  /// ## Parameters
  /// - [json]: JSON map containing schedule data
  ///
  /// ## Returns
  /// A [NotificationScheduleModel] populated with data from JSON
  ///
  /// ## JSON Format
  /// ```json
  /// {
  ///   "scheduledDate": "2023-01-01T12:00:00Z",
  ///   "repeatInterval": "daily",
  ///   "allowWhileIdle": false,
  ///   "exact": true
  /// }
  /// ```
  ///
  /// ## Example
  /// ```dart
  /// final json = {
  ///   'scheduledDate': '2023-01-01T12:00:00Z',
  ///   'repeatInterval': 'daily',
  ///   'allowWhileIdle': true,
  /// };
  ///
  /// final schedule = NotificationScheduleModel.fromJson(json);
  /// print(schedule.repeatInterval); // RepeatInterval.daily
  /// print(schedule.allowWhileIdle); // true
  /// ```
  factory NotificationScheduleModel.fromJson(Map<String, dynamic> json) {
    return NotificationScheduleModel(
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      repeatInterval: RepeatInterval.values.firstWhere(
        (e) => e.name == json['repeatInterval'],
        orElse: () => RepeatInterval.none,
      ),
      allowWhileIdle: json['allowWhileIdle'] as bool? ?? false,
      exact: json['exact'] as bool? ?? true,
    );
  }

  /// Converts the notification schedule to JSON format.
  ///
  /// Serializes all schedule properties to a JSON map that can be
  /// stored, transmitted, or used for scheduling logic.
  ///
  /// ## Returns
  /// A JSON map representation of the notification schedule
  ///
  /// ## Example
  /// ```dart
  /// final schedule = NotificationScheduleModel(
  ///   scheduledDate: DateTime.now().add(Duration(hours: 1)),
  ///   repeatInterval: RepeatInterval.daily,
  ///   exact: true,
  /// );
  ///
  /// final json = schedule.toJson();
  /// print(json['repeatInterval']); // 'daily'
  /// print(json['exact']); // true
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'scheduledDate': scheduledDate.toIso8601String(),
      'repeatInterval': repeatInterval.name,
      'allowWhileIdle': allowWhileIdle,
      'exact': exact,
    };
  }

  /// Creates a [NotificationScheduleModel] from a domain entity.
  ///
  /// Converts a [NotificationSchedule] domain entity to its corresponding
  /// data model. This is useful when you need to serialize domain entities
  /// or when working with data layers that expect model objects.
  ///
  /// ## Parameters
  /// - [entity]: The domain entity to convert
  ///
  /// ## Returns
  /// A [NotificationScheduleModel] with the same data as the entity
  ///
  /// ## Example
  /// ```dart
  /// final domainSchedule = NotificationSchedule(
  ///   scheduledDate: DateTime.now().add(Duration(hours: 1)),
  ///   repeatInterval: RepeatInterval.daily,
  /// );
  ///
  /// final model = NotificationScheduleModel.fromEntity(domainSchedule);
  /// final json = model.toJson(); // Now serializable
  /// ```
  factory NotificationScheduleModel.fromEntity(NotificationSchedule entity) {
    return NotificationScheduleModel(
      scheduledDate: entity.scheduledDate,
      repeatInterval: entity.repeatInterval,
      allowWhileIdle: entity.allowWhileIdle,
      exact: entity.exact,
    );
  }
}
