import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';

/// Configuration for info panel appearance
class DeliveryInfoPanelConfig {
  final EdgeInsets padding;
  final Color backgroundColor;
  final BoxShadow? shadow;

  const DeliveryInfoPanelConfig({
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
    this.shadow,
  });
}

/// Widget that displays delivery details (from, to, distance, ETA)
class DeliveryInfoPanel extends ConsumerWidget {
  final DeliveryInfoPanelConfig config;
  final String? title;
  final Widget Function(BuildContext, DeliveryTrackingState)? customBuilder;
  final String Function(Duration)? formatDuration;
  final String Function(double)? formatDistance;

  const DeliveryInfoPanel({
    super.key,
    this.config = const DeliveryInfoPanelConfig(),
    this.title,
    this.customBuilder,
    this.formatDuration,
    this.formatDistance,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryTrackingProvider);

    if (customBuilder != null) {
      return customBuilder!(context, state);
    }

    return Container(
      padding: config.padding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        boxShadow: [
          config.shadow ??
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'From',
                  value: state.origin.label,
                  icon: Icons.restaurant,
                  color: Colors.red,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'To',
                  value: state.destination.label,
                  icon: Icons.home,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'Distance',
                  value: formatDistance != null
                      ? formatDistance!(state.remainingDistanceKm)
                      : '${state.remainingDistanceKm.toStringAsFixed(1)} km',
                  icon: Icons.straighten,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'ETA',
                  value: formatDuration != null
                      ? formatDuration!(state.remainingTime)
                      : _defaultFormatDuration(state.remainingTime),
                  icon: Icons.schedule,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _defaultFormatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes} min';
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
