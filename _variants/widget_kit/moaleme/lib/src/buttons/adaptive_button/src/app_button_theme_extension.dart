part of '../adaptive_button.dart';

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

  /// Default button styles using const values
  ///
  /// This provides a fallback when no theme extension is registered.
  /// The const values ensure optimal performance while the extension
  /// enables hot reload support when overridden in the theme.
  static const defaults = AppButtonThemeExtension(
    filled: AppButtonStyle.filled,
    filledTonal: AppButtonStyle.filledTonal,
    elevated: AppButtonStyle.elevated,
    outlined: AppButtonStyle.outlined,
    text: AppButtonStyle.text,
    icon: AppButtonStyle.icon,
    iconFilled: AppButtonStyle.iconFilled,
    iconFilledTonal: AppButtonStyle.iconFilledTonal,
    iconOutlined: AppButtonStyle.iconOutlined,
    fab: AppButtonStyle.fab,
  );

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

  /// Get the button theme extension from the current context
  ///
  /// Returns the registered theme extension or falls back to defaults.
  /// This ensures hot reload works even when no custom theme is set.
  static AppButtonThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<AppButtonThemeExtension>() ??
        AppButtonThemeExtension.defaults;
  }

  /// Get a specific button style by type
  ///
  /// This provides a convenient way to access button styles
  /// while maintaining the benefits of ThemeExtension.
  AppButtonStyle getStyle(AppButtonStyleType type) {
    switch (type) {
      case AppButtonStyleType.filled:
        return filled;
      case AppButtonStyleType.filledTonal:
        return filledTonal;
      case AppButtonStyleType.elevated:
        return elevated;
      case AppButtonStyleType.outlined:
        return outlined;
      case AppButtonStyleType.text:
        return text;
      case AppButtonStyleType.icon:
        return icon;
      case AppButtonStyleType.iconFilled:
        return iconFilled;
      case AppButtonStyleType.iconFilledTonal:
        return iconFilledTonal;
      case AppButtonStyleType.iconOutlined:
        return iconOutlined;
      case AppButtonStyleType.fab:
        return fab;
    }
  }
}
