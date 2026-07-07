import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/failures/notification_failures.dart';

enum NotificationInitStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  final NotificationInitStatus initStatus;
  final String? fcmToken;
  final PermissionStatus permissionStatus;
  final List<NotificationEntity> recentNotifications;
  final int unreadCount;
  final int badgeCount;
  final bool isProcessingNotification;
  final NotificationEntity? lastReceivedNotification;
  final NotificationEntity? lastTappedNotification;
  final NotificationFailure? error;
  final List<String> subscribedTopics;

  // Pagination fields
  final bool hasMoreNotifications;
  final bool isLoadingMore;
  final int currentOffset;
  final int pageSize;

  const NotificationState({
    this.initStatus = NotificationInitStatus.initial,
    this.fcmToken,
    this.permissionStatus = PermissionStatus.denied,
    this.recentNotifications = const [],
    this.unreadCount = 0,
    this.badgeCount = 0,
    this.isProcessingNotification = false,
    this.lastReceivedNotification,
    this.lastTappedNotification,
    this.error,
    this.subscribedTopics = const [],
    this.hasMoreNotifications = true,
    this.isLoadingMore = false,
    this.currentOffset = 0,
    this.pageSize = 20,
  });

  NotificationState copyWith({
    NotificationInitStatus? initStatus,
    String? fcmToken,
    PermissionStatus? permissionStatus,
    List<NotificationEntity>? recentNotifications,
    int? unreadCount,
    int? badgeCount,
    bool? isProcessingNotification,
    NotificationEntity? lastReceivedNotification,
    NotificationEntity? lastTappedNotification,
    NotificationFailure? error,
    List<String>? subscribedTopics,
    bool? hasMoreNotifications,
    bool? isLoadingMore,
    int? currentOffset,
    int? pageSize,
  }) {
    return NotificationState(
      initStatus: initStatus ?? this.initStatus,
      fcmToken: fcmToken ?? this.fcmToken,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      recentNotifications: recentNotifications ?? this.recentNotifications,
      unreadCount: unreadCount ?? this.unreadCount,
      badgeCount: badgeCount ?? this.badgeCount,
      isProcessingNotification:
          isProcessingNotification ?? this.isProcessingNotification,
      lastReceivedNotification:
          lastReceivedNotification ?? this.lastReceivedNotification,
      lastTappedNotification:
          lastTappedNotification ?? this.lastTappedNotification,
      error: error ?? this.error,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
      hasMoreNotifications: hasMoreNotifications ?? this.hasMoreNotifications,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentOffset: currentOffset ?? this.currentOffset,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        initStatus,
        fcmToken,
        permissionStatus,
        recentNotifications,
        unreadCount,
        badgeCount,
        isProcessingNotification,
        lastReceivedNotification,
        lastTappedNotification,
        error,
        subscribedTopics,
        hasMoreNotifications,
        isLoadingMore,
        currentOffset,
        pageSize,
      ];
}
