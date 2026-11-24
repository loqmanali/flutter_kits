part of 'adaptive_button.dart';

/// ---------------------------------------------------------------------------
/// AppButtonStyle - the colors one button variant paints with
/// ---------------------------------------------------------------------------
/// A plain value holder. It carries **no defaults of its own**: every variant
/// is derived from the host app's [ColorScheme] by
/// [AppButtonThemeExtension.fromScheme], so the kit never ships a brand color
/// and every app gets its own palette — in light and dark — for free.
/// ---------------------------------------------------------------------------

class AppButtonStyle {
  const AppButtonStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.overlayColor,
    this.borderColor,
    this.elevation = 0.0,
    this.borderSide = BorderSide.none,
  });

  /// Background + foreground pair, with the ripple derived from the
  /// foreground so it stays legible on any background.
  ///
  /// [overlayOpacity] follows Material's state-layer scale: 0.08 for a
  /// pressed container, 0.12 for a bare icon/outline.
  factory AppButtonStyle.pair({
    required Color background,
    required Color foreground,
    double overlayOpacity = 0.08,
    Color? borderColor,
    double elevation = 0.0,
  }) {
    return AppButtonStyle(
      backgroundColor: background,
      foregroundColor: foreground,
      overlayColor: foreground.withValues(alpha: overlayOpacity),
      borderColor: borderColor,
      elevation: elevation,
      borderSide: borderColor == null
          ? BorderSide.none
          : BorderSide(color: borderColor),
    );
  }

  final Color backgroundColor;
  final Color foregroundColor;
  final Color overlayColor;
  final Color? borderColor;
  final double elevation;
  final BorderSide borderSide;
}

/// The colors an [AppButton] actually paints with, after the widget's own
/// overrides are merged over the themed [AppButtonStyle].
class AppButtonColors {
  const AppButtonColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.overlayColor,
    required this.borderSide,
    required this.defaultForeground,
  });
  final Color backgroundColor;
  final Color foregroundColor;
  final Color overlayColor;
  final BorderSide borderSide;
  final Color defaultForeground;
}
