/// Represents the type of coupon/promo code.
enum CouponType {
  /// Percentage discount (e.g., 10% off)
  percentage,

  /// Fixed amount discount (e.g., $5 off)
  fixedAmount,

  /// Free shipping
  freeShipping,

  /// Free item/product
  freeItem,

  /// Buy X get Y free
  buyXGetY,

  /// Fixed price for specific items
  fixedPrice,

  /// Cashback (credited to wallet)
  cashback,

  /// Points multiplier
  pointsMultiplier,

  /// Bundle discount
  bundleDiscount,

  /// First order discount
  firstOrder,

  /// Referral discount
  referral,

  /// Birthday/special occasion
  special,
}

/// Extension methods for [CouponType].
extension CouponTypeExtension on CouponType {
  /// Returns true if this coupon affects price directly
  bool get affectsPrice =>
      this == CouponType.percentage ||
      this == CouponType.fixedAmount ||
      this == CouponType.fixedPrice ||
      this == CouponType.bundleDiscount ||
      this == CouponType.firstOrder;

  /// Returns true if this coupon affects shipping
  bool get affectsShipping => this == CouponType.freeShipping;

  /// Returns true if this coupon adds items
  bool get addsItems =>
      this == CouponType.freeItem || this == CouponType.buyXGetY;

  /// Returns true if this coupon affects rewards
  bool get affectsRewards =>
      this == CouponType.cashback || this == CouponType.pointsMultiplier;

  /// Returns true if this is a one-time use type
  bool get isOneTimeUse =>
      this == CouponType.firstOrder ||
      this == CouponType.referral ||
      this == CouponType.special;

  /// Returns a human-readable label
  String get label {
    switch (this) {
      case CouponType.percentage:
        return 'Percentage Off';
      case CouponType.fixedAmount:
        return 'Amount Off';
      case CouponType.freeShipping:
        return 'Free Shipping';
      case CouponType.freeItem:
        return 'Free Item';
      case CouponType.buyXGetY:
        return 'Buy X Get Y';
      case CouponType.fixedPrice:
        return 'Special Price';
      case CouponType.cashback:
        return 'Cashback';
      case CouponType.pointsMultiplier:
        return 'Bonus Points';
      case CouponType.bundleDiscount:
        return 'Bundle Deal';
      case CouponType.firstOrder:
        return 'First Order';
      case CouponType.referral:
        return 'Referral';
      case CouponType.special:
        return 'Special Offer';
    }
  }

  /// Returns a description format string
  String descriptionFormat(dynamic value) {
    switch (this) {
      case CouponType.percentage:
        return '$value% off';
      case CouponType.fixedAmount:
        return '\$$value off';
      case CouponType.freeShipping:
        return 'Free shipping';
      case CouponType.freeItem:
        return 'Free item';
      case CouponType.buyXGetY:
        return 'Buy $value get 1 free';
      case CouponType.fixedPrice:
        return 'Special price: \$$value';
      case CouponType.cashback:
        return '$value% cashback';
      case CouponType.pointsMultiplier:
        return '${value}x points';
      case CouponType.bundleDiscount:
        return '$value% bundle discount';
      case CouponType.firstOrder:
        return '$value% first order discount';
      case CouponType.referral:
        return '\$$value referral bonus';
      case CouponType.special:
        return 'Special offer';
    }
  }
}
