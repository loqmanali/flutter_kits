import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_entity.dart';
import '../../utils/notification_id_generator.dart';
import '../../utils/notification_payload_parser.dart';

/// Model for converting Firebase Cloud Messaging (FCM) messages to notification entities.
///
/// This class provides static methods to transform FCM [RemoteMessage] objects
/// into [NotificationEntity] instances that can be used throughout the notification
/// system. It handles the conversion of FCM-specific fields to domain entities.
///
/// ## Supported Message Formats
///
/// ### Standard FCM Message
/// ```json
/// {
///   "notification": {
///     "title": "Order Update",
///     "body": "Your order has been shipped",
///     "android": {"imageUrl": "https://example.com/image.jpg"}
///   },
///   "data": {
///     "payload": "{\"type\":\"order\",\"targetId\":\"12345\"}"
///   }
/// }
/// ```
///
/// ### Data-Only Message
/// ```json
/// {
///   "data": {
///     "title": "Order Update",
///     "body": "Your order has been shipped",
///     "image": "https://example.com/image.jpg",
///     "type": "order",
///     "targetId": "12345"
///   }
/// }
/// ```
///
/// ## Usage
/// ```dart
/// // Convert FCM message to notification entity
/// final notification = FCMMessageModel.fromRemoteMessage(remoteMessage);
///
/// // Handle the notification
/// await notificationService.handleReceivedNotification(notification);
/// ```
class FCMMessageModel {
  /// Converts an FCM [RemoteMessage] to a [NotificationEntity].
  ///
  /// This method extracts data from both the notification and data fields
  /// of the FCM message and creates a standardized notification entity.
  /// It handles various message formats and provides sensible defaults.
  ///
  /// ## Conversion Logic
  /// 1. **Title**: Uses notification.title, then data['title'], then empty string
  /// 2. **Body**: Uses notification.body, then data['body'], then empty string
  /// 3. **Image**: Uses Android imageUrl, then Apple imageUrl, then data['image']
  /// 4. **Payload**: Parses payload from data field using NotificationPayloadParser
  /// 5. **ID**: Uses messageId, then generates a unique ID
  /// 6. **Timestamp**: Uses sentTime, then current time
  ///
  /// ## Parameters
  /// - [message]: The FCM RemoteMessage to convert
  ///
  /// ## Returns
  /// A [NotificationEntity] populated with data from the FCM message
  ///
  /// ## Example
  /// ```dart
  /// final remoteMessage = RemoteMessage(
  ///   messageId: 'msg_12345',
  ///   notification: RemoteNotification(
  ///     title: 'New Order',
  ///     body: 'Order #12345 received',
  ///   ),
  ///   data: {'type': 'order', 'targetId': '12345'},
  ///   sentTime: DateTime.now(),
  /// );
  ///
  /// final notification = FCMMessageModel.fromRemoteMessage(remoteMessage);
  /// print(notification.title); // 'New Order'
  /// print(notification.payload?.type); // DeepLinkType.order
  /// ```
  static NotificationEntity fromRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    debugPrint('[FCMMessageModel] Raw data: $data');

    // Parse payload from data field
    // The payload parser handles both nested and flat payload formats
    final payload = NotificationPayloadParser.parse(data);

    debugPrint('[FCMMessageModel] Parsed payload: $payload');

    return NotificationEntity(
      // Use FCM message ID if available, otherwise generate a unique ID
      id: message.messageId ?? NotificationIdGenerator.generate(),

      // Title:优先使用notification字段，然后是data字段
      title: notification?.title ?? data['title'] ?? '',

      // Body:优先使用notification字段，然后是data字段
      body: notification?.body ?? data['body'] ?? '',

      // Image URL: Check platform-specific fields first, then data field
      imageUrl: notification?.android?.imageUrl ??
          notification?.apple?.imageUrl ??
          data['image'],

      // Parsed payload for navigation and actions
      payload: payload,

      // Timestamp: Use FCM sent time or current time as fallback
      createdAt: message.sentTime ?? DateTime.now(),

      // Store all original data for debugging and reference
      extraData: data,
    );
  }
}
