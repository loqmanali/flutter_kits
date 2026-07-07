import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Data source interface for local notification operations.
///
/// This abstract class defines the contract for all local notification
/// functionality including showing, scheduling, and managing notifications
/// using the flutter_local_notifications plugin.
///
/// ## Implementation Notes
/// - All methods should handle plugin-specific errors gracefully
/// - Notification IDs should be unique across the app
/// - Timezone-aware scheduling should be used for reliable delivery
/// - Platform-specific details should be handled appropriately
abstract class LocalNotificationDataSource {
  /// Initializes the local notifications plugin.
  ///
  /// This method must be called before any other notification operations.
  /// It configures the plugin with platform-specific settings and sets up
  /// callbacks for handling notification interactions.
  ///
  /// ## Parameters
  /// - [initializationSettings]: Platform-specific initialization settings
  /// - [onDidReceiveNotificationResponse]: Callback for notification taps when app is foreground
  /// - [onDidReceiveBackgroundNotificationResponse]: Callback for notification taps when app is background
  ///
  /// ## Returns
  /// - [bool] indicating if initialization was successful
  /// - [null] if initialization status is unknown
  ///
  /// ## Usage
  /// ```dart
  /// final success = await localNotifications.initialize(
  ///   InitializationSettings(
  ///     Android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  ///     iOS: DarwinInitializationSettings(),
  ///   ),
  ///   onDidReceiveNotificationResponse: handleNotificationResponse,
  /// );
  /// ```
  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
        onDidReceiveBackgroundNotificationResponse,
  });

  /// Shows an immediate notification.
  ///
  /// Displays a notification to the user immediately. This is used for
  /// time-sensitive notifications that should appear right away.
  ///
  /// ## Parameters
  /// - [id]: Unique identifier for the notification
  /// - [title]: The main title text of the notification
  /// - [body]: The body text of the notification
  /// - [notificationDetails]: Platform-specific notification styling and behavior
  /// - [payload]: Optional data payload for the notification
  ///
  /// ## Usage
  /// ```dart
  /// await localNotifications.show(
  ///   123,
  ///   'New Message',
  ///   'You have received a new message',
  ///   notificationDetails,
  ///   payload: '{"type":"message","id":"456"}',
  /// );
  /// ```
  Future<void> show(
    int id,
    String? title,
    String? body, {
    NotificationDetails? notificationDetails,
    String? payload,
    String? imageUrl,
  });

  /// Schedules a notification for a specific time with timezone support.
  ///
  /// This method is used for scheduling notifications that should appear
  /// at a specific date and time, accounting for timezone differences.
  /// Ideal for reminders, scheduled alerts, and time-sensitive notifications.
  ///
  /// ## Parameters
  /// - [id]: Unique identifier for the notification
  /// - [title]: The main title text of the notification
  /// - [body]: The body text of the notification
  /// - [scheduledDate]: The exact date and time when notification should appear (timezone-aware)
  /// - [notificationDetails]: Platform-specific notification styling and behavior
  /// - [uiLocalNotificationDateInterpretation]: How to interpret the scheduled date on iOS
  /// - [androidScheduleMode]: Scheduling precision mode on Android
  /// - [payload]: Optional data payload for the notification
  /// - [matchDateTimeComponents]: Components for repeating notifications
  ///
  /// ## Usage
  /// ```dart
  /// await localNotifications.zonedSchedule(
  ///   124,
  ///   'Reminder',
  ///   'Meeting in 1 hour',
  ///   tz.TZDateTime.from(DateTime.now().add(Duration(hours: 1)), tz.local),
  ///   notificationDetails,
  ///   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  ///   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  /// );
  /// ```
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required UILocalNotificationDateInterpretation
        uiLocalNotificationDateInterpretation,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  });

  /// Cancels a specific notification by ID.
  ///
  /// Removes a pending notification that hasn't been shown yet,
  /// or dismisses a currently visible notification.
  ///
  /// ## Parameters
  /// - [id]: The unique identifier of the notification to cancel
  ///
  /// ## Usage
  /// ```dart
  /// await localNotifications.cancel(123);
  /// ```
  Future<void> cancel(int id);

  /// Cancels all notifications.
  ///
  /// Removes all pending notifications and dismisses any currently
  /// visible notifications. Use this when logging out or when you
  /// need to clear all notifications.
  ///
  /// ## Usage
  /// ```dart
  /// await localNotifications.cancelAll();
  /// ```
  Future<void> cancelAll();

  /// Retrieves all pending notification requests.
  ///
  /// Returns a list of notifications that are scheduled but haven't
  /// been delivered yet. Useful for debugging and notification management.
  ///
  /// ## Returns
  /// List of [PendingNotificationRequest] objects containing pending notifications
  ///
  /// ## Usage
  /// ```dart
  /// final pending = await localNotifications.pendingNotificationRequests();
  /// print('Pending notifications: ${pending.length}');
  /// ```
  Future<List<PendingNotificationRequest>> pendingNotificationRequests();

  /// Retrieves all currently active notifications.
  ///
  /// Returns a list of notifications that are currently visible
  /// to the user in the notification shade.
  ///
  /// ## Returns
  /// List of [ActiveNotification] objects containing active notifications
  ///
  /// ## Usage
  /// ```dart
  /// final active = await localNotifications.getActiveNotifications();
  /// for (final notification in active) {
  ///   print('Active: ${notification.id} - ${notification.title}');
  /// }
  /// ```
  Future<List<ActiveNotification>> getActiveNotifications();

  /// Retrieves details about how the app was launched.
  ///
  /// Returns information about whether the app was launched from
  /// a notification tap, including the notification details.
  /// Should be called during app initialization.
  ///
  /// ## Returns
  /// - [NotificationAppLaunchDetails] if app was launched from notification
  /// - [null] if app was launched normally
  ///
  /// ## Usage
  /// ```dart
  /// final launchDetails = await localNotifications.getNotificationAppLaunchDetails();
  /// if (launchDetails?.didNotificationLaunchApp == true) {
  ///   // Handle notification launch
  ///   handleNotificationTap(launchDetails.notificationResponse);
  /// }
  /// ```
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails();
}

/// Flutter Local Notifications implementation of [LocalNotificationDataSource].
///
/// This class wraps the flutter_local_notifications plugin and provides
/// a clean interface for local notification operations. It handles all
/// the low-level plugin interactions and exposes them through the data source interface.
///
/// ## Error Handling
/// All plugin exceptions are propagated to the caller.
/// Repository layer should handle these errors and convert them to appropriate domain failures.
///
/// ## Platform Considerations
/// - Android: Requires notification channels for API 26+
/// - iOS: Requires permissions and proper configuration
/// - Timezone handling is critical for reliable scheduling
class LocalNotificationDataSourceImpl implements LocalNotificationDataSource {
  /// The underlying Flutter Local Notifications plugin instance.
  final FlutterLocalNotificationsPlugin _plugin;

  /// Creates a new local notification data source implementation.
  ///
  /// ## Parameters
  /// - [plugin]: The Flutter Local Notifications plugin instance to use
  LocalNotificationDataSourceImpl(this._plugin);

  @override
  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
        onDidReceiveBackgroundNotificationResponse,
  }) async {
    return await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );
  }

  @override
  Future<void> show(
    int id,
    String? title,
    String? body, {
    NotificationDetails? notificationDetails,
    String? payload,
    String? imageUrl,
  }) async {
    // Handle BigPictureStyle if imageUrl is provided
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // NOTE: For local notifications with remote images, we need to download the image first
      // or use a file path if it's already downloaded.
      // This implementation assumes the image handling is done by the caller or NotificationInitializer
      // For now, we delegate to the plugin directly, but advanced image handling
      // is better managed in NotificationInitializer or a helper.

      // However, since we are using NotificationInitializer in the Repository,
      // this method is low-level.
      // If we want to support images here directly, we would need http download logic.
    }

    await _plugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required UILocalNotificationDateInterpretation
        uiLocalNotificationDateInterpretation,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          uiLocalNotificationDateInterpretation,
      androidScheduleMode: androidScheduleMode,
      payload: payload,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    return await _plugin.pendingNotificationRequests();
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async {
    return await _plugin.getActiveNotifications();
  }

  @override
  Future<NotificationAppLaunchDetails?>
      getNotificationAppLaunchDetails() async {
    return await _plugin.getNotificationAppLaunchDetails();
  }
}
