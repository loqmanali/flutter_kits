part of 'adaptive_button.dart';

/// ---------------------------------------------------------------------------
/// AppButtonThemeExtension - Theme Extension for Button Styles
/// ---------------------------------------------------------------------------
/// Provides theme-aware button styles that support hot reload.
/// All button styles are resolved at runtime from the theme, allowing
/// instant style updates without hot restart.
/// ---------------------------------------------------------------------------

class AppButtonThemeExtension extends ThemeExtension<AppButtonThemeExtension> {
  final AppButtonStyle filled;
  final AppButtonStyle filledTonal;
  final AppButtonStyle elevated;
  final AppButtonStyle outlined;
  final AppButtonStyle text;
  final AppButtonStyle icon;
  final AppButtonStyle iconFilled;
  final AppButtonStyle iconFilledTonal;
  final AppButtonStyle iconOutlined;
  final AppButtonStyle fab;

  const AppButtonThemeExtension({
    required this.filled,
    required this.filledTonal,
    required this.elevated,
    required this.outlined,
    required this.text,
    required this.icon,
    required this.iconFilled,
    required this.iconFilledTonal,
    required this.iconOutlined,
    required this.fab,
  });

  /// Every variant derived from a [ColorScheme].
  ///
  /// This is the fallback when the host app registers no extension, which is
  /// why the kit needs no palette of its own: `filled` is the app's primary,
  /// `filledTonal` its secondary, `icon` its `onSurfaceVariant`, and so on.
  /// Light and dark follow automatically because the scheme does.
  factory AppButtonThemeExtension.fromScheme(ColorScheme scheme) {
    return AppButtonThemeExtension(
      filled: AppButtonStyle.pair(
        background: scheme.primary,
        foreground: scheme.onPrimary,
      ),
      filledTonal: AppButtonStyle.pair(
        background: scheme.secondary,
        foreground: scheme.onSecondary,
      ),
      elevated: AppButtonStyle.pair(
        background: scheme.surface,
        foreground: scheme.primary,
        elevation: 1.0,
      ),
      outlined: AppButtonStyle.pair(
        background: Colors.transparent,
        foreground: scheme.primary,
        borderColor: scheme.primary,
      ),
      text: AppButtonStyle.pair(
        background: Colors.transparent,
        foreground: scheme.primary,
      ),
      icon: AppButtonStyle.pair(
        background: Colors.transparent,
        foreground: scheme.onSurfaceVariant,
        overlayOpacity: 0.12,
      ),
      iconFilled: AppButtonStyle.pair(
        background: scheme.primary,
        foreground: scheme.onPrimary,
        overlayOpacity: 0.12,
      ),
      iconFilledTonal: AppButtonStyle.pair(
        background: scheme.secondary,
        foreground: scheme.onSecondary,
        overlayOpacity: 0.12,
      ),
      iconOutlined: AppButtonStyle.pair(
        background: Colors.transparent,
        foreground: scheme.onSurfaceVariant,
        overlayOpacity: 0.12,
        borderColor: scheme.outlineVariant,
      ),
      fab: AppButtonStyle.pair(
        background: scheme.secondary,
        foreground: scheme.onSecondary,
        elevation: 3.0,
      ),
    );
  }

  @override
  ThemeExtension<AppButtonThemeExtension> copyWith({
    AppButtonStyle? filled,
    AppButtonStyle? filledTonal,
    AppButtonStyle? elevated,
    AppButtonStyle? outlined,
    AppButtonStyle? text,
    AppButtonStyle? icon,
    AppButtonStyle? iconFilled,
    AppButtonStyle? iconFilledTonal,
    AppButtonStyle? iconOutlined,
    AppButtonStyle? fab,
  }) {
    return AppButtonThemeExtension(
      filled: filled ?? this.filled,
      filledTonal: filledTonal ?? this.filledTonal,
      elevated: elevated ?? this.elevated,
      outlined: outlined ?? this.outlined,
      text: text ?? this.text,
      icon: icon ?? this.icon,
      iconFilled: iconFilled ?? this.iconFilled,
      iconFilledTonal: iconFilledTonal ?? this.iconFilledTonal,
      iconOutlined: iconOutlined ?? this.iconOutlined,
      fab: fab ?? this.fab,
    );
  }

  @override
  ThemeExtension<AppButtonThemeExtension> lerp(
    ThemeExtension<AppButtonThemeExtension>? other,
    double t,
  ) {
    if (other is! AppButtonThemeExtension) return this;

    return AppButtonThemeExtension(
      filled: _lerpButtonStyle(filled, other.filled, t),
      filledTonal: _lerpButtonStyle(filledTonal, other.filledTonal, t),
      elevated: _lerpButtonStyle(elevated, other.elevated, t),
      outlined: _lerpButtonStyle(outlined, other.outlined, t),
      text: _lerpButtonStyle(text, other.text, t),
      icon: _lerpButtonStyle(icon, other.icon, t),
      iconFilled: _lerpButtonStyle(iconFilled, other.iconFilled, t),
      iconFilledTonal:
          _lerpButtonStyle(iconFilledTonal, other.iconFilledTonal, t),
      iconOutlined: _lerpButtonStyle(iconOutlined, other.iconOutlined, t),
      fab: _lerpButtonStyle(fab, other.fab, t),
    );
  }

  /// Helper method to lerp between two AppButtonStyle instances
  AppButtonStyle _lerpButtonStyle(
    AppButtonStyle a,
    AppButtonStyle b,
    double t,
  ) {
    return AppButtonStyle(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t) ??
          a.backgroundColor,
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t) ??
          a.foregroundColor,
      overlayColor:
          Color.lerp(a.overlayColor, b.overlayColor, t) ?? a.overlayColor,
      borderColor: Color.lerp(a.borderColor, b.borderColor, t) ?? a.borderColor,
      elevation: ui.lerpDouble(a.elevation, b.elevation, t) ?? a.elevation,
      borderSide: BorderSide.lerp(a.borderSide, b.borderSide, t),
    );
  }

  /// Get the button theme extension from the current context.
  ///
  /// Returns the registered extension, or one derived from the ambient
  /// [ColorScheme] — so an app that registers nothing still gets buttons in
  /// its own colors, correct in light and dark.
  static AppButtonThemeExtension of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppButtonThemeExtension>() ??
        AppButtonThemeExtension.fromScheme(theme.colorScheme);
  }

  /// Get a specific button style by type
  ///
  /// This provides a convenient way to access button styles
  /// while maintaining the benefits of ThemeExtension.
  AppButtonStyle getStyle(AppButtonVariant type) {
    switch (type) {
      case AppButtonVariant.filled:
        return filled;
      case AppButtonVariant.filledTonal:
        return filledTonal;
      case AppButtonVariant.elevated:
        return elevated;
      case AppButtonVariant.outlined:
        return outlined;
      case AppButtonVariant.text:
        return text;
      case AppButtonVariant.icon:
        return icon;
      case AppButtonVariant.iconFilled:
        return iconFilled;
      case AppButtonVariant.iconFilledTonal:
        return iconFilledTonal;
      case AppButtonVariant.iconOutlined:
        return iconOutlined;
      case AppButtonVariant.fab:
        return fab;
    }
  }
}
