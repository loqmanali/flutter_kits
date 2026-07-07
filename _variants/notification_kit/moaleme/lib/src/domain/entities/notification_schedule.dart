import 'package:equatable/equatable.dart';

/// Enumeration of repeat intervals for scheduled notifications.
///
/// Defines how often a scheduled notification should be repeated.
/// This allows for recurring notifications like daily reminders
/// or weekly updates.
enum RepeatInterval {
  /// No repetition - notification shows once.
  ///
  /// The notification will be delivered at the scheduled time
  /// and then dismissed without repeating.
  none,

  /// Daily repetition.
  ///
  /// The notification will repeat every 24 hours at the same time.
  daily,

  /// Weekly repetition.
  ///
  /// The notification will repeat every 7 days on the same day of week.
  weekly,

  /// Monthly repetition.
  ///
  /// The notification will repeat every month on the same date.
  monthly
}

/// Represents scheduling configuration for notifications.
///
/// This entity defines when and how often a notification should be delivered.
/// Scheduled notifications are useful for reminders, recurring updates,
/// and time-sensitive messages.
///
/// ## Usage
/// ```dart
/// final schedule = NotificationSchedule(
///   scheduledDate: DateTime.now().add(Duration(hours: 2)),
///   repeatInterval: RepeatInterval.daily,
///   allowWhileIdle: true,
///   exact: true,
/// );
///
/// // Schedule notification
/// await notificationRepository.scheduleNotification(notification, schedule);
/// ```
class NotificationSchedule extends Equatable {
  /// The date and time when the notification should be delivered.
  ///
  /// This is the initial trigger time for the notification.
  /// For repeating notifications, this serves as the start time.
  final DateTime scheduledDate;

  /// How often the notification should repeat.
  ///
  /// Determines if the notification should repeat and at what interval.
  /// Default is [RepeatInterval.none] for one-time notifications.
  final RepeatInterval repeatInterval;

  /// Whether the notification can be delivered while device is in Doze mode.
  ///
  /// When true, the notification may wake up the device to deliver
  /// even if the device is in a low-power state. Use sparingly
  /// to avoid battery drain.
  final bool allowWhileIdle;

  /// Whether the notification should be delivered at the exact time.
  ///
  /// When true, the system will try to deliver the notification
  /// at the precise scheduled time. When false, the system may
  /// batch notifications for better battery efficiency.
  final bool exact;

  const NotificationSchedule({
    required this.scheduledDate,
    this.repeatInterval = RepeatInterval.none,
    this.allowWhileIdle = false,
    this.exact = true,
  });

  @override
  List<Object?> get props =>
      [scheduledDate, repeatInterval, allowWhileIdle, exact];
}
