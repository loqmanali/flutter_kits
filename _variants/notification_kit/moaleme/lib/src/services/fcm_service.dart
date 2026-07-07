import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../adapters/notification_kit_runtime.dart';
import '../data/datasources/fcm_data_source.dart';
import '../domain/failures/notification_failures.dart';

/// Service for handling Firebase Cloud Messaging (FCM) operations.
///
/// This service provides a high-level abstraction over FCM operations,
/// handling token management, topic subscriptions, and message streams.
/// It converts Firebase exceptions into domain-specific failures.
class FCMService {
  final FCMDataSource _dataSource;

  FCMService(this._dataSource);

  /// Gets the current FCM registration token.
  ///
  /// Returns the token if successful, or a failure if an error occurs.
  /// The token can change over time, so it should be refreshed periodically.
  Future<Either<FCMFailure, String>> getFCMToken() async {
    try {
      final token = await _dataSource.getToken();
      if (token == null || token.isEmpty) {
        return const Left(
          FCMFailure(
            message:
                'FCM token is not available. Please check your Firebase configuration.',
            code: 'TOKEN_UNAVAILABLE',
          ),
        );
      }
      return Right(token);
    } catch (e) {
      return Left(
        FCMFailure(
          message: 'Failed to get FCM token: $e',
          code: 'TOKEN_GET_FAILED',
          originalError: e,
        ),
      );
    }
  }

  /// Deletes the current FCM registration token.
  ///
  /// This invalidates the current token. A new token will be generated
  /// on the next call to getFCMToken.
  Future<Either<FCMFailure, void>> deleteFCMToken() async {
    try {
      await _dataSource.deleteToken();
      return const Right(null);
    } catch (e) {
      return Left(
        FCMFailure(
          message: 'Failed to delete FCM token: $e',
          code: 'TOKEN_DELETE_FAILED',
          originalError: e,
        ),
      );
    }
  }

  /// Stream that emits events when the FCM token is refreshed.
  ///
  /// Firebase automatically refreshes tokens periodically. Listen to
  /// this stream to keep your server updated with the latest token.
  Stream<Either<FCMFailure, String>> get onTokenRefresh {
    return _dataSource.onTokenRefresh.map<Either<FCMFailure, String>>((token) {
      if (token.isEmpty) {
        return const Left(
          FCMFailure(
            message: 'Token refresh resulted in empty token',
            code: 'TOKEN_REFRESH_EMPTY',
          ),
        );
      }
      return Right(token);
    });
  }

  /// Subscribes the device to an FCM topic.
  ///
  /// Topics allow you to send messages to multiple devices that share
  /// a common interest.
  Future<Either<FCMFailure, void>> subscribeToTopic(String topic) async {
    if (topic.isEmpty) {
      return const Left(
        FCMFailure(
          message: 'Topic name cannot be empty',
          code: 'INVALID_TOPIC',
        ),
      );
    }

    // Validate topic format (alphanumeric, underscores, hyphens only)
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(topic)) {
      return const Left(
        FCMFailure(
          message:
              'Topic name can only contain letters, numbers, hyphens, and underscores',
          code: 'INVALID_TOPIC_FORMAT',
        ),
      );
    }

    try {
      await _dataSource.subscribeToTopic(topic);
      NotificationKitRuntime.logger.debug('[FCMService] Subscribed to topic: $topic');
      return const Right(null);
    } catch (e) {
      return Left(
        FCMFailure(
          message: 'Failed to subscribe to topic "$topic": $e',
          code: 'TOPIC_SUBSCRIBE_FAILED',
          originalError: e,
        ),
      );
    }
  }

  /// Unsubscribes the device from an FCM topic.
  ///
  /// Removes the device from the specified topic.
  Future<Either<FCMFailure, void>> unsubscribeFromTopic(String topic) async {
    if (topic.isEmpty) {
      return const Left(
        FCMFailure(
          message: 'Topic name cannot be empty',
          code: 'INVALID_TOPIC',
        ),
      );
    }

    try {
      await _dataSource.unsubscribeFromTopic(topic);
      NotificationKitRuntime.logger.debug('[FCMService] Unsubscribed from topic: $topic');
      return const Right(null);
    } catch (e) {
      return Left(
        FCMFailure(
          message: 'Failed to unsubscribe from topic "$topic": $e',
          code: 'TOPIC_UNSUBSCRIBE_FAILED',
          originalError: e,
        ),
      );
    }
  }

  /// Gets the message that caused the application to open.
  ///
  /// Returns the initial message if the app was launched from a notification,
  /// or null if the app was opened normally.
  Future<Either<FCMFailure, RemoteMessage?>> getInitialMessage() async {
    try {
      final message = await _dataSource.getInitialMessage();
      return Right(message);
    } catch (e) {
      return Left(
        FCMFailure(
          message: 'Failed to get initial message: $e',
          code: 'INITIAL_MESSAGE_FAILED',
          originalError: e,
        ),
      );
    }
  }

  /// Stream of messages received when the app is in the foreground.
  ///
  /// Use this stream to handle incoming messages and display in-app notifications.
  Stream<RemoteMessage> get onMessage {
    return _dataSource.onMessage;
  }

  /// Stream of messages received when the user taps a notification.
  ///
  /// Use this stream to handle navigation and deep linking from notifications.
  Stream<RemoteMessage> get onMessageOpenedApp {
    return _dataSource.onMessageOpenedApp;
  }

  /// Sets the background message handler for FCM.
  ///
  /// The handler is called when a message is received while the app is
  /// in the background or terminated.
  Future<Either<FCMFailure, void>> setBackgroundHandler(
    BackgroundMessageHandler handler,
  ) async {
    try {
      await _dataSource.setBackgroundHandler(handler);
      NotificationKitRuntime.logger.debug('[FCMService] Background handler registered');
      return const Right(null);
    } catch (e) {
      return Left(
        FCMFailure(
          message: 'Failed to set background handler: $e',
          code: 'BACKGROUND_HANDLER_FAILED',
          originalError: e,
        ),
      );
    }
  }

  /// Requests permission for iOS notifications.
  ///
  /// On iOS, you must request permission before receiving notifications.
  /// This method requests the appropriate permissions from the user.
  Future<Either<FCMFailure, NotificationSettings>> requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();

      NotificationKitRuntime.logger.debug(
        '[FCMService] Permission status: ${settings.authorizationStatus}',
      );
      return Right(settings);
    } catch (e) {
      return Left(
        FCMFailure(
          message: 'Failed to request permission: $e',
          code: 'PERMISSION_REQUEST_FAILED',
          originalError: e,
        ),
      );
    }
  }

  /// Gets the APNS token for iOS.
  ///
  /// The APNS token is required for FCM to work on iOS. This token
  /// may not be available immediately after app launch.
  Future<Either<FCMFailure, String>> getAPNSToken() async {
    try {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null || apnsToken.isEmpty) {
        return const Left(
          FCMFailure(
            message:
                'APNS token is not available yet. Wait for APNS token to be provisioned.',
            code: 'APNS_TOKEN_UNAVAILABLE',
          ),
        );
      }
      return Right(apnsToken);
    } catch (e) {
      return Left(
        FCMFailure(
          message: 'Failed to get APNS token: $e',
          code: 'APNS_TOKEN_FAILED',
          originalError: e,
        ),
      );
    }
  }

  /// Checks if the app has notification permission.
  ///
  /// Returns true if permission is granted, false otherwise.
  Future<Either<FCMFailure, bool>> isPermissionGranted() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      final isGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      return Right(isGranted);
    } catch (e) {
      return Left(
        FCMFailure(
          message: 'Failed to check permission status: $e',
          code: 'PERMISSION_CHECK_FAILED',
          originalError: e,
        ),
      );
    }
  }

  /// Enables auto-init for FCM.
  ///
  /// When enabled, FCM automatically generates a registration token on app startup.
  Future<Either<FCMFailure, void>> setAutoInitEnabled(bool enabled) async {
    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(enabled);
      NotificationKitRuntime.logger
          .debug('[FCMService] Auto-init ${enabled ? "enabled" : "disabled"}');
      return const Right(null);
    } catch (e) {
      return Left(
        FCMFailure(
          message: 'Failed to set auto-init: $e',
          code: 'AUTO_INIT_FAILED',
          originalError: e,
        ),
      );
    }
  }
}
