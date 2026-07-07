import 'package:dartz/dartz.dart';

import '../failures/notification_failures.dart';
import '../repositories/notification_repository.dart';

class HandlePermissionUseCase {
  final NotificationRepository _repository;

  HandlePermissionUseCase(this._repository);

  Future<Either<NotificationFailure, bool>> requestPermission() {
    return _repository.requestPermission();
  }

  Future<Either<NotificationFailure, bool>> checkPermission() {
    return _repository.isPermissionGranted();
  }

  Future<Either<NotificationFailure, void>> openSettings() {
    return _repository.openSettings();
  }
}
