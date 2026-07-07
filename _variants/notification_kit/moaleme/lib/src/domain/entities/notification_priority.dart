/// Priority levels for FCM notifications (used for sending via FCM Admin API)
///
/// This is different from [NotificationPriority] in notification_entity.dart
/// which is used for local notification display priority.
enum FCMNotificationPriority {
  /// High priority - the notification is sent immediately
  high,

  /// Normal priority - default behavior
  normal,

  /// Low priority - can be delayed to save battery
  low,
}

extension FCMNotificationPriorityExtension on FCMNotificationPriority {
  String get displayName {
    switch (this) {
      case FCMNotificationPriority.high:
        return 'High';
      case FCMNotificationPriority.normal:
        return 'Normal';
      case FCMNotificationPriority.low:
        return 'Low';
    }
  }

  String get androidPriority {
    switch (this) {
      case FCMNotificationPriority.high:
        return '2'; // PRIORITY_HIGH
      case FCMNotificationPriority.normal:
        return '0'; // PRIORITY_DEFAULT
      case FCMNotificationPriority.low:
        return '-2'; // PRIORITY_LOW
    }
  }

  String get applePriority {
    switch (this) {
      case FCMNotificationPriority.high:
        return '10';
      case FCMNotificationPriority.normal:
        return '5';
      case FCMNotificationPriority.low:
        return '1';
    }
  }
}
