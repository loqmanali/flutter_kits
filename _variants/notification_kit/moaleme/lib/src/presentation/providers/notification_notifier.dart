import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/failures/notification_failures.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/notification_storage_repository.dart';
import '../../handlers/notification_handler.dart';
import 'notification_providers.dart';
import 'notification_state.dart';

class NotificationNotifier extends Notifier<NotificationState> {
  late final NotificationRepository _repository;
  late final NotificationStorageRepository _storageRepository;
  late final NotificationHandler _handler;

  @override
  NotificationState build() {
    _repository = ref.watch(notificationRepositoryProvider);
    _storageRepository = ref.watch(notificationStorageRepositoryProvider);
    _handler = ref.watch(notificationHandlerProvider);

    // Listen to repository streams
    _repository.onNotificationReceived.listen((notification) {
      state = state.copyWith(
        lastReceivedNotification: notification,
        recentNotifications: [notification, ...state.recentNotifications],
        unreadCount: state.unreadCount + 1,
      );
      _storageRepository.saveNotification(notification);
      _storageRepository.saveUnreadCount(state.unreadCount);
    });

    _repository.onNotificationTapped.listen((notification) {
      state = state.copyWith(lastTappedNotification: notification);
    });

    return const NotificationState();
  }

  Future<void> initialize() async {
    state = state.copyWith(initStatus: NotificationInitStatus.loading);
    try {
      await _handler.initialize();

      // Load initial data with pagination
      final unreadCount = await _storageRepository.getUnreadCount();
      final historyResult = await _storageRepository.getNotificationHistory(
        limit: state.pageSize,
      );
      final recentNotifications = historyResult.getOrElse(() => []);
      final fcmTokenResult = await _repository.getFCMToken();
      final fcmToken = fcmTokenResult.getOrElse(() => null);
      final permissionGranted = await _repository.isPermissionGranted();
      final permission = permissionGranted.getOrElse(() => false)
          ? PermissionStatus.granted
          : PermissionStatus.denied;

      // Recalculate unread count to fix sync issues
      final recalculatedResult =
          await _storageRepository.recalculateUnreadCount();
      final actualUnreadCount =
          recalculatedResult.getOrElse(() => unreadCount.getOrElse(() => 0));

      // Check if there are more notifications
      final hasMore = recentNotifications.length == state.pageSize;

      state = state.copyWith(
        initStatus: NotificationInitStatus.success,
        unreadCount: actualUnreadCount,
        recentNotifications: recentNotifications,
        fcmToken: fcmToken,
        permissionStatus: permission,
        hasMoreNotifications: hasMore,
        currentOffset: recentNotifications.length,
      );
    } catch (e) {
      state = state.copyWith(initStatus: NotificationInitStatus.failure);
    }
  }

  Future<void> requestPermission() async {
    final result = await _repository.requestPermission();
    result.fold(
      (failure) => state = state.copyWith(error: failure),
      (granted) => state = state.copyWith(
        permissionStatus:
            granted ? PermissionStatus.granted : PermissionStatus.denied,
      ),
    );
  }

  Future<void> markAsRead(String id) async {
    await _storageRepository.markAsRead(id);
    final count = await _storageRepository.getUnreadCount();

    // Update the notification in the state list
    final updatedNotifications = state.recentNotifications.map((notification) {
      if (notification.id == id) {
        return notification.copyWith(
          status: NotificationStatus.read,
          readAt: DateTime.now(),
        );
      }
      return notification;
    }).toList();

    state = state.copyWith(
      unreadCount: count.getOrElse(() => 0),
      recentNotifications: updatedNotifications,
    );
  }

  Future<void> markAllAsRead() async {
    await _storageRepository.markAllAsRead();

    // Update all notifications in the state list
    final updatedNotifications = state.recentNotifications.map((notification) {
      return notification.copyWith(
        status: NotificationStatus.read,
        readAt: DateTime.now(),
      );
    }).toList();

    state = state.copyWith(
      unreadCount: 0,
      recentNotifications: updatedNotifications,
    );
  }

  Future<void> deleteNotification(String id) async {
    await _storageRepository.deleteNotification(id);

    // Remove the notification from the state list
    final updatedNotifications = state.recentNotifications
        .where((notification) => notification.id != id)
        .toList();

    final count = await _storageRepository.getUnreadCount();
    state = state.copyWith(
      recentNotifications: updatedNotifications,
      unreadCount: count.getOrElse(() => 0),
    );
  }

  Future<void> showTestNotification() async {
    final testNotification = NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Test Notification',
      body: 'This is a test notification to verify settings',
      createdAt: DateTime.now(),
    );

    await _repository.showNotification(testNotification);
  }

  Future<void> recalculateUnreadCount() async {
    final result = await _storageRepository.recalculateUnreadCount();
    result.fold(
      (failure) => state = state.copyWith(error: failure),
      (count) => state = state.copyWith(unreadCount: count),
    );
  }

  Future<void> loadMoreNotifications() async {
    if (!state.hasMoreNotifications || state.isLoadingMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final historyResult = await _storageRepository.getNotificationHistory(
        limit: state.pageSize,
        offset: state.currentOffset,
      );

      final newNotifications = historyResult.getOrElse(() => []);
      final allNotifications = [
        ...state.recentNotifications,
        ...newNotifications,
      ];

      // Check if there are more notifications
      final hasMore = newNotifications.length == state.pageSize;

      state = state.copyWith(
        recentNotifications: allNotifications,
        hasMoreNotifications: hasMore,
        currentOffset: allNotifications.length,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: StorageFailure(message: 'Failed to load more notifications: $e'),
      );
    }
  }
}
