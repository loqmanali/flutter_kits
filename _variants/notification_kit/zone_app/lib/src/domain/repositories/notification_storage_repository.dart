import 'package:dartz/dartz.dart';

import '../entities/notification_entity.dart';
import '../failures/notification_failures.dart';

/// Repository interface for notification storage and history management.
///
/// This abstract class defines the contract for persisting and retrieving
/// notification data, including history tracking, read status management,
/// and unread count maintenance. It provides a clean abstraction over
/// the underlying storage mechanism.
///
/// ## Implementation Notes
/// - All methods should handle errors gracefully and return Either types
/// - History should be limited to prevent excessive storage usage
/// - Operations should be atomic where possible
/// - Consider thread safety for concurrent access
/// - Implement proper pagination for history retrieval
///
/// ## Usage
/// ```dart
/// class NotificationHistoryService {
///   final NotificationStorageRepository _repository;
///
///   NotificationHistoryService(this._repository);
///
///   Future<List<NotificationEntity>> getHistory() async {
///     final result = await _repository.getNotificationHistory();
///     return result.fold(
///       (failure) => [],
///       (notifications) => notifications,
///     );
///   }
/// }
/// ```
abstract class NotificationStorageRepository {
  /// Saves a notification to persistent storage.
  ///
  /// Persists a notification entity for history tracking and future reference.
  /// This operation should add the notification to the history without
  /// affecting existing notifications.
  ///
  /// ## Parameters
  /// - [notification]: The notification entity to save
  ///
  /// ## Returns
  /// - [Right] with void if successful
  /// - [Left] with [NotificationFailure] if an error occurs
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.saveNotification(notification);
  /// result.fold(
  ///   (failure) => showError('Failed to save notification: ${failure.message}'),
  ///   (_) => updateUI(),
  /// );
  /// ```
  Future<Either<NotificationFailure, void>> saveNotification(
    NotificationEntity notification,
  );

  /// Retrieves notification history with pagination support.
  ///
  /// Loads a paginated list of stored notifications ordered by creation time.
  /// The results should be sorted with the most recent notifications first.
  ///
  /// ## Parameters
  /// - [limit]: Maximum number of notifications to return (default: 20)
  /// - [offset]: Number of notifications to skip for pagination (default: 0)
  ///
  /// ## Returns
  /// - [Right] with list of [NotificationEntity] if successful
  /// - [Left] with [NotificationFailure] if an error occurs
  ///
  /// ## Example
  /// ```dart
  /// // Get first page
  /// final result = await repository.getNotificationHistory(limit: 20, offset: 0);
  ///
  /// // Get second page
  /// final result2 = await repository.getNotificationHistory(limit: 20, offset: 20);
  ///
  /// result.fold(
  ///   (failure) => showError('Failed to load history: ${failure.message}'),
  ///   (notifications) => displayHistory(notifications),
  /// );
  /// ```
  Future<Either<NotificationFailure, List<NotificationEntity>>>
      getNotificationHistory({int limit = 20, int offset = 0});

  /// Deletes a specific notification from storage.
  ///
  /// Removes a notification from the history using its unique identifier.
  /// This operation should not affect other notifications in the history.
  ///
  /// ## Parameters
  /// - [id]: The unique identifier of the notification to delete
  ///
  /// ## Returns
  /// - [Right] with void if successful
  /// - [Left] with [NotificationFailure] if an error occurs
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.deleteNotification('notification_123');
  /// result.fold(
  ///   (failure) => showError('Failed to delete: ${failure.message}'),
  ///   (_) => showSuccess('Notification deleted'),
  /// );
  /// ```
  Future<Either<NotificationFailure, void>> deleteNotification(String id);

  /// Clears all notification history.
  ///
  /// Removes all stored notifications from the history. This operation
  /// is typically used when clearing user data or resetting the notification
  /// system. Use with caution as this action cannot be undone.
  ///
  /// ## Returns
  /// - [Right] with void if successful
  /// - [Left] with [NotificationFailure] if an error occurs
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.clearHistory();
  /// result.fold(
  ///   (failure) => showError('Failed to clear history: ${failure.message}'),
  ///   (_) => showSuccess('History cleared'),
  /// );
  /// ```
  Future<Either<NotificationFailure, void>> clearHistory();

  /// Marks a specific notification as read.
  ///
  /// Updates the read status and read timestamp for a specific notification.
  /// This operation should only affect the specified notification.
  ///
  /// ## Parameters
  /// - [id]: The unique identifier of the notification to mark as read
  ///
  /// ## Returns
  /// - [Right] with void if successful
  /// - [Left] with [NotificationFailure] if an error occurs
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.markAsRead('notification_123');
  /// result.fold(
  ///   (failure) => showError('Failed to mark as read: ${failure.message}'),
  ///   (_) => updateBadgeCount(),
  /// );
  /// ```
  Future<Either<NotificationFailure, void>> markAsRead(String id);

  /// Marks all notifications as read.
  ///
  /// Updates the read status and read timestamp for all stored notifications.
  /// This operation should efficiently update all notifications without
  /// requiring individual updates for each one.
  ///
  /// ## Returns
  /// - [Right] with void if successful
  /// - [Left] with [NotificationFailure] if an error occurs
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.markAllAsRead();
  /// result.fold(
  ///   (failure) => showError('Failed to mark all as read: ${failure.message}'),
  ///   (_) => clearBadge(),
  /// );
  /// ```
  Future<Either<NotificationFailure, void>> markAllAsRead();

  /// Retrieves the current unread notification count.
  ///
  /// Calculates and returns the number of notifications that have not been
  /// marked as read. This count is typically used for badge indicators
  /// and UI display purposes.
  ///
  /// ## Returns
  /// - [Right] with the unread count if successful
  /// - [Left] with [NotificationFailure] if an error occurs
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.getUnreadCount();
  /// result.fold(
  ///   (failure) => showError('Failed to get count: ${failure.message}'),
  ///   (count) => updateBadge(count),
  /// );
  /// ```
  Future<Either<NotificationFailure, int>> getUnreadCount();

  /// Saves the unread notification count.
  ///
  /// Persists the current unread count for quick retrieval and badge
  /// management. This count should be kept in sync with the actual
  /// number of unread notifications in the history.
  ///
  /// ## Parameters
  /// - [count]: The unread count to save
  ///
  /// ## Returns
  /// - [Right] with void if successful
  /// - [Left] with [NotificationFailure] if an error occurs
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.saveUnreadCount(5);
  /// result.fold(
  ///   (failure) => showError('Failed to save count: ${failure.message}'),
  ///   (_) => updateUI(),
  /// );
  /// ```
  Future<Either<NotificationFailure, void>> saveUnreadCount(int count);

  /// Recalculates the unread count from the actual notification history.
  ///
  /// This method scans through all notifications in the history and
  /// counts how many are unread, then updates the stored count accordingly.
  /// Use this to fix synchronization issues between the stored count
  /// and actual notifications.
  ///
  /// ## Returns
  /// - [Right] with the recalculated unread count if successful
  /// - [Left] with [NotificationFailure] if an error occurs
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.recalculateUnreadCount();
  /// result.fold(
  ///   (failure) => showError('Failed to recalculate: ${failure.message}'),
  ///   (count) => updateBadge(count),
  /// );
  /// ```
  Future<Either<NotificationFailure, int>> recalculateUnreadCount();
}
