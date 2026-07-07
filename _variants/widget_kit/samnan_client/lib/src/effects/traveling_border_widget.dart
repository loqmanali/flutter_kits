import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class TravelingBorderWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color borderColor;
  final double strokeWidth;
  final double borderRadius;
  final AnimationController? controller;

  const TravelingBorderWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.borderColor = Colors.blue,
    this.strokeWidth = 2.0,
    this.borderRadius = 10.0,
    this.controller,
  });

  @override
  State<TravelingBorderWidget> createState() => TravelingBorderWidgetState();
}

class TravelingBorderWidgetState extends State<TravelingBorderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        AnimationController(
          vsync: this,
          duration: widget.duration,
        );

    // Add listener to reset when animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void startAnimation() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _BorderPainter(
        animation: _controller,
        color: widget.borderColor,
        strokeWidth: widget.strokeWidth,
        radius: widget.borderRadius,
        textDirection: Directionality.of(context),
      ),
      child: widget.child,
    );
  }
}

class _BorderPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final double strokeWidth;
  final double radius;
  final TextDirection textDirection;

  _BorderPainter({
    required this.animation,
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.textDirection,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0) return;

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Path path = Path();
    final double r = radius;
    final double w = size.width;
    final double h = size.height;

    // Start coordinates depend on TextDirection
    // For LTR: Bottom-Right is (w, h)
    // For RTL: Bottom-Left is (0, h)

    if (textDirection == TextDirection.rtl) {
      // RTL Logic: Start from Bottom-Left (near Add button in RTL), go Counter-Clockwise

      // 1. Start at the end of the bottom edge (near bottom-left corner)
      path.moveTo(r, h);

      // 2. Draw bottom line to the right
      path.lineTo(w - r, h);

      // 3. Bottom-Right Arc
      path.arcTo(
        Rect.fromLTWH(w - 2 * r, h - 2 * r, 2 * r, 2 * r),
        pi / 2,
        -pi / 2,
        false,
      );

      // 4. Right line up
      path.lineTo(w, r);

      // 5. Top-Right Arc
      path.arcTo(
        Rect.fromLTWH(w - 2 * r, 0, 2 * r, 2 * r),
        0,
        -pi / 2,
        false,
      );

      // 6. Top line to the left
      path.lineTo(r, 0);

      // 7. Top-Left Arc
      path.arcTo(
        Rect.fromLTWH(0, 0, 2 * r, 2 * r),
        3 * pi / 2,
        -pi / 2,
        false,
      );

      // 8. Left line down
      path.lineTo(0, h - r);

      // 9. Bottom-Left Arc (finishing loop)
      path.arcTo(
        Rect.fromLTWH(0, h - 2 * r, 2 * r, 2 * r),
        pi,
        -pi / 2,
        false,
      );
    } else {
      // LTR Logic: Start from Bottom-Right (near Add button in LTR), go Clockwise

      // 1. Start at the end of the bottom edge (near bottom-right corner)
      path.moveTo(w - r, h);

      // 2. Draw bottom line to the left
      path.lineTo(r, h);

      // 3. Bottom-Left Arc
      path.arcTo(
        Rect.fromLTWH(0, h - 2 * r, 2 * r, 2 * r),
        pi / 2,
        pi / 2,
        false,
      );

      // 4. Left line up
      path.lineTo(0, r);

      // 5. Top-Left Arc
      path.arcTo(Rect.fromLTWH(0, 0, 2 * r, 2 * r), pi, pi / 2, false);

      // 6. Top line to the right
      path.lineTo(w - r, 0);

      // 7. Top-Right Arc
      path.arcTo(
        Rect.fromLTWH(w - 2 * r, 0, 2 * r, 2 * r),
        3 * pi / 2,
        pi / 2,
        false,
      );

      // 8. Right line down
      path.lineTo(w, h - r);

      // 9. Bottom-Right Arc (finishing loop)
      path.arcTo(
        Rect.fromLTWH(w - 2 * r, h - 2 * r, 2 * r, 2 * r),
        0,
        pi / 2,
        false,
      );
    }

    final PathMetrics metrics = path.computeMetrics();
    for (final PathMetric metric in metrics) {
      final double length = metric.length;
      final double currentLength = length * animation.value;

      if (currentLength > 0) {
        final Path extract = metric.extractPath(0, currentLength);
        canvas.drawPath(extract, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BorderPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.textDirection != textDirection;
  }
}
