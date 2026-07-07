import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../config/notification_channels.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_schedule.dart';
import '../../domain/failures/notification_failures.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../notification_initializer.dart';
import '../../utils/notification_id_generator.dart';
import '../datasources/fcm_data_source.dart';
import '../datasources/local_notification_data_source.dart';
import '../datasources/notification_storage_data_source.dart';
import '../datasources/platform_notification_data_source.dart';
import '../models/fcm_message_model.dart';
import '../models/notification_settings_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FCMDataSource _fcmDataSource;
  final LocalNotificationDataSource _localDataSource;
  final NotificationStorageDataSource _storageDataSource;
  final PlatformNotificationDataSource _platformDataSource;

  final StreamController<NotificationEntity> _notificationReceivedController =
      StreamController.broadcast();
  final StreamController<NotificationEntity> _notificationTappedController =
      StreamController.broadcast();
  final StreamController<String> _actionTappedController =
      StreamController.broadcast();

  NotificationRepositoryImpl(
    this._fcmDataSource,
    this._localDataSource,
    this._storageDataSource,
    this._platformDataSource,
  ) {
    _setupStreams();
  }

  void _setupStreams() {
    _fcmDataSource.onMessage.listen((message) {
      debugPrint(
        '[NotificationRepository] onMessage: id=${message.messageId} '
        'title=${message.notification?.title} body=${message.notification?.body} data=${message.data}',
      );
      final notification = FCMMessageModel.fromRemoteMessage(message);
      debugPrint(
        '[NotificationRepository] Mapped notification: title=${notification.title} body=${notification.body}',
      );
      _notificationReceivedController.add(notification);
    });

    _fcmDataSource.onMessageOpenedApp.listen((message) {
      debugPrint(
        '[NotificationRepository] onMessageOpenedApp: id=${message.messageId}',
      );
      final notification = FCMMessageModel.fromRemoteMessage(message);
      _notificationTappedController.add(notification);
    });
  }

  @override
  Future<Either<NotificationFailure, String?>> getFCMToken() async {
    try {
      final token = await _fcmDataSource.getToken();
      return Right(token);
    } catch (e) {
      return Left(FCMFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> refreshFCMToken() async {
    try {
      await _fcmDataSource.deleteToken();
      await _fcmDataSource.getToken();
      return const Right(null);
    } catch (e) {
      return Left(FCMFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Stream<String> get onTokenRefresh => _fcmDataSource.onTokenRefresh;

  @override
  Future<Either<NotificationFailure, bool>> requestPermission() async {
    try {
      final status = await _platformDataSource.requestPermission();
      return Right(status.isGranted);
    } catch (e) {
      return Left(PermissionFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, bool>> isPermissionGranted() async {
    try {
      final status = await _platformDataSource.getPermissionStatus();
      return Right(status.isGranted);
    } catch (e) {
      return Left(PermissionFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> openSettings() async {
    try {
      await _platformDataSource.openSettings();
      return const Right(null);
    } catch (e) {
      return Left(PermissionFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> showNotification(
    NotificationEntity notification,
  ) async {
    try {
      debugPrint(
        '[NotificationRepository] showNotification: id=${notification.id} title=${notification.title} body=${notification.body}',
      );

      // Check if notifications are globally enabled
      try {
        final settingsJson = await _storageDataSource.getSettings();
        debugPrint('[NotificationRepository] Settings JSON: $settingsJson');
        if (settingsJson != null) {
          final settings = NotificationSettingsModel.fromJson(settingsJson);
          debugPrint(
            '[NotificationRepository] Settings loaded: enabled=${settings.enabled}, soundEnabled=${settings.soundEnabled}, vibrationEnabled=${settings.vibrationEnabled}',
          );
          if (!settings.enabled) {
            debugPrint(
              '[NotificationRepository] Notifications disabled - skipping notification',
            );
            return const Right(null);
          }
        } else {
          debugPrint(
            '[NotificationRepository] No settings found, using defaults',
          );
        }
      } catch (e) {
        debugPrint(
          '[NotificationRepository] Failed to check notification settings: $e',
        );
      }

      // Parse ID safely
      final int notificationId =
          int.tryParse(notification.id) ?? notification.id.hashCode;

      // Determine channel ID and sound based on user settings
      String channelId = 'high_importance_channel'; // Default
      String? sound;
      bool playSound = true; // Default to true
      bool enableVibration = true; // Default to true

      try {
        final settingsJson = await _storageDataSource.getSettings();
        if (settingsJson != null) {
          final settings = NotificationSettingsModel.fromJson(settingsJson);

          // Check sound settings
          playSound = settings.soundEnabled;
          if (settings.customSoundPath != null && settings.soundEnabled) {
            channelId = NotificationChannels.getChannelIdForSound(
              settings.customSoundPath,
            );
            sound = settings.customSoundPath;
          }

          // Check vibration settings
          enableVibration = settings.vibrationEnabled;

          debugPrint(
            '[NotificationRepository] Applied settings: playSound=$playSound, '
            'sound=$sound, enableVibration=$enableVibration, channelId=$channelId',
          );
        }
      } catch (e) {
        debugPrint(
          '[NotificationRepository] Failed to get sound/vibration settings, using default: $e',
        );
      }

      // Use NotificationInitializer directly for advanced features like images
      // This bypasses the basic LocalNotificationDataSource for foreground display
      await NotificationInitializer.showNotification(
        id: notificationId,
        title: notification.title,
        body: notification.body,
        payload: notification.payload != null
            ? jsonEncode(notification.payload)
            : null,
        imageUrl: notification.imageUrl,
        channelId: channelId,
        playSound: playSound,
        sound: playSound ? sound : null,
        enableVibration: enableVibration,
      );

      debugPrint(
        '[NotificationRepository] Local notification displayed successfully',
      );
      return const Right(null);
    } catch (e) {
      debugPrint(
        '[NotificationRepository] Failed to show local notification: $e',
      );
      return Left(
        LocalNotificationFailure(message: e.toString(), originalError: e),
      );
    }
  }

  @override
  Future<Either<NotificationFailure, void>> showGroupedNotification(
    List<NotificationEntity> notifications,
    String groupKey,
  ) async {
    try {
      for (final notification in notifications) {
        await showNotification(notification);
      }
      return const Right(null);
    } catch (e) {
      return Left(
        LocalNotificationFailure(message: e.toString(), originalError: e),
      );
    }
  }

  @override
  Future<Either<NotificationFailure, void>> scheduleNotification(
    NotificationEntity notification,
    NotificationSchedule schedule,
  ) async {
    try {
      int id;
      try {
        id = int.parse(notification.id);
      } catch (_) {
        id = NotificationIdGenerator.generateIntId();
      }

      await _localDataSource.zonedSchedule(
        id,
        notification.title,
        notification.body,
        tz.TZDateTime.from(schedule.scheduledDate, tz.local),
        const NotificationDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: notification.payload?.toString(),
      );
      return const Right(null);
    } catch (e) {
      return Left(SchedulingFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> cancelScheduledNotification(
    int id,
  ) async {
    try {
      await _localDataSource.cancel(id);
      return const Right(null);
    } catch (e) {
      return Left(SchedulingFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, List<NotificationEntity>>>
      getPendingNotifications() async {
    try {
      final requests = await _localDataSource.pendingNotificationRequests();
      final notifications = requests
          .map(
            (r) => NotificationEntity(
              id: r.id.toString(),
              title: r.title ?? '',
              body: r.body ?? '',
              createdAt: DateTime.now(),
            ),
          )
          .toList();
      return Right(notifications);
    } catch (e) {
      return Left(
        LocalNotificationFailure(message: e.toString(), originalError: e),
      );
    }
  }

  @override
  Future<Either<NotificationFailure, void>> subscribeToTopic(
    String topic,
  ) async {
    try {
      await _fcmDataSource.subscribeToTopic(topic);
      final topics = await _storageDataSource.getSubscribedTopics();
      if (!topics.contains(topic)) {
        topics.add(topic);
        await _storageDataSource.saveSubscribedTopics(topics);
      }
      return const Right(null);
    } catch (e) {
      return Left(FCMFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> unsubscribeFromTopic(
    String topic,
  ) async {
    try {
      await _fcmDataSource.unsubscribeFromTopic(topic);
      final topics = await _storageDataSource.getSubscribedTopics();
      if (topics.contains(topic)) {
        topics.remove(topic);
        await _storageDataSource.saveSubscribedTopics(topics);
      }
      return const Right(null);
    } catch (e) {
      return Left(FCMFailure(message: e.toString(), originalError: e));
    }
  }

  Future<Either<NotificationFailure, List<String>>>
      getSubscribedTopics() async {
    try {
      final topics = await _storageDataSource.getSubscribedTopics();
      return Right(topics);
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> setBadgeCount(int count) async {
    try {
      await _storageDataSource.saveBadgeCount(count);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> clearBadge() async {
    return setBadgeCount(0);
  }

  @override
  Future<Either<NotificationFailure, int>> getBadgeCount() async {
    try {
      final count = await _storageDataSource.getBadgeCount();
      return Right(count);
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> cancelNotification(int id) async {
    try {
      await _localDataSource.cancel(id);
      return const Right(null);
    } catch (e) {
      return Left(
        LocalNotificationFailure(message: e.toString(), originalError: e),
      );
    }
  }

  @override
  Future<Either<NotificationFailure, void>> cancelAllNotifications() async {
    try {
      await _localDataSource.cancelAll();
      return const Right(null);
    } catch (e) {
      return Left(
        LocalNotificationFailure(message: e.toString(), originalError: e),
      );
    }
  }

  @override
  Stream<NotificationEntity> get onNotificationReceived =>
      _notificationReceivedController.stream;

  @override
  Stream<NotificationEntity> get onNotificationTapped =>
      _notificationTappedController.stream;

  @override
  Stream<String> get onActionTapped => _actionTappedController.stream;
}
