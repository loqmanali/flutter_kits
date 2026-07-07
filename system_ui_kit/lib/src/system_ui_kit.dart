import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Builds and applies system UI overlay styles from Flutter colors.
class SystemUiKit {
  const SystemUiKit._();

  /// Creates an overlay style whose status bar icons contrast with [color].
  ///
  /// [themeBrightness] is used when [color] is transparent, because Flutter
  /// cannot infer the brightness of the content behind a transparent pixel.
  static SystemUiOverlayStyle overlayForColor(
    Color color, {
    required Brightness themeBrightness,
    Color? statusBarColor,
    Color? navigationBarColor,
    Brightness? navigationBarIconBrightness,
    bool enforceStatusBarContrast = false,
    bool enforceNavigationBarContrast = false,
  }) {
    final backgroundBrightness = color.a == 0
        ? themeBrightness
        : ThemeData.estimateBrightnessForColor(color);
    final statusIconBrightness = backgroundBrightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;
    final resolvedNavigationBarColor = navigationBarColor ??
        (themeBrightness == Brightness.dark ? Colors.black : Colors.white);
    final resolvedNavigationBarIconBrightness = navigationBarIconBrightness ??
        (themeBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);

    return SystemUiOverlayStyle(
      statusBarColor: statusBarColor ?? color,
      statusBarIconBrightness: statusIconBrightness,
      statusBarBrightness: statusIconBrightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      systemStatusBarContrastEnforced: enforceStatusBarContrast,
      systemNavigationBarColor: resolvedNavigationBarColor,
      systemNavigationBarIconBrightness: resolvedNavigationBarIconBrightness,
      systemNavigationBarContrastEnforced: enforceNavigationBarContrast,
    );
  }

  /// Applies the overlay style for [color] immediately.
  static void applyColor(
    Color color, {
    required Brightness themeBrightness,
    Color? statusBarColor,
    Color? navigationBarColor,
    Brightness? navigationBarIconBrightness,
    bool enforceStatusBarContrast = false,
    bool enforceNavigationBarContrast = false,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      overlayForColor(
        color,
        themeBrightness: themeBrightness,
        statusBarColor: statusBarColor,
        navigationBarColor: navigationBarColor,
        navigationBarIconBrightness: navigationBarIconBrightness,
        enforceStatusBarContrast: enforceStatusBarContrast,
        enforceNavigationBarContrast: enforceNavigationBarContrast,
      ),
    );
  }
}
