import 'dart:convert';

import '../adapters/notification_kit_runtime.dart';
import '../data/models/notification_payload_model.dart';
import '../domain/entities/notification_payload.dart';

/// Utility class for parsing notification payload data from various formats.
///
/// This parser handles different payload structures that can come from
/// FCM messages, local notifications, or other sources. It supports
/// both nested payload structures and flat payload formats.
///
/// ## Usage
/// ```dart
/// // Parse FCM message data
/// final payload = NotificationPayloadParser.parse(fcmMessage.data);
///
/// if (payload != null) {
///   // Handle navigation based on payload type
///   switch (payload.type) {
///     case DeepLinkType.order:
///       navigateToOrder(payload.targetId);
///       break;
///     // ... other cases
///   }
/// }
/// ```
class NotificationPayloadParser {
  /// Parses notification payload data from a map.
  ///
  /// This method handles multiple payload formats:
  /// - Nested payload: `{'payload': '{"type":"order","targetId":"123"}'}`
  /// - Flat payload: `{'type':'order','targetId':'123','route':'/order/123'}`
  ///
  /// ## Parameters
  /// - [data]: The raw data map from FCM or notification source
  ///
  /// ## Returns
  /// - [NotificationPayload] if parsing succeeds
  /// - [null] if data is empty, invalid, or parsing fails
  ///
  /// ## Supported Formats
  ///
  /// ### Nested Format (FCM recommended)
  /// ```json
  /// {
  ///   "title": "Order Update",
  ///   "body": "Your order has been shipped",
  ///   "payload": "{\"type\":\"order\",\"targetId\":\"12345\",\"route\":\"/order/12345\"}"
  /// }
  /// ```
  ///
  /// ### Flat Format
  /// ```json
  /// {
  ///   "title": "Order Update",
  ///   "body": "Your order has been shipped",
  ///   "type": "order",
  ///   "targetId": "12345",
  ///   "route": "/order/12345",
  ///   "parameters": {"source": "notification"}
  /// }
  /// ```
  static NotificationPayload? parse(Map<String, dynamic> data) {
    try {
      // Return null for empty data
      if (data.isEmpty) return null;

      NotificationKitRuntime.logger.debug('[NotificationPayloadParser] Parsing data: $data');

      // Check if payload is nested in 'payload' key as string
      // This is the recommended format for FCM messages
      if (data.containsKey('payload') && data['payload'] is String) {
        final nestedPayload = jsonDecode(data['payload']);
        if (nestedPayload is Map<String, dynamic>) {
          NotificationKitRuntime.logger.debug(
            '[NotificationPayloadParser] Found nested payload: $nestedPayload',
          );
          return NotificationPayloadModel.fromJson(nestedPayload);
        }
      }

      // Check if payload keys are at root level (flat format)
      // This format is used for local notifications or simple FCM messages
      if (data.containsKey('type')) {
        NotificationKitRuntime.logger.debug(
          '[NotificationPayloadParser] Found flat payload with type',
        );
        return NotificationPayloadModel.fromJson(data);
      }

      // Handle simple key-value data (like {home: Loqman})
      // If no type field but has other data, create a generic payload
      if (data.isNotEmpty) {
        NotificationKitRuntime.logger.debug(
          '[NotificationPayloadParser] Creating generic payload from simple data',
        );
        // Try to extract a meaningful type from the data
        final firstKey = data.keys.first;
        final firstValue = data[firstKey];

        return NotificationPayloadModel(
          type: _inferTypeFromData(firstKey, firstValue),
          targetId: firstValue?.toString(),
          route: '/$firstKey',
          parameters: data,
        );
      }

      // No valid payload structure found
      NotificationKitRuntime.logger.debug(
        '[NotificationPayloadParser] No valid payload structure found',
      );
      return null;
    } catch (e, stackTrace) {
      NotificationKitRuntime.logger.error(
        '[NotificationPayloadParser] Error parsing notification payload',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Infer payload type from simple key-value data
  static DeepLinkType _inferTypeFromData(String key, dynamic value) {
    // Common mappings for simple data
    switch (key.toLowerCase()) {
      case 'home':
        return DeepLinkType.custom;
      case 'order':
      case 'orderid':
        return DeepLinkType.order;
      case 'product':
      case 'productid':
        return DeepLinkType.product;
      case 'category':
        return DeepLinkType.category;
      case 'promotion':
      case 'offer':
        return DeepLinkType.promotion;
      case 'user':
      case 'userid':
      case 'profile':
        return DeepLinkType.profile;
      case 'cart':
        return DeepLinkType.cart;
      case 'checkout':
        return DeepLinkType.checkout;
      default:
        return DeepLinkType.custom;
    }
  }
}
