import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../config/widget_kit_config.dart';
import 'dialog_picker.dart';

/// {@template ui_helper}
/// Utility class for showing bottom sheets, dialogs, snackbars, and toasts
/// with consistent styling.
/// {@endtemplate}
class UIHelper {
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    BottomSheetType type = BottomSheetType.scrollable,
    bool? isDismissible,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    bool? useRootNavigator,
    bool? useSafeArea,
    bool showDragHandle = false,
  }) {
    // Resolution: call-site arg > WidgetKitBehavior > built-in default.
    final behavior = WidgetKitScope.of(context).behavior;
    final safeArea = useSafeArea ?? behavior.bottomSheetUseSafeArea ?? false;
    final dismissible =
        isDismissible ?? behavior.bottomSheetIsDismissible ?? true;
    final rootNavigator = useRootNavigator ?? behavior.useRootNavigator ?? true;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: type == BottomSheetType.scrollable,
      isDismissible: dismissible,
      backgroundColor: backgroundColor,
      elevation: elevation,
      useSafeArea: safeArea,
      shape: shape,
      useRootNavigator: rootNavigator,
      showDragHandle: showDragHandle,
      builder: (context) =>
          safeArea ? SafeArea(top: false, child: child) : child,
    );
  }

  /// Confirmation for an add-to-cart / move-to-cart. Backed by [showToast] as a
  /// success toast — the `context`, [icon], and colour params are accepted for
  /// source compatibility but no longer used. Requires a [ToastificationWrapper]
  /// above the app.
  static void showSnackBarMoveToCart(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    showToast(
      title: message,
      type: ToastificationType.success,
      duration: duration,
    );
  }

  static Future<T?> showDialogPicker<T>(
    BuildContext context, {
    required Widget child,
    bool? barrierDismissible,
    Color? barrierColor,
    Color? backgroundColor,
    EdgeInsets? insetPadding,
    Widget? dialogWidget,
  }) {
    final behavior = WidgetKitScope.of(context).behavior;
    final dismissible =
        barrierDismissible ?? behavior.dialogBarrierDismissible ?? true;
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
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

  /// Maps the legacy [SnackBarType] palette onto a [ToastificationType], so
  /// callers that still pass a snackbar type get the matching toast colour.
  static ToastificationType _toastTypeFor(SnackBarType type) => switch (type) {
        SnackBarType.success => ToastificationType.success,
        SnackBarType.error => ToastificationType.error,
        SnackBarType.warning => ToastificationType.warning,
        SnackBarType.normal => ToastificationType.info,
      };

  /// Shows a transient message. Backed by [showToast] (toastification) — the
  /// `context` and snackbar-only styling params ([action], [elevation],
  /// [margin], [padding], [behavior]) are accepted for source compatibility but
  /// no longer used. Requires a [ToastificationWrapper] above the app.
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
    showToast(
      title: message,
      type: _toastTypeFor(type),
      duration: duration,
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
    // A toast is never critical to a flow — if no `ToastificationWrapper` is
    // mounted above the app (e.g. an isolated widget test, or a screen rendered
    // outside the app shell), swallow the error instead of crashing the caller.
    try {
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
        closeButton: ToastCloseButton(
          showType: closeButtonShowType ?? CloseButtonShowType.none,
        ),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    } catch (_) {
      // No toast host available — silently skip.
    }
  }
}

enum BottomSheetType { normal, scrollable }

enum SnackBarType { normal, success, error, warning }

bool isRTL(String languageCode) => ['ar'].contains(languageCode);
