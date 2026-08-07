import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/refresh_trigger_stage.dart';

/// iOS-style indicator: a refresh glyph that spins with the pull.
///
/// ```dart
/// RefreshTrigger(
///   headerBuilder: (context, stage) => ClassicHeader(stage: stage),
///   onRefresh: load,
///   child: list,
/// )
/// ```
class ClassicHeader extends StatelessWidget {
  final RefreshTriggerStage stage;

  /// Falls back to the theme's primary colour.
  final Color? color;

  const ClassicHeader({super.key, required this.stage, this.color});

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: AnimatedBuilder(
        animation: stage.extent,
        builder: (context, _) {
          switch (stage.stage) {
            case TriggerStage.refreshing:
              return SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              );
            case TriggerStage.completed:
              return Icon(Icons.check_circle, color: color, size: 24);
            case TriggerStage.failed:
              return Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              );
            case TriggerStage.idle:
            case TriggerStage.pulling:
              return Transform.rotate(
                angle: math.pi * 2 * stage.extentValue.clamp(0.0, 1.0),
                child: Icon(Icons.refresh, color: color, size: 24),
              );
          }
        },
      ),
    );
  }
}
