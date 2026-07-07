import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/fcm_data_source.dart';
import '../../data/datasources/local_notification_data_source.dart';
import '../../data/datasources/notification_storage_data_source.dart';
import '../../data/datasources/platform_notification_data_source.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/notification_settings_repository_impl.dart';
import '../../data/repositories/notification_storage_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/notification_settings_repository.dart';
import '../../domain/repositories/notification_storage_repository.dart';
import '../../domain/usecases/process_deep_link_usecase.dart';
import '../../handlers/foreground_handler.dart';
import '../../handlers/notification_handler.dart';
import '../../handlers/notification_tap_handler.dart';
import '../../notification_initializer.dart';
import '../../services/deep_link_notification_service.dart';
import '../../services/notification_service.dart';
import '../../services/toast_notification_service.dart';
import 'notification_notifier.dart';
import 'notification_settings_notifier.dart';
import 'notification_settings_state.dart';
import 'notification_state.dart';

// Data Sources
final fcmDataSourceProvider = Provider<FCMDataSource>((ref) {
  return FCMDataSourceImpl(FirebaseMessaging.instance);
});

final localNotificationDataSourceProvider =
    Provider<LocalNotificationDataSource>((ref) {
  return LocalNotificationDataSourceImpl(
    NotificationInitializer.localNotificationsPlugin,
  );
});

final notificationStorageDataSourceProvider =
    Provider<NotificationStorageDataSource>((ref) {
  return NotificationStorageDataSourceImpl();
});

final platformNotificationDataSourceProvider =
    Provider<PlatformNotificationDataSource>((ref) {
  return PlatformNotificationDataSourceImpl();
});

// Repositories
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    ref.watch(fcmDataSourceProvider),
    ref.watch(localNotificationDataSourceProvider),
    ref.watch(notificationStorageDataSourceProvider),
    ref.watch(platformNotificationDataSourceProvider),
  );
});

final notificationStorageRepositoryProvider =
    Provider<NotificationStorageRepository>((ref) {
  return NotificationStorageRepositoryImpl(
    ref.watch(notificationStorageDataSourceProvider),
  );
});

final notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>((ref) {
  return NotificationSettingsRepositoryImpl(
    ref.watch(notificationStorageDataSourceProvider),
  );
});

// Services
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    ref.watch(notificationRepositoryProvider),
    ref.watch(notificationSettingsRepositoryProvider),
    ref.watch(notificationStorageRepositoryProvider),
  );
});

final toastNotificationServiceProvider =
    Provider<ToastNotificationService>((ref) {
  return ToastNotificationService();
});

final deepLinkNotificationServiceProvider =
    Provider<DeepLinkNotificationService>((ref) {
  return DeepLinkNotificationService(ProcessDeepLinkUseCase());
});

// Handlers
final foregroundHandlerProvider = Provider<ForegroundHandler>((ref) {
  return ForegroundHandler(
    ref.watch(notificationServiceProvider),
    ref.watch(toastNotificationServiceProvider),
    ref,
  );
});

final notificationTapHandlerProvider = Provider<NotificationTapHandler>((ref) {
  return NotificationTapHandler(
    ref.watch(notificationServiceProvider),
    ref.watch(deepLinkNotificationServiceProvider),
  );
});

final notificationHandlerProvider = Provider<NotificationHandler>((ref) {
  return NotificationHandler(
    ref.watch(foregroundHandlerProvider),
    ref.watch(notificationTapHandlerProvider),
    ref.watch(fcmDataSourceProvider),
  );
});

// Notifiers
final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(() {
  return NotificationNotifier();
});

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>(
        () {
  return NotificationSettingsNotifier();
});
