import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'system_ui_kit.dart';

/// Paints the top safe area and syncs the platform status bar overlay.
///
/// Use this around custom app bars or top headers when the status bar should
/// visually share the same background color as the header.
class StatusBarColorScope extends StatelessWidget {
  /// Creates a status-bar-aware top surface.
  const StatusBarColorScope({
    super.key,
    required this.color,
    required this.child,
    this.themeBrightness,
    this.overlayStyle,
    this.navigationBarColor,
    this.navigationBarIconBrightness,
    this.paintTopSafeArea = true,
    this.applySystemOverlayStyle = true,
    this.transparentStatusBar = true,
  });

  /// The color painted behind the status bar and used for icon contrast.
  final Color color;

  /// The content below the status bar.
  ///
  /// When wrapping a Flutter [AppBar], set `primary: false` on that [AppBar]
  /// to avoid applying top safe-area padding twice.
  final Widget child;

  /// The app brightness used when [color] is transparent.
  final Brightness? themeBrightness;

  /// An already-built overlay style.
  ///
  /// When omitted, the style is derived from [color].
  final SystemUiOverlayStyle? overlayStyle;

  /// Android navigation bar color.
  final Color? navigationBarColor;

  /// Android navigation bar icon brightness.
  final Brightness? navigationBarIconBrightness;

  /// Whether to paint the top safe area with [color].
  final bool paintTopSafeArea;

  /// Whether to call [SystemChrome.setSystemUIOverlayStyle] after build.
  final bool applySystemOverlayStyle;

  /// Whether the platform status bar should be transparent.
  ///
  /// Keep this enabled when [paintTopSafeArea] is true so Flutter paints the
  /// visible background. Disable it if the platform should draw [color] itself.
  final bool transparentStatusBar;

  @override
  Widget build(BuildContext context) {
    final resolvedBrightness =
        themeBrightness ?? Theme.of(context).colorScheme.brightness;
    final resolvedOverlay = overlayStyle ??
        SystemUiKit.overlayForColor(
          color,
          themeBrightness: resolvedBrightness,
          statusBarColor: transparentStatusBar ? Colors.transparent : color,
          navigationBarColor: navigationBarColor,
          navigationBarIconBrightness: navigationBarIconBrightness,
        );

    if (applySystemOverlayStyle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SystemChrome.setSystemUIOverlayStyle(resolvedOverlay);
      });
    }

    final annotatedChild = AnnotatedRegion<SystemUiOverlayStyle>(
      value: resolvedOverlay,
      child: child,
    );

    if (!paintTopSafeArea) {
      return annotatedChild;
    }

    return ColoredBox(
      color: color,
      child: SafeArea(
        bottom: false,
        child: annotatedChild,
      ),
    );
  }
}
