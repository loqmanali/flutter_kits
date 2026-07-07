import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'config.dart';
import 'mappers.dart';
import 'models.dart';
import 'safe.dart';

/// Internal: all flutter_local_notifications interaction. Not exported.
class LocalService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  AndroidChannelConfig? _channel;

  Future<void> init(
    AndroidChannelConfig channel,
    NotifyTapHandler? onTap, {
    NotifyErrorHandler? onError,
  }) async {
    _channel = channel;

    // iOS permission is requested by firebase_messaging (requestPermission),
    // NEVER here: flutter_local_notifications' permission path interferes
    // with firebase's UNUserNotificationCenter ownership and can silently
    // kill foreground onMessage delivery (see flutter_local_notifications
    // issue #111) — and it double-prompts.
    final settings = InitializationSettings(
      android: AndroidInitializationSettings(channel.icon),
      iOS: const DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (onTap == null) return;
        runSafely(
          'onTap(local)',
          () => onTap(
            messageFromLocalPayload(response.payload),
            NotifyTapSource.local,
          ),
          onError: onError,
        );
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            channel.id,
            channel.name,
            description: channel.description,
            importance: Importance.max,
          ),
        );
  }

  Future<void> show({
    int id = 0,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
  }) async {
    final channel = _channel;
    if (channel == null) {
      throw StateError('notify_kit: LocalService.show called before init');
    }
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: channel.icon,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
        ),
      ),
      payload: payload == null ? null : jsonEncode(payload),
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  Future<void> cancelAll() => _plugin.cancelAll();
}
