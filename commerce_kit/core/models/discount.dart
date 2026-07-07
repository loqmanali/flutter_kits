import 'package:equatable/equatable.dart';

import '../enums/discount_type.dart';
import 'money.dart';

/// Represents a discount that can be applied to cart items or the entire cart.
///
/// Supports various discount types including percentage, fixed amount,
/// buy-X-get-Y, free shipping, and more.
///
/// ## Usage
///
/// ```dart
/// // Percentage discount
/// final percentOff = Discount(
///   id: 'summer20',
///   code: 'SUMMER20',
///   type: DiscountType.percentage,
///   value: 20, // 20% off
///   name: 'Summer Sale',
/// );
///
/// // Fixed amount discount
/// final fixedOff = Discount(
///   id: 'flat50',
///   code: 'FLAT50',
///   type: DiscountType.fixedAmount,
///   value: 50, // 50 EGP off
///   name: 'Flat Discount',
/// );
///
/// // Calculate discount
/// final subtotal = Money(200);
/// final discountAmount = percentOff.calculate(subtotal); // Money(40)
/// ```
class Discount extends Equatable {
  /// Unique identifier for this discount.
  final String id;

  /// The discount/coupon code (if applicable).
  final String? code;

  /// The type of discount.
  final DiscountType type;

  /// The discount value (percentage or fixed amount).
  final double value;

  /// The display name of this discount.
  final String name;

  /// A description of this discount.
  final String? description;

  /// The minimum order amount required.
  final Money? minimumOrderAmount;

  /// The maximum discount amount (for percentage discounts).
  final Money? maximumDiscount;

  /// Product IDs this discount applies to (empty = all products).
  final List<String> applicableProductIds;

  /// Category IDs this discount applies to (empty = all categories).
  final List<String> applicableCategoryIds;

  /// Product IDs excluded from this discount.
  final List<String> excludedProductIds;

  /// Category IDs excluded from this discount.
  final List<String> excludedCategoryIds;

  /// The number of times this discount can be used.
  final int? usageLimit;

  /// The number of times this discount has been used.
  final int? usageCount;

  /// Whether this discount can only be used once per customer.
  final bool oncePerCustomer;

  /// The start date of this discount.
  final DateTime? startDate;

  /// The end date of this discount.
  final DateTime? endDate;

  /// Whether this discount is currently active.
  final bool isActive;

  /// Whether this discount can be combined with others.
  final bool canCombine;

  /// For buy-X-get-Y: the required purchase quantity.
  final int? buyQuantity;

  /// For buy-X-get-Y: the free item quantity.
  final int? getQuantity;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a [Discount] instance.
  const Discount({
    required this.id,
    this.code,
    required this.type,
    required this.value,
    required this.name,
    this.description,
    this.minimumOrderAmount,
    this.maximumDiscount,
    this.applicableProductIds = const [],
    this.applicableCategoryIds = const [],
    this.excludedProductIds = const [],
    this.excludedCategoryIds = const [],
    this.usageLimit,
    this.usageCount,
    this.oncePerCustomer = false,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.canCombine = false,
    this.buyQuantity,
    this.getQuantity,
    this.metadata,
  });

  /// Creates a percentage discount.
  factory Discount.percentage({
    required String id,
    required String name,
    required double percentage,
    String? code,
    Money? minimumOrderAmount,
    Money? maximumDiscount,
  }) {
    return Discount(
      id: id,
      code: code,
      type: DiscountType.percentage,
      value: percentage,
      name: name,
      minimumOrderAmount: minimumOrderAmount,
      maximumDiscount: maximumDiscount,
    );
  }

  /// Creates a fixed amount discount.
  factory Discount.fixedAmount({
    required String id,
    required String name,
    required double amount,
    String? code,
    Money? minimumOrderAmount,
  }) {
    return Discount(
      id: id,
      code: code,
      type: DiscountType.fixedAmount,
      value: amount,
      name: name,
      minimumOrderAmount: minimumOrderAmount,
    );
  }

  /// Creates a free shipping discount.
  factory Discount.freeShipping({
    required String id,
    required String name,
    String? code,
    Money? minimumOrderAmount,
  }) {
    return Discount(
      id: id,
      code: code,
      type: DiscountType.freeShipping,
      value: 0,
      name: name,
      minimumOrderAmount: minimumOrderAmount,
      canCombine: true,
    );
  }

  /// Creates a [Discount] from JSON.
  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? json['coupon_code'],
      type: _parseDiscountType(json['type'] ?? json['discount_type']),
      value: (json['value'] ?? json['amount'] ?? json['percentage'] ?? 0)
          .toDouble(),
      name: json['name'] ?? json['title'] ?? '',
      description: json['description'],
      minimumOrderAmount: json['minimum_order_amount'] != null ||
              json['minimumOrderAmount'] != null
          ? Money.fromJson({
              'amount':
                  json['minimum_order_amount'] ?? json['minimumOrderAmount'],
            })
          : null,
      maximumDiscount:
          json['maximum_discount'] != null || json['maximumDiscount'] != null
              ? Money.fromJson({
                  'amount': json['maximum_discount'] ?? json['maximumDiscount'],
                })
              : null,
      applicableProductIds: _parseStringList(
        json['applicable_product_ids'] ?? json['product_ids'],
      ),
      applicableCategoryIds: _parseStringList(
        json['applicable_category_ids'] ?? json['category_ids'],
      ),
      excludedProductIds: _parseStringList(
        json['excluded_product_ids'] ?? json['exclude_products'],
      ),
      excludedCategoryIds: _parseStringList(
        json['excluded_category_ids'] ?? json['exclude_categories'],
      ),
      usageLimit: json['usage_limit'] ?? json['usageLimit'],
      usageCount: json['usage_count'] ?? json['usageCount'],
      oncePerCustomer:
          json['once_per_customer'] ?? json['oncePerCustomer'] ?? false,
      startDate: _parseDateTime(json['start_date'] ?? json['startDate']),
      endDate: _parseDateTime(json['end_date'] ?? json['endDate']),
      isActive: json['is_active'] ?? json['active'] ?? true,
      canCombine: json['can_combine'] ?? json['combinable'] ?? false,
      buyQuantity: json['buy_quantity'] ?? json['buyQuantity'],
      getQuantity: json['get_quantity'] ?? json['getQuantity'],
      metadata: json['metadata'],
    );
  }

  /// Converts this [Discount] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        if (code != null) 'code': code,
        'type': type.name,
        'value': value,
        'name': name,
        if (description != null) 'description': description,
        if (minimumOrderAmount != null)
          'minimum_order_amount': minimumOrderAmount!.toJson(),
        if (maximumDiscount != null)
          'maximum_discount': maximumDiscount!.toJson(),
        'applicable_product_ids': applicableProductIds,
        'applicable_category_ids': applicableCategoryIds,
        'excluded_product_ids': excludedProductIds,
        'excluded_category_ids': excludedCategoryIds,
        if (usageLimit != null) 'usage_limit': usageLimit,
        if (usageCount != null) 'usage_count': usageCount,
        'once_per_customer': oncePerCustomer,
        if (startDate != null) 'start_date': startDate!.toIso8601String(),
        if (endDate != null) 'end_date': endDate!.toIso8601String(),
        'is_active': isActive,
        'can_combine': canCombine,
        if (buyQuantity != null) 'buy_quantity': buyQuantity,
        if (getQuantity != null) 'get_quantity': getQuantity,
        if (metadata != null) 'metadata': metadata,
      };

  /// Calculates the discount amount for a given subtotal.
  ///
  /// Returns the discount amount (not the final price).
  Money calculate(Money subtotal, {String currency = 'EGP'}) {
    switch (type) {
      case DiscountType.percentage:
        var discount = subtotal.percentage(value);
        if (maximumDiscount != null && discount > maximumDiscount!) {
          discount = maximumDiscount!;
        }
        return discount;

      case DiscountType.fixedAmount:
        return Money(value, currency: currency);

      case DiscountType.fixedPrice:
        return subtotal - Money(value, currency: currency);

      case DiscountType.freeShipping:
        return const Money.zero();

      default:
        return const Money.zero();
    }
  }

  /// Validates if this discount can be applied.
  ///
  /// Returns null if valid, or an error message if invalid.
  String? validate({
    required Money subtotal,
    String? customerId,
    List<String>? productIds,
    List<String>? categoryIds,
  }) {
    // Check if active
    if (!isActive) {
      return 'This discount is no longer active';
    }

    // Check date range
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) {
      return 'This discount is not yet active';
    }
    if (endDate != null && now.isAfter(endDate!)) {
      return 'This discount has expired';
    }

    // Check minimum order amount
    if (minimumOrderAmount != null && subtotal < minimumOrderAmount!) {
      return 'Minimum order of ${minimumOrderAmount!.formatted} required';
    }

    // Check usage limit
    if (usageLimit != null &&
        usageCount != null &&
        usageCount! >= usageLimit!) {
      return 'This discount has reached its usage limit';
    }

    // Check product applicability
    if (applicableProductIds.isNotEmpty && productIds != null) {
      final applicable =
          productIds.any((id) => applicableProductIds.contains(id));
      if (!applicable) {
        return 'This discount does not apply to your items';
      }
    }

    // Check excluded products
    if (excludedProductIds.isNotEmpty && productIds != null) {
      final allExcluded =
          productIds.every((id) => excludedProductIds.contains(id));
      if (allExcluded) {
        return 'This discount does not apply to your items';
      }
    }

    return null;
  }

  /// Returns `true` if this discount is currently valid.
  bool get isValid {
    if (!isActive) return false;

    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;

    if (usageLimit != null &&
        usageCount != null &&
        usageCount! >= usageLimit!) {
      return false;
    }

    return true;
  }

  /// Returns `true` if this discount has expired.
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// Returns the remaining uses for this discount.
  int? get remainingUses {
    if (usageLimit == null) return null;
    return usageLimit! - (usageCount ?? 0);
  }

  /// Returns the formatted discount value.
  String get formattedValue {
    switch (type) {
      case DiscountType.percentage:
        return '${value.toStringAsFixed(0)}%';
      case DiscountType.fixedAmount:
      case DiscountType.fixedPrice:
        return Money(value).formatted;
      case DiscountType.freeShipping:
        return 'Free Shipping';
      default:
        return value.toString();
    }
  }

  /// Copies this [Discount] with optional new values.
  Discount copyWith({
    String? id,
    String? code,
    DiscountType? type,
    double? value,
    String? name,
    String? description,
    Money? minimumOrderAmount,
    Money? maximumDiscount,
    List<String>? applicableProductIds,
    List<String>? applicableCategoryIds,
    List<String>? excludedProductIds,
    List<String>? excludedCategoryIds,
    int? usageLimit,
    int? usageCount,
    bool? oncePerCustomer,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? canCombine,
    int? buyQuantity,
    int? getQuantity,
    Map<String, dynamic>? metadata,
  }) {
    return Discount(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      name: name ?? this.name,
      description: description ?? this.description,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      maximumDiscount: maximumDiscount ?? this.maximumDiscount,
      applicableProductIds: applicableProductIds ?? this.applicableProductIds,
      applicableCategoryIds:
          applicableCategoryIds ?? this.applicableCategoryIds,
      excludedProductIds: excludedProductIds ?? this.excludedProductIds,
      excludedCategoryIds: excludedCategoryIds ?? this.excludedCategoryIds,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      oncePerCustomer: oncePerCustomer ?? this.oncePerCustomer,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      canCombine: canCombine ?? this.canCombine,
      buyQuantity: buyQuantity ?? this.buyQuantity,
      getQuantity: getQuantity ?? this.getQuantity,
      metadata: metadata ?? this.metadata,
    );
  }

  static DiscountType _parseDiscountType(String? type) {
    switch (type?.toLowerCase()) {
      case 'percentage':
      case 'percent':
        return DiscountType.percentage;
      case 'fixed':
      case 'fixed_amount':
      case 'fixedamount':
        return DiscountType.fixedAmount;
      case 'fixed_price':
      case 'fixedprice':
        return DiscountType.fixedPrice;
      case 'free_shipping':
      case 'freeshipping':
        return DiscountType.freeShipping;
      case 'bxgy':
      case 'buy_x_get_y':
        return DiscountType.buyXGetY;
      default:
        return DiscountType.percentage;
    }
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        code,
        type,
        value,
        name,
        isActive,
        startDate,
        endDate,
      ];
}
