import 'package:dartz/dartz.dart';

import '../domain/entities/notification_entity.dart';
import '../domain/failures/notification_failures.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/repositories/notification_settings_repository.dart';
import '../domain/repositories/notification_storage_repository.dart';

class NotificationService {
  final NotificationRepository _repository;
  final NotificationSettingsRepository settingsRepository;
  final NotificationStorageRepository storageRepository;

  NotificationService(
    this._repository,
    this.settingsRepository,
    this.storageRepository,
  );

  Future<Either<NotificationFailure, void>> initialize() async {
    return const Right(null);
  }

  Stream<NotificationEntity> get onNotificationReceived =>
      _repository.onNotificationReceived;
  Stream<NotificationEntity> get onNotificationTapped =>
      _repository.onNotificationTapped;

  Future<void> showNotification(NotificationEntity notification) async {
    await _repository.showNotification(notification);
  }
}
