import 'dart:convert';

import '../../adapters/notification_kit_runtime.dart';
import '../../adapters/notification_storage_adapter.dart';
import '../../constants/notification_keys.dart';

/// Data source interface for notification storage operations.
///
/// This abstract class defines the contract for persisting and retrieving
/// notification-related data using local storage. It handles settings,
/// history, counts, and topic subscriptions.
///
/// ## Implementation Notes
/// - All operations should handle storage errors gracefully
/// - JSON serialization/deserialization should be handled safely
/// - Default values should be provided when data is missing
/// - Storage operations should be atomic where possible
abstract class NotificationStorageDataSource {
  /// Saves notification settings to local storage.
  ///
  /// Persists the user's notification preferences including enabled states,
  /// channel settings, and topic subscriptions. Settings are stored as JSON
  /// for easy serialization and deserialization.
  ///
  /// ## Parameters
  /// - [settings]: Map containing all notification settings
  ///
  /// ## Usage
  /// ```dart
  /// await dataSource.saveSettings({
  ///   'enabled': true,
  ///   'soundEnabled': true,
  ///   'channelSettings': {'orders': true, 'promotions': false},
  /// });
  /// ```
  Future<void> saveSettings(Map<String, dynamic> settings);

  /// Retrieves notification settings from local storage.
  ///
  /// Loads the user's notification preferences from storage. Returns null
  /// if no settings have been saved yet, allowing the caller to apply
  /// default settings.
  ///
  /// ## Returns
  /// - [Map<String, dynamic>] containing settings if found
  /// - [null] if no settings exist in storage
  ///
  /// ## Usage
  /// ```dart
  /// final settings = await dataSource.getSettings();
  /// if (settings != null) {
  ///   applySettings(settings);
  /// } else {
  ///   applyDefaultSettings();
  /// }
  /// ```
  Future<Map<String, dynamic>?> getSettings();

  /// Saves notification history to local storage.
  ///
  /// Persists the list of past notifications for history and debugging
  /// purposes. The history is typically limited to a maximum size to
  /// prevent excessive storage usage.
  ///
  /// ## Parameters
  /// - [history]: List of notification data maps
  ///
  /// ## Usage
  /// ```dart
  /// await dataSource.saveHistory([
  ///   {'id': '123', 'title': 'Order Update', 'timestamp': '2023-01-01T12:00:00Z'},
  ///   {'id': '124', 'title': 'Promotion', 'timestamp': '2023-01-01T13:00:00Z'},
  /// ]);
  /// ```
  Future<void> saveHistory(List<Map<String, dynamic>> history);

  /// Retrieves notification history from local storage.
  ///
  /// Loads the list of past notifications. Returns an empty list
  /// if no history exists, allowing the caller to handle the absence
  /// of historical data gracefully.
  ///
  /// ## Returns
  /// List of notification data maps, empty if no history exists
  ///
  /// ## Usage
  /// ```dart
  /// final history = await dataSource.getHistory();
  /// displayNotificationHistory(history);
  /// ```
  Future<List<Map<String, dynamic>>> getHistory();

  /// Clears all notification history from storage.
  ///
  /// Removes all stored notification history. This is typically used
  /// when clearing user data or when the history size limit is exceeded.
  ///
  /// ## Usage
  /// ```dart
  /// await dataSource.clearHistory();
  /// ```
  Future<void> clearHistory();

  /// Saves the unread notification count to storage.
  ///
  /// Persists the current count of unread notifications. This count
  /// is used to display badge indicators and track notification status.
  ///
  /// ## Parameters
  /// - [count]: The number of unread notifications
  ///
  /// ## Usage
  /// ```dart
  /// await dataSource.saveUnreadCount(5);
  /// ```
  Future<void> saveUnreadCount(int count);

  /// Retrieves the unread notification count from storage.
  ///
  /// Loads the current count of unread notifications. Returns 0 if
  /// no count has been saved, treating it as the default value.
  ///
  /// ## Returns
  /// The number of unread notifications, 0 if not found
  ///
  /// ## Usage
  /// ```dart
  /// final unreadCount = await dataSource.getUnreadCount();
  /// updateBadgeCount(unreadCount);
  /// ```
  Future<int> getUnreadCount();

  /// Saves the badge count to storage.
  ///
  /// Persists the current app icon badge count. This is used to
  /// maintain consistency across app restarts and platform updates.
  ///
  /// ## Parameters
  /// - [count]: The badge count to display on the app icon
  ///
  /// ## Usage
  /// ```dart
  /// await dataSource.saveBadgeCount(3);
  /// ```
  Future<void> saveBadgeCount(int count);

  /// Retrieves the badge count from storage.
  ///
  /// Loads the current app icon badge count. Returns 0 if no count
  /// has been saved, treating it as the default value.
  ///
  /// ## Returns
  /// The badge count, 0 if not found
  ///
  /// ## Usage
  /// ```dart
  /// final badgeCount = await dataSource.getBadgeCount();
  /// updateAppBadge(badgeCount);
  /// ```
  Future<int> getBadgeCount();

  /// Saves the list of subscribed topics to storage.
  ///
  /// Persists the topics that the user is subscribed to for receiving
  /// targeted notifications. This helps maintain subscription state
  /// across app restarts.
  ///
  /// ## Parameters
  /// - [topics]: List of topic names the user is subscribed to
  ///
  /// ## Usage
  /// ```dart
  /// await dataSource.saveSubscribedTopics(['promotions', 'news', 'orders']);
  /// ```
  Future<void> saveSubscribedTopics(List<String> topics);

  /// Retrieves the list of subscribed topics from storage.
  ///
  /// Loads the topics that the user is subscribed to. Returns an empty
  /// list if no topics have been saved, allowing the caller to handle
  /// the absence of subscriptions gracefully.
  ///
  /// ## Returns
  /// List of subscribed topic names, empty if none exist
  ///
  /// ## Usage
  /// ```dart
  /// final topics = await dataSource.getSubscribedTopics();
  /// for (final topic in topics) {
  ///   await fcm.subscribeToTopic(topic);
  /// }
  /// ```
  Future<List<String>> getSubscribedTopics();
}

/// AppStorage implementation of [NotificationStorageDataSource].
///
/// This class provides storage operations using the AppStorage utility
/// for persisting notification-related data. It handles JSON serialization
/// and provides a clean interface for storage operations.
///
/// ## Error Handling
/// All storage exceptions are caught and handled gracefully.
/// Invalid JSON is safely handled with fallback to default values.
///
/// ## Performance Considerations
/// - JSON operations are performed synchronously within async methods
/// - Large history lists should be paginated or limited in size
/// - Consider using database storage for complex queries
class NotificationStorageDataSourceImpl
    implements NotificationStorageDataSource {
  /// The underlying storage adapter (host-supplied or default).
  final NotificationStorageAdapter _storage;

  /// Creates a new notification storage data source implementation.
  ///
  /// If [storage] is null, the adapter configured on [NotificationKitRuntime]
  /// is used (defaulting to [SharedPreferencesAdapter] when none is set).
  NotificationStorageDataSourceImpl([NotificationStorageAdapter? storage])
      : _storage = storage ?? NotificationKitRuntime.storage;

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _storage.setString(NotificationKeys.settings, jsonEncode(settings));
  }

  @override
  Future<Map<String, dynamic>?> getSettings() async {
    final json = await _storage.getString(NotificationKeys.settings);
    if (json == null) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      // Invalid JSON - return null to trigger default settings
      return null;
    }
  }

  @override
  Future<void> saveHistory(List<Map<String, dynamic>> history) async {
    await _storage.setString(NotificationKeys.history, jsonEncode(history));
  }

  @override
  Future<List<Map<String, dynamic>>> getHistory() async {
    final json = await _storage.getString(NotificationKeys.history);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      // Invalid JSON - return empty history
      return [];
    }
  }

  @override
  Future<void> clearHistory() async {
    await _storage.remove(NotificationKeys.history);
  }

  @override
  Future<void> saveUnreadCount(int count) async {
    await _storage.setInt(NotificationKeys.unreadCount, count);
  }

  @override
  Future<int> getUnreadCount() async {
    return await _storage.getInt(NotificationKeys.unreadCount) ?? 0;
  }

  @override
  Future<void> saveBadgeCount(int count) async {
    await _storage.setInt(NotificationKeys.badgeCount, count);
  }

  @override
  Future<int> getBadgeCount() async {
    return await _storage.getInt(NotificationKeys.badgeCount) ?? 0;
  }

  @override
  Future<void> saveSubscribedTopics(List<String> topics) async {
    await _storage.setStringList(NotificationKeys.subscribedTopics, topics);
  }

  @override
  Future<List<String>> getSubscribedTopics() async {
    return await _storage.getStringList(NotificationKeys.subscribedTopics) ??
        [];
  }
}
