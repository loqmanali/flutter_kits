import 'package:dartz/dartz.dart';

import '../entities/notification_entity.dart';
import '../failures/notification_failures.dart';
import '../repositories/notification_repository.dart';

class ShowNotificationUseCase {
  final NotificationRepository _repository;

  ShowNotificationUseCase(this._repository);

  Future<Either<NotificationFailure, void>> call(NotificationEntity notification) {
    return _repository.showNotification(notification);
  }
}
