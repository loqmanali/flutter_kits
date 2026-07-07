import 'dart:math';

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../notification_initializer.dart';

enum ToastStyle {
  custom,
  system,
}

class ToastNotificationService {
  final ToastStyle _defaultStyle;

  ToastNotificationService({ToastStyle defaultStyle = ToastStyle.system})
      : _defaultStyle = defaultStyle;

  int _generateId() {
    return Random().nextInt(100000);
  }

  void showSuccess(
    BuildContext context,
    String title,
    String message, {
    ToastStyle? style,
    String? imageUrl,
  }) {
    final effectiveStyle = style ?? _defaultStyle;
    if (effectiveStyle == ToastStyle.system) {
      NotificationInitializer.showNotification(
        id: _generateId(),
        title: title,
        body: message,
        imageUrl: imageUrl,
      );
    } else {
      toastification.show(
        context: context,
        title: Text(title),
        description: Text(message),
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.topRight,
      );
    }
  }

  void showError(
    BuildContext context,
    String title,
    String message, {
    ToastStyle? style,
    String? imageUrl,
  }) {
    final effectiveStyle = style ?? _defaultStyle;
    if (effectiveStyle == ToastStyle.system) {
      NotificationInitializer.showNotification(
        id: _generateId(),
        title: title,
        body: message,
        imageUrl: imageUrl,
      );
    } else {
      toastification.show(
        context: context,
        title: Text(title),
        description: Text(message),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.topRight,
      );
    }
  }

  void showWarning(
    BuildContext context,
    String title,
    String message, {
    ToastStyle? style,
    String? imageUrl,
  }) {
    final effectiveStyle = style ?? _defaultStyle;
    if (effectiveStyle == ToastStyle.system) {
      NotificationInitializer.showNotification(
        id: _generateId(),
        title: title,
        body: message,
        imageUrl: imageUrl,
      );
    } else {
      toastification.show(
        context: context,
        title: Text(title),
        description: Text(message),
        type: ToastificationType.warning,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.topRight,
      );
    }
  }

  void showInfo(
    BuildContext context,
    String title,
    String message, {
    ToastStyle? style,
    String? imageUrl,
    bool playSound = true,
    bool enableVibration = true,
    String? customSound,
  }) {
    final effectiveStyle = style ?? _defaultStyle;
    if (effectiveStyle == ToastStyle.system) {
      NotificationInitializer.showNotification(
        id: _generateId(),
        title: title,
        body: message,
        imageUrl: imageUrl,
        enableVibration: enableVibration,
        // If playSound is false, use silent mode
        // If playSound is true and customSound is provided, use custom sound
        // Otherwise use default sound
        playSound: playSound,
        sound: playSound ? customSound : null,
      );
    } else {
      toastification.show(
        context: context,
        title: Text(title),
        description: Text(message),
        type: ToastificationType.info,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.topRight,
      );
    }
  }
}
