import 'package:flutter/material.dart';

import '../../models/refresh_trigger_stage.dart';
import '../../painters/bezier_painter.dart';

/// Liquid bezier indicator that stretches downward as you pull.
class BezierHeader extends StatelessWidget {
  final RefreshTriggerStage stage;

  /// Falls back to the theme's primary colour.
  final Color? color;

  const BezierHeader({super.key, required this.stage, this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = this.color ?? scheme.primary;
    // Glyphs sit on the painted blob, so they follow its fill colour.
    final onColor = scheme.onPrimary;

    return AnimatedBuilder(
      animation: stage.extent,
      builder: (context, _) {
        final v = stage.extentValue.clamp(0.0, 1.0);

        return CustomPaint(
          painter: BezierPainter(
            progress: v,
            color: color,
            isRefreshing: stage.stage == TriggerStage.refreshing,
          ),
          child: Center(
            child: switch (stage.stage) {
              TriggerStage.refreshing => SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: onColor,
                  ),
                ),
              TriggerStage.completed =>
                Icon(Icons.check, color: onColor, size: 24),
              TriggerStage.failed => Icon(Icons.close, color: onColor, size: 24),
              _ => null,
            },
          ),
        );
      },
    );
  }
}
