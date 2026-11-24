import 'package:flutter/widgets.dart';

import '../models/refresh_trigger_stage.dart';

/// How long the indicator takes to slide back once the finger lifts.
const kDefaultDuration = Duration(milliseconds: 250);

/// Paints the two indicators around [child] for a given pull state.
///
/// Pure presentation: it owns the pull resistance curve, the slide-in
/// animation and the overlay/inset placement, and holds no state of its own.
/// [RefreshTriggerState] feeds it raw extents and decides when to fire.
class RefreshTriggerLayout extends StatelessWidget {
  /// The scrollable being wrapped.
  final Widget child;

  final RefreshTriggerDisplayMode displayMode;
  final Axis direction;

  /// Anchors the refresh side to the end of the scrollable instead of the start.
  final bool reverse;

  final Curve curve;

  /// `false` while the finger is down, so the indicator tracks the pull 1:1
  /// instead of lagging behind an animation.
  final bool animate;

  final double minExtent;
  final double maxExtent;

  final bool enableRefresh;
  final bool enableLoadMore;

  final RefreshIndicatorBuilder headerBuilder;
  final RefreshIndicatorBuilder footerBuilder;

  final TriggerStage refreshStage;
  final TriggerStage loadMoreStage;

  /// Raw pull distances in pixels, before resistance is applied.
  final double refreshExtent;
  final double loadMoreExtent;

  final bool noMoreData;

  const RefreshTriggerLayout({
    super.key,
    required this.child,
    required this.displayMode,
    required this.direction,
    required this.reverse,
    required this.curve,
    required this.animate,
    required this.minExtent,
    required this.maxExtent,
    required this.enableRefresh,
    required this.enableLoadMore,
    required this.headerBuilder,
    required this.footerBuilder,
    required this.refreshStage,
    required this.loadMoreStage,
    required this.refreshExtent,
    required this.loadMoreExtent,
    required this.noMoreData,
  });

  bool get _vertical => direction == Axis.vertical;

  /// While a callback runs the indicator parks at [minExtent] so it stays put.
  static bool _isBusy(TriggerStage stage) =>
      stage == TriggerStage.refreshing ||
      stage == TriggerStage.completed ||
      stage == TriggerStage.failed;

  double _targetFor(TriggerStage stage, double extent) =>
      _isBusy(stage) ? minExtent : extent;

  /// Past [minExtent] the pull decelerates instead of tracking the finger 1:1,
  /// and it never travels beyond [maxExtent].
  double _resist(double extent) {
    if (extent <= minExtent) return extent;
    final span = maxExtent - minExtent;
    // A caller may set maxExtent <= minExtent; without this the division below
    // yields NaN and every downstream SizedBox/Offset blows up.
    if (span <= 0) return extent < maxExtent ? extent : maxExtent;
    final relativeExtent = extent - minExtent;
    final diff = span - relativeExtent;
    final decel = Curves.decelerate.transform((diff / span).clamp(0, 1));
    return maxExtent - decel * diff;
  }

  /// `1.0` at the trigger point. A zero [minExtent] fires on any pull, so any
  /// non-zero extent is already "past" it.
  double _normalize(double extent) {
    if (minExtent > 0) return extent / minExtent;
    return extent > 0 ? 1 : 0;
  }

  Widget _indicator(BuildContext context, bool isHeader, double rawExtent) {
    final triggerStage = isHeader ? refreshStage : loadMoreStage;
    final busy = _isBusy(triggerStage);

    final stage = RefreshTriggerStage(
      triggerStage,
      AlwaysStoppedAnimation<double>(_normalize(rawExtent)),
      direction,
      isHeader ? reverse : !reverse,
      pixels: _resist(rawExtent),
      isHeader: isHeader,
      noMoreData: noMoreData,
    );

    final indicator =
        (isHeader ? headerBuilder : footerBuilder)(context, stage);

    return ExcludeSemantics(
      // At rest the indicator still sits in the tree, translated off-screen.
      // Without this a screen reader reads "Pull to refresh" from anywhere in
      // the list.
      excluding: rawExtent <= 0 && !busy,
      child: busy
          // Announce the status change (refreshing / done / failed) once.
          ? MergeSemantics(child: Semantics(liveRegion: true, child: indicator))
          : indicator,
    );
  }

  /// Animates the raw extent, then hands the animated raw value and its
  /// resistance-adjusted counterpart to [builder].
  Widget _animatedExtent(
    Duration duration,
    double target,
    Widget Function(BuildContext context, double raw, double resisted) builder,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target),
      duration: duration,
      curve: curve,
      builder: (context, value, _) => builder(context, value, _resist(value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final refreshTarget = _targetFor(refreshStage, refreshExtent);
    final loadTarget = _targetFor(loadMoreStage, loadMoreExtent);

    // Tracking the finger is direct manipulation, not motion — but the
    // slide-back once it lifts is, so reduced-motion users get it instantly.
    final duration = animate && !MediaQuery.disableAnimationsOf(context)
        ? kDefaultDuration
        : Duration.zero;

    return displayMode == RefreshTriggerDisplayMode.inset
        ? _buildInset(duration, refreshTarget, loadTarget)
        : _buildOverlay(duration, refreshTarget, loadTarget);
  }

  Widget _buildOverlay(
    Duration duration,
    double refreshTarget,
    double loadTarget,
  ) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        if (enableRefresh)
          _animatedExtent(
            duration,
            refreshTarget,
            (context, raw, resisted) => _positionEdge(
              _indicator(context, true, raw),
              reverse,
              resisted,
            ),
          ),
        if (enableLoadMore)
          _animatedExtent(
            duration,
            loadTarget,
            (context, raw, resisted) => _positionEdge(
              _indicator(context, false, raw),
              !reverse,
              resisted,
            ),
          ),
      ],
    );
  }

  /// Pins [indicator] to one edge of the stack and slides it in by [extent].
  Widget _positionEdge(Widget indicator, bool atEnd, double extent) {
    final slide = _vertical
        ? Offset(0, atEnd ? -extent : extent)
        : Offset(atEnd ? -extent : extent, 0);
    final hidden =
        _vertical ? Offset(0, atEnd ? 1 : -1) : Offset(atEnd ? 1 : -1, 0);

    return Positioned(
      top: _vertical ? (atEnd ? null : 0) : 0,
      bottom: _vertical ? (atEnd ? 0 : null) : 0,
      left: _vertical ? 0 : (atEnd ? null : 0),
      right: _vertical ? 0 : (atEnd ? 0 : null),
      child: ClipRect(
        child: FractionalTranslation(
          translation: hidden,
          child: Transform.translate(offset: slide, child: indicator),
        ),
      ),
    );
  }

  Widget _buildInset(
    Duration duration,
    double refreshTarget,
    double loadTarget,
  ) {
    final header = enableRefresh
        ? _animatedExtent(
            duration,
            refreshTarget,
            (context, raw, resisted) => _insetSlot(
              _indicator(context, true, raw),
              resisted,
              true,
            ),
          )
        : const SizedBox.shrink();

    final footer = enableLoadMore
        ? _animatedExtent(
            duration,
            loadTarget,
            (context, raw, resisted) => _insetSlot(
              _indicator(context, false, raw),
              resisted,
              false,
            ),
          )
        : const SizedBox.shrink();

    // `reverse` puts the refresh indicator at the end of the scrollable.
    final children = reverse
        ? [footer, Expanded(child: child), header]
        : [header, Expanded(child: child), footer];

    return _vertical ? Column(children: children) : Row(children: children);
  }

  /// A layout slot that grows to [extent] while letting the indicator keep its
  /// natural size (clipped, anchored to the edge it slides in from).
  Widget _insetSlot(Widget indicator, double extent, bool isHeader) {
    final atEnd = isHeader ? reverse : !reverse;

    return SizedBox(
      height: _vertical ? extent : null,
      width: _vertical ? null : extent,
      child: ClipRect(
        child: OverflowBox(
          alignment: _vertical
              ? (atEnd ? Alignment.topCenter : Alignment.bottomCenter)
              : (atEnd ? Alignment.centerLeft : Alignment.centerRight),
          minHeight: 0,
          minWidth: 0,
          maxHeight: _vertical ? double.infinity : null,
          maxWidth: _vertical ? null : double.infinity,
          child: indicator,
        ),
      ),
    );
  }
}
