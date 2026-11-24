import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../models/refresh_trigger_stage.dart';

/// Material-style indicator: a circular chip with a rotating arrow.
class MaterialHeader extends StatelessWidget {
  final RefreshTriggerStage stage;

  /// Falls back to the theme's primary colour.
  final Color? color;

  const MaterialHeader({super.key, required this.stage, this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = this.color ?? scheme.primary;
    final onColor = scheme.onPrimary;

    return Center(
      child: AnimatedBuilder(
        animation: stage.extent,
        builder: (context, _) {
          switch (stage.stage) {
            case TriggerStage.refreshing:
              return SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: color),
              );
            case TriggerStage.completed:
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(Icons.check, color: onColor, size: 24),
              );
            case TriggerStage.failed:
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: scheme.onError, size: 24),
              );
            case TriggerStage.idle:
            case TriggerStage.pulling:
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: math.pi * 2 * stage.extentValue.clamp(0.0, 1.0),
                    child: Icon(Icons.arrow_downward, color: color, size: 20),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
