import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';

/// Configuration for status card appearance
class DeliveryStatusCardConfig {
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final Color backgroundColor;
  final BoxShadow? shadow;
  final DeliveryStatusConfigs? statusConfigs;

  const DeliveryStatusCardConfig({
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.borderRadius = 12.0,
    this.backgroundColor = Colors.white,
    this.shadow,
    this.statusConfigs,
  });
}

/// Widget that displays delivery status and progress
class DeliveryStatusCard extends ConsumerWidget {
  final DeliveryStatusCardConfig config;
  final Widget Function(BuildContext, DeliveryTrackingState)? customBuilder;

  const DeliveryStatusCard({
    super.key,
    this.config = const DeliveryStatusCardConfig(),
    this.customBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryTrackingProvider);

    if (customBuilder != null) {
      return customBuilder!(context, state);
    }

    final statusConfig = config.statusConfigs?.getConfig(state.status) ??
        DeliveryStatusConfigs.defaultConfigFor(state.status);

    return Container(
      width: double.infinity,
      padding: config.padding,
      margin: config.margin,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(config.borderRadius),
        boxShadow: [
          config.shadow ??
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusConfig.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusConfig.icon,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusConfig.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${state.progressPercent}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: state.progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(statusConfig.color),
          ),
        ],
      ),
    );
  }
}
