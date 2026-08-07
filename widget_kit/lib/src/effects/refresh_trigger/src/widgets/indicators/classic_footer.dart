import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/refresh_trigger_stage.dart';

/// Load-more footer with rotating arrow, status text and a "no more data" rest
/// state. [noMoreData] defaults to the value carried on [stage].
class ClassicFooter extends StatelessWidget {
  final RefreshTriggerStage stage;

  /// Falls back to the theme's primary colour.
  final Color? color;

  /// Overrides `stage.noMoreData` when you drive that flag yourself.
  final bool? noMoreData;

  const ClassicFooter({
    super.key,
    required this.stage,
    this.color,
    this.noMoreData,
  });

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).colorScheme.primary;

    if (noMoreData ?? stage.noMoreData) {
      return Center(
        child: Text(
          'No more data',
          // Informational, not branded — the secondary-copy token keeps it
          // readable where `primary` at 60% would not be.
          style:
              TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    return Center(
      child: AnimatedBuilder(
        animation: stage.extent,
        builder: (context, _) {
          if (stage.stage == TriggerStage.refreshing) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Loading...', style: TextStyle(color: color)),
              ],
            );
          }

          if (stage.stage == TriggerStage.completed) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: color, size: 16),
                const SizedBox(width: 8),
                Text('Loaded', style: TextStyle(color: color)),
              ],
            );
          }

          if (stage.stage == TriggerStage.failed) {
            final error = Theme.of(context).colorScheme.error;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: error, size: 16),
                const SizedBox(width: 8),
                Text('Load failed', style: TextStyle(color: error)),
              ],
            );
          }

          final v = stage.extentValue.clamp(0.0, 1.0);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: math.pi * v,
                child: Icon(Icons.arrow_upward, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                v < 1 ? 'Pull to load more' : 'Release to load',
                style: TextStyle(color: color),
              ),
            ],
          );
        },
      ),
    );
  }
}
