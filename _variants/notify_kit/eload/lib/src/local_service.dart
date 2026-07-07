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

    final settings = InitializationSettings(
      android: AndroidInitializationSettings(channel.icon),
      iOS: const DarwinInitializationSettings(),
    );

    await _plugin.initialize(
      settings: settings,
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
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
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

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  Future<void> cancelAll() => _plugin.cancelAll();
}
