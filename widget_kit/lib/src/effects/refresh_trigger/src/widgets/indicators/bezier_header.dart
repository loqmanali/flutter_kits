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
    final color = this.color ?? Theme.of(context).colorScheme.primary;

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
              TriggerStage.refreshing => const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              TriggerStage.completed =>
                const Icon(Icons.check, color: Colors.white, size: 24),
              TriggerStage.failed =>
                const Icon(Icons.close, color: Colors.white, size: 24),
              _ => null,
            },
          ),
        );
      },
    );
  }
}
