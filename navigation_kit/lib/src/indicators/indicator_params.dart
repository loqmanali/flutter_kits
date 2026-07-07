import 'package:flutter/material.dart';

/// Geometry and animation data handed to indicator builders.
///
/// Bundled into a single value so the `IndicatorBuilder` typedef remains
/// stable when new fields are added.
@immutable
class IndicatorParams {
  /// Snapshot of indicator state for one frame.
  const IndicatorParams({
    required this.selectedIndex,
    required this.previousIndex,
    required this.itemCount,
    required this.itemWidth,
    required this.color,
    required this.animation,
    required this.isRTL,
  });

  /// Currently selected item index.
  final int selectedIndex;

  /// Previously selected item index — useful for animating between two
  /// positions.
  final int previousIndex;

  /// Total number of items in the bar.
  final int itemCount;

  /// Width of a single item slot (`barWidth / itemCount`).
  final double itemWidth;

  /// The resolved indicator color.
  final Color color;

  /// Animation that drives the indicator. Runs from 0 → 1 on each selection
  /// change.
  final Animation<double> animation;

  /// True when the host is laid out right-to-left.
  final bool isRTL;
}
