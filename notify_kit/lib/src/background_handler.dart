import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'config.dart';

/// Whether the background-isolate local-notification plugin has been set up.
/// The handler runs in a separate isolate with fresh statics, so it owns its
/// own plugin instance and channel — it cannot reach [NotifyKit]'s state.
bool _isBackgroundLocalNotificationsInitialized = false;

Future<FlutterLocalNotificationsPlugin> _backgroundPlugin() async {
  final plugin = FlutterLocalNotificationsPlugin();
  if (!_isBackgroundLocalNotificationsInitialized) {
    // Never request permissions here — that happened on the main isolate.
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await plugin.initialize(initSettings);

    if (Platform.isAndroid) {
      await plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              kDefaultChannelId,
              kDefaultChannelName,
              description: kDefaultChannelDescription,
              importance: Importance.high,
            ),
          );
    }
    _isBackgroundLocalNotificationsInitialized = true;
  }
  return plugin;
}

/// Extracts a displayable title/body from an FCM `data` block, matching the
/// common backend keys (title/notification_title/message_title, body/
/// notification_body/message_body/message). Null when nothing displayable.
({String title, String body})? extractTitleBody(Map<String, dynamic> data) {
  final title =
      data['title'] ?? data['notification_title'] ?? data['message_title'];
  final body = data['body'] ??
      data['notification_body'] ??
      data['message_body'] ??
      data['message'];
  if (title == null && body == null) return null;
  return (
    title: (title ?? 'New Notification').toString(),
    body: (body ?? 'You have a new notification').toString(),
  );
}

Future<void> _showDataOnlyNotification(RemoteMessage message) async {
  final content = extractTitleBody(message.data);
  if (content == null) return;

  final plugin = await _backgroundPlugin();
  final notificationId =
      (message.messageId ?? DateTime.now().toString()).hashCode;

  await plugin.show(
    notificationId,
    content.title,
    content.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        kDefaultChannelId,
        kDefaultChannelName,
        channelDescription: kDefaultChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: kDefaultNotificationIcon,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    // Carries the FCM data through, so a tap routes via onTap(local) and
    // campaign opens get reported.
    payload: message.data.isEmpty ? null : jsonEncode(message.data),
  );
}

/// Top-level FCM background message handler. Register it before runApp:
///
/// ```dart
/// NotifyKit.registerBackgroundHandler(notifyKitBackgroundHandler);
/// ```
///
/// Messages carrying an FCM `notification` block are displayed by the OS in
/// background/terminated states, so this only displays data-only messages.
@pragma('vm:entry-point')
Future<void> notifyKitBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('notify_kit: background message: ${message.messageId}');

    if (message.notification == null && message.data.isNotEmpty) {
      await _showDataOnlyNotification(message);
    }
  } catch (error) {
    debugPrint('notify_kit: background handler error: $error');
  }
}
