import 'package:dartz/dartz.dart';

import '../entities/notification_entity.dart';
import '../entities/notification_schedule.dart';
import '../failures/notification_failures.dart';
import '../repositories/notification_repository.dart';

class ScheduleNotificationUseCase {
  final NotificationRepository _repository;

  ScheduleNotificationUseCase(this._repository);

  Future<Either<NotificationFailure, void>> call(NotificationEntity notification, NotificationSchedule schedule) {
    return _repository.scheduleNotification(notification, schedule);
  }
}
