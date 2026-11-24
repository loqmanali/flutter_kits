import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'config.dart';
import 'mappers.dart';
import 'models.dart';
import 'safe.dart';
import 'schedule.dart';

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

    // Timezone DB — required for zonedSchedule (scheduleDaily). Safe to call
    // more than once; the guarded NotifyKit.init only runs this path once.
    tzdata.initializeTimeZones();

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
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(),
      payload: payload == null ? null : jsonEncode(payload),
    );
  }

  /// Schedule a notification that repeats every day at (hour, minute). Taps
  /// flow through the same [NotifyTapSource.local] path as [show].
  Future<void> scheduleDaily({
    required int id,
    String? title,
    String? body,
    required int hour,
    required int minute,
    Map<String, dynamic>? payload,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: nextInstanceOfTime(hour, minute),
      notificationDetails: _details(),
      payload: payload == null ? null : jsonEncode(payload),
      // Inexact avoids the SCHEDULE_EXACT_ALARM permission prompt; a daily
      // reminder does not need to-the-second precision.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule a one-shot notification at an absolute [when]. Taps flow through
  /// the same [NotifyTapSource.local] path as [show].
  Future<void> scheduleAt({
    required int id,
    String? title,
    String? body,
    required DateTime when,
    Map<String, dynamic>? payload,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: _details(),
      payload: payload == null ? null : jsonEncode(payload),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// The [NotificationDetails] for this app's single channel — shared by
  /// [show], [scheduleDaily] and [scheduleAt] so all look identical.
  NotificationDetails _details() {
    final channel = _channel;
    if (channel == null) {
      throw StateError('notify_kit: LocalService called before init');
    }
    return NotificationDetails(
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
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  Future<void> cancelAll() => _plugin.cancelAll();
}
