part of 'adaptive_button.dart';

/// Turns an [AppButton]'s properties plus the ambient theme into the concrete
/// numbers and colors the framework buttons need.
///
/// Pure and cheap to build — no state of its own — so the widget can create one
/// per build. It lives apart from `_AppButtonState` because "what this button
/// should look like" and "what happens when you press it" are two jobs, and
/// only the first one is worth testing without pumping a button.
@immutable
class AppButtonResolver {
  const AppButtonResolver(this.button, this.context);

  final AppButton button;
  final BuildContext context;

  /// True for the four icon-only variants, which hug their content and take
  /// their padding from [IconButton] rather than the size table.
  bool get isIconButton =>
      button.style == AppButtonVariant.icon ||
      button.style == AppButtonVariant.iconFilled ||
      button.style == AppButtonVariant.iconFilledTonal ||
      button.style == AppButtonVariant.iconOutlined;

  AppButtonWidthMode get widthMode {
    if (button.widthMode != null) return button.widthMode!;
    if (isIconButton) return AppButtonWidthMode.hug;
    return AppButtonWidthMode.fill;
  }

  AppIconAlignment get iconAlignment {
    if (button.iconAlignment != null) return button.iconAlignment!;

    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return isRTL ? AppIconAlignment.end : AppIconAlignment.start;
  }

  Color get foregroundColor {
    if (button.foregroundColor != null) return button.foregroundColor!;

    // Get button style from theme extension for hot reload support
    final buttonTheme = AppButtonThemeExtension.of(context);
    final style = buttonTheme.getStyle(button.style);

    return style.foregroundColor;
  }

  AppButtonMetrics get metrics {
    switch (button.size) {
      case AppButtonSize.large:
        return const AppButtonMetrics(
          height: 56.0,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          iconSize: 24.0,
        );
      case AppButtonSize.medium:
        return const AppButtonMetrics(
          height: 48.0,
          fontSize: 14.0,
          //fontWeight: FontWeight.w500,
          fontWeight: FontWeight.w600,
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          iconSize: 20.0,
        );
      case AppButtonSize.small:
        return const AppButtonMetrics(
          height: 32.0,
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          // fontWeight: FontWeight.w500,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          iconSize: 18.0,
        );
    }
  }

  AppButtonColors get colors {
    final buttonTheme = AppButtonThemeExtension.of(context);
    final style = buttonTheme.getStyle(button.style);

    return AppButtonColors(
      backgroundColor: button.backgroundColor ?? style.backgroundColor,
      foregroundColor: button.foregroundColor ?? style.foregroundColor,
      overlayColor: style.overlayColor,
      borderSide: button.borderColor != null
          ? BorderSide(color: button.borderColor!)
          : style.borderSide,
      defaultForeground: style.foregroundColor,
    );
  }

  ButtonStyle get buttonStyle {
    final size = metrics;
    final t = colors;
    final scheme = Theme.of(context).colorScheme;

    final disabledFg = button.disabledForegroundColor ??
        scheme.onSurface.withValues(alpha: 0.38);
    final disabledBg = button.disabledBackgroundColor ??
        scheme.onSurface.withValues(alpha: 0.12);

    final radius = button.borderRadius ?? 8.0;
    final shape = button.shape is OutlinedBorder
        ? button.shape as OutlinedBorder
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          );

    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        Size(
          widthMode == AppButtonWidthMode.fill ? double.infinity : 0,
          size.height,
        ),
      ),
      padding: WidgetStateProperty.all(
        button.customPadding ?? size.padding,
      ),
      shape: WidgetStateProperty.all(shape),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return disabledBg;
        return t.backgroundColor;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return disabledFg;
        return t.foregroundColor;
      }),
      iconColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return disabledFg;
        return button.iconColor ?? t.foregroundColor;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return t.overlayColor;
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (button.style == AppButtonVariant.outlined ||
            button.style == AppButtonVariant.iconOutlined) {
          final disabledSide = BorderSide(
            color: scheme.outline.withValues(alpha: 0.12),
          );
          return states.contains(WidgetState.disabled)
              ? disabledSide
              : t.borderSide;
        }
        return t.borderSide;
      }),
      elevation: WidgetStateProperty.resolveWith((states) {
        final base = (button.elevation ?? 0).toDouble();
        if (button.style == AppButtonVariant.filled ||
            button.style == AppButtonVariant.elevated) {
          if (states.contains(WidgetState.disabled)) return 0;
          if (states.contains(WidgetState.pressed)) {
            return button.style == AppButtonVariant.elevated
                ? base + 2
                : base + 1;
          }
          if (states.contains(WidgetState.hovered)) {
            return button.style == AppButtonVariant.elevated ? base + 2 : base;
          }
          return base;
        }
        return 0;
      }),
      shadowColor: button.shadowColor != null
          ? WidgetStateProperty.all(button.shadowColor)
          : null,
      surfaceTintColor: button.surfaceTintColor != null
          ? WidgetStateProperty.all(button.surfaceTintColor)
          : null,
      textStyle: WidgetStateProperty.all(
        button.textStyle ??
            TextStyle(
              fontSize: size.fontSize,
              fontWeight: size.fontWeight,
            ),
      ),
      alignment: Alignment.center,
    );
  }
}
