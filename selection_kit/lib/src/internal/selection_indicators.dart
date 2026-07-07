import 'package:flutter/material.dart';

/// Signature for a custom selection indicator. The first argument is whether
/// the option is currently selected; the second is whether it is enabled.
typedef SelectionIndicatorBuilder = Widget Function(
  bool selected,
  bool enabled,
);

/// Default radio-style indicator: an outlined circle with an animated inner dot.
class RadioIndicator extends StatelessWidget {
  const RadioIndicator({
    super.key,
    required this.selected,
    required this.enabled,
    required this.size,
    required this.color,
    required this.animationDuration,
  });

  final bool selected;
  final bool enabled;
  final double size;
  final Color color;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final effective = enabled ? color : color.withValues(alpha: 0.38);
    return AnimatedContainer(
      duration: animationDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: effective, width: selected ? 2.5 : 2),
      ),
      child: selected
          ? Center(
              child: AnimatedContainer(
                duration: animationDuration,
                width: size * 0.45,
                height: size * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: effective,
                ),
              ),
            )
          : null,
    );
  }
}

/// Default checkbox-style indicator: a rounded square that fills with the
/// selected color and shows a check icon.
class CheckboxIndicator extends StatelessWidget {
  const CheckboxIndicator({
    super.key,
    required this.selected,
    required this.enabled,
    required this.size,
    required this.color,
    required this.unselectedColor,
    required this.animationDuration,
    this.cornerRadius = 4.0,
    this.checkColor,
  });

  final bool selected;
  final bool enabled;
  final double size;
  final Color color;
  final Color unselectedColor;
  final Duration animationDuration;
  final double cornerRadius;
  final Color? checkColor;

  @override
  Widget build(BuildContext context) {
    final fill = enabled ? color : color.withValues(alpha: 0.38);
    final border =
        enabled ? unselectedColor : unselectedColor.withValues(alpha: 0.38);
    return AnimatedContainer(
      duration: animationDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected ? fill : Colors.transparent,
        borderRadius: BorderRadius.circular(cornerRadius),
        border: Border.all(color: selected ? fill : border, width: 2),
      ),
      child: selected
          ? Icon(
              Icons.check_rounded,
              size: size * 0.75,
              color: checkColor ?? Colors.white,
            )
          : null,
    );
  }
}
