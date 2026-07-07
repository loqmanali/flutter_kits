import 'package:dartz/dartz.dart';

import '../entities/notification_entity.dart';
import '../failures/notification_failures.dart';
import '../repositories/notification_storage_repository.dart';

class GetNotificationHistoryUseCase {
  final NotificationStorageRepository _repository;

  GetNotificationHistoryUseCase(this._repository);

  Future<Either<NotificationFailure, List<NotificationEntity>>> call(
      {int limit = 20, int offset = 0,}) {
    return _repository.getNotificationHistory(limit: limit, offset: offset);
  }
}
