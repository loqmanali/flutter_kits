import 'package:flutter/material.dart';

import '../../core/models/money.dart';
import '../../core/models/price_breakdown.dart';

/// A widget for displaying cart price summary.
///
/// ## Usage
///
/// ```dart
/// CartSummaryWidget(
///   breakdown: priceBreakdown,
/// )
/// ```
class CartSummaryWidget extends StatelessWidget {
  /// The price breakdown to display.
  final PriceBreakdown breakdown;

  /// Whether to show all line items.
  final bool showDetails;

  /// Text style for labels.
  final TextStyle? labelStyle;

  /// Text style for values.
  final TextStyle? valueStyle;

  /// Text style for total.
  final TextStyle? totalStyle;

  /// Padding between rows.
  final double rowSpacing;

  const CartSummaryWidget({
    super.key,
    required this.breakdown,
    this.showDetails = true,
    this.labelStyle,
    this.valueStyle,
    this.totalStyle,
    this.rowSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveLabelStyle = labelStyle ?? theme.textTheme.bodyMedium;
    final effectiveValueStyle = valueStyle ?? theme.textTheme.bodyMedium;
    final effectiveTotalStyle = totalStyle ??
        theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        );

    if (!showDetails) {
      return _buildRow(
        context,
        'Total',
        breakdown.total.formatted,
        effectiveTotalStyle!,
        effectiveTotalStyle,
      );
    }

    return Column(
      children: [
        // Subtotal
        _buildRow(
          context,
          'Subtotal',
          breakdown.subtotal.formatted,
          effectiveLabelStyle!,
          effectiveValueStyle!,
        ),

        // Discount
        if (breakdown.hasDiscount) ...[
          SizedBox(height: rowSpacing),
          _buildRow(
            context,
            'Discount',
            '-${breakdown.discount.formatted}',
            effectiveLabelStyle,
            effectiveValueStyle.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],

        // Shipping
        if (!breakdown.shipping.isZero || breakdown.isFreeShipping) ...[
          SizedBox(height: rowSpacing),
          _buildRow(
            context,
            'Shipping',
            breakdown.isFreeShipping ? 'Free' : breakdown.shipping.formatted,
            effectiveLabelStyle,
            effectiveValueStyle.copyWith(
              color: breakdown.isFreeShipping
                  ? theme.colorScheme.primary
                  : null,
            ),
          ),
        ],

        // Tax
        if (breakdown.hasTax) ...[
          SizedBox(height: rowSpacing),
          _buildRow(
            context,
            breakdown.taxRate != null
                ? 'Tax (${(breakdown.taxRate! * 100).toStringAsFixed(0)}%)'
                : 'Tax',
            breakdown.tax.formatted,
            effectiveLabelStyle,
            effectiveValueStyle,
          ),
        ],

        // Fees
        for (final fee in breakdown.feeBreakdown) ...[
          SizedBox(height: rowSpacing),
          _buildRow(
            context,
            fee.name,
            fee.amount.formatted,
            effectiveLabelStyle,
            effectiveValueStyle,
          ),
        ],

        // Tip
        if (breakdown.hasTip) ...[
          SizedBox(height: rowSpacing),
          _buildRow(
            context,
            'Tip',
            breakdown.tip.formatted,
            effectiveLabelStyle,
            effectiveValueStyle,
          ),
        ],

        // Divider
        SizedBox(height: rowSpacing * 2),
        const Divider(),
        SizedBox(height: rowSpacing),

        // Total
        _buildRow(
          context,
          'Total',
          breakdown.total.formatted,
          effectiveTotalStyle!,
          effectiveTotalStyle,
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    String value,
    TextStyle labelStyle,
    TextStyle valueStyle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}

/// Simple total display widget.
class CartTotalWidget extends StatelessWidget {
  final Money total;
  final String label;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const CartTotalWidget({
    super.key,
    required this.total,
    this.label = 'Total',
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ??
              theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          total.formatted,
          style: valueStyle ??
              theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
        ),
      ],
    );
  }
}
