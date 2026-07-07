import 'package:flutter/widgets.dart';

/// Position of the page indicator relative to the carousel.
enum IndicatorPosition {
  /// Indicator overlays the bottom of the carousel content.
  overlay,

  /// Indicator appears below the carousel content.
  below,

  /// Indicator appears above the carousel content.
  above,

  /// Indicator is hidden.
  none,
}

/// Shape of individual indicator dots.
enum IndicatorShape {
  /// Circular dots.
  circle,

  /// Rounded rectangle (pill shape).
  pill,

  /// Square dots.
  square,

  /// Custom shape (use with customBuilder).
  custom,
}

/// Animation effect for indicator transitions.
enum IndicatorEffect {
  /// Simple dot effect - just changes color.
  dot,

  /// Worm effect - active indicator stretches between dots.
  worm,

  /// Expanding effect - active dot expands.
  expanding,

  /// Jumping effect - active dot jumps.
  jumping,

  /// Scrolling effect - dots scroll with content.
  scrolling,

  /// Swap effect - active and inactive dots swap places.
  swap,
}

/// Configuration for the carousel page indicator.
///
/// Use this class to customize the appearance and behavior of the
/// page indicator dots.
class IndicatorConfig {
  /// Whether to show the indicator.
  final bool show;

  /// Position of the indicator.
  final IndicatorPosition position;

  /// Shape of indicator dots.
  final IndicatorShape shape;

  /// Animation effect for transitions.
  final IndicatorEffect effect;

  /// Width of active indicator dot.
  final double activeWidth;

  /// Height of active indicator dot.
  final double activeHeight;

  /// Width of inactive indicator dots.
  final double inactiveWidth;

  /// Height of inactive indicator dots.
  final double inactiveHeight;

  /// Spacing between dots.
  final double spacing;

  /// Color of active indicator dot.
  final Color activeColor;

  /// Color of inactive indicator dots.
  final Color inactiveColor;

  /// Border radius for pill/square shapes.
  final double borderRadius;

  /// Margin from carousel edge (depends on position).
  final double margin;

  /// Padding around the indicator container.
  final EdgeInsets padding;

  /// Animation duration for indicator transitions.
  final Duration animationDuration;

  /// Animation curve for indicator transitions.
  final Curve animationCurve;

  /// Alignment of the indicator within its container.
  final MainAxisAlignment alignment;

  /// Custom builder for indicator dots (used with IndicatorShape.custom).
  final Widget Function(int index, bool isActive)? customBuilder;

  const IndicatorConfig({
    this.show = true,
    this.position = IndicatorPosition.below,
    this.shape = IndicatorShape.circle,
    this.effect = IndicatorEffect.dot,
    this.activeWidth = 8.0,
    this.activeHeight = 8.0,
    this.inactiveWidth = 8.0,
    this.inactiveHeight = 8.0,
    this.spacing = 8.0,
    this.activeColor = const Color(0xFFD96B77),
    this.inactiveColor = const Color(0xFFF5D2D7),
    this.borderRadius = 4.0,
    this.margin = 12.0,
    this.padding = EdgeInsets.zero,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.alignment = MainAxisAlignment.center,
    this.customBuilder,
  });

  /// Creates a copy with the given fields replaced.
  IndicatorConfig copyWith({
    bool? show,
    IndicatorPosition? position,
    IndicatorShape? shape,
    IndicatorEffect? effect,
    double? activeWidth,
    double? activeHeight,
    double? inactiveWidth,
    double? inactiveHeight,
    double? spacing,
    Color? activeColor,
    Color? inactiveColor,
    double? borderRadius,
    double? margin,
    EdgeInsets? padding,
    Duration? animationDuration,
    Curve? animationCurve,
    MainAxisAlignment? alignment,
    Widget Function(int index, bool isActive)? customBuilder,
  }) {
    return IndicatorConfig(
      show: show ?? this.show,
      position: position ?? this.position,
      shape: shape ?? this.shape,
      effect: effect ?? this.effect,
      activeWidth: activeWidth ?? this.activeWidth,
      activeHeight: activeHeight ?? this.activeHeight,
      inactiveWidth: inactiveWidth ?? this.inactiveWidth,
      inactiveHeight: inactiveHeight ?? this.inactiveHeight,
      spacing: spacing ?? this.spacing,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      borderRadius: borderRadius ?? this.borderRadius,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      alignment: alignment ?? this.alignment,
      customBuilder: customBuilder ?? this.customBuilder,
    );
  }

  /// Preset: Small circular dots.
  static const smallDots = IndicatorConfig(
    activeWidth: 6.0,
    activeHeight: 6.0,
    inactiveWidth: 6.0,
    inactiveHeight: 6.0,
    spacing: 6.0,
  );

  /// Preset: Medium circular dots.
  static const mediumDots = IndicatorConfig();

  /// Preset: Large circular dots.
  static const largeDots = IndicatorConfig(
    activeWidth: 12.0,
    activeHeight: 12.0,
    inactiveWidth: 12.0,
    inactiveHeight: 12.0,
    spacing: 10.0,
  );

  /// Preset: Pill-shaped indicator (active dot is wider).
  static const pill = IndicatorConfig(
    shape: IndicatorShape.pill,
    activeWidth: 24.0,
  );

  /// Preset: Worm effect indicator.
  static const worm = IndicatorConfig(
    effect: IndicatorEffect.worm,
    activeWidth: 16.0,
  );

  /// Preset: Expanding effect indicator.
  static const expanding = IndicatorConfig(
    effect: IndicatorEffect.expanding,
    activeWidth: 12.0,
    activeHeight: 12.0,
  );

  /// Preset: Hidden indicator.
  static const hidden = IndicatorConfig(show: false);

  /// Preset: Overlay position.
  static const overlay = IndicatorConfig(
    position: IndicatorPosition.overlay,
    margin: 16.0,
  );
}
