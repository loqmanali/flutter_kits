import 'package:equatable/equatable.dart';

import 'discount.dart';
import 'money.dart';

/// Represents a detailed breakdown of cart pricing.
///
/// Includes subtotal, discounts, taxes, shipping, and the final total.
///
/// ## Usage
///
/// ```dart
/// final breakdown = PriceBreakdown(
///   subtotal: Money(500),
///   discount: Money(50),
///   shipping: Money(25),
///   tax: Money(47.5),
///   total: Money(522.5),
/// );
///
/// print(breakdown.total.formatted); // "522.50 EGP"
/// ```
class PriceBreakdown extends Equatable {
  /// The sum of all item prices before discounts.
  final Money subtotal;

  /// The total discount amount.
  final Money discount;

  /// The shipping cost.
  final Money shipping;

  /// The tax amount.
  final Money tax;

  /// Any additional fees (service fee, packaging, etc.).
  final Money fees;

  /// The tip amount (if applicable).
  final Money tip;

  /// The final total to be paid.
  final Money total;

  /// The currency for all amounts.
  final String currency;

  /// The tax rate used (e.g., 0.14 for 14%).
  final double? taxRate;

  /// Whether shipping is free.
  final bool isFreeShipping;

  /// The amount needed for free shipping.
  final Money? freeShippingThreshold;

  /// The amount remaining to qualify for free shipping.
  final Money? amountToFreeShipping;

  /// Applied discounts with details.
  final List<AppliedDiscount> appliedDiscounts;

  /// Fee breakdown details.
  final List<FeeBreakdownItem> feeBreakdown;

  /// Creates a [PriceBreakdown] instance.
  const PriceBreakdown({
    required this.subtotal,
    this.discount = const Money.zero(),
    this.shipping = const Money.zero(),
    this.tax = const Money.zero(),
    this.fees = const Money.zero(),
    this.tip = const Money.zero(),
    required this.total,
    this.currency = 'EGP',
    this.taxRate,
    this.isFreeShipping = false,
    this.freeShippingThreshold,
    this.amountToFreeShipping,
    this.appliedDiscounts = const [],
    this.feeBreakdown = const [],
  });

  /// Creates an empty [PriceBreakdown].
  const PriceBreakdown.empty({String currency = 'EGP'})
      : this(
          subtotal: const Money.zero(),
          total: const Money.zero(),
          currency: currency,
        );

  /// Creates a [PriceBreakdown] by calculating from components.
  factory PriceBreakdown.calculate({
    required Money subtotal,
    Money? discount,
    Money? shipping,
    double? taxRate,
    Money? fees,
    Money? tip,
    String currency = 'EGP',
    Money? freeShippingThreshold,
    List<AppliedDiscount> appliedDiscounts = const [],
    List<FeeBreakdownItem> feeBreakdown = const [],
  }) {
    final effectiveDiscount = discount ?? const Money.zero();
    final effectiveShipping = shipping ?? const Money.zero();
    final effectiveFees = fees ?? const Money.zero();
    final effectiveTip = tip ?? const Money.zero();

    // Calculate taxable amount (subtotal - discount)
    final taxableAmount = subtotal - effectiveDiscount;

    // Calculate tax
    final effectiveTax = taxRate != null
        ? Money(taxableAmount.amount * taxRate, currency: currency)
        : const Money.zero();

    // Calculate total
    final total = taxableAmount +
        effectiveShipping +
        effectiveTax +
        effectiveFees +
        effectiveTip;

    // Calculate free shipping threshold
    Money? amountToFreeShipping;
    bool isFreeShipping = effectiveShipping.isZero;

    if (freeShippingThreshold != null && !isFreeShipping) {
      if (subtotal >= freeShippingThreshold) {
        isFreeShipping = true;
      } else {
        amountToFreeShipping = freeShippingThreshold - subtotal;
      }
    }

    return PriceBreakdown(
      subtotal: subtotal,
      discount: effectiveDiscount,
      shipping: isFreeShipping ? const Money.zero() : effectiveShipping,
      tax: effectiveTax,
      fees: effectiveFees,
      tip: effectiveTip,
      total: total,
      currency: currency,
      taxRate: taxRate,
      isFreeShipping: isFreeShipping,
      freeShippingThreshold: freeShippingThreshold,
      amountToFreeShipping: amountToFreeShipping,
      appliedDiscounts: appliedDiscounts,
      feeBreakdown: feeBreakdown,
    );
  }

  /// Creates a [PriceBreakdown] from JSON.
  factory PriceBreakdown.fromJson(Map<String, dynamic> json) {
    return PriceBreakdown(
      subtotal: Money.fromJson({
        'amount': json['subtotal'] ?? json['sub_total'] ?? 0,
        'currency': json['currency'] ?? 'EGP',
      }),
      discount: Money.fromJson({
        'amount': json['discount'] ?? json['discount_total'] ?? 0,
        'currency': json['currency'] ?? 'EGP',
      }),
      shipping: Money.fromJson({
        'amount': json['shipping'] ?? json['shipping_total'] ?? 0,
        'currency': json['currency'] ?? 'EGP',
      }),
      tax: Money.fromJson({
        'amount': json['tax'] ?? json['tax_total'] ?? 0,
        'currency': json['currency'] ?? 'EGP',
      }),
      fees: Money.fromJson({
        'amount': json['fees'] ?? json['service_fee'] ?? 0,
        'currency': json['currency'] ?? 'EGP',
      }),
      tip: Money.fromJson({
        'amount': json['tip'] ?? 0,
        'currency': json['currency'] ?? 'EGP',
      }),
      total: Money.fromJson({
        'amount': json['total'] ?? json['grand_total'] ?? 0,
        'currency': json['currency'] ?? 'EGP',
      }),
      currency: json['currency'] ?? 'EGP',
      taxRate: (json['tax_rate'] ?? json['taxRate'] as num?)?.toDouble(),
      isFreeShipping:
          json['is_free_shipping'] ?? json['isFreeShipping'] ?? false,
      freeShippingThreshold: json['free_shipping_threshold'] != null
          ? Money.fromJson({'amount': json['free_shipping_threshold']})
          : null,
      amountToFreeShipping: json['amount_to_free_shipping'] != null
          ? Money.fromJson({'amount': json['amount_to_free_shipping']})
          : null,
      appliedDiscounts: (json['applied_discounts'] as List<dynamic>?)
              ?.map((d) => AppliedDiscount.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      feeBreakdown: (json['fee_breakdown'] as List<dynamic>?)
              ?.map((f) => FeeBreakdownItem.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Converts this [PriceBreakdown] to JSON.
  Map<String, dynamic> toJson() => {
        'subtotal': subtotal.amount,
        'discount': discount.amount,
        'shipping': shipping.amount,
        'tax': tax.amount,
        'fees': fees.amount,
        'tip': tip.amount,
        'total': total.amount,
        'currency': currency,
        if (taxRate != null) 'tax_rate': taxRate,
        'is_free_shipping': isFreeShipping,
        if (freeShippingThreshold != null)
          'free_shipping_threshold': freeShippingThreshold!.amount,
        if (amountToFreeShipping != null)
          'amount_to_free_shipping': amountToFreeShipping!.amount,
        'applied_discounts': appliedDiscounts.map((d) => d.toJson()).toList(),
        'fee_breakdown': feeBreakdown.map((f) => f.toJson()).toList(),
      };

  /// Returns `true` if there's any discount applied.
  bool get hasDiscount => !discount.isZero;

  /// Returns `true` if there's any tax.
  bool get hasTax => !tax.isZero;

  /// Returns `true` if there are any fees.
  bool get hasFees => !fees.isZero;

  /// Returns `true` if there's a tip.
  bool get hasTip => !tip.isZero;

  /// Returns the discount percentage.
  double get discountPercentage {
    if (subtotal.isZero) return 0;
    return (discount.amount / subtotal.amount) * 100;
  }

  /// Returns the progress towards free shipping (0.0 to 1.0).
  double get freeShippingProgress {
    if (freeShippingThreshold == null || isFreeShipping) return 1.0;
    if (freeShippingThreshold!.isZero) return 1.0;
    return (subtotal.amount / freeShippingThreshold!.amount).clamp(0.0, 1.0);
  }

  /// Returns all line items for display.
  List<PriceLineItem> get lineItems {
    final items = <PriceLineItem>[];

    items.add(
      PriceLineItem(
        label: 'Subtotal',
        amount: subtotal,
        type: LineItemType.subtotal,
      ),
    );

    if (hasDiscount) {
      items.add(
        PriceLineItem(
          label: 'Discount',
          amount: -discount,
          type: LineItemType.discount,
        ),
      );
    }

    if (!shipping.isZero || isFreeShipping) {
      items.add(
        PriceLineItem(
          label: isFreeShipping ? 'Shipping (Free)' : 'Shipping',
          amount: shipping,
          type: LineItemType.shipping,
        ),
      );
    }

    if (hasTax) {
      final taxLabel = taxRate != null
          ? 'Tax (${(taxRate! * 100).toStringAsFixed(0)}%)'
          : 'Tax';
      items.add(
        PriceLineItem(
          label: taxLabel,
          amount: tax,
          type: LineItemType.tax,
        ),
      );
    }

    for (final fee in feeBreakdown) {
      items.add(
        PriceLineItem(
          label: fee.name,
          amount: fee.amount,
          type: LineItemType.fee,
        ),
      );
    }

    if (hasTip) {
      items.add(
        PriceLineItem(
          label: 'Tip',
          amount: tip,
          type: LineItemType.tip,
        ),
      );
    }

    items.add(
      PriceLineItem(
        label: 'Total',
        amount: total,
        type: LineItemType.total,
      ),
    );

    return items;
  }

  /// Copies this [PriceBreakdown] with optional new values.
  PriceBreakdown copyWith({
    Money? subtotal,
    Money? discount,
    Money? shipping,
    Money? tax,
    Money? fees,
    Money? tip,
    Money? total,
    String? currency,
    double? taxRate,
    bool? isFreeShipping,
    Money? freeShippingThreshold,
    Money? amountToFreeShipping,
    List<AppliedDiscount>? appliedDiscounts,
    List<FeeBreakdownItem>? feeBreakdown,
  }) {
    return PriceBreakdown(
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shipping: shipping ?? this.shipping,
      tax: tax ?? this.tax,
      fees: fees ?? this.fees,
      tip: tip ?? this.tip,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
      isFreeShipping: isFreeShipping ?? this.isFreeShipping,
      freeShippingThreshold:
          freeShippingThreshold ?? this.freeShippingThreshold,
      amountToFreeShipping: amountToFreeShipping ?? this.amountToFreeShipping,
      appliedDiscounts: appliedDiscounts ?? this.appliedDiscounts,
      feeBreakdown: feeBreakdown ?? this.feeBreakdown,
    );
  }

  @override
  List<Object?> get props => [
        subtotal,
        discount,
        shipping,
        tax,
        fees,
        tip,
        total,
      ];
}

/// Represents an applied discount in the price breakdown.
class AppliedDiscount extends Equatable {
  /// The discount that was applied.
  final Discount discount;

  /// The calculated discount amount.
  final Money amount;

  /// Creates an [AppliedDiscount] instance.
  const AppliedDiscount({
    required this.discount,
    required this.amount,
  });

  /// Creates an [AppliedDiscount] from JSON.
  factory AppliedDiscount.fromJson(Map<String, dynamic> json) {
    return AppliedDiscount(
      discount: Discount.fromJson(json['discount'] as Map<String, dynamic>),
      amount: Money.fromJson({'amount': json['amount']}),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'discount': discount.toJson(),
        'amount': amount.amount,
      };

  @override
  List<Object?> get props => [discount, amount];
}

/// Represents a fee item in the breakdown.
class FeeBreakdownItem extends Equatable {
  /// The fee identifier.
  final String id;

  /// The fee name.
  final String name;

  /// The fee amount.
  final Money amount;

  /// Creates a [FeeBreakdownItem] instance.
  const FeeBreakdownItem({
    required this.id,
    required this.name,
    required this.amount,
  });

  /// Creates a [FeeBreakdownItem] from JSON.
  factory FeeBreakdownItem.fromJson(Map<String, dynamic> json) {
    return FeeBreakdownItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      amount: Money.fromJson({'amount': json['amount']}),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount.amount,
      };

  @override
  List<Object?> get props => [id, name, amount];
}

/// Represents a line item in the price display.
class PriceLineItem extends Equatable {
  /// The label to display.
  final String label;

  /// The amount.
  final Money amount;

  /// The type of line item.
  final LineItemType type;

  /// Creates a [PriceLineItem] instance.
  const PriceLineItem({
    required this.label,
    required this.amount,
    required this.type,
  });

  @override
  List<Object?> get props => [label, amount, type];
}

/// Types of price line items.
enum LineItemType {
  subtotal,
  discount,
  shipping,
  tax,
  fee,
  tip,
  total,
}
