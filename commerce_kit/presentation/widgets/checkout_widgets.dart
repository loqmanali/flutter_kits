import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/payment_method.dart';
import '../../core/models/money.dart';
import '../../core/models/order_summary.dart';
import '../../core/models/shipping_method.dart';
import '../providers/checkout_provider.dart';

/// A widget that displays the order summary in a checkout flow.
class OrderSummaryWidget extends StatelessWidget {
  /// The order summary to display.
  final OrderSummary summary;

  /// Whether to show all line items (including zero amounts).
  final bool showAllItems;

  /// Custom styling.
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final TextStyle? totalLabelStyle;
  final TextStyle? totalValueStyle;
  final TextStyle? discountStyle;
  final TextStyle? strikethroughStyle;

  /// Custom colors.
  final Color? discountColor;
  final Color? strikethroughColor;

  /// Padding between rows.
  final double rowSpacing;

  /// Padding before total row.
  final double totalSpacing;

  /// Divider before total.
  final bool showDivider;
  final Color? dividerColor;

  /// Custom labels for different line item types.
  final String? subtotalLabel;
  final String? itemDiscountLabel;
  final String? discountLabel;
  final String? deliveryFeeLabel;
  final String? serviceFeeLabel;
  final String? handlingFeeLabel;
  final String? packagingFeeLabel;
  final String? taxLabel;
  final String? tipLabel;
  final String? walletLabel;
  final String? pointsLabel;
  final String? giftCardLabel;
  final String? storeCreditLabel;
  final String? totalLabel;

  const OrderSummaryWidget({
    super.key,
    required this.summary,
    this.showAllItems = false,
    this.labelStyle,
    this.valueStyle,
    this.totalLabelStyle,
    this.totalValueStyle,
    this.discountStyle,
    this.strikethroughStyle,
    this.discountColor,
    this.strikethroughColor,
    this.rowSpacing = 12.0,
    this.totalSpacing = 16.0,
    this.showDivider = true,
    this.dividerColor,
    this.subtotalLabel,
    this.itemDiscountLabel,
    this.discountLabel,
    this.deliveryFeeLabel,
    this.serviceFeeLabel,
    this.handlingFeeLabel,
    this.packagingFeeLabel,
    this.taxLabel,
    this.tipLabel,
    this.walletLabel,
    this.pointsLabel,
    this.giftCardLabel,
    this.storeCreditLabel,
    this.totalLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineItems = summary.toLineItems(includeZeroAmounts: showAllItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lineItems.length; i++) ...[
          if (lineItems[i].type == SummaryLineItemType.total) ...[
            if (showDivider)
              Padding(
                padding: EdgeInsets.symmetric(vertical: totalSpacing / 2),
                child: Divider(color: dividerColor),
              )
            else
              SizedBox(height: totalSpacing),
            _buildTotalRow(context, lineItems[i], theme),
          ] else ...[
            _buildLineItem(context, lineItems[i], theme),
            if (i < lineItems.length - 1 &&
                lineItems[i + 1].type != SummaryLineItemType.total)
              SizedBox(height: rowSpacing),
          ],
        ],
      ],
    );
  }

  /// Returns the custom label for a line item type, or the default label if not provided.
  String _getCustomLabel(SummaryLineItem item) {
    switch (item.type) {
      case SummaryLineItemType.subtotal:
        return subtotalLabel ?? item.label;
      case SummaryLineItemType.discount:
        if (item.label.startsWith('Coupon')) {
          return discountLabel ?? item.label;
        }
        return itemDiscountLabel ?? item.label;
      case SummaryLineItemType.shipping:
        return deliveryFeeLabel ?? item.label;
      case SummaryLineItemType.fee:
        if (item.label == 'Service Fee') {
          return serviceFeeLabel ?? item.label;
        } else if (item.label == 'Handling Fee') {
          return handlingFeeLabel ?? item.label;
        } else if (item.label == 'Packaging Fee') {
          return packagingFeeLabel ?? item.label;
        }
        return item.label;
      case SummaryLineItemType.tax:
        return taxLabel ?? item.label;
      case SummaryLineItemType.tip:
        return tipLabel ?? item.label;
      case SummaryLineItemType.credit:
        if (item.label == 'Wallet') {
          return walletLabel ?? item.label;
        } else if (item.label.startsWith('Points')) {
          return pointsLabel ?? item.label;
        } else if (item.label == 'Gift Card') {
          return giftCardLabel ?? item.label;
        } else if (item.label == 'Store Credit') {
          return storeCreditLabel ?? item.label;
        }
        return item.label;
      case SummaryLineItemType.total:
        return totalLabel ?? item.label;
    }
  }

  Widget _buildLineItem(
    BuildContext context,
    SummaryLineItem item,
    ThemeData theme,
  ) {
    final isDiscount = item.type == SummaryLineItemType.discount ||
        item.type == SummaryLineItemType.credit;
    final effectiveValueStyle = isDiscount
        ? (discountStyle ??
            valueStyle?.copyWith(color: discountColor ?? Colors.green) ??
            theme.textTheme.bodyMedium?.copyWith(
              color: discountColor ?? Colors.green,
            ))
        : (valueStyle ?? theme.textTheme.bodyMedium);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getCustomLabel(item),
                style: labelStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              ),
              if (item.description != null)
                Text(
                  item.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.hasStrikethrough) ...[
              Text(
                item.originalAmount!.formattedWithSymbolForLocale(
                  Localizations.localeOf(context),
                ),
                style: strikethroughStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: strikethroughColor ??
                          theme.colorScheme.onSurfaceVariant,
                      decoration: TextDecoration.lineThrough,
                    ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              item.amount.formattedWithSymbolForLocale(
                Localizations.localeOf(context),
              ),
              style: effectiveValueStyle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    SummaryLineItem item,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _getCustomLabel(item),
          style: totalLabelStyle ??
              theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          item.amount.formattedWithSymbolForLocale(
            Localizations.localeOf(context),
          ),
          style: totalValueStyle ??
              theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

/// A connected order summary widget that uses Riverpod.
class ConnectedOrderSummaryWidget extends ConsumerWidget {
  /// Whether to show all line items.
  final bool showAllItems;

  /// Custom styling (same as OrderSummaryWidget).
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final TextStyle? totalLabelStyle;
  final TextStyle? totalValueStyle;
  final double rowSpacing;
  final double totalSpacing;
  final bool showDivider;

  /// Custom labels for different line item types.
  final String? subtotalLabel;
  final String? itemDiscountLabel;
  final String? discountLabel;
  final String? deliveryFeeLabel;
  final String? serviceFeeLabel;
  final String? handlingFeeLabel;
  final String? packagingFeeLabel;
  final String? taxLabel;
  final String? tipLabel;
  final String? walletLabel;
  final String? pointsLabel;
  final String? giftCardLabel;
  final String? storeCreditLabel;
  final String? totalLabel;

  const ConnectedOrderSummaryWidget({
    super.key,
    this.showAllItems = false,
    this.labelStyle,
    this.valueStyle,
    this.totalLabelStyle,
    this.totalValueStyle,
    this.rowSpacing = 12.0,
    this.totalSpacing = 16.0,
    this.showDivider = true,
    this.subtotalLabel,
    this.itemDiscountLabel,
    this.discountLabel,
    this.deliveryFeeLabel,
    this.serviceFeeLabel,
    this.handlingFeeLabel,
    this.packagingFeeLabel,
    this.taxLabel,
    this.tipLabel,
    this.walletLabel,
    this.pointsLabel,
    this.giftCardLabel,
    this.storeCreditLabel,
    this.totalLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(orderSummaryProvider);
    return OrderSummaryWidget(
      summary: summary,
      showAllItems: showAllItems,
      labelStyle: labelStyle,
      valueStyle: valueStyle,
      totalLabelStyle: totalLabelStyle,
      totalValueStyle: totalValueStyle,
      rowSpacing: rowSpacing,
      totalSpacing: totalSpacing,
      showDivider: showDivider,
      subtotalLabel: subtotalLabel,
      itemDiscountLabel: itemDiscountLabel,
      discountLabel: discountLabel,
      deliveryFeeLabel: deliveryFeeLabel,
      serviceFeeLabel: serviceFeeLabel,
      handlingFeeLabel: handlingFeeLabel,
      packagingFeeLabel: packagingFeeLabel,
      taxLabel: taxLabel,
      tipLabel: tipLabel,
      walletLabel: walletLabel,
      pointsLabel: pointsLabel,
      giftCardLabel: giftCardLabel,
      storeCreditLabel: storeCreditLabel,
      totalLabel: totalLabel,
    );
  }
}

/// A widget to select payment methods.
class PaymentMethodSelector extends StatelessWidget {
  /// Available payment methods.
  final List<PaymentMethod> methods;

  /// Currently selected method.
  final PaymentMethod? selected;

  /// Callback when selection changes.
  final ValueChanged<PaymentMethod>? onSelected;

  /// Custom icons for payment methods (method -> icon widget).
  final Map<PaymentMethod, Widget>? customIcons;

  /// Custom labels for payment methods.
  final Map<PaymentMethod, String>? customLabels;

  /// Selected color.
  final Color? selectedColor;

  /// Border radius.
  final double borderRadius;

  /// Spacing between items.
  final double spacing;

  const PaymentMethodSelector({
    super.key,
    required this.methods,
    this.selected,
    this.onSelected,
    this.customIcons,
    this.customLabels,
    this.selectedColor,
    this.borderRadius = 12.0,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveSelectedColor = selectedColor ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < methods.length; i++) ...[
          _buildMethodItem(
            context,
            methods[i],
            methods[i] == selected,
            effectiveSelectedColor,
            theme,
          ),
          if (i < methods.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }

  Widget _buildMethodItem(
    BuildContext context,
    PaymentMethod method,
    bool isSelected,
    Color selectedColor,
    ThemeData theme,
  ) {
    final icon = customIcons?[method] ?? _getDefaultIcon(method, theme);
    final label = customLabels?[method] ?? method.label;

    return InkWell(
      onTap: onSelected != null ? () => onSelected!(method) : null,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: selectedColor,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: theme.colorScheme.outline,
              ),
          ],
        ),
      ),
    );
  }

  Widget _getDefaultIcon(PaymentMethod method, ThemeData theme) {
    IconData iconData;
    switch (method) {
      case PaymentMethod.cashOnDelivery:
        iconData = Icons.payments_outlined;
      case PaymentMethod.card:
        iconData = Icons.credit_card;
      case PaymentMethod.applePay:
        iconData = Icons.apple;
      case PaymentMethod.googlePay:
        iconData = Icons.g_mobiledata;
      case PaymentMethod.paypal:
        iconData = Icons.paypal_outlined;
      case PaymentMethod.wallet:
        iconData = Icons.account_balance_wallet_outlined;
      case PaymentMethod.bankTransfer:
        iconData = Icons.account_balance_outlined;
      case PaymentMethod.bnpl:
        iconData = Icons.schedule;
      case PaymentMethod.crypto:
        iconData = Icons.currency_bitcoin;
      case PaymentMethod.storeCredit:
        iconData = Icons.store;
      case PaymentMethod.giftCard:
        iconData = Icons.card_giftcard;
      case PaymentMethod.pointsOnly:
        iconData = Icons.stars;
      case PaymentMethod.mixed:
        iconData = Icons.payments;
    }
    return Icon(iconData, color: theme.colorScheme.primary);
  }
}

/// A connected payment method selector that uses Riverpod.
class ConnectedPaymentMethodSelector extends ConsumerWidget {
  /// Custom icons for payment methods.
  final Map<PaymentMethod, Widget>? customIcons;

  /// Custom labels for payment methods.
  final Map<PaymentMethod, String>? customLabels;

  /// Selected color.
  final Color? selectedColor;

  /// Border radius.
  final double borderRadius;

  /// Spacing between items.
  final double spacing;

  const ConnectedPaymentMethodSelector({
    super.key,
    this.customIcons,
    this.customLabels,
    this.selectedColor,
    this.borderRadius = 12.0,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = ref.watch(availablePaymentMethodsProvider);
    final selected = ref.watch(checkoutPaymentMethodProvider);

    return PaymentMethodSelector(
      methods: methods,
      selected: selected,
      onSelected: (method) {
        ref.read(checkoutProvider.notifier).setPaymentMethod(method);
      },
      customIcons: customIcons,
      customLabels: customLabels,
      selectedColor: selectedColor,
      borderRadius: borderRadius,
      spacing: spacing,
    );
  }
}

/// A widget to select shipping methods.
class ShippingMethodSelector extends StatelessWidget {
  /// Available shipping methods.
  final List<ShippingMethod> methods;

  /// Currently selected method.
  final ShippingMethod? selected;

  /// Callback when selection changes.
  final ValueChanged<ShippingMethod>? onSelected;

  /// Selected color.
  final Color? selectedColor;

  /// Border radius.
  final double borderRadius;

  /// Spacing between items.
  final double spacing;

  /// Show estimated time.
  final bool showEstimatedTime;

  const ShippingMethodSelector({
    super.key,
    required this.methods,
    this.selected,
    this.onSelected,
    this.selectedColor,
    this.borderRadius = 12.0,
    this.spacing = 12.0,
    this.showEstimatedTime = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveSelectedColor = selectedColor ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < methods.length; i++) ...[
          _buildMethodItem(
            context,
            methods[i],
            methods[i] == selected,
            effectiveSelectedColor,
            theme,
          ),
          if (i < methods.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }

  Widget _buildMethodItem(
    BuildContext context,
    ShippingMethod method,
    bool isSelected,
    Color selectedColor,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: method.isAvailable && onSelected != null
          ? () => onSelected!(method)
          : null,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: !method.isAvailable
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : isSelected
                  ? selectedColor.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: !method.isAvailable
                ? theme.colorScheme.outline.withValues(alpha: 0.2)
                : isSelected
                    ? selectedColor
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        method.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color:
                              method.isAvailable ? null : theme.disabledColor,
                        ),
                      ),
                      if (method.isFree) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'FREE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (showEstimatedTime &&
                      method.estimatedTimeFormatted.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        method.estimatedTimeFormatted,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (method.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        method.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (!method.isAvailable && method.unavailableReason != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        method.unavailableReason!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (method.hasDiscount) ...[
                  Text(
                    method.originalCost!.formattedWithSymbol,
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  method.isFree ? 'Free' : method.cost.formattedWithSymbol,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: method.isFree ? Colors.green : null,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: selectedColor,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: method.isAvailable
                    ? theme.colorScheme.outline
                    : theme.disabledColor,
              ),
          ],
        ),
      ),
    );
  }
}

/// A connected shipping method selector that uses Riverpod.
class ConnectedShippingMethodSelector extends ConsumerWidget {
  /// Selected color.
  final Color? selectedColor;

  /// Border radius.
  final double borderRadius;

  /// Spacing between items.
  final double spacing;

  /// Show estimated time.
  final bool showEstimatedTime;

  const ConnectedShippingMethodSelector({
    super.key,
    this.selectedColor,
    this.borderRadius = 12.0,
    this.spacing = 12.0,
    this.showEstimatedTime = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = ref.watch(availableShippingMethodsProvider);
    final selected = ref.watch(checkoutShippingMethodProvider);

    return ShippingMethodSelector(
      methods: methods,
      selected: selected,
      onSelected: (method) {
        ref.read(checkoutProvider.notifier).setShippingMethod(method);
      },
      selectedColor: selectedColor,
      borderRadius: borderRadius,
      spacing: spacing,
      showEstimatedTime: showEstimatedTime,
    );
  }
}

/// A widget to display earned rewards/points for an order.
class EarnedRewardsWidget extends StatelessWidget {
  /// Points to be earned.
  final int pointsToEarn;

  /// Cashback to be earned.
  final Money? cashbackToEarn;

  /// Icon for points.
  final Widget? pointsIcon;

  /// Icon for cashback.
  final Widget? cashbackIcon;

  /// Text style.
  final TextStyle? textStyle;

  /// Points color.
  final Color? pointsColor;

  /// Cashback color.
  final Color? cashbackColor;

  const EarnedRewardsWidget({
    super.key,
    required this.pointsToEarn,
    this.cashbackToEarn,
    this.pointsIcon,
    this.cashbackIcon,
    this.textStyle,
    this.pointsColor,
    this.cashbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePointsColor = pointsColor ?? Colors.amber;
    final effectiveCashbackColor = cashbackColor ?? Colors.green;

    if (pointsToEarn <= 0 &&
        (cashbackToEarn == null || cashbackToEarn!.isZero)) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        if (pointsToEarn > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              pointsIcon ??
                  Icon(
                    Icons.stars,
                    color: effectivePointsColor,
                    size: 18,
                  ),
              const SizedBox(width: 4),
              Text(
                'Earn $pointsToEarn points',
                style: textStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: effectivePointsColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        if (cashbackToEarn != null && cashbackToEarn!.isPositive)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              cashbackIcon ??
                  Icon(
                    Icons.savings_outlined,
                    color: effectiveCashbackColor,
                    size: 18,
                  ),
              const SizedBox(width: 4),
              Text(
                '${cashbackToEarn!.formattedWithSymbol} cashback',
                style: textStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: effectiveCashbackColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
      ],
    );
  }
}

/// A connected earned rewards widget that uses Riverpod.
class ConnectedEarnedRewardsWidget extends ConsumerWidget {
  /// Icon for points.
  final Widget? pointsIcon;

  /// Icon for cashback.
  final Widget? cashbackIcon;

  /// Text style.
  final TextStyle? textStyle;

  /// Points color.
  final Color? pointsColor;

  /// Cashback color.
  final Color? cashbackColor;

  const ConnectedEarnedRewardsWidget({
    super.key,
    this.pointsIcon,
    this.cashbackIcon,
    this.textStyle,
    this.pointsColor,
    this.cashbackColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointsToEarn = ref.watch(pointsToEarnProvider);
    final cashbackToEarn = ref.watch(cashbackToEarnProvider);

    return EarnedRewardsWidget(
      pointsToEarn: pointsToEarn,
      cashbackToEarn: cashbackToEarn,
      pointsIcon: pointsIcon,
      cashbackIcon: cashbackIcon,
      textStyle: textStyle,
      pointsColor: pointsColor,
      cashbackColor: cashbackColor,
    );
  }
}

/// A widget displaying total savings.
class TotalSavingsWidget extends StatelessWidget {
  /// Total savings amount.
  final Money savings;

  /// Text prefix.
  final String prefix;

  /// Text suffix.
  final String suffix;

  /// Icon.
  final Widget? icon;

  /// Text style.
  final TextStyle? textStyle;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const TotalSavingsWidget({
    super.key,
    required this.savings,
    this.prefix = 'You saved ',
    this.suffix = ' on this order!',
    this.icon,
    this.textStyle,
    this.backgroundColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    if (savings.isZero) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ?? Colors.green.withValues(alpha: 0.1);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon ??
              const Icon(
                Icons.celebration,
                color: Colors.green,
                size: 20,
              ),
          const SizedBox(width: 8),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: textStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                children: [
                  TextSpan(text: prefix),
                  TextSpan(
                    text: savings.formattedWithSymbol,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: suffix),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget for tip selection.
class TipSelector extends StatelessWidget {
  /// Available tip percentages.
  final List<double> percentages;

  /// Currently selected percentage.
  final double? selectedPercentage;

  /// Custom tip amount.
  final Money? customAmount;

  /// Base amount to calculate tip from.
  final Money baseAmount;

  /// Callback when percentage selected.
  final ValueChanged<double>? onPercentageSelected;

  /// Callback when custom amount selected.
  final ValueChanged<Money>? onCustomAmountSelected;

  /// Selected color.
  final Color? selectedColor;

  /// Border radius.
  final double borderRadius;

  /// Spacing.
  final double spacing;

  /// Allow custom amount.
  final bool allowCustom;

  /// Custom label.
  final String customLabel;

  const TipSelector({
    super.key,
    this.percentages = const [10, 15, 20],
    this.selectedPercentage,
    this.customAmount,
    required this.baseAmount,
    this.onPercentageSelected,
    this.onCustomAmountSelected,
    this.selectedColor,
    this.borderRadius = 12.0,
    this.spacing = 8.0,
    this.allowCustom = true,
    this.customLabel = 'Custom',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveSelectedColor = selectedColor ?? theme.colorScheme.primary;
    final hasCustom = customAmount != null;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        // No tip option
        _buildChip(
          context,
          label: 'No tip',
          isSelected: selectedPercentage == 0 && !hasCustom,
          selectedColor: effectiveSelectedColor,
          onTap: () => onPercentageSelected?.call(0),
        ),
        // Percentage options
        ...percentages.map((percent) {
          final amount = baseAmount * (percent / 100);
          return _buildChip(
            context,
            label: '${percent.toInt()}%',
            subtitle: amount.formattedWithSymbol,
            isSelected: selectedPercentage == percent && !hasCustom,
            selectedColor: effectiveSelectedColor,
            onTap: () => onPercentageSelected?.call(percent),
          );
        }),
        // Custom option
        if (allowCustom)
          _buildChip(
            context,
            label: customLabel,
            subtitle: hasCustom ? customAmount!.formattedWithSymbol : null,
            isSelected: hasCustom,
            selectedColor: effectiveSelectedColor,
            onTap: () {
              // Would typically show a dialog
              onCustomAmountSelected?.call(const Money.zero());
            },
          ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    String? subtitle,
    required bool isSelected,
    required Color selectedColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A place order button.
class PlaceOrderButton extends StatelessWidget {
  /// Total amount.
  final Money totalAmount;

  /// Whether the button is enabled.
  final bool enabled;

  /// Whether loading.
  final bool isLoading;

  /// Button label.
  final String label;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Background color.
  final Color? backgroundColor;

  /// Foreground color.
  final Color? foregroundColor;

  /// Border radius.
  final double borderRadius;

  /// Height.
  final double height;

  const PlaceOrderButton({
    super.key,
    required this.totalAmount,
    this.enabled = true,
    this.isLoading = false,
    this.label = 'Place Order',
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 12.0,
    this.height = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor ?? theme.colorScheme.onPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: foregroundColor ?? theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${totalAmount.formattedWithSymbol}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: (foregroundColor ?? theme.colorScheme.onPrimary)
                          .withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// A connected place order button that uses Riverpod.
class ConnectedPlaceOrderButton extends ConsumerWidget {
  /// Button label.
  final String label;

  /// Background color.
  final Color? backgroundColor;

  /// Foreground color.
  final Color? foregroundColor;

  /// Border radius.
  final double borderRadius;

  /// Height.
  final double height;

  /// Callback after successful order.
  final void Function(dynamic order)? onOrderPlaced;

  const ConnectedPlaceOrderButton({
    super.key,
    this.label = 'Place Order',
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 12.0,
    this.height = 56.0,
    this.onOrderPlaced,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(orderSummaryProvider);
    final isReady = ref.watch(checkoutReadyProvider);
    final isProcessing = ref.watch(checkoutProcessingProvider);

    return PlaceOrderButton(
      totalAmount: summary.total,
      enabled: isReady,
      isLoading: isProcessing,
      label: label,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderRadius: borderRadius,
      height: height,
      onPressed: () async {
        final order = await ref.read(checkoutProvider.notifier).placeOrder();
        if (order != null && onOrderPlaced != null) {
          onOrderPlaced!(order);
        }
      },
    );
  }
}
