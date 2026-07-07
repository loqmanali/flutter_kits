import 'package:flutter/material.dart';

/// App-wide visual defaults for [CustomDropdownMenu] and its rendered items.
///
/// Any field left null is filled in from the ambient [ThemeData] by
/// [DropdownKitThemeData.resolveWith].
class DropdownKitThemeData {
  const DropdownKitThemeData({
    this.panelBackground,
    this.panelBorderColor,
    this.panelBorderRadius,
    this.panelElevation,
    this.itemHoverBackground,
    this.itemSelectedBackground,
    this.itemTextColor,
    this.itemSelectedTextColor,
    this.itemDisabledTextColor,
    this.itemIconColor,
    this.itemSelectedIconColor,
    this.labelTextColor,
    this.separatorColor,
    this.shortcutTextColor,
    this.checkIconColor,
    this.itemPadding,
    this.itemMargin,
    this.itemBorderRadius,
    this.animationDuration,
  });

  final Color? panelBackground;
  final Color? panelBorderColor;
  final double? panelBorderRadius;
  final double? panelElevation;

  final Color? itemHoverBackground;
  final Color? itemSelectedBackground;
  final Color? itemTextColor;
  final Color? itemSelectedTextColor;
  final Color? itemDisabledTextColor;
  final Color? itemIconColor;
  final Color? itemSelectedIconColor;
  final Color? labelTextColor;
  final Color? separatorColor;
  final Color? shortcutTextColor;
  final Color? checkIconColor;

  final EdgeInsetsGeometry? itemPadding;
  final EdgeInsetsGeometry? itemMargin;
  final double? itemBorderRadius;

  final Duration? animationDuration;

  /// Resolves a fully-populated theme against the current [BuildContext]
  /// by filling any null field from a sensible Material default.
  DropdownKitThemeData resolveWith(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DropdownKitThemeData(
      panelBackground: panelBackground ?? scheme.surface,
      panelBorderColor:
          panelBorderColor ?? scheme.outlineVariant.withValues(alpha: 0.6),
      panelBorderRadius: panelBorderRadius ?? 8,
      panelElevation: panelElevation ?? 0,
      itemHoverBackground:
          itemHoverBackground ?? scheme.onSurface.withValues(alpha: 0.04),
      itemSelectedBackground: itemSelectedBackground ??
          scheme.primary.withValues(alpha: 0.08),
      itemTextColor: itemTextColor ?? scheme.onSurface,
      itemSelectedTextColor: itemSelectedTextColor ?? scheme.onSurface,
      itemDisabledTextColor:
          itemDisabledTextColor ?? scheme.onSurface.withValues(alpha: 0.38),
      itemIconColor: itemIconColor ?? scheme.onSurfaceVariant,
      itemSelectedIconColor: itemSelectedIconColor ?? scheme.primary,
      labelTextColor: labelTextColor ?? scheme.onSurface,
      separatorColor:
          separatorColor ?? scheme.outlineVariant.withValues(alpha: 0.6),
      shortcutTextColor: shortcutTextColor ?? scheme.onSurfaceVariant,
      checkIconColor: checkIconColor ?? scheme.primary,
      itemPadding: itemPadding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemMargin: itemMargin ?? const EdgeInsets.symmetric(horizontal: 4),
      itemBorderRadius: itemBorderRadius ?? 4,
      animationDuration:
          animationDuration ?? const Duration(milliseconds: 150),
    );
  }
}

/// Inherited widget that exposes [DropdownKitThemeData] to the subtree.
class DropdownKitTheme extends InheritedWidget {
  const DropdownKitTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final DropdownKitThemeData data;

  static DropdownKitThemeData of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<DropdownKitTheme>();
    return (inherited?.data ?? const DropdownKitThemeData())
        .resolveWith(context);
  }

  @override
  bool updateShouldNotify(DropdownKitTheme oldWidget) =>
      oldWidget.data != data;
}
