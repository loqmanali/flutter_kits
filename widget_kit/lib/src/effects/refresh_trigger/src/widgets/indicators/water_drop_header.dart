import 'package:flutter/material.dart';

import '../../models/refresh_trigger_stage.dart';

/// Water-drop indicator that swells with the pull.
class WaterDropHeader extends StatelessWidget {
  final RefreshTriggerStage stage;

  /// Falls back to the theme's primary colour.
  final Color? color;

  const WaterDropHeader({super.key, required this.stage, this.color});

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: AnimatedBuilder(
        animation: stage.extent,
        builder: (context, _) {
          final v = stage.extentValue.clamp(0.0, 1.0);
          final size = 20 + (v * 30);

          switch (stage.stage) {
            case TriggerStage.refreshing:
              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(strokeWidth: 3, color: color),
              );
            case TriggerStage.completed:
              return Icon(Icons.check_circle, color: color, size: size);
            case TriggerStage.failed:
              return Icon(
                Icons.error,
                color: Theme.of(context).colorScheme.error,
                size: size,
              );
            case TriggerStage.idle:
            case TriggerStage.pulling:
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1 + (v * 0.2)),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.water_drop, color: color, size: size * 0.6),
              );
          }
        },
      ),
    );
  }
}
