part of 'adaptive_button.dart';

/// Fixed numbers for one [AppButtonSize]: height, type scale, padding, icon.

class AppButtonMetrics {
  const AppButtonMetrics({
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
