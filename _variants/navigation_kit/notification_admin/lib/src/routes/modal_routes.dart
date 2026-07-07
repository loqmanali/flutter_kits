// =============================================================================
// MODAL ROUTES
// =============================================================================
//
// This file provides custom Page implementations for modal-style navigation.
// Use these for dialogs, bottom sheets, and other overlay content that should
// be part of the navigation stack.
//
// BENEFITS OF MODAL ROUTES:
// - Deep-linkable modals
// - Proper back button handling
// - Browser history support (web)
// - Consistent with app navigation
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../adapters/navigator_key_registry.dart';

/// A custom Page that displays content as a dialog
///
/// Usage:
/// ```dart
/// GoRoute(
///   path: '/confirm',
///   pageBuilder: (context, state) => DialogPage(
///     child: ConfirmDialog(),
///   ),
/// )
/// ```
class DialogPage<T> extends Page<T> {
  const DialogPage({
    required this.child,
    this.barrierDismissible = true,
    this.barrierColor = Colors.black54,
    this.barrierLabel,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final bool barrierDismissible;
  final Color barrierColor;
  final String? barrierLabel;

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(
      context: context,
      settings: this,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel,
      builder: (context) => child,
    );
  }
}

/// A custom Page that displays content as a modal bottom sheet
///
/// Usage:
/// ```dart
/// GoRoute(
///   path: '/filters',
///   pageBuilder: (context, state) => BottomSheetPage(
///     child: FilterSheet(),
///   ),
/// )
/// ```
class BottomSheetPage<T> extends Page<T> {
  const BottomSheetPage({
    required this.child,
    this.isScrollControlled = true,
    this.isDismissible = true,
    this.enableDrag = true,
    this.showDragHandle = true,
    this.backgroundColor,
    this.barrierColor = Colors.black54,
    this.constraints,
    this.useSafeArea = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final bool isScrollControlled;
  final bool isDismissible;
  final bool enableDrag;
  final bool showDragHandle;
  final Color? backgroundColor;
  final Color barrierColor;
  final BoxConstraints? constraints;
  final bool useSafeArea;

  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      settings: this,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      backgroundColor: backgroundColor,
      constraints: constraints,
      useSafeArea: useSafeArea,
      builder: (context) => child,
    );
  }
}

/// A custom Page that displays content as a full-screen modal
///
/// This is useful for iOS-style modals that slide up from the bottom.
///
/// Usage:
/// ```dart
/// GoRoute(
///   path: '/edit-profile',
///   pageBuilder: (context, state) => FullScreenModalPage(
///     child: EditProfileScreen(),
///   ),
/// )
/// ```
class FullScreenModalPage<T> extends Page<T> {
  const FullScreenModalPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final bool maintainState;
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    return MaterialPageRoute<T>(
      settings: this,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      builder: (context) => child,
    );
  }
}

/// A custom Page that displays an iOS-style modal sheet
///
/// This creates a modal that appears as a card on top of the current content,
/// similar to iOS 13+ presentation style.
class CupertinoModalPage<T> extends Page<T> {
  const CupertinoModalPage({
    required this.child,
    this.barrierDismissible = true,
    this.previousRouteAnimationCurve = Curves.easeInOut,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final bool barrierDismissible;
  final Curve previousRouteAnimationCurve;

  @override
  Route<T> createRoute(BuildContext context) {
    return _CupertinoModalRoute<T>(
      settings: this,
      child: child,
      barrierDismissible: barrierDismissible,
    );
  }
}

class _CupertinoModalRoute<T> extends PageRoute<T> {
  _CupertinoModalRoute({
    required this.child,
    required this.barrierDismissible,
    required RouteSettings settings,
  }) : super(settings: settings);

  final Widget child;

  @override
  final bool barrierDismissible;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

/// Builder helpers for modal routes
class ModalRouteBuilder {
  ModalRouteBuilder._();

  /// Build a dialog route
  ///
  /// Example:
  /// ```dart
  /// ModalRouteBuilder.dialog(
  ///   path: '/confirm-delete',
  ///   name: 'confirm-delete',
  ///   builder: (context, state) => ConfirmDeleteDialog(
  ///     itemId: state.queryParameters['id'],
  ///   ),
  /// )
  /// ```
  static GoRoute dialog({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
  }) {
    return GoRoute(
      path: path,
      name: name,
      parentNavigatorKey: NavigatorKeyRegistry.instance.rootKey,
      pageBuilder: (context, state) => DialogPage(
        key: state.pageKey,
        name: name,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        child: builder(context, state),
      ),
    );
  }

  /// Build a bottom sheet route
  ///
  /// Example:
  /// ```dart
  /// ModalRouteBuilder.bottomSheet(
  ///   path: '/filters',
  ///   name: 'filters',
  ///   builder: (context, state) => FilterBottomSheet(),
  /// )
  /// ```
  static GoRoute bottomSheet({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    Color? backgroundColor,
    BoxConstraints? constraints,
  }) {
    return GoRoute(
      path: path,
      name: name,
      parentNavigatorKey: NavigatorKeyRegistry.instance.rootKey,
      pageBuilder: (context, state) => BottomSheetPage(
        key: state.pageKey,
        name: name,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        showDragHandle: showDragHandle,
        backgroundColor: backgroundColor,
        constraints: constraints,
        child: builder(context, state),
      ),
    );
  }

  /// Build a full-screen modal route
  ///
  /// Example:
  /// ```dart
  /// ModalRouteBuilder.fullScreenModal(
  ///   path: '/create-post',
  ///   name: 'create-post',
  ///   builder: (context, state) => CreatePostScreen(),
  /// )
  /// ```
  static GoRoute fullScreenModal({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
  }) {
    return GoRoute(
      path: path,
      name: name,
      parentNavigatorKey: NavigatorKeyRegistry.instance.rootKey,
      pageBuilder: (context, state) => FullScreenModalPage(
        key: state.pageKey,
        name: name,
        child: builder(context, state),
      ),
    );
  }

  /// Build an iOS-style modal sheet route
  static GoRoute cupertinoModal({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    bool barrierDismissible = true,
  }) {
    return GoRoute(
      path: path,
      name: name,
      parentNavigatorKey: NavigatorKeyRegistry.instance.rootKey,
      pageBuilder: (context, state) => CupertinoModalPage(
        key: state.pageKey,
        name: name,
        barrierDismissible: barrierDismissible,
        child: builder(context, state),
      ),
    );
  }
}

/// A confirmation dialog that can be used as a route
///
/// Returns true if confirmed, false if cancelled.
///
/// Usage:
/// ```dart
/// final confirmed = await context.push<bool>('/confirm-delete');
/// if (confirmed == true) {
///   // Perform delete
/// }
/// ```
class ConfirmationDialogPage extends StatelessWidget {
  const ConfirmationDialogPage({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () => context.pop(true),
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }
}
