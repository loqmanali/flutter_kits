import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../adapters/notification_kit_runtime.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    NotificationKitRuntime.logger.debug(
      '[BackgroundHandler] Handling a background message: ${message.messageId}',
    );

    // Process data-only messages if needed
    if (message.notification == null && message.data.isNotEmpty) {
      // Logic to show local notification for data messages in background
      // This would require initializing FlutterLocalNotificationsPlugin here
    }
  } catch (e, stackTrace) {
    NotificationKitRuntime.logger.error(
      '[BackgroundHandler] Error in background handler',
      e,
      stackTrace,
    );
  }
}
