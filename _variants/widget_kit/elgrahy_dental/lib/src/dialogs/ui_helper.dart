import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'dialog_picker.dart';

/// Resolves a [SnackBarType] into its (background, foreground) pair.
typedef SnackBarColorResolver = ({Color background, Color foreground}) Function(
  BuildContext context,
  SnackBarType type,
);

/// {@template ui_helper}
/// Utility class for showing bottom sheets, dialogs, snackbars, and toasts
/// with consistent styling.
/// {@endtemplate}
class UIHelper {
  /// Override globally to control the snackbar palette. If left as `null`,
  /// colors are derived from `Theme.of(context).colorScheme`.
  static SnackBarColorResolver? snackBarColorResolver;

  static ({Color background, Color foreground}) _resolveSnackBarColors(
    BuildContext context,
    SnackBarType type,
  ) {
    final resolver = snackBarColorResolver;
    if (resolver != null) return resolver(context, type);

    final scheme = Theme.of(context).colorScheme;
    return switch (type) {
      SnackBarType.normal => (
          background: scheme.primary,
          foreground: scheme.onPrimary,
        ),
      SnackBarType.success => (
          background: const Color(0xFF2E7D32),
          foreground: Colors.white,
        ),
      SnackBarType.error => (
          background: scheme.error,
          foreground: scheme.onError,
        ),
      SnackBarType.warning => (
          background: const Color(0xFFED6C02),
          foreground: Colors.white,
        ),
    };
  }

  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    BottomSheetType type = BottomSheetType.scrollable,
    bool isDismissible = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    bool useRootNavigator = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: type == BottomSheetType.scrollable,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      elevation: elevation,
      useSafeArea: true,
      shape: shape,
      useRootNavigator: useRootNavigator,
      showDragHandle: false,
      builder: (context) => SafeArea(child: child),
    );
  }

  /// Renders a flat, pill-shaped snackbar (used for transient confirmations).
  static void showSnackBarMoveToCart(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveBg = backgroundColor ?? scheme.primary;
    final effectiveFg = textColor ?? scheme.onPrimary;
    final effectiveIcon = iconColor ?? effectiveFg;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: EdgeInsets.zero,
        duration: duration,
        content: Container(
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: effectiveIcon, size: 18),
              const SizedBox(width: 8),
              Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: effectiveFg),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<T?> showDialogPicker<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    Color? backgroundColor,
    EdgeInsets? insetPadding,
    Widget? dialogWidget,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (context) =>
          dialogWidget ??
          DialogPicker(
            backgroundColor: backgroundColor,
            insetPadding: insetPadding,
            child: child,
          ),
    );
  }

  static void showSnackBar(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.normal,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    double? elevation,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    final colors = _resolveSnackBarColors(context, type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: colors.foreground),
        ),
        backgroundColor: colors.background,
        duration: duration,
        action: action,
        elevation: elevation,
        margin: margin,
        padding: padding,
        behavior: behavior,
      ),
    );
  }

  static void showToast({
    String? title,
    String? description,
    Duration duration = const Duration(seconds: 2),
    ToastificationType? type,
    ToastificationStyle? style,
    Alignment? alignment,
    bool applyBlurEffect = false,
    bool showProgressBar = true,
    bool showIcon = false,
    bool closeOnClick = false,
    bool dragToClose = false,
    bool pauseOnHover = true,
    DismissDirection? dismissDirection,
    ui.TextDirection? direction,
    TextStyle? titleStyle,
    ProgressIndicatorThemeData? progressBarTheme =
        const ProgressIndicatorThemeData(
      linearTrackColor: Color(0xFFf4f4f4),
      circularTrackColor: Color(0xFF333333),
      linearMinHeight: 1,
    ),
    CloseButtonShowType? closeButtonShowType = CloseButtonShowType.none,
  }) {
    toastification.show(
      type: type ?? ToastificationType.success,
      style: style ?? ToastificationStyle.flatColored,
      title: title != null ? Text(title, style: titleStyle) : null,
      description: description != null ? Text(description) : null,
      alignment: alignment,
      autoCloseDuration: duration,
      applyBlurEffect: applyBlurEffect,
      showProgressBar: showProgressBar,
      showIcon: showIcon,
      closeOnClick: closeOnClick,
      dragToClose: dragToClose,
      pauseOnHover: pauseOnHover,
      dismissDirection: dismissDirection,
      direction: direction,
      progressBarTheme: progressBarTheme,
      closeButtonShowType: closeButtonShowType,
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

enum BottomSheetType { normal, scrollable }

enum SnackBarType { normal, success, error, warning }

bool isRTL(String languageCode) => ['ar'].contains(languageCode);
