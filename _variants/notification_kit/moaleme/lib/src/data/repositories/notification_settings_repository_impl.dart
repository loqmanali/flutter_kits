import 'package:dartz/dartz.dart';

import '../../domain/entities/notification_settings.dart';
import '../../domain/failures/notification_failures.dart';
import '../../domain/repositories/notification_settings_repository.dart';
import '../datasources/notification_storage_data_source.dart';
import '../models/notification_settings_model.dart';

class NotificationSettingsRepositoryImpl
    implements NotificationSettingsRepository {
  final NotificationStorageDataSource _dataSource;

  NotificationSettingsRepositoryImpl(this._dataSource);

  @override
  Future<Either<NotificationFailure, NotificationSettings>>
      getSettings() async {
    try {
      final json = await _dataSource.getSettings();
      if (json == null) {
        return const Right(NotificationSettings());
      }
      return Right(NotificationSettingsModel.fromJson(json));
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> saveSettings(
    NotificationSettings settings,
  ) async {
    try {
      final model = NotificationSettingsModel.fromEntity(settings);
      await _dataSource.saveSettings(model.toJson());
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> updateChannelSetting(
    String channelId,
    bool enabled,
  ) async {
    try {
      final settingsResult = await getSettings();

      return settingsResult.fold(
        (failure) => Left(failure),
        (settings) async {
          final newChannels = Map<String, bool>.from(settings.channelSettings);
          newChannels[channelId] = enabled;

          final newSettings = settings.copyWith(channelSettings: newChannels);
          return await saveSettings(newSettings);
        },
      );
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> updateTopicSubscription(
    String topic,
    bool subscribed,
  ) async {
    try {
      final settingsResult = await getSettings();

      return settingsResult.fold(
        (failure) => Left(failure),
        (settings) async {
          final newTopics = Map<String, bool>.from(settings.topicSubscriptions);
          newTopics[topic] = subscribed;

          final newSettings = settings.copyWith(topicSubscriptions: newTopics);
          return await saveSettings(newSettings);
        },
      );
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }
}
