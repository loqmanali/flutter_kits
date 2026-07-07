import 'package:flutter/widgets.dart';

/// Configuration for the visual appearance of the carousel.
///
/// Use this class to customize the styling and animations
/// of the carousel container and items.
class VisualConfig {
  /// Height of the carousel.
  final double height;

  /// Border radius of carousel items.
  final double borderRadius;

  /// Border color of the carousel container.
  final Color? borderColor;

  /// Border width of the carousel container.
  final double borderWidth;

  /// Padding inside the carousel container.
  final EdgeInsets padding;

  /// Background color of the carousel container.
  final Color? backgroundColor;

  /// Box shadow for the carousel container.
  final List<BoxShadow>? boxShadow;

  /// Default fit for images in carousel items.
  final BoxFit imageFit;

  /// Duration of page transition animations.
  final Duration animationDuration;

  /// Curve for page transition animations.
  final Curve animationCurve;

  /// Gradient overlay for carousel items.
  final Gradient? gradient;

  /// Opacity of the gradient overlay.
  final double gradientOpacity;

  /// Whether to clip carousel content.
  final Clip clipBehavior;

  const VisualConfig({
    this.height = 180.0,
    this.borderRadius = 16.0,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding = EdgeInsets.zero,
    this.backgroundColor,
    this.boxShadow,
    this.imageFit = BoxFit.cover,
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationCurve = Curves.easeInOut,
    this.gradient,
    this.gradientOpacity = 0.5,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Creates a copy with the given fields replaced.
  VisualConfig copyWith({
    double? height,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    EdgeInsets? padding,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
    BoxFit? imageFit,
    Duration? animationDuration,
    Curve? animationCurve,
    Gradient? gradient,
    double? gradientOpacity,
    Clip? clipBehavior,
  }) {
    return VisualConfig(
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      padding: padding ?? this.padding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      boxShadow: boxShadow ?? this.boxShadow,
      imageFit: imageFit ?? this.imageFit,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      gradient: gradient ?? this.gradient,
      gradientOpacity: gradientOpacity ?? this.gradientOpacity,
      clipBehavior: clipBehavior ?? this.clipBehavior,
    );
  }

  /// Preset: Small carousel (120px height).
  static const small = VisualConfig(height: 120.0, borderRadius: 12.0);

  /// Preset: Medium carousel (180px height).
  static const medium = VisualConfig();

  /// Preset: Large carousel (250px height).
  static const large = VisualConfig(height: 250.0, borderRadius: 20.0);

  /// Preset: Full-width banner (no border radius).
  static const fullWidth = VisualConfig(height: 200.0, borderRadius: 0.0);

  /// Preset: Card style with shadow.
  static const card = VisualConfig(
    boxShadow: [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 10.0,
        offset: Offset(0, 4),
      ),
    ],
  );

  /// Preset: Rounded style with larger border radius.
  static const rounded = VisualConfig(borderRadius: 24.0);
}
