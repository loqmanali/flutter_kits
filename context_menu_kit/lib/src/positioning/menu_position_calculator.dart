import 'package:flutter/material.dart';

/// Clamps a desired menu origin so the menu rectangle stays fully inside
/// the screen.
///
/// The algorithm is a constant-time, per-axis clamp:
/// - Right overflow:  `x' = screen.w - menu.w - padding`
/// - Left  overflow:  `x' = padding`
/// - Bottom overflow: `y' = screen.h - menu.h - padding`
/// - Top   overflow:  `y' = padding`
///
/// Complexity: O(1).
class MenuPositionCalculator {
  /// Default padding kept between the menu and each screen edge.
  static const double defaultEdgePadding = 10;

  const MenuPositionCalculator._();

  /// Returns an [Offset] that keeps a `contentSize` rectangle inside
  /// `screenSize` while staying as close to `initialPosition` as possible.
  static Offset calculateAdjustedPosition(
    Offset initialPosition,
    Size contentSize,
    Size screenSize, {
    double edgePadding = defaultEdgePadding,
  }) {
    double x = initialPosition.dx;
    double y = initialPosition.dy;

    if (x + contentSize.width > screenSize.width) {
      x = screenSize.width - contentSize.width - edgePadding;
    }
    if (x < edgePadding) x = edgePadding;

    if (y + contentSize.height > screenSize.height) {
      y = screenSize.height - contentSize.height - edgePadding;
    }
    if (y < edgePadding) y = edgePadding;

    return Offset(x, y);
  }
}
