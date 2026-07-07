import 'package:dartz/dartz.dart';

import '../entities/notification_settings.dart';
import '../failures/notification_failures.dart';
import '../repositories/notification_settings_repository.dart';

class UpdateSettingsUseCase {
  final NotificationSettingsRepository _repository;

  UpdateSettingsUseCase(this._repository);

  Future<Either<NotificationFailure, void>> call(NotificationSettings settings) {
    return _repository.saveSettings(settings);
  }

  Future<Either<NotificationFailure, void>> updateChannel(String channelId, bool enabled) {
    return _repository.updateChannelSetting(channelId, enabled);
  }

  Future<Either<NotificationFailure, void>> updateTopic(String topic, bool subscribed) {
    return _repository.updateTopicSubscription(topic, subscribed);
  }
  
  Future<Either<NotificationFailure, NotificationSettings>> getSettings() {
    return _repository.getSettings();
  }
}
