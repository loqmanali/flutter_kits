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

  @override
  Widget build(BuildContext context) {
    final isHeader = widget.isHeader;
    final Widget child = switch (widget.stage.stage) {
      TriggerStage.refreshing => _RefreshingRow(isHeader: isHeader),
      TriggerStage.completed => _CompletedRow(isHeader: isHeader),
      TriggerStage.failed => _FailedRow(isHeader: isHeader),
      TriggerStage.pulling => _PullingRow(
          stage: widget.stage,
          isHeader: isHeader,
        ),
      TriggerStage.idle => _IdleRow(stage: widget.stage, isHeader: isHeader),
    };

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

class _RefreshingRow extends StatelessWidget {
  const _RefreshingRow({required this.isHeader});

  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(isHeader ? 'Refreshing...' : 'Loading...')),
        const SizedBox(width: 8),
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    );
  }
}

class _CompletedRow extends StatelessWidget {
  const _CompletedRow({required this.isHeader});

  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(isHeader ? 'Completed' : 'Loaded')),
        const SizedBox(width: 8),
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
}

class _FailedRow extends StatelessWidget {
  const _FailedRow({required this.isHeader});

  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(isHeader ? 'Failed' : 'Load failed')),
        const SizedBox(width: 8),
        Icon(Icons.error_outline, size: 16, color: color),
      ],
    );
  }
}

class _PullingRow extends StatelessWidget {
  const _PullingRow({required this.stage, required this.isHeader});

  final RefreshTriggerStage stage;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: stage.extent,
      builder: (context, child) {
        final v = stage.extentValue.clamp(0.0, 1.0);
        double angle;
        if (stage.direction == Axis.vertical) {
          // 0 -> 1 (0 -> 180)
          angle = isHeader ? -math.pi * v : math.pi * v;
        } else {
          // 0 -> 1 (90 -> 270)
          angle = isHeader
              ? (-math.pi / 2 + -math.pi * v)
              : (math.pi / 2 + math.pi * v);
        }

        final icon = isHeader ? Icons.arrow_downward : Icons.arrow_upward;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(angle: angle, child: Icon(icon, size: 18)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                v < 1
                    ? (isHeader ? 'Pull to refresh' : 'Pull to load more')
                    : (isHeader ? 'Release to refresh' : 'Release to load'),
              ),
            ),
            const SizedBox(width: 8),
            Transform.rotate(angle: angle, child: Icon(icon, size: 18)),
          ],
        );
      },
    );
  }
}

class _IdleRow extends StatelessWidget {
  const _IdleRow({required this.stage, required this.isHeader});

  final RefreshTriggerStage stage;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    if (!isHeader && stage.noMoreData) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [Flexible(child: Text('No more data'))],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(isHeader ? 'Pull to refresh' : 'Pull to load more'),
        ),
      ],
    );
  }
}
