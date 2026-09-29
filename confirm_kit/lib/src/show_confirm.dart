import 'package:flutter/material.dart';

import 'confirm_dialog.dart';
import 'confirm_enums.dart';
import 'confirm_kit_theme.dart';

/// Presentation helpers: the dialog carries its own [ConfirmSurface], so one
/// call site works for dialogs and sheets alike.
extension ConfirmDialogPresentation<T> on ConfirmDialog<T> {
  /// Shows the confirmation and resolves with the pressed action's result, or
  /// `null` when it was dismissed.
  ///
  /// ```dart
  /// final choice = await ConfirmDialog<SaveChoice>(
  ///   title: 'Unsaved changes',
  ///   surface: ConfirmSurface.sheet,
  ///   actions: [...],
  /// ).show(context);
  /// ```
  Future<T?> show(
    BuildContext context, {
    bool useRootNavigator = true,
    bool useSafeArea = true,
    Color? barrierColor,
    RouteSettings? routeSettings,
  }) {
    if (surface == ConfirmSurface.sheet) {
      final width = maxWidth ?? ConfirmKitTheme.of(context).maxWidth!;
      return showModalBottomSheet<T>(
        context: context,
        isDismissible: dismissible,
        enableDrag: dismissible,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: barrierColor,
        useRootNavigator: useRootNavigator,
        useSafeArea: useSafeArea,
        routeSettings: routeSettings,
        constraints: BoxConstraints(maxWidth: width),
        builder: (_) => this,
      );
    }

    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      useSafeArea: useSafeArea,
      routeSettings: routeSettings,
      builder: (_) => this,
    );
  }

  /// [show] narrowed to the yes/no case: `true` only when the confirm action
  /// was pressed, `false` for cancel *and* for a dismissal.
  ///
  /// ```dart
  /// if (await const ConfirmDialog(
  ///   title: 'Log out?',
  ///   intent: ConfirmIntent.destructive,
  /// ).ask(context)) {
  ///   await auth.logout();
  /// }
  /// ```
  Future<bool> ask(
    BuildContext context, {
    bool useRootNavigator = true,
    bool useSafeArea = true,
    Color? barrierColor,
    RouteSettings? routeSettings,
  }) async {
    final result = await show(
      context,
      useRootNavigator: useRootNavigator,
      useSafeArea: useSafeArea,
      barrierColor: barrierColor,
      routeSettings: routeSettings,
    );
    return result == true;
  }
}
