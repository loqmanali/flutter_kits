import 'package:flutter/widgets.dart';

/// Builds the indicator for a given [RefreshTriggerStage].
typedef RefreshIndicatorBuilder = Widget Function(
  BuildContext context,
  RefreshTriggerStage stage,
);

typedef FutureVoidCallback = Future<void> Function();

/// Alias for the load-more callback. There is deliberately no `RefreshCallback`
/// alias here — `package:flutter/material.dart` already exports one and a second
/// top-level declaration would make every consumer's import ambiguous.
typedef LoadMoreCallback = FutureVoidCallback;

/// How the indicators are placed relative to the scrollable.
///
/// * [overlay] — indicator floats above the content (default).
/// * [inset] — indicator takes real layout space and pushes the content.
enum RefreshTriggerDisplayMode { overlay, inset }

/// Lifecycle of one side (refresh or load-more) of the trigger.
enum TriggerStage { idle, pulling, refreshing, completed, failed }

/// Everything an indicator builder needs to render one side of the trigger.
class RefreshTriggerStage {
  final TriggerStage stage;

  /// Pull distance normalised by `minExtent`; `1.0` means the trigger point.
  final Animation<double> extent;

  final Axis direction;
  final bool reverse;

  /// Raw (resistance-adjusted) pull distance in pixels.
  final double pixels;

  /// `true` for the refresh indicator, `false` for the load-more indicator.
  final bool isHeader;

  /// `true` once the trigger was told there is nothing left to load.
  final bool noMoreData;

  const RefreshTriggerStage(
    this.stage,
    this.extent,
    this.direction,
    this.reverse, {
    this.pixels = 0,
    this.isHeader = true,
    this.noMoreData = false,
  });

  double get extentValue => extent.value;
}
