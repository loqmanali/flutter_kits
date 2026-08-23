part of '../refresh_trigger.dart';

/// A compact pill-style refresh indicator — flat (no shadow), localised
/// strings, rotating arrow on pull, spinner on refresh, checkmark on done.
///
/// Use as: `RefreshTrigger(indicatorBuilder: AppPillRefreshIndicator.builder, ...)`
class AppPillRefreshIndicator {
  const AppPillRefreshIndicator._();

  /// Plug straight into `RefreshTrigger.indicatorBuilder`.
  static Widget builder(BuildContext context, RefreshTriggerStage stage) =>
      _AppPillIndicator(stage: stage);
}

/// The pill itself: one class so Flutter can skip rebuilding it when the
/// surrounding list rebuilds.
class _AppPillIndicator extends StatelessWidget {
  const _AppPillIndicator({required this.stage});

  final RefreshTriggerStage stage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;
    final muted = scheme.onSurface.withValues(alpha: 0.6);

    // Theme copy wins when supplied; the Arabic strings are only fallbacks so
    // an app that never configures the theme keeps working unchanged.
    final theme = RefreshTriggerThemeProvider.of(context);
    final pullText = theme?.pullText ?? 'اسحب للأسفل للتحديث';
    final releaseText = theme?.releaseText ?? 'اترك للتحديث';
    final refreshingText = theme?.refreshingText ?? 'جاري التحديث…';
    final completedText = theme?.completedText ?? 'تم التحديث';

    final String label;
    Widget? trailing;
    switch (stage.stage) {
      case TriggerStage.idle:
        label = pullText;
      case TriggerStage.pulling:
        label = stage.extentValue >= 1 ? releaseText : pullText;
        trailing = AnimatedBuilder(
          animation: stage.extent,
          builder: (_, __) => Transform.rotate(
            angle: -math.pi * stage.extentValue.clamp(0.0, 1.0),
            child: Icon(Icons.arrow_downward, size: 14, color: muted),
          ),
        );
      case TriggerStage.refreshing:
        label = refreshingText;
        trailing = SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 1.8, color: primary),
        );
      case TriggerStage.completed:
        label = completedText;
        trailing = Icon(Icons.check, size: 16, color: primary);
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: muted),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              trailing,
            ],
          ],
        ),
      ),
    );
  }
}

/// Draws a checkmark that animates with [progress] 0..1
class AnimatedCheckPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  AnimatedCheckPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = color;

    // Define a simple check ✔ path based on size.
    final start = Offset(size.width * 0.05, size.height * 0.55);
    final mid = Offset(size.width * 0.40, size.height * 0.90);
    final end = Offset(size.width * 0.95, size.height * 0.10);

    // Animate two segments: start->mid then mid->end
    const total = 1.0;
    const firstSegWeight = 0.5; // first half draws first segment
    if (progress <= firstSegWeight) {
      final t = (progress / firstSegWeight).clamp(0.0, 1.0);
      final p = Offset.lerp(start, mid, t)!;
      canvas.drawLine(start, p, paint);
    } else {
      // draw full first segment
      canvas.drawLine(start, mid, paint);
      // draw partial second segment
      final t = ((progress - firstSegWeight) / (total - firstSegWeight)).clamp(
        0.0,
        1.0,
      );
      final p = Offset.lerp(mid, end, t)!;
      canvas.drawLine(mid, p, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedCheckPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// ===============================
/// CORE LOGIC
/// ===============================

const kDefaultDuration = Duration(milliseconds: 250);
