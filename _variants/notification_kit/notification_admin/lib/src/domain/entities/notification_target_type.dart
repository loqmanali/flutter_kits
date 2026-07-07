/// Enum representing the different target types for sending notifications
enum NotificationTargetType {
  /// Send to all users using the 'all_users' topic
  allUsers,

  /// Send to a specific topic (promotions, news, updates, etc.)
  topic,

  /// Send to a specific device using its FCM token
  singleDevice,

  /// Send to multiple specific devices using their FCM tokens
  multipleDevices,
}

extension NotificationTargetTypeExtension on NotificationTargetType {
  String get displayName {
    switch (this) {
      case NotificationTargetType.allUsers:
        return 'All Users';
      case NotificationTargetType.topic:
        return 'Topic';
      case NotificationTargetType.singleDevice:
        return 'Single Device';
      case NotificationTargetType.multipleDevices:
        return 'Multiple Devices';
    }
  }

  String get description {
    switch (this) {
      case NotificationTargetType.allUsers:
        return 'Send to all app users';
      case NotificationTargetType.topic:
        return 'Send to users subscribed to a specific topic';
      case NotificationTargetType.singleDevice:
        return 'Send to a specific device using FCM token';
      case NotificationTargetType.multipleDevices:
        return 'Send to multiple devices using FCM tokens';
    }
  }
}
