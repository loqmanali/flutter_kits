import 'package:equatable/equatable.dart';

import 'notification_action.dart';
import 'notification_payload.dart';

/// Enumeration of notification priority levels.
///
/// Determines how the notification system should prioritize
/// the notification relative to other notifications.
enum NotificationPriority {
  /// High priority - may interrupt and make sound.
  ///
  /// Used for urgent notifications that require immediate attention.
  high,

  /// Default priority - standard notification behavior.
  ///
  /// Used for most regular notifications.
  defaultPriority,

  /// Low priority - no sound or interruption.
  ///
  /// Used for non-urgent informational notifications.
  low,

  /// Minimum priority - no sound, no interruption, no peek.
  ///
  /// Used for background notifications that shouldn't disturb the user.
  min,

  /// Maximum priority - always makes sound, peeks, and can use full-screen intents.
  ///
  /// Used for critical alerts that must be seen immediately.
  max
}

/// Enumeration of notification status states.
///
/// Tracks the lifecycle of a notification from creation to dismissal.
enum NotificationStatus {
  /// Notification has been sent but not yet delivered.
  ///
  /// Initial state when notification is created.
  sent,

  /// Notification has been delivered to the device.
  ///
  /// The notification is visible to the user.
  delivered,

  /// Notification has been read by the user.
  ///
  /// User has interacted with the notification content.
  read,

  /// Notification has been dismissed by the user.
  ///
  /// User has swiped away or dismissed the notification.
  dismissed
}

/// Core entity representing a notification in the system.
///
/// This is the central data model for all notifications, whether they
/// originate from FCM (remote) or are created locally. It contains all
/// the information needed to display, handle, and track notifications.
///
/// ## Usage
/// ```dart
/// final notification = NotificationEntity(
///   id: 'unique_notification_id',
///   title: 'New Order Received',
///   body: 'Your order #12345 has been confirmed',
///   imageUrl: 'https://example.com/image.jpg',
///   payload: NotificationPayload(
///     type: DeepLinkType.order,
///     targetId: '12345',
///     route: '/order/12345',
///   ),
///   actions: [
///     NotificationAction(id: 'view', title: 'View Order'),
///     NotificationAction(id: 'track', title: 'Track Delivery'),
///   ],
///   priority: NotificationPriority.high,
///   createdAt: DateTime.now(),
/// );
///
/// // Show notification
/// await notificationRepository.showNotification(notification);
/// ```
class NotificationEntity extends Equatable {
  /// Unique identifier for the notification.
  ///
  /// Must be unique across all notifications. Used for tracking,
  /// cancellation, and identification purposes.
  final String id;

  /// The main title text displayed in the notification.
  ///
  /// This is the prominent text that appears in bold at the top
  /// of the notification. Should be concise and descriptive.
  final String title;

  /// The body text displayed in the notification.
  ///
  /// This is the secondary text that provides more details about
  /// the notification. Can be longer than the title.
  final String body;

  /// Optional URL for the main notification image.
  ///
  /// When provided, this image will be displayed in the notification
  /// if the platform supports notification images.
  final String? imageUrl;

  /// Optional URL for the large icon image.
  ///
  /// Used for a larger icon that appears on the right side of
  /// the notification on some platforms.
  final String? largeIconUrl;

  /// Optional payload containing navigation and action data.
  ///
  /// Contains deep link information and custom data that determines
  /// what happens when the notification is tapped.
  final NotificationPayload? payload;

  /// List of actions that can be performed on the notification.
  ///
  /// These appear as buttons beneath the notification and allow
  /// users to perform quick actions without opening the app.
  final List<NotificationAction> actions;

  /// Priority level of the notification.
  ///
  /// Determines how the notification system should handle this
  /// notification relative to others.
  final NotificationPriority priority;

  /// Current status of the notification.
  ///
  /// Tracks where the notification is in its lifecycle.
  final NotificationStatus status;

  /// Optional channel identifier for the notification.
  ///
  /// Determines which notification channel this notification
  /// belongs to, affecting its appearance and behavior.
  final String? channelId;

  /// Optional group key for notification grouping.
  ///
  /// Notifications with the same group key can be grouped together
  /// in the notification shade.
  final String? groupKey;

  /// Optional tag for notification identification.
  ///
  /// Used to identify and replace notifications of the same type.
  final String? tag;

  /// Timestamp when the notification was created.
  ///
  /// Used for sorting, history, and analytics purposes.
  final DateTime createdAt;

  /// Optional timestamp when the notification was delivered.
  ///
  /// Set when the notification is successfully delivered to the device.
  final DateTime? deliveredAt;

  /// Optional timestamp when the notification was read.
  ///
  /// Set when the user interacts with the notification content.
  final DateTime? readAt;

  /// Whether this is a locally created notification.
  ///
  /// True for notifications created within the app, false for
  /// notifications received from FCM.
  final bool isLocal;

  /// Optional additional data for the notification.
  ///
  /// Can contain any custom data needed for handling the notification
  /// or for analytics purposes.
  final Map<String, dynamic>? extraData;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.largeIconUrl,
    this.payload,
    this.actions = const [],
    this.priority = NotificationPriority.defaultPriority,
    this.status = NotificationStatus.sent,
    this.channelId,
    this.groupKey,
    this.tag,
    required this.createdAt,
    this.deliveredAt,
    this.readAt,
    this.isLocal = false,
    this.extraData,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        imageUrl,
        largeIconUrl,
        payload,
        actions,
        priority,
        status,
        channelId,
        groupKey,
        tag,
        createdAt,
        deliveredAt,
        readAt,
        isLocal,
        extraData,
      ];

  /// Creates a copy of this notification with updated values.
  ///
  /// Useful for updating notification status or other properties
  /// while maintaining immutability.
  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    String? largeIconUrl,
    NotificationPayload? payload,
    List<NotificationAction>? actions,
    NotificationPriority? priority,
    NotificationStatus? status,
    String? channelId,
    String? groupKey,
    String? tag,
    DateTime? createdAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    bool? isLocal,
    Map<String, dynamic>? extraData,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      largeIconUrl: largeIconUrl ?? this.largeIconUrl,
      payload: payload ?? this.payload,
      actions: actions ?? this.actions,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      channelId: channelId ?? this.channelId,
      groupKey: groupKey ?? this.groupKey,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      isLocal: isLocal ?? this.isLocal,
      extraData: extraData ?? this.extraData,
    );
  }
}
