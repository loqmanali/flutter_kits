import 'package:firebase_messaging/firebase_messaging.dart';

/// Data source interface for Firebase Cloud Messaging (FCM) operations.
///
/// This abstract class defines the contract for all FCM-related operations
/// including token management, topic subscriptions, and message handling.
/// It provides a clean abstraction over the Firebase Messaging SDK.
///
/// ## Implementation Notes
/// - All methods should handle Firebase-specific errors gracefully
/// - Token refresh stream should be properly managed to avoid memory leaks
/// - Background handler registration should be done once during app initialization
abstract class FCMDataSource {
  /// Retrieves the current FCM registration token.
  ///
  /// This token is used to target this specific device instance
  /// for push notifications. The token can change over time,
  /// so it should be refreshed periodically.
  ///
  /// ## Returns
  /// - [String] token if successful
  /// - [null] if token retrieval fails or FCM is not available
  ///
  /// ## Usage
  /// ```dart
  /// final token = await fcmDataSource.getToken();
  /// if (token != null) {
  ///   // Send token to your server
  ///   await serverService.registerDeviceToken(token);
  /// }
  /// ```
  Future<String?> getToken();

  /// Deletes the current FCM registration token.
  ///
  /// This invalidates the current token and generates a new one
  /// on the next call to [getToken]. Use this when users log out
  /// or when you need to refresh the token for security reasons.
  ///
  /// ## Usage
  /// ```dart
  /// // User logged out - invalidate token
  /// await fcmDataSource.deleteToken();
  /// ```
  Future<void> deleteToken();

  /// Stream that emits events when the FCM token is refreshed.
  ///
  /// Firebase automatically refreshes tokens periodically or when
  /// certain conditions change (app update, token invalidation, etc.).
  /// Listen to this stream to keep your server updated with the latest token.
  ///
  /// ## Usage
  /// ```dart
  /// fcmDataSource.onTokenRefresh.listen((newToken) {
  ///   // Update server with new token
  ///   serverService.updateDeviceToken(newToken);
  /// });
  /// ```
  Stream<String> get onTokenRefresh;

  /// Subscribes the device to an FCM topic.
  ///
  /// Topics allow you to send messages to multiple devices that
  /// share a common interest. This is useful for sending notifications
  /// to user segments (e.g., 'promotions', 'news', 'android_users').
  ///
  /// ## Parameters
  /// - [topic]: The topic name to subscribe to
  ///
  /// ## Usage
  /// ```dart
  /// await fcmDataSource.subscribeToTopic('promotions');
  /// ```
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribes the device from an FCM topic.
  ///
  /// Removes the device from the specified topic, preventing
  /// future messages sent to that topic from being delivered.
  ///
  /// ## Parameters
  /// - [topic]: The topic name to unsubscribe from
  ///
  /// ## Usage
  /// ```dart
  /// await fcmDataSource.unsubscribeFromTopic('promotions');
  /// ```
  Future<void> unsubscribeFromTopic(String topic);

  /// Retrieves the message that caused the application to open.
  ///
  /// When the app is launched from a notification tap, this method
  /// returns the message that triggered the launch. Should be called
  /// during app initialization to handle notification launches.
  ///
  /// ## Returns
  /// - [RemoteMessage] if app was opened from a notification
  /// - [null] if app was opened normally
  ///
  /// ## Usage
  /// ```dart
  /// final initialMessage = await fcmDataSource.getInitialMessage();
  /// if (initialMessage != null) {
  ///   // Handle notification launch
  ///   handleNotificationTap(initialMessage);
  /// }
  /// ```
  Future<RemoteMessage?> getInitialMessage();

  /// Stream of messages received when the app is in the foreground.
  ///
  /// This stream delivers messages that arrive while the app is
  /// visible and in focus. You should handle these messages
  /// to display in-app notifications or update UI accordingly.
  ///
  /// ## Usage
  /// ```dart
  /// fcmDataSource.onMessage.listen((message) {
  ///   // Show in-app notification
  ///   showInAppNotification(message);
  /// });
  /// ```
  Stream<RemoteMessage> get onMessage;

  /// Stream of messages received when the user taps a notification.
  ///
  /// This stream delivers messages when the app is opened from
  /// a notification tap. Use this to handle navigation and
  /// deep linking from notifications.
  ///
  /// ## Usage
  /// ```dart
  /// fcmDataSource.onMessageOpenedApp.listen((message) {
  ///   // Handle notification tap
  ///   navigateFromNotification(message);
  /// });
  /// ```
  Stream<RemoteMessage> get onMessageOpenedApp;

  /// Sets the background message handler for FCM.
  ///
  /// This handler is called when a message is received while the
  /// app is in the background or terminated. The handler must be
  /// a top-level or static function and should handle message
  /// processing and local notification display.
  ///
  /// ## Parameters
  /// - [handler]: The background handler function
  ///
  /// ## Usage
  /// ```dart
  /// await fcmDataSource.setBackgroundHandler(firebaseMessagingBackgroundHandler);
  /// ```
  Future<void> setBackgroundHandler(BackgroundMessageHandler handler);
}

/// Firebase implementation of [FCMDataSource].
///
/// This class wraps the Firebase Messaging SDK and provides
/// a clean interface for FCM operations. It handles all the
/// low-level Firebase interactions and exposes them through
/// the data source interface.
///
/// ## Error Handling
/// All Firebase exceptions are propagated to the caller.
/// Repository layer should handle these errors and convert
/// them to appropriate domain failures.
class FCMDataSourceImpl implements FCMDataSource {
  /// The underlying Firebase Messaging instance.
  final FirebaseMessaging _firebaseMessaging;

  /// Creates a new FCM data source implementation.
  ///
  /// ## Parameters
  /// - [firebaseMessaging]: The Firebase Messaging instance to use
  FCMDataSourceImpl(this._firebaseMessaging);

  @override
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  @override
  Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
  }

  @override
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  @override
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  @override
  Future<RemoteMessage?> getInitialMessage() {
    return _firebaseMessaging.getInitialMessage();
  }

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<void> setBackgroundHandler(BackgroundMessageHandler handler) async {
    FirebaseMessaging.onBackgroundMessage(handler);
  }
}
