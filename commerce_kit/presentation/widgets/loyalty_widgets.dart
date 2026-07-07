import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/loyalty_tier.dart';
import '../../core/enums/points_transaction_type.dart';
import '../../core/models/loyalty_account.dart';
import '../../core/models/money.dart';
import '../providers/loyalty_provider.dart';

/// A widget to display points balance.
class PointsBalanceWidget extends StatelessWidget {
  /// Points balance.
  final int points;

  /// Money value of points.
  final Money? pointsValue;

  /// Icon.
  final Widget? icon;

  /// Points label.
  final String pointsLabel;

  /// Show value.
  final bool showValue;

  /// Value label format.
  final String Function(Money value)? valueLabel;

  /// Title style.
  final TextStyle? titleStyle;

  /// Value style.
  final TextStyle? valueStyle;

  /// Points color.
  final Color? pointsColor;

  const PointsBalanceWidget({
    super.key,
    required this.points,
    this.pointsValue,
    this.icon,
    this.pointsLabel = 'Points',
    this.showValue = true,
    this.valueLabel,
    this.titleStyle,
    this.valueStyle,
    this.pointsColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = pointsColor ?? Colors.amber;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon ??
            Icon(
              Icons.stars,
              color: effectiveColor,
              size: 32,
            ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$points $pointsLabel',
              style: titleStyle ??
                  theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (showValue && pointsValue != null)
              Text(
                valueLabel?.call(pointsValue!) ?? '= ${pointsValue!.formatted}',
                style: valueStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A connected points balance widget.
class ConnectedPointsBalanceWidget extends ConsumerWidget {
  /// Icon.
  final Widget? icon;

  /// Points label.
  final String pointsLabel;

  /// Show value.
  final bool showValue;

  /// Value label format.
  final String Function(Money value)? valueLabel;

  /// Title style.
  final TextStyle? titleStyle;

  /// Value style.
  final TextStyle? valueStyle;

  /// Points color.
  final Color? pointsColor;

  const ConnectedPointsBalanceWidget({
    super.key,
    this.icon,
    this.pointsLabel = 'Points',
    this.showValue = true,
    this.valueLabel,
    this.titleStyle,
    this.valueStyle,
    this.pointsColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(pointsBalanceProvider);
    final value = ref.watch(pointsValueProvider);

    return PointsBalanceWidget(
      points: points,
      pointsValue: value,
      icon: icon,
      pointsLabel: pointsLabel,
      showValue: showValue,
      valueLabel: valueLabel,
      titleStyle: titleStyle,
      valueStyle: valueStyle,
      pointsColor: pointsColor,
    );
  }
}

/// A widget to display loyalty tier.
class LoyaltyTierWidget extends StatelessWidget {
  /// Current tier.
  final LoyaltyTier tier;

  /// Points to next tier.
  final int? pointsToNextTier;

  /// Progress to next tier (0-1).
  final double? progress;

  /// Show progress bar.
  final bool showProgress;

  /// Tier color (overrides default).
  final Color? tierColor;

  /// Progress bar color.
  final Color? progressColor;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const LoyaltyTierWidget({
    super.key,
    required this.tier,
    this.pointsToNextTier,
    this.progress,
    this.showProgress = true,
    this.tierColor,
    this.progressColor,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTierColor = tierColor ?? _getTierColor(tier);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveTierColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      effectiveTierColor.withValues(alpha: 0.8),
                      effectiveTierColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTierIcon(tier),
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tier.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (tier.pointsMultiplier > 1)
                Text(
                  '${tier.pointsMultiplier}x Points',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: effectiveTierColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (showProgress && tier.nextTier != null && progress != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                          effectiveTierColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(
                        progressColor ?? effectiveTierColor,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pointsToNextTier != null
                  ? '$pointsToNextTier points to ${tier.nextTier!.label}'
                  : '${(progress! * 100).toInt()}% to ${tier.nextTier!.label}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTierColor(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.none:
        return Colors.grey;
      case LoyaltyTier.bronze:
        return const Color(0xFFCD7F32);
      case LoyaltyTier.silver:
        return const Color(0xFFC0C0C0);
      case LoyaltyTier.gold:
        return const Color(0xFFFFD700);
      case LoyaltyTier.platinum:
        return const Color(0xFFE5E4E2);
      case LoyaltyTier.diamond:
        return const Color(0xFF00BFFF);
      case LoyaltyTier.vip:
        return const Color(0xFF8B008B);
    }
  }

  IconData _getTierIcon(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.none:
        return Icons.person_outline;
      case LoyaltyTier.bronze:
        return Icons.workspace_premium;
      case LoyaltyTier.silver:
        return Icons.workspace_premium;
      case LoyaltyTier.gold:
        return Icons.workspace_premium;
      case LoyaltyTier.platinum:
        return Icons.diamond_outlined;
      case LoyaltyTier.diamond:
        return Icons.diamond;
      case LoyaltyTier.vip:
        return Icons.star;
    }
  }
}

/// A connected loyalty tier widget.
class ConnectedLoyaltyTierWidget extends ConsumerWidget {
  /// Show progress bar.
  final bool showProgress;

  /// Tier color (overrides default).
  final Color? tierColor;

  /// Progress bar color.
  final Color? progressColor;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const ConnectedLoyaltyTierWidget({
    super.key,
    this.showProgress = true,
    this.tierColor,
    this.progressColor,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(loyaltyTierProvider);
    final nextTierProgress = ref.watch(nextTierProgressProvider);

    return LoyaltyTierWidget(
      tier: tier,
      pointsToNextTier: nextTierProgress.pointsNeeded,
      progress: nextTierProgress.progress,
      showProgress: showProgress,
      tierColor: tierColor,
      progressColor: progressColor,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding: padding,
    );
  }
}

/// A widget to display points that can be redeemed.
class PointsRedeemWidget extends StatelessWidget {
  /// Available points.
  final int availablePoints;

  /// Points value.
  final Money pointsValue;

  /// Whether redemption is enabled.
  final bool isEnabled;

  /// Whether points are being redeemed.
  final bool isRedeeming;

  /// Callback when toggle.
  final ValueChanged<bool>? onToggle;

  /// Icon.
  final Widget? icon;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const PointsRedeemWidget({
    super.key,
    required this.availablePoints,
    required this.pointsValue,
    this.isEnabled = true,
    this.isRedeeming = false,
    this.onToggle,
    this.icon,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          icon ??
              const Icon(
                Icons.stars,
                color: Colors.amber,
                size: 32,
              ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$availablePoints Points',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '= ${pointsValue.formatted}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isRedeeming,
            onChanged: isEnabled && availablePoints > 0 ? onToggle : null,
          ),
        ],
      ),
    );
  }
}

/// A connected points redeem widget.
class ConnectedPointsRedeemWidget extends ConsumerWidget {
  /// Icon.
  final Widget? icon;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const ConnectedPointsRedeemWidget({
    super.key,
    this.icon,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(pointsBalanceProvider);
    final value = ref.watch(pointsValueProvider);
    // Would need to import checkout provider for this
    // For now, just display the balance

    return PointsRedeemWidget(
      availablePoints: points,
      pointsValue: value,
      icon: icon,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding: padding,
    );
  }
}

/// A widget to display expiring points warning.
class ExpiringPointsWidget extends StatelessWidget {
  /// Expiring points.
  final int expiringPoints;

  /// Expiration date.
  final DateTime expiresAt;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const ExpiringPointsWidget({
    super.key,
    required this.expiringPoints,
    required this.expiresAt,
    this.backgroundColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    if (expiringPoints <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final daysRemaining = expiresAt.difference(DateTime.now()).inDays;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$expiringPoints points expiring in $daysRemaining days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A connected expiring points widget.
class ConnectedExpiringPointsWidget extends ConsumerWidget {
  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const ConnectedExpiringPointsWidget({
    super.key,
    this.backgroundColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiring = ref.watch(expiringPointsProvider);

    if (expiring.points <= 0 || expiring.expiresAt == null) {
      return const SizedBox.shrink();
    }

    return ExpiringPointsWidget(
      expiringPoints: expiring.points,
      expiresAt: expiring.expiresAt!,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding: padding,
    );
  }
}

/// A loyalty banner widget.
class LoyaltyBannerWidget extends StatelessWidget {
  /// Title.
  final String title;

  /// Subtitle.
  final String? subtitle;

  /// Icon or image.
  final Widget? leading;

  /// Action widget.
  final Widget? trailing;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Background color.
  final Color? backgroundColor;

  /// Gradient colors.
  final List<Color>? gradientColors;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const LoyaltyBannerWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.gradientColors,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: gradientColors == null ? backgroundColor : null,
          gradient: gradientColors != null
              ? LinearGradient(
                  colors: gradientColors!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// A widget to display points transaction history.
class PointsTransactionList extends StatelessWidget {
  /// List of transactions.
  final List<PointsTransaction> transactions;

  /// Empty state widget.
  final Widget? emptyWidget;

  /// Item builder for customization.
  final Widget Function(BuildContext, PointsTransaction)? itemBuilder;

  /// Max items to show (null = all).
  final int? maxItems;

  /// Show all link callback.
  final VoidCallback? onShowAll;

  const PointsTransactionList({
    super.key,
    required this.transactions,
    this.emptyWidget,
    this.itemBuilder,
    this.maxItems,
    this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return emptyWidget ??
          const Center(
            child: Text('No transactions yet'),
          );
    }

    final displayTransactions =
        maxItems != null ? transactions.take(maxItems!).toList() : transactions;

    return Column(
      children: [
        ...displayTransactions.map(
          (t) => itemBuilder?.call(context, t) ?? _buildDefaultItem(context, t),
        ),
        if (maxItems != null &&
            transactions.length > maxItems! &&
            onShowAll != null)
          TextButton(
            onPressed: onShowAll,
            child: const Text('Show all'),
          ),
      ],
    );
  }

  Widget _buildDefaultItem(
    BuildContext context,
    PointsTransaction transaction,
  ) {
    final theme = Theme.of(context);
    final isCredit = transaction.type.isCredit;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  (isCredit ? Colors.green : Colors.red).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.add : Icons.remove,
              color: isCredit ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (transaction.description != null)
                  Text(
                    transaction.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            transaction.formattedPoints,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isCredit ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// A connected points transaction list.
class ConnectedPointsTransactionList extends ConsumerWidget {
  /// Empty state widget.
  final Widget? emptyWidget;

  /// Max items to show.
  final int? maxItems;

  /// Show all link callback.
  final VoidCallback? onShowAll;

  const ConnectedPointsTransactionList({
    super.key,
    this.emptyWidget,
    this.maxItems,
    this.onShowAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(pointsTransactionsProvider);

    return PointsTransactionList(
      transactions: transactions,
      emptyWidget: emptyWidget,
      maxItems: maxItems,
      onShowAll: onShowAll,
    );
  }
}
