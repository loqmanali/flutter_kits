import 'package:dartz/dartz.dart';

import '../failures/notification_failures.dart';
import '../repositories/notification_repository.dart';

class CancelNotificationUseCase {
  final NotificationRepository _repository;

  CancelNotificationUseCase(this._repository);

  Future<Either<NotificationFailure, void>> cancel(int id) {
    return _repository.cancelNotification(id);
  }

  Future<Either<NotificationFailure, void>> cancelAll() {
    return _repository.cancelAllNotifications();
  }

  Future<Either<NotificationFailure, void>> cancelScheduled(int id) {
    return _repository.cancelScheduledNotification(id);
  }
}
