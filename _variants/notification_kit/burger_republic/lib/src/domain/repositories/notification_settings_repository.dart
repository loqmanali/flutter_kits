import 'package:dartz/dartz.dart';

import '../entities/notification_settings.dart';
import '../failures/notification_failures.dart';

/// Repository interface for notification settings management.
///
/// This abstract class defines the contract for managing user notification
/// preferences and settings. It provides methods for retrieving, saving,
/// and updating notification configuration data.
///
/// ## Implementation Notes
/// - All methods should handle errors gracefully and return Either types
/// - Settings should be persisted across app restarts
/// - Channel and topic updates should be atomic operations
/// - Consider thread safety for concurrent access
///
/// ## Usage
/// ```dart
/// class MyNotificationService {
///   final NotificationSettingsRepository _repository;
///
///   MyNotificationService(this._repository);
///
///   Future<void> updateSettings(NotificationSettings settings) async {
///     final result = await _repository.saveSettings(settings);
///     result.fold(
///       (failure) => showError(failure.message),
///       (_) => showSuccess('Settings saved'),
///     );
///   }
/// }
/// ```
abstract class NotificationSettingsRepository {
  /// Retrieves the current notification settings.
  ///
  /// Loads the user's notification preferences from persistent storage.
  /// If no settings have been saved, default settings should be returned.
  ///
  /// ## Returns
  /// - [Right] with [NotificationSettings] if successful
  /// - [Left] with [NotificationFailure] if an error occurs
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.getSettings();
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (settings) => applySettings(settings),
  /// );
  /// ```
  Future<Either<NotificationFailure, NotificationSettings>> getSettings();

  /// Saves notification settings to persistent storage.
  ///
  /// Persists the complete notification settings configuration. This operation
  /// should overwrite any existing settings with the new values.
  ///
  /// ## Parameters
  /// - [settings]: The notification settings to save
  ///
  /// ## Returns
  /// - [Right] with void if successful
  /// - [Left] with [NotificationFailure] if an error occurs
  ///
  /// ## Example
  /// ```dart
  /// final settings = NotificationSettings(
  ///   enabled: true,
  ///   soundEnabled: false,
  ///   promotionalEnabled: false,
  /// );
  ///
  /// final result = await repository.saveSettings(settings);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('Settings saved'),
  /// );
  /// ```
  Future<Either<NotificationFailure, void>> saveSettings(
      NotificationSettings settings,);

  /// Updates a specific notification channel setting.
  ///
  /// Modifies the enabled/disabled state for a specific notification channel.
  /// This operation should be atomic and not affect other channel settings.
  ///
  /// ## Parameters
  /// - [channelId]: The identifier of the channel to update
  /// - [enabled]: Whether the channel should be enabled
  ///
  /// ## Returns
  /// - [Right] with void if successful
  /// - [Left] with [NotificationFailure] if an error occurs
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.updateChannelSetting('orders', true);
  /// result.fold(
  ///   (failure) => showError('Failed to update channel: ${failure.message}'),
  ///   (_) => showSuccess('Order notifications enabled'),
  /// );
  /// ```
  Future<Either<NotificationFailure, void>> updateChannelSetting(
      String channelId, bool enabled,);

  /// Updates a topic subscription setting.
  ///
  /// Modifies the subscription state for a specific FCM topic. This operation
  /// should be atomic and not affect other topic subscriptions.
  ///
  /// ## Parameters
  /// - [topic]: The topic name to update subscription for
  /// - [subscribed]: Whether the user should be subscribed to the topic
  ///
  /// ## Returns
  /// - [Right] with void if successful
  /// - [Left] with [NotificationFailure] if an error occurs
  ///
  /// ## Example
  /// ```dart
  /// final result = await repository.updateTopicSubscription('promotions', false);
  /// result.fold(
  ///   (failure) => showError('Failed to update topic: ${failure.message}'),
  ///   (_) => showSuccess('Unsubscribed from promotions'),
  /// );
  /// ```
  Future<Either<NotificationFailure, void>> updateTopicSubscription(
      String topic, bool subscribed,);
}
