import 'package:equatable/equatable.dart';

import 'money.dart';

/// Represents the financial summary of an order.
///
/// This model breaks down all costs and discounts applied to an order.
class OrderSummary extends Equatable {
  /// Subtotal (sum of item prices before discounts).
  final Money subtotal;

  /// Item-level discount amount.
  final Money itemDiscount;

  /// Order-level discount amount (coupons, promotions).
  final Money orderDiscount;

  /// Total discount (itemDiscount + orderDiscount).
  Money get totalDiscount => itemDiscount + orderDiscount;

  /// Subtotal after discounts.
  Money get discountedSubtotal => subtotal - totalDiscount;

  /// Shipping cost.
  final Money shippingCost;

  /// Original shipping cost (if discounted/free).
  final Money? originalShippingCost;

  /// Shipping discount amount.
  Money get shippingDiscount => originalShippingCost != null
      ? originalShippingCost! - shippingCost
      : const Money.zero();

  /// Service fee.
  final Money serviceFee;

  /// Handling fee.
  final Money handlingFee;

  /// Packaging fee.
  final Money packagingFee;

  /// Tip amount.
  final Money tip;

  /// Tax amount.
  final Money tax;

  /// Tax percentage.
  final double? taxPercentage;

  /// Whether tax is included in prices.
  final bool taxInclusive;

  /// Wallet balance used.
  final Money walletUsed;

  /// Points value redeemed.
  final Money pointsValueRedeemed;

  /// Number of points redeemed.
  final int pointsRedeemed;

  /// Gift card amount used.
  final Money giftCardUsed;

  /// Store credit used.
  final Money storeCreditUsed;

  /// Total amount to pay (after all adjustments).
  Money get total {
    var amount = discountedSubtotal +
        shippingCost +
        serviceFee +
        handlingFee +
        packagingFee +
        tip;

    if (!taxInclusive) {
      amount = amount + tax;
    }

    // Subtract payment credits
    amount = amount -
        walletUsed -
        pointsValueRedeemed -
        giftCardUsed -
        storeCreditUsed;

    return amount.amount < 0 ? const Money.zero() : amount;
  }

  /// Amount to be paid by selected payment method.
  Money get amountDue => total;

  /// Total savings (all discounts + free shipping).
  Money get totalSavings => totalDiscount + shippingDiscount;

  /// Number of items in order.
  final int itemCount;

  /// Unique item count.
  final int uniqueItemCount;

  /// Points earned from this order.
  final int pointsEarned;

  /// Cashback earned.
  final Money cashbackEarned;

  /// Currency code.
  final String currency;

  /// Applied coupon code.
  final String? couponCode;

  /// Coupon discount description.
  final String? couponDescription;

  /// Free shipping threshold (remaining amount).
  final Money? freeShippingRemaining;

  /// Whether free shipping is applied.
  bool get hasFreeShipping =>
      shippingCost.isZero && originalShippingCost != null;

  /// Creates an [OrderSummary].
  const OrderSummary({
    required this.subtotal,
    this.itemDiscount = const Money.zero(),
    this.orderDiscount = const Money.zero(),
    this.shippingCost = const Money.zero(),
    this.originalShippingCost,
    this.serviceFee = const Money.zero(),
    this.handlingFee = const Money.zero(),
    this.packagingFee = const Money.zero(),
    this.tip = const Money.zero(),
    this.tax = const Money.zero(),
    this.taxPercentage,
    this.taxInclusive = false,
    this.walletUsed = const Money.zero(),
    this.pointsValueRedeemed = const Money.zero(),
    this.pointsRedeemed = 0,
    this.giftCardUsed = const Money.zero(),
    this.storeCreditUsed = const Money.zero(),
    this.itemCount = 0,
    this.uniqueItemCount = 0,
    this.pointsEarned = 0,
    this.cashbackEarned = const Money.zero(),
    this.currency = 'EGP',
    this.couponCode,
    this.couponDescription,
    this.freeShippingRemaining,
  });

  /// Creates an empty [OrderSummary].
  const OrderSummary.empty()
      : subtotal = const Money.zero(),
        itemDiscount = const Money.zero(),
        orderDiscount = const Money.zero(),
        shippingCost = const Money.zero(),
        originalShippingCost = null,
        serviceFee = const Money.zero(),
        handlingFee = const Money.zero(),
        packagingFee = const Money.zero(),
        tip = const Money.zero(),
        tax = const Money.zero(),
        taxPercentage = null,
        taxInclusive = false,
        walletUsed = const Money.zero(),
        pointsValueRedeemed = const Money.zero(),
        pointsRedeemed = 0,
        giftCardUsed = const Money.zero(),
        storeCreditUsed = const Money.zero(),
        itemCount = 0,
        uniqueItemCount = 0,
        pointsEarned = 0,
        cashbackEarned = const Money.zero(),
        currency = 'EGP',
        couponCode = null,
        couponDescription = null,
        freeShippingRemaining = null;

  /// Creates an [OrderSummary] from JSON.
  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      subtotal: _parseMoneyField(json, ['subtotal', 'sub_total']),
      itemDiscount: _parseMoneyField(json, ['item_discount', 'itemDiscount']),
      orderDiscount: _parseMoneyField(
        json,
        ['order_discount', 'orderDiscount', 'discount'],
      ),
      shippingCost: _parseMoneyField(json, [
        'shipping_cost',
        'shippingCost',
        'shipping',
        'delivery_fee',
        'deliveryFee',
      ]),
      originalShippingCost: json['original_shipping_cost'] != null
          ? Money.fromJson(
              json['original_shipping_cost'] as Map<String, dynamic>,
            )
          : json['originalShippingCost'] != null
              ? Money((json['originalShippingCost'] as num).toDouble())
              : null,
      serviceFee: _parseMoneyField(json, ['service_fee', 'serviceFee']),
      handlingFee: _parseMoneyField(json, ['handling_fee', 'handlingFee']),
      packagingFee: _parseMoneyField(json, ['packaging_fee', 'packagingFee']),
      tip: _parseMoneyField(json, ['tip', 'gratuity']),
      tax: _parseMoneyField(json, ['tax', 'vat', 'tax_amount', 'taxAmount']),
      taxPercentage: (json['tax_percentage'] ??
              json['taxPercentage'] ??
              json['tax_rate'] as num?)
          ?.toDouble(),
      taxInclusive:
          json['tax_inclusive'] ?? json['taxInclusive'] as bool? ?? false,
      walletUsed:
          _parseMoneyField(json, ['wallet_used', 'walletUsed', 'wallet']),
      pointsValueRedeemed: _parseMoneyField(
        json,
        ['points_value_redeemed', 'pointsValueRedeemed', 'points_value'],
      ),
      pointsRedeemed:
          json['points_redeemed'] ?? json['pointsRedeemed'] as int? ?? 0,
      giftCardUsed: _parseMoneyField(
        json,
        ['gift_card_used', 'giftCardUsed', 'gift_card'],
      ),
      storeCreditUsed: _parseMoneyField(
        json,
        ['store_credit_used', 'storeCreditUsed', 'store_credit'],
      ),
      itemCount: json['item_count'] ?? json['itemCount'] as int? ?? 0,
      uniqueItemCount:
          json['unique_item_count'] ?? json['uniqueItemCount'] as int? ?? 0,
      pointsEarned: json['points_earned'] ?? json['pointsEarned'] as int? ?? 0,
      cashbackEarned: _parseMoneyField(
        json,
        ['cashback_earned', 'cashbackEarned', 'cashback'],
      ),
      currency: json['currency'] as String? ?? 'EGP',
      couponCode: json['coupon_code'] ?? json['couponCode'] as String?,
      couponDescription:
          json['coupon_description'] ?? json['couponDescription'] as String?,
      freeShippingRemaining: json['free_shipping_remaining'] != null
          ? Money.fromJson(
              json['free_shipping_remaining'] as Map<String, dynamic>,
            )
          : json['freeShippingRemaining'] != null
              ? Money((json['freeShippingRemaining'] as num).toDouble())
              : null,
    );
  }

  static Money _parseMoneyField(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json[key] != null) {
        if (json[key] is Map) {
          return Money.fromJson(json[key] as Map<String, dynamic>);
        } else if (json[key] is num) {
          return Money((json[key] as num).toDouble());
        }
      }
    }
    return const Money.zero();
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'subtotal': subtotal.toJson(),
        'item_discount': itemDiscount.toJson(),
        'order_discount': orderDiscount.toJson(),
        'total_discount': totalDiscount.toJson(),
        'discounted_subtotal': discountedSubtotal.toJson(),
        'shipping_cost': shippingCost.toJson(),
        'original_shipping_cost': originalShippingCost?.toJson(),
        'shipping_discount': shippingDiscount.toJson(),
        'service_fee': serviceFee.toJson(),
        'handling_fee': handlingFee.toJson(),
        'packaging_fee': packagingFee.toJson(),
        'tip': tip.toJson(),
        'tax': tax.toJson(),
        'tax_percentage': taxPercentage,
        'tax_inclusive': taxInclusive,
        'wallet_used': walletUsed.toJson(),
        'points_value_redeemed': pointsValueRedeemed.toJson(),
        'points_redeemed': pointsRedeemed,
        'gift_card_used': giftCardUsed.toJson(),
        'store_credit_used': storeCreditUsed.toJson(),
        'total': total.toJson(),
        'amount_due': amountDue.toJson(),
        'total_savings': totalSavings.toJson(),
        'item_count': itemCount,
        'unique_item_count': uniqueItemCount,
        'points_earned': pointsEarned,
        'cashback_earned': cashbackEarned.toJson(),
        'currency': currency,
        'coupon_code': couponCode,
        'coupon_description': couponDescription,
        'free_shipping_remaining': freeShippingRemaining?.toJson(),
        'has_free_shipping': hasFreeShipping,
      };

  /// Returns a list of summary line items for display.
  List<SummaryLineItem> toLineItems({bool includeZeroAmounts = false}) {
    final items = <SummaryLineItem>[];

    items.add(
      SummaryLineItem(
        label: 'Subtotal',
        amount: subtotal,
        type: SummaryLineItemType.subtotal,
      ),
    );

    if (includeZeroAmounts || !itemDiscount.isZero) {
      items.add(
        SummaryLineItem(
          label: 'Item Discount',
          amount: -itemDiscount,
          type: SummaryLineItemType.discount,
        ),
      );
    }

    if (includeZeroAmounts || !orderDiscount.isZero) {
      items.add(
        SummaryLineItem(
          label: couponCode != null ? 'Coupon ($couponCode)' : 'Discount',
          amount: -orderDiscount,
          type: SummaryLineItemType.discount,
          description: couponDescription,
        ),
      );
    }

    items.add(
      SummaryLineItem(
        label: 'Delivery Fee',
        amount: shippingCost,
        originalAmount: originalShippingCost,
        type: SummaryLineItemType.shipping,
      ),
    );

    if (includeZeroAmounts || !serviceFee.isZero) {
      items.add(
        SummaryLineItem(
          label: 'Service Fee',
          amount: serviceFee,
          type: SummaryLineItemType.fee,
        ),
      );
    }

    if (includeZeroAmounts || !handlingFee.isZero) {
      items.add(
        SummaryLineItem(
          label: 'Handling Fee',
          amount: handlingFee,
          type: SummaryLineItemType.fee,
        ),
      );
    }

    if (includeZeroAmounts || !packagingFee.isZero) {
      items.add(
        SummaryLineItem(
          label: 'Packaging Fee',
          amount: packagingFee,
          type: SummaryLineItemType.fee,
        ),
      );
    }

    if (!taxInclusive && (includeZeroAmounts || !tax.isZero)) {
      final taxLabel = taxPercentage != null
          ? 'Tax (${taxPercentage!.toStringAsFixed(0)}%)'
          : 'Tax';
      items.add(
        SummaryLineItem(
          label: taxLabel,
          amount: tax,
          type: SummaryLineItemType.tax,
        ),
      );
    }

    if (includeZeroAmounts || !tip.isZero) {
      items.add(
        SummaryLineItem(
          label: 'Tip',
          amount: tip,
          type: SummaryLineItemType.tip,
        ),
      );
    }

    if (includeZeroAmounts || !walletUsed.isZero) {
      items.add(
        SummaryLineItem(
          label: 'Wallet',
          amount: -walletUsed,
          type: SummaryLineItemType.credit,
        ),
      );
    }

    if (includeZeroAmounts || !pointsValueRedeemed.isZero) {
      items.add(
        SummaryLineItem(
          label: 'Points ($pointsRedeemed pts)',
          amount: -pointsValueRedeemed,
          type: SummaryLineItemType.credit,
        ),
      );
    }

    if (includeZeroAmounts || !giftCardUsed.isZero) {
      items.add(
        SummaryLineItem(
          label: 'Gift Card',
          amount: -giftCardUsed,
          type: SummaryLineItemType.credit,
        ),
      );
    }

    if (includeZeroAmounts || !storeCreditUsed.isZero) {
      items.add(
        SummaryLineItem(
          label: 'Store Credit',
          amount: -storeCreditUsed,
          type: SummaryLineItemType.credit,
        ),
      );
    }

    items.add(
      SummaryLineItem(
        label: 'Total',
        amount: total,
        type: SummaryLineItemType.total,
      ),
    );

    return items;
  }

  /// Creates a copy with updated values.
  OrderSummary copyWith({
    Money? subtotal,
    Money? itemDiscount,
    Money? orderDiscount,
    Money? shippingCost,
    Money? originalShippingCost,
    Money? serviceFee,
    Money? handlingFee,
    Money? packagingFee,
    Money? tip,
    Money? tax,
    double? taxPercentage,
    bool? taxInclusive,
    Money? walletUsed,
    Money? pointsValueRedeemed,
    int? pointsRedeemed,
    Money? giftCardUsed,
    Money? storeCreditUsed,
    int? itemCount,
    int? uniqueItemCount,
    int? pointsEarned,
    Money? cashbackEarned,
    String? currency,
    String? couponCode,
    String? couponDescription,
    Money? freeShippingRemaining,
  }) {
    return OrderSummary(
      subtotal: subtotal ?? this.subtotal,
      itemDiscount: itemDiscount ?? this.itemDiscount,
      orderDiscount: orderDiscount ?? this.orderDiscount,
      shippingCost: shippingCost ?? this.shippingCost,
      originalShippingCost: originalShippingCost ?? this.originalShippingCost,
      serviceFee: serviceFee ?? this.serviceFee,
      handlingFee: handlingFee ?? this.handlingFee,
      packagingFee: packagingFee ?? this.packagingFee,
      tip: tip ?? this.tip,
      tax: tax ?? this.tax,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      taxInclusive: taxInclusive ?? this.taxInclusive,
      walletUsed: walletUsed ?? this.walletUsed,
      pointsValueRedeemed: pointsValueRedeemed ?? this.pointsValueRedeemed,
      pointsRedeemed: pointsRedeemed ?? this.pointsRedeemed,
      giftCardUsed: giftCardUsed ?? this.giftCardUsed,
      storeCreditUsed: storeCreditUsed ?? this.storeCreditUsed,
      itemCount: itemCount ?? this.itemCount,
      uniqueItemCount: uniqueItemCount ?? this.uniqueItemCount,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      cashbackEarned: cashbackEarned ?? this.cashbackEarned,
      currency: currency ?? this.currency,
      couponCode: couponCode ?? this.couponCode,
      couponDescription: couponDescription ?? this.couponDescription,
      freeShippingRemaining:
          freeShippingRemaining ?? this.freeShippingRemaining,
    );
  }

  @override
  List<Object?> get props => [
        subtotal,
        itemDiscount,
        orderDiscount,
        shippingCost,
        originalShippingCost,
        serviceFee,
        handlingFee,
        packagingFee,
        tip,
        tax,
        taxPercentage,
        taxInclusive,
        walletUsed,
        pointsValueRedeemed,
        pointsRedeemed,
        giftCardUsed,
        storeCreditUsed,
        itemCount,
        uniqueItemCount,
        pointsEarned,
        cashbackEarned,
        currency,
        couponCode,
        couponDescription,
        freeShippingRemaining,
      ];
}

/// Represents a line item in the order summary display.
class SummaryLineItem {
  /// Display label.
  final String label;

  /// Amount.
  final Money amount;

  /// Original amount (if different).
  final Money? originalAmount;

  /// Description/subtitle.
  final String? description;

  /// Line item type.
  final SummaryLineItemType type;

  /// Creates a [SummaryLineItem].
  const SummaryLineItem({
    required this.label,
    required this.amount,
    this.originalAmount,
    this.description,
    required this.type,
  });

  /// Whether this item has a strikethrough original amount.
  bool get hasStrikethrough =>
      originalAmount != null && originalAmount != amount;
}

/// Type of summary line item.
enum SummaryLineItemType {
  subtotal,
  discount,
  shipping,
  fee,
  tax,
  tip,
  credit,
  total,
}
