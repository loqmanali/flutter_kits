import 'package:flutter/material.dart';

import 'shimmer_shape_type.dart';

/// Shimmer Container for creating different shapes
class ShimmerShape extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Color backgroundColor;
  final ShimmerShapeType type;
  final double? circleRadius;

  const ShimmerShape({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.backgroundColor = Colors.white,
    this.type = ShimmerShapeType.rectangle,
    this.circleRadius,
  });

  // Named constructors for common shapes
  const ShimmerShape.rectangle({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.backgroundColor = Colors.white,
  })  : type = ShimmerShapeType.rectangle,
        circleRadius = null;

  const ShimmerShape.circle({
    super.key,
    required double radius,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.backgroundColor = Colors.white,
  })  : width = radius * 2,
        height = radius * 2,
        borderRadius = radius,
        type = ShimmerShapeType.circle,
        circleRadius = radius;

  const ShimmerShape.text({
    super.key,
    required this.width,
    this.height = 16.0,
    this.borderRadius = 4.0,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.backgroundColor = Colors.white,
  })  : type = ShimmerShapeType.text,
        circleRadius = null;

  const ShimmerShape.button({
    super.key,
    this.width = 120.0,
    this.height = 40.0,
    this.borderRadius = 8.0,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.backgroundColor = Colors.white,
  })  : type = ShimmerShapeType.button,
        circleRadius = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: type == ShimmerShapeType.circle
            ? null
            : BorderRadius.circular(borderRadius),
        shape: type == ShimmerShapeType.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
      ),
    );
  }
}
