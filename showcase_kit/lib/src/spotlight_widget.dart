import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'hole_painter.dart';
import 'showcase_step.dart';
import 'spotlight_navigator.dart';
import 'tour_config.dart';

/// The overlay shown for one step: dimmed backdrop with a cut-out over the
/// target, a pulsing ring, and the info bubble with the navigation buttons.
///
/// The backdrop is modal — taps never reach the app underneath, so the user
/// cannot interact with a half-explained screen.
class SpotlightWidget extends HookWidget {
  const SpotlightWidget({
    super.key,
    required this.rect,
    required this.step,
    required this.index,
    required this.total,
    required this.navigator,
    required this.config,
  });

  /// Bounds of the highlighted widget, in global coordinates.
  final Rect rect;
  final ShowcaseStep step;

  /// 1-based position of this step.
  final int index;
  final int total;
  final ISpotlightNavigator navigator;
  final TourConfig config;

  /// The bubble is positioned before it is laid out, so its height is an
  /// estimate; only used to decide above-or-below and to keep it on screen.
  static const double _estimatedBubbleHeight = 220;
  static const double _maxBubbleWidth = 300;
  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    final fade = useAnimationController(
      duration: const Duration(milliseconds: 300),
    )..forward();
    final pulse = useAnimationController(duration: const Duration(seconds: 2))
      ..repeat();

    final theme = config.theme;
    final media = MediaQuery.of(context);
    final size = media.size;
    final width = math.min(_maxBubbleWidth, size.width - _gap * 2);

    final minTop = media.padding.top + _gap;
    final maxTop = math.max(
      minTop,
      size.height - media.padding.bottom - _gap - _estimatedBubbleHeight,
    );
    var top = rect.bottom + theme.padding + _gap;
    if (top > maxTop) {
      top = rect.top - theme.padding - _gap - _estimatedBubbleHeight;
    }
    top = top.clamp(minTop, maxTop);
    final left =
        (rect.center.dx - width / 2).clamp(_gap, size.width - width - _gap);

    return FadeTransition(
      opacity: fade,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: CustomPaint(painter: HolePainter(rect, theme)),
            ),
          ),
          AnimatedBuilder(
            animation: pulse,
            builder: (_, __) {
              final t = pulse.value;
              final ring = rect.inflate(theme.padding * (1 + t * .5));
              return Positioned(
                left: ring.left,
                top: ring.top,
                width: ring.width,
                height: ring.height,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(theme.radius),
                        border: Border.all(width: 2, color: theme.ring),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: top,
            left: left,
            width: width,
            child: _Bubble(
              step: step,
              index: index,
              total: total,
              navigator: navigator,
              config: config,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.step,
    required this.index,
    required this.total,
    required this.navigator,
    required this.config,
  });

  final ShowcaseStep step;
  final int index;
  final int total;
  final ISpotlightNavigator navigator;
  final TourConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final labels = config.labels;
    final isFirst = index == 1;
    final isLast = index == total;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(config.theme.radius),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$index / $total',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
                TextButton(
                  onPressed: navigator.skip,
                  child: Text(labels.skip),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              step.title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(step.body, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Disabled rather than hidden so the buttons never jump.
                TextButton(
                  onPressed: isFirst ? null : navigator.prev,
                  child: Text(labels.previous),
                ),
                ElevatedButton(
                  onPressed: navigator.next,
                  child: Text(isLast ? labels.done : labels.next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
