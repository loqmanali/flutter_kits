import 'package:dartz/dartz.dart';
import '../entities/notification_entity.dart';
import '../entities/notification_schedule.dart';
import '../failures/notification_failures.dart';

abstract class NotificationRepository {
  // FCM Operations
  Future<Either<NotificationFailure, String?>> getFCMToken();
  Future<Either<NotificationFailure, void>> refreshFCMToken();
  Stream<String> get onTokenRefresh;
  
  // Permissions
  Future<Either<NotificationFailure, bool>> requestPermission();
  Future<Either<NotificationFailure, bool>> isPermissionGranted();
  Future<Either<NotificationFailure, void>> openSettings();

  // Local Notifications
  Future<Either<NotificationFailure, void>> showNotification(NotificationEntity notification);
  Future<Either<NotificationFailure, void>> showGroupedNotification(List<NotificationEntity> notifications, String groupKey);
  
  // Scheduling
  Future<Either<NotificationFailure, void>> scheduleNotification(NotificationEntity notification, NotificationSchedule schedule);
  Future<Either<NotificationFailure, void>> cancelScheduledNotification(int id);
  Future<Either<NotificationFailure, List<NotificationEntity>>> getPendingNotifications();
  
  // Topics
  Future<Either<NotificationFailure, void>> subscribeToTopic(String topic);
  Future<Either<NotificationFailure, void>> unsubscribeFromTopic(String topic);
  
  // Badge
  Future<Either<NotificationFailure, void>> setBadgeCount(int count);
  Future<Either<NotificationFailure, void>> clearBadge();
  Future<Either<NotificationFailure, int>> getBadgeCount();
  
  // Cancellation
  Future<Either<NotificationFailure, void>> cancelNotification(int id);
  Future<Either<NotificationFailure, void>> cancelAllNotifications();
  
  // Streams
  Stream<NotificationEntity> get onNotificationReceived;
  Stream<NotificationEntity> get onNotificationTapped;
  Stream<String> get onActionTapped;
}
