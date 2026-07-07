import 'package:flutter/material.dart';

import '../../core/models/money.dart';

/// A widget for displaying prices with optional comparison/sale price.
///
/// ## Usage
///
/// ```dart
/// // Simple price
/// PriceDisplayWidget(price: Money(99))
///
/// // Sale price with original
/// PriceDisplayWidget(
///   price: Money(79),
///   compareAtPrice: Money(99),
/// )
/// ```
class PriceDisplayWidget extends StatelessWidget {
  /// The current/sale price.
  final Money price;

  /// The original price (for showing discount).
  final Money? compareAtPrice;

  /// Text style for the price.
  final TextStyle? priceStyle;

  /// Text style for the compare price.
  final TextStyle? compareStyle;

  /// Whether to show the discount badge.
  final bool showDiscountBadge;

  /// Layout direction.
  final Axis axis;

  /// Spacing between elements.
  final double spacing;

  const PriceDisplayWidget({
    super.key,
    required this.price,
    this.compareAtPrice,
    this.priceStyle,
    this.compareStyle,
    this.showDiscountBadge = true,
    this.axis = Axis.horizontal,
    this.spacing = 8,
  });

  bool get _isOnSale =>
      compareAtPrice != null && compareAtPrice!.amount > price.amount;

  double? get _discountPercentage {
    if (!_isOnSale) return null;
    return ((compareAtPrice!.amount - price.amount) / compareAtPrice!.amount) *
        100;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectivePriceStyle = priceStyle ??
        theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: _isOnSale ? theme.colorScheme.error : null,
        );

    final effectiveCompareStyle = compareStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          decoration: TextDecoration.lineThrough,
          color: theme.colorScheme.onSurfaceVariant,
        );

    final children = <Widget>[
      // Current price
      Text(price.formatted, style: effectivePriceStyle),

      // Compare at price
      if (_isOnSale) ...[
        SizedBox(width: spacing, height: spacing),
        Text(compareAtPrice!.formatted, style: effectiveCompareStyle),
      ],

      // Discount badge
      if (_isOnSale && showDiscountBadge) ...[
        SizedBox(width: spacing, height: spacing),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '-${_discountPercentage!.toStringAsFixed(0)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onError,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ];

    if (axis == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// Compact price tag widget.
class PriceTag extends StatelessWidget {
  final Money price;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const PriceTag({
    super.key,
    required this.price,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        price.formatted,
        style: TextStyle(
          color: textColor ?? theme.colorScheme.onPrimaryContainer,
          fontSize: fontSize ?? 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
