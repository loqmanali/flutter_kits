import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/notification_kit_runtime.dart';
import '../domain/entities/notification_entity.dart';
import '../presentation/providers/notification_providers.dart';
import '../services/notification_service.dart';
import '../services/toast_notification_service.dart';

class ForegroundHandler {
  final NotificationService _notificationService;
  final ToastNotificationService _toastService;
  final Ref _ref;

  ForegroundHandler(this._notificationService, this._toastService, this._ref);

  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;

    _notificationService.onNotificationReceived.listen((notification) {
      _handleNotification(notification);
    });

    _isInitialized = true;
  }

  Future<void> _handleNotification(
    NotificationEntity notification,
  ) async {
    debugPrint(
      '[ForegroundHandler] Handling notification: title=${notification.title} body=${notification.body}',
    );

    // Check if notifications are globally enabled
    try {
      final settingsState = _ref.read(notificationSettingsProvider);
      debugPrint(
        '[ForegroundHandler] Settings loaded: enabled=${settingsState.settings.enabled}',
      );
      if (!settingsState.settings.enabled) {
        debugPrint(
          '[ForegroundHandler] Notifications disabled - skipping notification',
        );
        return;
      }
    } catch (e) {
      debugPrint('[ForegroundHandler] Error reading notification settings: $e');
      // Continue with notification if settings can't be read
    }

    final context = NotificationKitRuntime.navigator?.currentContext;

    // Show toast only if context is valid and has Directionality
    if (context == null ||
        !context.mounted ||
        Directionality.maybeOf(context) == null) {
      debugPrint('[ForegroundHandler] Skipping toast - context not ready');
      // If context is not ready, we MUST fallback to standard local notification
      // because we can't show a toast (ToastStyle.custom would fail).
      // Even if ToastStyle is system, _toastService needs a context (for some reason? No, showInfo takes context but system style doesn't use it).
      // Actually, showInfo takes context.
      // If we are here, we can try to force show a notification directly using the service
      // if we can't show a toast.
      // But if we want to avoid duplication, we should only do this if toast fails.

      // However, the original code had a separate try-catch block for local notification.
      // If we remove it, we risk not showing anything if context is null.

      // BETTER APPROACH:
      // If we can show toast, let toast service handle it (System or Custom).
      // If we cannot show toast (context null), then show System Notification directly.

      try {
        await _notificationService.showNotification(notification);
        debugPrint(
          '[ForegroundHandler] Fallback: Local notification shown (context not ready)',
        );
      } catch (e) {
        debugPrint(
          '[ForegroundHandler] Failed to show fallback notification: $e',
        );
      }
      return;
    }

    try {
      // Check sound and vibration settings before showing toast
      final settingsState = _ref.read(notificationSettingsProvider);
      debugPrint(
        '[ForegroundHandler] Toast settings: soundEnabled=${settingsState.settings.soundEnabled}, '
        'vibrationEnabled=${settingsState.settings.vibrationEnabled}, '
        'customSound=${settingsState.settings.customSoundPath}',
      );

      _toastService.showInfo(
        context,
        notification.title,
        notification.body,
        imageUrl: notification.imageUrl,
        playSound: settingsState.settings.soundEnabled,
        enableVibration: settingsState.settings.vibrationEnabled,
        customSound: settingsState.settings.customSoundPath,
      );
    } catch (e) {
      debugPrint('[ForegroundHandler] Toast notification failed: $e');
      // Fallback in case toast fails
      try {
        await _notificationService.showNotification(notification);
      } catch (_) {}
    }
  }
}
