import 'package:flutter/material.dart';

/// Inherits app-wide defaults for selection widgets.
///
/// Per-widget properties always win over the inherited theme. If no
/// [SelectionKitTheme] is present in the tree, [SelectionKitThemeData.fallback]
/// is used.
class SelectionKitTheme extends InheritedWidget {
  const SelectionKitTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final SelectionKitThemeData data;

  static SelectionKitThemeData of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<SelectionKitTheme>();
    return inherited?.data ?? const SelectionKitThemeData();
  }

  @override
  bool updateShouldNotify(SelectionKitTheme oldWidget) =>
      !identical(data, oldWidget.data);
}

@immutable
class SelectionKitThemeData {
  const SelectionKitThemeData({
    this.selectedColor,
    this.unselectedColor,
    this.borderColor,
    this.selectedBorderColor,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.borderRadius = 8.0,
    this.borderWidth = 1.0,
    this.selectedBorderWidth = 2.0,
    this.contentPadding = const EdgeInsets.all(12.0),
    this.indicatorSize = 20.0,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.showBorder = true,
    this.showBackground = true,
    this.dense = false,
    this.showRipple = true,
    this.titleStyle,
    this.subtitleStyle,
    this.descriptionStyle,
    this.labelStyle,
    this.errorStyle,
    this.helperStyle,
  });

  // Colors
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? borderColor;
  final Color? selectedBorderColor;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;

  // Shape
  final double borderRadius;
  final double borderWidth;
  final double selectedBorderWidth;
  final EdgeInsetsGeometry contentPadding;
  final double indicatorSize;

  // Spacing
  final double spacing;
  final double runSpacing;

  // Animation
  final Duration animationDuration;

  // Behavior
  final bool showBorder;
  final bool showBackground;
  final bool dense;
  final bool showRipple;

  // Text
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? descriptionStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;

  SelectionKitThemeData copyWith({
    Color? selectedColor,
    Color? unselectedColor,
    Color? borderColor,
    Color? selectedBorderColor,
    Color? backgroundColor,
    Color? selectedBackgroundColor,
    double? borderRadius,
    double? borderWidth,
    double? selectedBorderWidth,
    EdgeInsetsGeometry? contentPadding,
    double? indicatorSize,
    double? spacing,
    double? runSpacing,
    Duration? animationDuration,
    bool? showBorder,
    bool? showBackground,
    bool? dense,
    bool? showRipple,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    TextStyle? descriptionStyle,
    TextStyle? labelStyle,
    TextStyle? errorStyle,
    TextStyle? helperStyle,
  }) {
    return SelectionKitThemeData(
      selectedColor: selectedColor ?? this.selectedColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      borderColor: borderColor ?? this.borderColor,
      selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      selectedBorderWidth: selectedBorderWidth ?? this.selectedBorderWidth,
      contentPadding: contentPadding ?? this.contentPadding,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      spacing: spacing ?? this.spacing,
      runSpacing: runSpacing ?? this.runSpacing,
      animationDuration: animationDuration ?? this.animationDuration,
      showBorder: showBorder ?? this.showBorder,
      showBackground: showBackground ?? this.showBackground,
      dense: dense ?? this.dense,
      showRipple: showRipple ?? this.showRipple,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      descriptionStyle: descriptionStyle ?? this.descriptionStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      errorStyle: errorStyle ?? this.errorStyle,
      helperStyle: helperStyle ?? this.helperStyle,
    );
  }
}
