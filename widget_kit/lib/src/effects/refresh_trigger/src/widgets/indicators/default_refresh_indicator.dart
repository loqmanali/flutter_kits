import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/refresh_trigger_stage.dart';
import '../../painters/animated_check_painter.dart';

/// The indicator `RefreshTrigger` falls back to when no builder is supplied.
///
/// Renders one card per stage: arrows while pulling, a spinner while running,
/// an animated check on success and an error glyph on failure.
class DefaultRefreshIndicator extends StatefulWidget {
  final RefreshTriggerStage stage;

  /// Whether this is the header (top/left) or footer (bottom/right) indicator.
  final bool isHeader;

  const DefaultRefreshIndicator({
    super.key,
    required this.stage,
    this.isHeader = true,
  });

  @override
  State<DefaultRefreshIndicator> createState() =>
      _DefaultRefreshIndicatorState();
}

class _DefaultRefreshIndicatorState extends State<DefaultRefreshIndicator> {
  static const _kPadH = EdgeInsets.symmetric(horizontal: 12, vertical: 6);
  static const _kPadSmall = EdgeInsets.all(6);
  static const _kAnimDuration = Duration(milliseconds: 250);

  Widget _spacerW(double w) => SizedBox(width: w);

  Widget _buildRefreshing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(widget.isHeader ? 'Refreshing...' : 'Loading...')),
        const SizedBox(width: 8),
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    );
  }

  Widget _buildCompleted(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(widget.isHeader ? 'Completed' : 'Loaded')),
        _spacerW(8),
        SizedBox(
          width: 24,
          height: 16,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            // Drawing the tick is decoration; reduced-motion users get the
            // finished mark straight away.
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return CustomPaint(
                painter: AnimatedCheckPainter(
                  progress: value,
                  color: color,
                  strokeWidth: 1.8,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFailed(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(widget.isHeader ? 'Failed' : 'Load failed')),
        _spacerW(8),
        Icon(Icons.error_outline, size: 16, color: color),
      ],
    );
  }

  Widget _buildPulling(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.stage.extent,
      builder: (context, child) {
        final v = widget.stage.extentValue.clamp(0.0, 1.0);
        double angle;
        if (widget.stage.direction == Axis.vertical) {
          // 0 -> 1 (0 -> 180)
          angle = widget.isHeader ? -math.pi * v : math.pi * v;
        } else {
          // 0 -> 1 (90 -> 270)
          angle = widget.isHeader
              ? (-math.pi / 2 + -math.pi * v)
              : (math.pi / 2 + math.pi * v);
        }

        final icon =
            widget.isHeader ? Icons.arrow_downward : Icons.arrow_upward;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(angle: angle, child: Icon(icon, size: 18)),
            _spacerW(8),
            Flexible(
              child: Text(
                v < 1
                    ? (widget.isHeader
                        ? 'Pull to refresh'
                        : 'Pull to load more')
                    : (widget.isHeader
                        ? 'Release to refresh'
                        : 'Release to load'),
              ),
            ),
            _spacerW(8),
            Transform.rotate(angle: angle, child: Icon(icon, size: 18)),
          ],
        );
      },
    );
  }

  Widget _buildIdle(BuildContext context) {
    if (!widget.isHeader && widget.stage.noMoreData) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [Flexible(child: Text('No more data'))],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child:
              Text(widget.isHeader ? 'Pull to refresh' : 'Pull to load more'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (widget.stage.stage) {
      case TriggerStage.refreshing:
        child = _buildRefreshing(context);
        break;
      case TriggerStage.completed:
        child = _buildCompleted(context);
        break;
      case TriggerStage.failed:
        child = _buildFailed(context);
        break;
      case TriggerStage.pulling:
        child = _buildPulling(context);
        break;
      case TriggerStage.idle:
        child = _buildIdle(context);
        break;
    }

    final card = Container(
      padding: widget.stage.stage == TriggerStage.pulling ? _kPadSmall : _kPadH,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : _kAnimDuration,
        child: KeyedSubtree(key: ValueKey(widget.stage.stage), child: child),
      ),
    );

    return Center(child: card);
  }
}
