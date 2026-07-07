import 'package:flutter/material.dart';

import 'indicator_params.dart';

/// A sliding underline indicator: a short bar aligned to the bottom of the
/// navigation bar that animates from the previously-selected slot to the
/// currently-selected one.
///
/// Time complexity: O(1) per build (a single `Transform.translate` + a
/// `Container`).
class UnderlineIndicator extends StatelessWidget {
  /// Creates an underline indicator driven by [params].
  const UnderlineIndicator({
    super.key,
    required this.params,
    this.thickness = 3,
    this.bottomPadding = 6,
    this.curve = Curves.easeInOut,
  });

  /// Geometry and animation for this frame.
  final IndicatorParams params;

  /// Thickness (height) of the bar in logical pixels.
  final double thickness;

  /// Distance between the bar and the bottom edge of the navigation widget.
  final double bottomPadding;

  /// Animation curve for the slide.
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final width = params.itemWidth;
    final animation =
        CurvedAnimation(parent: params.animation, curve: curve);
    final begin = params.previousIndex * width;
    final end = params.selectedIndex * width;

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final x = Tween<double>(begin: begin, end: end).evaluate(animation);
        return Transform.translate(
          offset: Offset(x, 0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: width,
              height: thickness,
              margin: EdgeInsets.only(bottom: bottomPadding),
              decoration: BoxDecoration(
                color: params.color,
                borderRadius: BorderRadius.circular(thickness / 1.5),
              ),
            ),
          ),
        );
      },
    );
  }
}
