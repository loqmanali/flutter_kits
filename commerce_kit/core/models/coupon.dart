import 'package:equatable/equatable.dart';

import '../enums/coupon_type.dart';
import 'money.dart';

/// Represents a coupon/promo code.
class Coupon extends Equatable {
  /// Unique identifier.
  final String id;

  /// Coupon code.
  final String code;

  /// Display name.
  final String? name;

  /// Description.
  final String? description;

  /// Coupon type.
  final CouponType type;

  /// Discount value (percentage or fixed amount).
  final double value;

  /// Maximum discount amount (for percentage coupons).
  final Money? maxDiscount;

  /// Minimum order amount required.
  final Money? minimumOrderAmount;

  /// Minimum items required.
  final int? minimumItems;

  /// Maximum usage count (total).
  final int? maxUsageCount;

  /// Current usage count.
  final int currentUsageCount;

  /// Maximum usage per user.
  final int? maxUsagePerUser;

  /// Start date.
  final DateTime? validFrom;

  /// End date.
  final DateTime? validUntil;

  /// Applicable product IDs (empty = all products).
  final List<String> applicableProductIds;

  /// Applicable category IDs (empty = all categories).
  final List<String> applicableCategoryIds;

  /// Excluded product IDs.
  final List<String> excludedProductIds;

  /// Excluded category IDs.
  final List<String> excludedCategoryIds;

  /// Applicable user IDs (empty = all users).
  final List<String> applicableUserIds;

  /// Whether coupon is active.
  final bool isActive;

  /// Whether this is a single-use coupon.
  final bool isSingleUse;

  /// Whether coupon can combine with other discounts.
  final bool canCombine;

  /// Free item product ID (for free item coupons).
  final String? freeItemProductId;

  /// Free item quantity.
  final int? freeItemQuantity;

  /// Buy X quantity (for buy X get Y).
  final int? buyQuantity;

  /// Get Y quantity (for buy X get Y).
  final int? getQuantity;

  /// Points multiplier (for points multiplier coupons).
  final double? pointsMultiplier;

  /// Cashback percentage (for cashback coupons).
  final double? cashbackPercentage;

  /// Image URL.
  final String? imageUrl;

  /// Terms and conditions.
  final String? termsAndConditions;

  /// Custom metadata.
  final Map<String, dynamic> metadata;

  /// Creates a [Coupon].
  const Coupon({
    required this.id,
    required this.code,
    this.name,
    this.description,
    required this.type,
    required this.value,
    this.maxDiscount,
    this.minimumOrderAmount,
    this.minimumItems,
    this.maxUsageCount,
    this.currentUsageCount = 0,
    this.maxUsagePerUser,
    this.validFrom,
    this.validUntil,
    this.applicableProductIds = const [],
    this.applicableCategoryIds = const [],
    this.excludedProductIds = const [],
    this.excludedCategoryIds = const [],
    this.applicableUserIds = const [],
    this.isActive = true,
    this.isSingleUse = false,
    this.canCombine = false,
    this.freeItemProductId,
    this.freeItemQuantity,
    this.buyQuantity,
    this.getQuantity,
    this.pointsMultiplier,
    this.cashbackPercentage,
    this.imageUrl,
    this.termsAndConditions,
    this.metadata = const {},
  });

  /// Returns true if coupon is currently valid (date-wise).
  bool get isValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    if (maxUsageCount != null && currentUsageCount >= maxUsageCount!) {
      return false;
    }
    return true;
  }

  /// Returns true if coupon has expired.
  bool get isExpired =>
      validUntil != null && DateTime.now().isAfter(validUntil!);

  /// Returns true if coupon hasn't started yet.
  bool get isNotStarted =>
      validFrom != null && DateTime.now().isBefore(validFrom!);

  /// Returns true if usage limit is reached.
  bool get isUsageLimitReached =>
      maxUsageCount != null && currentUsageCount >= maxUsageCount!;

  /// Returns remaining uses.
  int? get remainingUses =>
      maxUsageCount != null ? maxUsageCount! - currentUsageCount : null;

  /// Returns formatted discount description.
  String get formattedDiscount {
    switch (type) {
      case CouponType.percentage:
        final maxText =
            maxDiscount != null ? ' (max ${maxDiscount!.formatted})' : '';
        return '${value.toStringAsFixed(0)}% off$maxText';
      case CouponType.fixedAmount:
        return '${Money(value).formatted} off';
      case CouponType.freeShipping:
        return 'Free Shipping';
      case CouponType.freeItem:
        return 'Free Item';
      case CouponType.buyXGetY:
        return 'Buy $buyQuantity Get $getQuantity Free';
      case CouponType.fixedPrice:
        return 'Special Price: ${Money(value).formatted}';
      case CouponType.cashback:
        return '${value.toStringAsFixed(0)}% Cashback';
      case CouponType.pointsMultiplier:
        return '${pointsMultiplier?.toStringAsFixed(1)}x Points';
      case CouponType.bundleDiscount:
        return '${value.toStringAsFixed(0)}% Bundle Discount';
      case CouponType.firstOrder:
        return '${value.toStringAsFixed(0)}% First Order';
      case CouponType.referral:
        return 'Referral Bonus';
      case CouponType.special:
        return description ?? 'Special Offer';
    }
  }

  /// Calculates discount for a given order amount.
  Money calculateDiscount(Money orderAmount) {
    if (!isValid) return const Money.zero();

    switch (type) {
      case CouponType.percentage:
      case CouponType.bundleDiscount:
      case CouponType.firstOrder:
        var discount = orderAmount * (value / 100);
        if (maxDiscount != null && discount > maxDiscount!) {
          discount = maxDiscount!;
        }
        return discount;
      case CouponType.fixedAmount:
        return Money(value, currency: orderAmount.currency);
      case CouponType.freeShipping:
      case CouponType.freeItem:
      case CouponType.buyXGetY:
      case CouponType.fixedPrice:
      case CouponType.cashback:
      case CouponType.pointsMultiplier:
      case CouponType.referral:
      case CouponType.special:
        return const Money.zero();
    }
  }

  /// Creates a [Coupon] from JSON.
  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      type: CouponType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'percentage'),
        orElse: () => CouponType.percentage,
      ),
      value: (json['value'] as num).toDouble(),
      maxDiscount: json['max_discount'] != null
          ? Money.fromJson(json['max_discount'] as Map<String, dynamic>)
          : json['maxDiscount'] != null
              ? Money((json['maxDiscount'] as num).toDouble())
              : null,
      minimumOrderAmount: json['minimum_order_amount'] != null
          ? Money.fromJson(json['minimum_order_amount'] as Map<String, dynamic>)
          : json['minimumOrderAmount'] != null
              ? Money((json['minimumOrderAmount'] as num).toDouble())
              : null,
      minimumItems: json['minimum_items'] ?? json['minimumItems'] as int?,
      maxUsageCount: json['max_usage_count'] ?? json['maxUsageCount'] as int?,
      currentUsageCount:
          json['current_usage_count'] ?? json['currentUsageCount'] as int? ?? 0,
      maxUsagePerUser:
          json['max_usage_per_user'] ?? json['maxUsagePerUser'] as int?,
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'] as String)
          : json['validFrom'] != null
              ? DateTime.parse(json['validFrom'] as String)
              : null,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : json['validUntil'] != null
              ? DateTime.parse(json['validUntil'] as String)
              : null,
      applicableProductIds: (json['applicable_product_ids'] ??
                  json['applicableProductIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      applicableCategoryIds: (json['applicable_category_ids'] ??
                  json['applicableCategoryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      excludedProductIds: (json['excluded_product_ids'] ??
                  json['excludedProductIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      excludedCategoryIds: (json['excluded_category_ids'] ??
                  json['excludedCategoryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      applicableUserIds: (json['applicable_user_ids'] ??
                  json['applicableUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: json['is_active'] ?? json['isActive'] as bool? ?? true,
      isSingleUse:
          json['is_single_use'] ?? json['isSingleUse'] as bool? ?? false,
      canCombine: json['can_combine'] ?? json['canCombine'] as bool? ?? false,
      freeItemProductId:
          json['free_item_product_id'] ?? json['freeItemProductId'] as String?,
      freeItemQuantity:
          json['free_item_quantity'] ?? json['freeItemQuantity'] as int?,
      buyQuantity: json['buy_quantity'] ?? json['buyQuantity'] as int?,
      getQuantity: json['get_quantity'] ?? json['getQuantity'] as int?,
      pointsMultiplier:
          (json['points_multiplier'] ?? json['pointsMultiplier'] as num?)
              ?.toDouble(),
      cashbackPercentage:
          (json['cashback_percentage'] ?? json['cashbackPercentage'] as num?)
              ?.toDouble(),
      imageUrl: json['image_url'] ?? json['imageUrl'] as String?,
      termsAndConditions:
          json['terms_and_conditions'] ?? json['termsAndConditions'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'type': type.name,
        'value': value,
        'max_discount': maxDiscount?.toJson(),
        'minimum_order_amount': minimumOrderAmount?.toJson(),
        'minimum_items': minimumItems,
        'max_usage_count': maxUsageCount,
        'current_usage_count': currentUsageCount,
        'max_usage_per_user': maxUsagePerUser,
        'valid_from': validFrom?.toIso8601String(),
        'valid_until': validUntil?.toIso8601String(),
        'applicable_product_ids': applicableProductIds,
        'applicable_category_ids': applicableCategoryIds,
        'excluded_product_ids': excludedProductIds,
        'excluded_category_ids': excludedCategoryIds,
        'applicable_user_ids': applicableUserIds,
        'is_active': isActive,
        'is_single_use': isSingleUse,
        'can_combine': canCombine,
        'free_item_product_id': freeItemProductId,
        'free_item_quantity': freeItemQuantity,
        'buy_quantity': buyQuantity,
        'get_quantity': getQuantity,
        'points_multiplier': pointsMultiplier,
        'cashback_percentage': cashbackPercentage,
        'image_url': imageUrl,
        'terms_and_conditions': termsAndConditions,
        'metadata': metadata,
      };

  /// Creates a copy with updated values.
  Coupon copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    CouponType? type,
    double? value,
    Money? maxDiscount,
    Money? minimumOrderAmount,
    int? minimumItems,
    int? maxUsageCount,
    int? currentUsageCount,
    int? maxUsagePerUser,
    DateTime? validFrom,
    DateTime? validUntil,
    List<String>? applicableProductIds,
    List<String>? applicableCategoryIds,
    List<String>? excludedProductIds,
    List<String>? excludedCategoryIds,
    List<String>? applicableUserIds,
    bool? isActive,
    bool? isSingleUse,
    bool? canCombine,
    String? freeItemProductId,
    int? freeItemQuantity,
    int? buyQuantity,
    int? getQuantity,
    double? pointsMultiplier,
    double? cashbackPercentage,
    String? imageUrl,
    String? termsAndConditions,
    Map<String, dynamic>? metadata,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      minimumItems: minimumItems ?? this.minimumItems,
      maxUsageCount: maxUsageCount ?? this.maxUsageCount,
      currentUsageCount: currentUsageCount ?? this.currentUsageCount,
      maxUsagePerUser: maxUsagePerUser ?? this.maxUsagePerUser,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      applicableProductIds: applicableProductIds ?? this.applicableProductIds,
      applicableCategoryIds:
          applicableCategoryIds ?? this.applicableCategoryIds,
      excludedProductIds: excludedProductIds ?? this.excludedProductIds,
      excludedCategoryIds: excludedCategoryIds ?? this.excludedCategoryIds,
      applicableUserIds: applicableUserIds ?? this.applicableUserIds,
      isActive: isActive ?? this.isActive,
      isSingleUse: isSingleUse ?? this.isSingleUse,
      canCombine: canCombine ?? this.canCombine,
      freeItemProductId: freeItemProductId ?? this.freeItemProductId,
      freeItemQuantity: freeItemQuantity ?? this.freeItemQuantity,
      buyQuantity: buyQuantity ?? this.buyQuantity,
      getQuantity: getQuantity ?? this.getQuantity,
      pointsMultiplier: pointsMultiplier ?? this.pointsMultiplier,
      cashbackPercentage: cashbackPercentage ?? this.cashbackPercentage,
      imageUrl: imageUrl ?? this.imageUrl,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        type,
        value,
        maxDiscount,
        minimumOrderAmount,
        minimumItems,
        maxUsageCount,
        currentUsageCount,
        maxUsagePerUser,
        validFrom,
        validUntil,
        applicableProductIds,
        applicableCategoryIds,
        excludedProductIds,
        excludedCategoryIds,
        applicableUserIds,
        isActive,
        isSingleUse,
        canCombine,
        freeItemProductId,
        freeItemQuantity,
        buyQuantity,
        getQuantity,
        pointsMultiplier,
        cashbackPercentage,
        imageUrl,
        termsAndConditions,
        metadata,
      ];
}

/// Represents coupon validation result.
class CouponValidation extends Equatable {
  /// Whether coupon is valid.
  final bool isValid;

  /// The coupon (if valid).
  final Coupon? coupon;

  /// Error message (if invalid).
  final String? errorMessage;

  /// Error code.
  final String? errorCode;

  /// Discount amount (if valid).
  final Money? discountAmount;

  /// Creates a [CouponValidation].
  const CouponValidation({
    required this.isValid,
    this.coupon,
    this.errorMessage,
    this.errorCode,
    this.discountAmount,
  });

  /// Creates a valid result.
  factory CouponValidation.valid({
    required Coupon coupon,
    required Money discountAmount,
  }) {
    return CouponValidation(
      isValid: true,
      coupon: coupon,
      discountAmount: discountAmount,
    );
  }

  /// Creates an invalid result.
  factory CouponValidation.invalid({
    required String message,
    String? code,
  }) {
    return CouponValidation(
      isValid: false,
      errorMessage: message,
      errorCode: code,
    );
  }

  /// Creates from JSON.
  factory CouponValidation.fromJson(Map<String, dynamic> json) {
    return CouponValidation(
      isValid: json['is_valid'] ?? json['isValid'] as bool,
      coupon: json['coupon'] != null
          ? Coupon.fromJson(json['coupon'] as Map<String, dynamic>)
          : null,
      errorMessage: json['error_message'] ??
          json['errorMessage'] ??
          json['message'] as String?,
      errorCode: json['error_code'] ?? json['errorCode'] as String?,
      discountAmount: json['discount_amount'] != null
          ? Money.fromJson(json['discount_amount'] as Map<String, dynamic>)
          : json['discountAmount'] != null
              ? Money((json['discountAmount'] as num).toDouble())
              : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'is_valid': isValid,
        'coupon': coupon?.toJson(),
        'error_message': errorMessage,
        'error_code': errorCode,
        'discount_amount': discountAmount?.toJson(),
      };

  @override
  List<Object?> get props => [
        isValid,
        coupon,
        errorMessage,
        errorCode,
        discountAmount,
      ];
}

/// Common coupon error codes.
class CouponErrorCode {
  static const String notFound = 'COUPON_NOT_FOUND';
  static const String expired = 'COUPON_EXPIRED';
  static const String notStarted = 'COUPON_NOT_STARTED';
  static const String inactive = 'COUPON_INACTIVE';
  static const String usageLimitReached = 'USAGE_LIMIT_REACHED';
  static const String userLimitReached = 'USER_LIMIT_REACHED';
  static const String minimumNotMet = 'MINIMUM_ORDER_NOT_MET';
  static const String minimumItemsNotMet = 'MINIMUM_ITEMS_NOT_MET';
  static const String notApplicable = 'NOT_APPLICABLE_TO_ITEMS';
  static const String alreadyUsed = 'ALREADY_USED';
  static const String cannotCombine = 'CANNOT_COMBINE';
}
