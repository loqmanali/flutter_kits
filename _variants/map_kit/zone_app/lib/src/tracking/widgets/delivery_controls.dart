import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

/// Widget that provides playback controls for delivery simulation
class DeliveryControls extends ConsumerWidget {
  final Widget Function(
    BuildContext context,
    bool isPaused,
    bool isCompleted,
    VoidCallback onTogglePause,
    VoidCallback onReset,
  )? customBuilder;

  const DeliveryControls({
    super.key,
    this.customBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryTrackingProvider);
    final notifier = ref.read(deliveryTrackingProvider.notifier);

    if (customBuilder != null) {
      return customBuilder!(
        context,
        state.isPaused,
        state.isCompleted,
        notifier.togglePause,
        notifier.reset,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: state.isCompleted ? null : notifier.togglePause,
          icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
          tooltip: state.isPaused ? 'Resume' : 'Pause',
        ),
        IconButton(
          onPressed: notifier.reset,
          icon: const Icon(Icons.refresh),
          tooltip: 'Reset',
        ),
      ],
    );
  }
}

/// Simple pause/play button
class DeliveryPauseButton extends ConsumerWidget {
  final ButtonStyle? style;
  final Widget? pauseIcon;
  final Widget? playIcon;

  const DeliveryPauseButton({
    super.key,
    this.style,
    this.pauseIcon,
    this.playIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      deliveryTrackingProvider.select((s) => (s.isPaused, s.isCompleted)),
    );
    final notifier = ref.read(deliveryTrackingProvider.notifier);

    final (isPaused, isCompleted) = state;

    return IconButton(
      onPressed: isCompleted ? null : notifier.togglePause,
      icon: isPaused
          ? (playIcon ?? const Icon(Icons.play_arrow))
          : (pauseIcon ?? const Icon(Icons.pause)),
      style: style,
    );
  }
}

/// Simple reset button
class DeliveryResetButton extends ConsumerWidget {
  final ButtonStyle? style;
  final Widget? icon;

  const DeliveryResetButton({
    super.key,
    this.style,
    this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(deliveryTrackingProvider.notifier);

    return IconButton(
      onPressed: notifier.reset,
      icon: icon ?? const Icon(Icons.refresh),
      style: style,
    );
  }
}
