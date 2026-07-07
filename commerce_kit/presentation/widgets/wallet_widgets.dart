import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/wallet_transaction_type.dart';
import '../../core/models/money.dart';
import '../../core/models/wallet.dart';
import '../providers/wallet_provider.dart';

/// A widget to display wallet balance.
class WalletBalanceWidget extends StatelessWidget {
  /// Total balance.
  final Money balance;

  /// Balance breakdown.
  final WalletBalanceBreakdown? breakdown;

  /// Icon.
  final Widget? icon;

  /// Show breakdown.
  final bool showBreakdown;

  /// Title style.
  final TextStyle? titleStyle;

  /// Balance style.
  final TextStyle? balanceStyle;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const WalletBalanceWidget({
    super.key,
    required this.balance,
    this.breakdown,
    this.icon,
    this.showBreakdown = false,
    this.titleStyle,
    this.balanceStyle,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon ??
                  Icon(
                    Icons.account_balance_wallet,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Balance',
                      style: titleStyle ??
                          theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      balance.formatted,
                      style: balanceStyle ??
                          theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showBreakdown && breakdown != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildBreakdownRow(
              context,
              'Main Balance',
              breakdown!.mainBalance,
              theme,
            ),
            if (breakdown!.promotionalBalance.isPositive) ...[
              const SizedBox(height: 8),
              _buildBreakdownRow(
                context,
                'Promotional',
                breakdown!.promotionalBalance,
                theme,
                color: Colors.amber,
              ),
            ],
            if (breakdown!.cashbackBalance.isPositive) ...[
              const SizedBox(height: 8),
              _buildBreakdownRow(
                context,
                'Cashback',
                breakdown!.cashbackBalance,
                theme,
                color: Colors.green,
              ),
            ],
            if (breakdown!.pendingBalance.isPositive) ...[
              const SizedBox(height: 8),
              _buildBreakdownRow(
                context,
                'Pending',
                breakdown!.pendingBalance,
                theme,
                color: Colors.orange,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context,
    String label,
    Money amount,
    ThemeData theme, {
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (color != null)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Text(
          amount.formatted,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// A connected wallet balance widget.
class ConnectedWalletBalanceWidget extends ConsumerWidget {
  /// Icon.
  final Widget? icon;

  /// Show breakdown.
  final bool showBreakdown;

  /// Title style.
  final TextStyle? titleStyle;

  /// Balance style.
  final TextStyle? balanceStyle;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const ConnectedWalletBalanceWidget({
    super.key,
    this.icon,
    this.showBreakdown = false,
    this.titleStyle,
    this.balanceStyle,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletTotalBalanceProvider);
    final breakdown = ref.watch(walletBalanceBreakdownProvider);

    return WalletBalanceWidget(
      balance: balance,
      breakdown: breakdown,
      icon: icon,
      showBreakdown: showBreakdown,
      titleStyle: titleStyle,
      balanceStyle: balanceStyle,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding: padding,
    );
  }
}

/// A widget to toggle wallet usage in checkout.
class WalletToggleWidget extends StatelessWidget {
  /// Available balance.
  final Money availableBalance;

  /// Whether wallet is being used.
  final bool isEnabled;

  /// Amount being used.
  final Money amountUsed;

  /// Callback when toggled.
  final ValueChanged<bool>? onToggle;

  /// Icon.
  final Widget? icon;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const WalletToggleWidget({
    super.key,
    required this.availableBalance,
    this.isEnabled = false,
    this.amountUsed = const Money.zero(),
    this.onToggle,
    this.icon,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBalance = availableBalance.isPositive;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          icon ??
              Icon(
                Icons.account_balance_wallet_outlined,
                color: hasBalance
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
                size: 24,
              ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use Wallet',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  hasBalance
                      ? 'Balance: ${availableBalance.formatted}'
                      : 'No balance available',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isEnabled && amountUsed.isPositive) ...[
            Text(
              '-${amountUsed.formatted}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Switch(
            value: isEnabled,
            onChanged: hasBalance ? onToggle : null,
          ),
        ],
      ),
    );
  }
}

/// A connected wallet toggle widget.
class ConnectedWalletToggleWidget extends ConsumerWidget {
  /// Icon.
  final Widget? icon;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  /// Callback when toggled (receives the new value).
  final ValueChanged<bool>? onToggle;

  const ConnectedWalletToggleWidget({
    super.key,
    this.icon,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
    this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletTotalBalanceProvider);
    // Would need to integrate with checkout provider for full functionality

    return WalletToggleWidget(
      availableBalance: balance,
      icon: icon,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding: padding,
      onToggle: onToggle,
    );
  }
}

/// A widget to display wallet transactions.
class WalletTransactionList extends StatelessWidget {
  /// List of transactions.
  final List<WalletTransaction> transactions;

  /// Empty state widget.
  final Widget? emptyWidget;

  /// Item builder for customization.
  final Widget Function(BuildContext, WalletTransaction)? itemBuilder;

  /// Max items to show (null = all).
  final int? maxItems;

  /// Show all link callback.
  final VoidCallback? onShowAll;

  const WalletTransactionList({
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

    final displayTransactions = maxItems != null
        ? transactions.take(maxItems!).toList()
        : transactions;

    return Column(
      children: [
        ...displayTransactions.map((t) =>
            itemBuilder?.call(context, t) ?? _buildDefaultItem(context, t),),
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

  Widget _buildDefaultItem(BuildContext context, WalletTransaction transaction) {
    final theme = Theme.of(context);
    final isCredit = transaction.type.isCredit;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isCredit ? Colors.green : Colors.red)
                  .withValues(alpha: 0.1),
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
            transaction.formattedAmount,
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

/// A connected wallet transaction list.
class ConnectedWalletTransactionList extends ConsumerWidget {
  /// Empty state widget.
  final Widget? emptyWidget;

  /// Max items to show.
  final int? maxItems;

  /// Show all link callback.
  final VoidCallback? onShowAll;

  const ConnectedWalletTransactionList({
    super.key,
    this.emptyWidget,
    this.maxItems,
    this.onShowAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(walletTransactionsProvider);

    return WalletTransactionList(
      transactions: transactions,
      emptyWidget: emptyWidget,
      maxItems: maxItems,
      onShowAll: onShowAll,
    );
  }
}

/// A compact wallet display for checkout.
class WalletCheckoutWidget extends StatelessWidget {
  /// Available balance.
  final Money availableBalance;

  /// Whether wallet is being used.
  final bool isUsing;

  /// Amount being used.
  final Money amountUsed;

  /// Callback when toggled.
  final ValueChanged<bool>? onToggle;

  /// Expiring balance.
  final Money? expiringBalance;

  /// Expiration date.
  final DateTime? expiresAt;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const WalletCheckoutWidget({
    super.key,
    required this.availableBalance,
    this.isUsing = false,
    this.amountUsed = const Money.zero(),
    this.onToggle,
    this.expiringBalance,
    this.expiresAt,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBalance = availableBalance.isPositive;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: hasBalance
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use Wallet',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      availableBalance.formatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isUsing,
                onChanged: hasBalance ? onToggle : null,
              ),
            ],
          ),
          if (expiringBalance != null &&
              expiringBalance!.isPositive &&
              expiresAt != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${expiringBalance!.formatted} expiring in ${expiresAt!.difference(DateTime.now()).inDays} days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
