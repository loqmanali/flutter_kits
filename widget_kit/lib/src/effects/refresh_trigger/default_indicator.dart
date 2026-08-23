part of '../refresh_trigger.dart';

/// ===============================
/// DEFAULT INDICATOR (Pure Flutter)
/// ===============================

class DefaultRefreshIndicator extends StatefulWidget {
  final RefreshTriggerStage stage;

  const DefaultRefreshIndicator({super.key, required this.stage});

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
    final Widget child = switch (widget.stage.stage) {
      TriggerStage.refreshing => const _RefreshingRow(),
      TriggerStage.completed => const _CompletedRow(),
      TriggerStage.pulling => _PullingRow(stage: widget.stage),
      TriggerStage.idle => const _IdleRow(),
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
        duration: _kAnimDuration,
        child: KeyedSubtree(key: ValueKey(widget.stage.stage), child: child),
      ),
    );

    return Center(child: card);
  }
}

class _RefreshingRow extends StatelessWidget {
  const _RefreshingRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text('Refreshing...')),
        SizedBox(width: 8),
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    );
  }
}

class _CompletedRow extends StatelessWidget {
  const _CompletedRow();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Flexible(child: Text('Completed')),
        const SizedBox(width: 8),
        SizedBox(
          width: 24,
          height: 16,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
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

class _PullingRow extends StatelessWidget {
  const _PullingRow({required this.stage});

  final RefreshTriggerStage stage;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: stage.extent,
      builder: (context, child) {
        final v = stage.extentValue.clamp(0.0, 1.0);
        // Vertical: 0 -> 180. Horizontal: 90 -> 270.
        final angle = stage.direction == Axis.vertical
            ? -math.pi * v
            : -math.pi / 2 + -math.pi * v;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: angle,
              child: const Icon(Icons.arrow_downward, size: 18),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(v < 1 ? 'Pull to refresh' : 'Release to refresh'),
            ),
            const SizedBox(width: 8),
            Transform.rotate(
              angle: angle,
              child: const Icon(Icons.arrow_downward, size: 18),
            ),
          ],
        );
      },
    );
  }
}

class _IdleRow extends StatelessWidget {
  const _IdleRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [Flexible(child: Text('Pull to refresh'))],
    );
  }
}
