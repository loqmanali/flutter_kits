import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'adapters/notification_kit_runtime.dart';
import 'config/notification_channels.dart';
import 'config/notification_config.dart';
import 'constants/notification_topics.dart';

/// Initializes and configures the notification module.
///
/// This class handles all the setup required for notifications to work properly,
/// including Firebase Messaging permissions, local notifications plugin setup,
/// notification channels, and automatic topic subscriptions.
///
/// ## Usage
/// Call [initialize] in your app's main function after Firebase initialization:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///
///   // Initialize notification module
///   await NotificationInitializer.initialize();
///
///   runApp(MyApp());
/// }
/// ```
class NotificationInitializer {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Returns whether the notification module has been initialized.
  static bool get isInitialized => _isInitialized;

  /// Returns the local notifications plugin instance.
  static FlutterLocalNotificationsPlugin get localNotificationsPlugin =>
      _localNotificationsPlugin;

  /// Initializes the notification module (essential setup only).
  ///
  /// This method should be called before runApp().
  /// It initializes the local notifications plugin.
  /// Heavy operations like permissions, timezone, and network calls are deferred to [setupRemoteNotifications].
  static Future<bool> initialize({
    void Function(NotificationResponse)? onNotificationTap,
  }) async {
    if (_isInitialized) {
      NotificationKitRuntime.logger.debug('Already initialized');
      return true;
    }

    try {
      // 1. Initialize local notifications
      await _initializeLocalNotifications(onNotificationTap);

      _isInitialized = true;
      return true;
    } catch (e) {
      NotificationKitRuntime.logger.error(
        'Initialization failed: $e',
      );
      return false;
    }
  }

  /// Sets up remote notifications (permissions, channels, subscriptions).
  ///
  /// This method should be called after the app is running (e.g., in App.initState)
  /// to avoid blocking startup.
  static Future<void> setupRemoteNotifications({
    bool subscribeToAllUsers = true,
    bool autoSubscribePlatformTopic = true,
  }) async {
    try {
      // 0. Initialize timezone (deferred)
      tz.initializeTimeZones();

      // 1. Request FCM permission
      await _requestPermission();

      // 2. Create Android notification channels
      await _createNotificationChannels();

      // 3. Wait for APNS token on iOS before subscribing to topics
      if (Platform.isIOS) {
        await _waitForAPNSToken();
      }

      // 4. Subscribe to topics
      if (subscribeToAllUsers) {
        await _subscribeToTopic(NotificationTopics.all);
      }
      if (autoSubscribePlatformTopic) {
        await _subscribeToPlatformTopic();
      }

      // 5. Set foreground notification options
      await _setForegroundOptions();

      NotificationKitRuntime.logger.debug(
        'Remote notifications setup complete',
      );
    } catch (e) {
      NotificationKitRuntime.logger.error(
        'Remote setup failed: $e',
      );
    }
  }

  /// Waits for the APNS token to be available on iOS.
  ///
  /// On iOS, FCM requires the APNS token before it can subscribe to topics
  /// or retrieve the FCM token. This method polls for the token with retries.
  static Future<bool> _waitForAPNSToken({
    int maxAttempts = 10,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        NotificationKitRuntime.logger.debug(
          'APNS token available (attempt $attempt)',
        );
        return true;
      }
      NotificationKitRuntime.logger.debug(
        'Waiting for APNS token (attempt $attempt/$maxAttempts)',
      );
      await Future.delayed(delay);
    }
    NotificationKitRuntime.logger.error(
      'APNS token not available after $maxAttempts attempts',
    );
    return false;
  }

  /// Requests notification permission from the user.
  static Future<NotificationSettings> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission();

    NotificationKitRuntime.logger.debug(
      'Permission status: ${settings.authorizationStatus}',
    );

    return settings;
  }

  /// Downloads an image from the internet and saves it locally.
  ///
  /// Returns the file path if successful, or null if download fails.
  static Future<String?> _downloadAndSaveFile(
    String url,
    String fileName,
  ) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        NotificationKitRuntime.logger.error(
          'Failed to download image. Status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      NotificationKitRuntime.logger.error('Error downloading image: $e');
      return null;
    }
  }

  /// Initializes the local notifications plugin.
  static Future<void> _initializeLocalNotifications(
    void Function(NotificationResponse)? onNotificationTap,
  ) async {
    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings();

    // Combined settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize
    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse:
          onNotificationTap ?? _defaultNotificationTapHandler,
      onDidReceiveBackgroundNotificationResponse:
          _backgroundNotificationHandler,
    );

    NotificationKitRuntime.logger.debug(
      'Local notifications initialized',
    );
  }

  /// Creates Android notification channels.
  static Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Create high importance channel for FCM notifications
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.high,
        ),
      );

      // Create predefined channels
      for (final channel in NotificationChannels.channels) {
        await androidPlugin.createNotificationChannel(channel);
      }

      NotificationKitRuntime.logger.debug(
        'Notification channels created',
      );
    }
  }

  /// Subscribes to a topic.
  static Future<void> _subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      NotificationKitRuntime.logger.debug(
        'Subscribed to topic: $topic',
      );
    } catch (e) {
      NotificationKitRuntime.logger.error(
        'Failed to subscribe to $topic: $e',
      );
    }
  }

  /// Subscribes to platform-specific topic (android_users or ios_users).
  static Future<void> _subscribeToPlatformTopic() async {
    final topic = Platform.isAndroid
        ? NotificationTopics.android
        : NotificationTopics.ios;
    await _subscribeToTopic(topic);
  }

  /// Sets foreground notification presentation options.
  static Future<void> _setForegroundOptions() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      badge: true,
      sound: true,
    );
    NotificationKitRuntime.logger.debug(
      'Foreground options set',
    );
  }

  /// Default handler for notification taps.
  static void _defaultNotificationTapHandler(NotificationResponse response) {
    NotificationKitRuntime.logger.debug(
      'Notification tapped: ${response.payload}',
    );
  }

  /// Gets the current FCM token.
  ///
  /// Returns the device's FCM registration token which can be used
  /// to send notifications to this specific device.
  ///
  /// ## Example
  /// ```dart
  /// final token = await NotificationInitializer.getFCMToken();
  /// print('FCM Token: $token');
  /// // Send this token to your backend for targeted notifications
  /// ```
  static Future<String?> getFCMToken() async {
    try {
      // On iOS, wait for APNS token before getting FCM token
      if (Platform.isIOS) {
        final hasAPNS = await _waitForAPNSToken();
        if (!hasAPNS) {
          NotificationKitRuntime.logger.error(
            'Cannot get FCM token: APNS token not available',
          );
          return null;
        }
      }
      final token = await FirebaseMessaging.instance.getToken();
      NotificationKitRuntime.logger.debug(
        'FCM token retrieved successfully',
      );
      return token;
    } catch (e) {
      NotificationKitRuntime.logger.error(
        'Failed to get FCM token: $e',
      );
      return null;
    }
  }

  /// Subscribes to additional topics.
  ///
  /// ## Example
  /// ```dart
  /// await NotificationInitializer.subscribeToTopics(['promotions', 'news']);
  /// ```
  static Future<void> subscribeToTopics(List<String> topics) async {
    for (final topic in topics) {
      await _subscribeToTopic(topic);
    }
  }

  /// Unsubscribes from topics.
  ///
  /// ## Example
  /// ```dart
  /// await NotificationInitializer.unsubscribeFromTopics(['promotions']);
  /// ```
  static Future<void> unsubscribeFromTopics(List<String> topics) async {
    for (final topic in topics) {
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
        NotificationKitRuntime.logger.debug(
          'Unsubscribed from: $topic',
        );
      } catch (e) {
        NotificationKitRuntime.logger.error(
          'Failed to unsubscribe from $topic: $e',
        );
      }
    }
  }

  /// Shows a local notification.
  ///
  /// Use this to display notifications when the app is in the foreground
  /// or for local reminders.
  ///
  /// ## Example
  /// ```dart
  /// await NotificationInitializer.showNotification(
  ///   id: 1,
  ///   title: 'Hello!',
  ///   body: 'This is a test notification',
  ///   payload: '{"screen": "/home"}',
  /// );
  /// ```
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
    String channelId = 'high_importance_channel',
    String? sound,
    bool enableVibration = true,
    bool playSound = true,
  }) async {
    StyleInformation? styleInformation;

    // If image URL is provided, try to download and use BigPictureStyle
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final String fileName =
            'notification_img_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String? imagePath =
            await _downloadAndSaveFile(imageUrl, fileName);

        if (imagePath != null) {
          final BigPictureStyleInformation bigPictureStyleInformation =
              BigPictureStyleInformation(
            FilePathAndroidBitmap(imagePath),
            hideExpandedLargeIcon: true,
            contentTitle: title,
            htmlFormatContentTitle: true,
            summaryText: body,
            htmlFormatSummaryText: true,
          );
          styleInformation = bigPictureStyleInformation;
        }
      } catch (e) {
        NotificationKitRuntime.logger.error(
          'Failed to create BigPictureStyle: $e',
        );
      }
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      icon: NotificationConfig.notificationIcon,
      styleInformation: styleInformation,
      // If playSound is false, use silent mode (no sound)
      // If playSound is true and sound is provided, use custom sound
      // Otherwise use default sound
      playSound: playSound,
      sound: (playSound && sound != null)
          ? RawResourceAndroidNotificationSound(sound)
          : null,
      enableVibration: enableVibration,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
      sound: (playSound && sound != null) ? '$sound.wav' : null,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }
}

/// Background notification handler (must be top-level function).
@pragma('vm:entry-point')
void _backgroundNotificationHandler(NotificationResponse response) {
  NotificationKitRuntime.logger.warning(
    'Background notification: ${response.payload}',
  );
}
