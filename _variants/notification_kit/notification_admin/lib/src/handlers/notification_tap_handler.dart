import 'package:go_router/go_router.dart';

import '../adapters/notification_kit_runtime.dart';
import '../services/deep_link_notification_service.dart';
import '../services/notification_service.dart';

class NotificationTapHandler {
  final NotificationService _notificationService;
  final DeepLinkNotificationService _deepLinkService;

  NotificationTapHandler(this._notificationService, this._deepLinkService);

  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;

    _notificationService.onNotificationTapped.listen((notification) {
      final log = NotificationKitRuntime.logger;
      log.debug('🔔 Notification tapped:');
      log.debug('  Title: ${notification.title}');
      log.debug('  Body: ${notification.body}');
      log.debug('  Payload: ${notification.payload}');
      log.debug('  ExtraData: ${notification.extraData}');

      final navigator = NotificationKitRuntime.navigator;
      final context = navigator?.currentContext;

      if (notification.payload != null) {
        if (context != null && context.mounted) {
          _deepLinkService.handleDeepLink(context, notification.payload!);
        }
      } else if (notification.extraData != null &&
          notification.extraData!.isNotEmpty) {
        log.warning(
          'No payload parsed, but extraData exists: ${notification.extraData}',
        );
        final fallback = navigator?.fallbackRoute;
        if (fallback != null && context != null && context.mounted) {
          context.push(fallback);
        }
      }
    });

    _isInitialized = true;
  }
}
