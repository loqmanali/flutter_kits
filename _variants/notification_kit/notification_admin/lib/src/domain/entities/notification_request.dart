import 'notification_priority.dart';
import 'notification_target_type.dart';

/// Entity representing a notification request to be sent via FCM
class NotificationRequest {
  /// The title of the notification
  final String title;

  /// The body/message of the notification
  final String body;

  /// Optional image URL to display with the notification
  final String? imageUrl;

  /// Target type for sending the notification
  final NotificationTargetType targetType;

  /// Topic name (required when targetType is NotificationTargetType.topic)
  final String? topic;

  /// FCM token (required when targetType is NotificationTargetType.singleDevice)
  final String? deviceToken;

  /// List of FCM tokens (required when targetType is NotificationTargetType.multipleDevices)
  final List<String>? deviceTokens;

  /// Optional custom data payload
  final Map<String, String>? data;

  /// Notification priority
  final FCMNotificationPriority priority;

  /// Optional channel ID for Android
  final String? channelId;

  /// Optional notification tag (groups notifications)
  final String? tag;

  /// Optional click action
  final String? clickAction;

  NotificationRequest({
    required this.title,
    required this.body,
    this.imageUrl,
    required this.targetType,
    this.topic,
    this.deviceToken,
    this.deviceTokens,
    this.data,
    this.priority = FCMNotificationPriority.normal,
    this.channelId,
    this.tag,
    this.clickAction,
  });

  /// Validates the request and returns an error message if invalid
  String? validate() {
    if (title.trim().isEmpty) {
      return 'Title is required';
    }
    if (body.trim().isEmpty) {
      return 'Body is required';
    }
    if (title.length > 100) {
      return 'Title must be less than 100 characters';
    }
    if (body.length > 500) {
      return 'Body must be less than 500 characters';
    }

    switch (targetType) {
      case NotificationTargetType.topic:
        if (topic == null || topic!.trim().isEmpty) {
          return 'Topic is required when targeting a topic';
        }
        break;
      case NotificationTargetType.singleDevice:
        if (deviceToken == null || deviceToken!.trim().isEmpty) {
          return 'Device token is required when targeting a single device';
        }
        break;
      case NotificationTargetType.multipleDevices:
        if (deviceTokens == null || deviceTokens!.isEmpty) {
          return 'At least one device token is required when targeting multiple devices';
        }
        break;
      case NotificationTargetType.allUsers:
        break;
    }

    return null;
  }

  /// Converts the request to a JSON map for FCM API
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    // Build the notification object
    final notification = <String, dynamic>{
      'title': title,
      'body': body,
    };

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      notification['image'] = imageUrl;
    }

    map['notification'] = notification;

    // Set the target based on targetType
    switch (targetType) {
      case NotificationTargetType.allUsers:
        map['topic'] = 'all_users';
        break;
      case NotificationTargetType.topic:
        map['topic'] = topic;
        break;
      case NotificationTargetType.singleDevice:
        map['token'] = deviceToken;
        break;
      case NotificationTargetType.multipleDevices:
        map['registration_ids'] = deviceTokens;
        break;
    }

    // Add Android config
    map['android'] = {
      'priority': priority.androidPriority,
      if (channelId != null) 'notification': {'channel_id': channelId},
      if (tag != null) 'notification': {'tag': tag},
    };

    // Add Apple config
    map['apns'] = {
      'payload': {
        'aps': {
          'priority': priority.applePriority,
        },
      },
    };

    // Add custom data
    if (data != null && data!.isNotEmpty) {
      map['data'] = data;
    }

    if (clickAction != null) {
      map['android']['click_action'] = clickAction;
    }

    return map;
  }

  NotificationRequest copyWith({
    String? title,
    String? body,
    String? imageUrl,
    NotificationTargetType? targetType,
    String? topic,
    String? deviceToken,
    List<String>? deviceTokens,
    Map<String, String>? data,
    FCMNotificationPriority? priority,
    String? channelId,
    String? tag,
    String? clickAction,
  }) {
    return NotificationRequest(
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      targetType: targetType ?? this.targetType,
      topic: topic ?? this.topic,
      deviceToken: deviceToken ?? this.deviceToken,
      deviceTokens: deviceTokens ?? this.deviceTokens,
      data: data ?? this.data,
      priority: priority ?? this.priority,
      channelId: channelId ?? this.channelId,
      tag: tag ?? this.tag,
      clickAction: clickAction ?? this.clickAction,
    );
  }
}
