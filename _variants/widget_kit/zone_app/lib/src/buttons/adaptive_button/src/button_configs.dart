part of '../adaptive_button.dart';

/// ---------------------------------------------------------------------------
/// Helper Classes
/// ---------------------------------------------------------------------------

class ButtonSizeConfig {
  const ButtonSizeConfig({
    required this.height,
    required this.fontSize,
    required this.fontWeight,
    required this.padding,
    required this.iconSize,
  });
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets padding;
  final double iconSize;
}

class ButtonTypeConfig {
  const ButtonTypeConfig({
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
