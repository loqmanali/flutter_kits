import 'package:dartz/dartz.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/failures/notification_failures.dart';
import '../../domain/repositories/notification_storage_repository.dart';
import '../datasources/notification_storage_data_source.dart';
import '../models/notification_model.dart';

class NotificationStorageRepositoryImpl
    implements NotificationStorageRepository {
  final NotificationStorageDataSource _dataSource;

  NotificationStorageRepositoryImpl(this._dataSource);

  @override
  Future<Either<NotificationFailure, void>> saveNotification(
    NotificationEntity notification,
  ) async {
    try {
      final history = await _dataSource.getHistory();
      // Add new notification to the beginning
      final model = NotificationModel.fromEntity(notification);
      history.insert(0, model.toJson());

      // Limit history size (e.g., 100)
      if (history.length > 100) {
        history.removeRange(100, history.length);
      }

      await _dataSource.saveHistory(history);

      // Increment unread count
      final count = await _dataSource.getUnreadCount();
      await _dataSource.saveUnreadCount(count + 1);

      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, List<NotificationEntity>>>
      getNotificationHistory({int limit = 20, int offset = 0}) async {
    try {
      final history = await _dataSource.getHistory();

      final entities = history
          .map((json) {
            try {
              return NotificationModel.fromJson(json);
            } catch (e) {
              // Skip invalid entries
              return null;
            }
          })
          .whereType<NotificationEntity>()
          .toList();

      // Apply pagination
      if (offset >= entities.length) {
        return const Right([]);
      }

      final end =
          (offset + limit < entities.length) ? offset + limit : entities.length;
      return Right(entities.sublist(offset, end));
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> deleteNotification(
    String id,
  ) async {
    try {
      final history = await _dataSource.getHistory();
      history.removeWhere((item) => item['id'] == id);
      await _dataSource.saveHistory(history);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> clearHistory() async {
    try {
      await _dataSource.clearHistory();
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> markAsRead(String id) async {
    try {
      final history = await _dataSource.getHistory();
      final index = history.indexWhere((item) => item['id'] == id);

      if (index != -1) {
        final item = history[index];
        if (item['status'] != 'read') {
          item['readAt'] = DateTime.now().toIso8601String();
          item['status'] = 'read';
          history[index] = item;
          await _dataSource.saveHistory(history);

          // Update unread count
          final count = await _dataSource.getUnreadCount();
          if (count > 0) {
            await _dataSource.saveUnreadCount(count - 1);
          }
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> markAllAsRead() async {
    try {
      final history = await _dataSource.getHistory();
      bool changed = false;

      for (var i = 0; i < history.length; i++) {
        if (history[i]['status'] != 'read') {
          history[i]['readAt'] = DateTime.now().toIso8601String();
          history[i]['status'] = 'read';
          changed = true;
        }
      }

      if (changed) {
        await _dataSource.saveHistory(history);
        await _dataSource.saveUnreadCount(0);
      }

      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, int>> getUnreadCount() async {
    try {
      final count = await _dataSource.getUnreadCount();
      return Right(count);
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, void>> saveUnreadCount(int count) async {
    try {
      await _dataSource.saveUnreadCount(count);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }

  @override
  Future<Either<NotificationFailure, int>> recalculateUnreadCount() async {
    try {
      final historyResult = await getNotificationHistory();
      return historyResult.fold(
        (failure) => Left(failure),
        (notifications) {
          final unreadCount = notifications
              .where(
                (notification) =>
                    notification.status != NotificationStatus.read &&
                    notification.readAt == null,
              )
              .length;

          // Update the stored count
          _dataSource.saveUnreadCount(unreadCount);

          return Right(unreadCount);
        },
      );
    } catch (e) {
      return Left(StorageFailure(message: e.toString(), originalError: e));
    }
  }
}
