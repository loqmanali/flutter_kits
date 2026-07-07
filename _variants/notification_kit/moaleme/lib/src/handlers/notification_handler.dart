import '../data/datasources/fcm_data_source.dart';
import 'background_handler.dart';
import 'foreground_handler.dart';
import 'notification_tap_handler.dart';

class NotificationHandler {
  final ForegroundHandler _foregroundHandler;
  final NotificationTapHandler _tapHandler;
  final FCMDataSource _fcmDataSource;

  NotificationHandler(
    this._foregroundHandler,
    this._tapHandler,
    this._fcmDataSource,
  );

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _foregroundHandler.initialize();
    _tapHandler.initialize();

    // Set background handler
    await _fcmDataSource
        .setBackgroundHandler(firebaseMessagingBackgroundHandler);

    _isInitialized = true;
  }
}
