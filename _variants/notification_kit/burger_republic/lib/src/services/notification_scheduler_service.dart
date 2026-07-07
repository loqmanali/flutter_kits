import 'package:dartz/dartz.dart';

import '../domain/entities/notification_entity.dart';
import '../domain/entities/notification_schedule.dart';
import '../domain/failures/notification_failures.dart';
import '../domain/repositories/notification_repository.dart';

class NotificationSchedulerService {
  final NotificationRepository _repository;

  NotificationSchedulerService(this._repository);

  Future<Either<NotificationFailure, void>> schedule(
      NotificationEntity notification, DateTime scheduledDate,) {
    return _repository.scheduleNotification(
      notification,
      NotificationSchedule(scheduledDate: scheduledDate),
    );
  }

  Future<Either<NotificationFailure, void>> scheduleDaily(
      NotificationEntity notification, DateTime time,) {
    return _repository.scheduleNotification(
      notification,
      NotificationSchedule(
        scheduledDate: time,
        repeatInterval: RepeatInterval.daily,
      ),
    );
  }

  Future<Either<NotificationFailure, void>> scheduleWeekly(
      NotificationEntity notification, DateTime time,) {
    return _repository.scheduleNotification(
      notification,
      NotificationSchedule(
        scheduledDate: time,
        repeatInterval: RepeatInterval.weekly,
      ),
    );
  }
}
