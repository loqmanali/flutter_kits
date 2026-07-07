import 'package:flutter/material.dart';

/// Provides access to the host app's root navigator so the kit can show
/// in-app toasts and navigate on notification taps.
///
/// The host app must supply a [GlobalKey<NavigatorState>] (typically the same
/// one passed to `MaterialApp.navigatorKey` or `GoRouter`'s
/// `navigatorKey`/`rootNavigatorKey`).
class NotificationNavigator {
  NotificationNavigator({
    required this.rootNavigatorKey,
    this.fallbackRoute,
  });

  /// Root navigator key — used to obtain a [BuildContext] from anywhere.
  final GlobalKey<NavigatorState> rootNavigatorKey;

  /// Route to navigate to when a notification is tapped but no deep link
  /// payload is present. If null, no fallback navigation occurs.
  final String? fallbackRoute;

  BuildContext? get currentContext => rootNavigatorKey.currentContext;
}
