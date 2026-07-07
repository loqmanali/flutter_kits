/// Defines the type of discount that can be applied to products or cart.
///
/// This enum helps categorize discounts and determine how they should be
/// calculated and displayed.
///
/// ## Usage
///
/// ```dart
/// final discount = Discount(
///   id: 'summer-sale',
///   code: 'SUMMER20',
///   type: DiscountType.percentage,
///   value: 20,
///   // 20% off
/// );
///
/// final fixedDiscount = Discount(
///   id: 'flat-50',
///   code: 'FLAT50',
///   type: DiscountType.fixedAmount,
///   value: 50,
///   // 50 EGP off
/// );
/// ```
enum DiscountType {
  /// A percentage-based discount.
  ///
  /// Value represents the percentage to discount (e.g., 20 = 20% off).
  /// Applied to the subtotal or item price.
  percentage,

  /// A fixed amount discount.
  ///
  /// Value represents the exact amount to discount in the currency.
  /// Applied directly to the total.
  fixedAmount,

  /// A fixed price discount (set price to a specific value).
  ///
  /// Value represents the final price after discount.
  /// Useful for "special price" promotions.
  fixedPrice,

  /// Buy X Get Y free discount.
  ///
  /// Requires additional configuration for X and Y values.
  /// Common for promotional offers.
  buyXGetY,

  /// Free shipping discount.
  ///
  /// Removes or reduces shipping costs.
  /// May have minimum order requirements.
  freeShipping,

  /// Bundle discount (discount when buying specific items together).
  ///
  /// Applied when all required items are in the cart.
  /// Can be percentage or fixed amount.
  bundle,

  /// Tiered discount (different discounts for different quantities).
  ///
  /// Example: 10% off for 2 items, 20% off for 3+ items.
  /// Requires tier configuration.
  tiered,

  /// First-time customer discount.
  ///
  /// Applied only to first-time orders.
  /// Can be percentage or fixed amount.
  firstOrder,

  /// Loyalty points redemption.
  ///
  /// Value represents points being redeemed.
  /// Converted to currency value based on configuration.
  loyaltyPoints,

  /// Referral discount.
  ///
  /// Applied when using a referral code.
  /// Benefits both referrer and referee.
  referral,

  /// Seasonal/promotional discount.
  ///
  /// Time-limited promotional discount.
  /// Automatically applied during promotion period.
  seasonal,

  /// Member-exclusive discount.
  ///
  /// Available only to members/subscribers.
  /// Can be percentage or fixed amount.
  memberExclusive,
}

/// Extension methods for [DiscountType].
extension DiscountTypeExtension on DiscountType {
  /// Returns `true` if this discount type requires a code.
  bool get requiresCode {
    switch (this) {
      case DiscountType.percentage:
      case DiscountType.fixedAmount:
      case DiscountType.referral:
        return true;
      case DiscountType.fixedPrice:
      case DiscountType.buyXGetY:
      case DiscountType.freeShipping:
      case DiscountType.bundle:
      case DiscountType.tiered:
      case DiscountType.firstOrder:
      case DiscountType.loyaltyPoints:
      case DiscountType.seasonal:
      case DiscountType.memberExclusive:
        return false;
    }
  }

  /// Returns `true` if this discount type can be stacked with others.
  bool get canStack {
    switch (this) {
      case DiscountType.freeShipping:
      case DiscountType.memberExclusive:
        return true;
      default:
        return false;
    }
  }

  /// Returns `true` if this discount type is applied automatically.
  bool get isAutomatic {
    switch (this) {
      case DiscountType.bundle:
      case DiscountType.tiered:
      case DiscountType.firstOrder:
      case DiscountType.seasonal:
      case DiscountType.memberExclusive:
        return true;
      default:
        return false;
    }
  }

  /// Returns `true` if this discount type uses percentage calculation.
  bool get isPercentageBased => this == DiscountType.percentage;

  /// Returns `true` if this discount type uses fixed amount calculation.
  bool get isFixedAmountBased =>
      this == DiscountType.fixedAmount || this == DiscountType.fixedPrice;

  /// Returns the display name for this discount type.
  String get displayName {
    switch (this) {
      case DiscountType.percentage:
        return 'Percentage Off';
      case DiscountType.fixedAmount:
        return 'Fixed Discount';
      case DiscountType.fixedPrice:
        return 'Special Price';
      case DiscountType.buyXGetY:
        return 'Buy X Get Y';
      case DiscountType.freeShipping:
        return 'Free Shipping';
      case DiscountType.bundle:
        return 'Bundle Discount';
      case DiscountType.tiered:
        return 'Tiered Discount';
      case DiscountType.firstOrder:
        return 'First Order Discount';
      case DiscountType.loyaltyPoints:
        return 'Points Redemption';
      case DiscountType.referral:
        return 'Referral Discount';
      case DiscountType.seasonal:
        return 'Seasonal Offer';
      case DiscountType.memberExclusive:
        return 'Member Exclusive';
    }
  }
}
