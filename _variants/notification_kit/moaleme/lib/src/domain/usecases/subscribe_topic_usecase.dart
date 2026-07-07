import 'package:dartz/dartz.dart';

import '../failures/notification_failures.dart';
import '../repositories/notification_repository.dart';

class SubscribeTopicUseCase {
  final NotificationRepository _repository;

  SubscribeTopicUseCase(this._repository);

  Future<Either<NotificationFailure, void>> subscribe(String topic) {
    return _repository.subscribeToTopic(topic);
  }

  Future<Either<NotificationFailure, void>> unsubscribe(String topic) {
    return _repository.unsubscribeFromTopic(topic);
  }
}
