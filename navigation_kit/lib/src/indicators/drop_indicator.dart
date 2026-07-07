import 'package:flutter/material.dart';

import 'indicator_params.dart';

/// A water-drop indicator: a curved bottom-rounded "drop" slides between
/// item slots, then a small circle is released and falls out the bottom of
/// the bar.
///
/// Two staged sub-animations drive the effect:
/// - `Interval(0.00, 0.35)`: horizontal slide between slots.
/// - `Interval(0.40, 0.70)`: vertical fall of the released droplet.
///
/// Mirrors automatically when the ambient [Directionality] is RTL.
class DropIndicator extends StatelessWidget {
  /// Creates a drop indicator driven by [params].
  const DropIndicator({
    super.key,
    required this.params,
    this.dropWidth = 56,
    this.dropHeight = 20,
    this.dropletRadius = 5,
  });

  /// Geometry and animation for this frame.
  final IndicatorParams params;

  /// Width of the curved drop shape.
  final double dropWidth;

  /// Height of the curved drop shape.
  final double dropHeight;

  /// Radius of the released droplet circle.
  final double dropletRadius;

  @override
  Widget build(BuildContext context) {
    final itemWidth = params.itemWidth;
    final totalWidth = itemWidth * params.itemCount;

    double start = params.previousIndex * itemWidth + itemWidth / 2;
    double end = params.selectedIndex * itemWidth + itemWidth / 2;
    if (params.isRTL) {
      start = totalWidth - start;
      end = totalWidth - end;
    }

    final slide = Tween<double>(begin: start, end: end).animate(
      CurvedAnimation(
        parent: params.animation,
        curve: const Interval(0.0, 0.35),
      ),
    );
    final fall = Tween<Offset>(
      begin: const Offset(0, 6),
      end: const Offset(0, 36),
    ).animate(
      CurvedAnimation(
        parent: params.animation,
        curve: const Interval(0.40, 0.70),
      ),
    );

    return AnimatedBuilder(
      animation: params.animation,
      builder: (_, __) {
        final x = slide.value - (itemWidth / 2);
        final t = params.animation.value;
        return Transform.translate(
          offset: Offset(x, 0),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: itemWidth,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Opacity(
                    opacity: t <= 0.7 ? 1.0 : 0.0,
                    child: Container(
                      width: dropWidth,
                      height: dropHeight,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: params.color,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: fall.value,
                    child: Container(
                      width: dropletRadius * 2,
                      height: dropletRadius * 2,
                      decoration: BoxDecoration(
                        color: t > 0.6 ? Colors.transparent : params.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
