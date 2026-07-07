import '../models/cart.dart';
import '../models/discount.dart';
import '../models/money.dart';
import '../models/price_breakdown.dart';
import '../models/product.dart';
import '../models/product_option.dart';

/// Utility class for calculating prices in the commerce module.
///
/// Provides methods for calculating product prices with options,
/// cart totals, discounts, taxes, and more.
///
/// ## Usage
///
/// ```dart
/// // Calculate product price with options
/// final price = PriceCalculator.calculateProductPrice(
///   product: product,
///   selectedOptions: {'size': 'large', 'cheese': 'extra'},
/// );
///
/// // Calculate cart total
/// final total = PriceCalculator.calculateCartTotal(cart);
///
/// // Calculate with discount
/// final discounted = PriceCalculator.applyDiscount(
///   subtotal: subtotal,
///   discount: discount,
/// );
/// ```
class PriceCalculator {
  PriceCalculator._();

  // ─────────────────────────────────────────────────────────────────────────
  // Product Price Calculations
  // ─────────────────────────────────────────────────────────────────────────

  /// Calculates the total price for a product with selected options.
  ///
  /// Returns the base price plus all option price modifiers.
  static Money calculateProductPrice({
    required Product product,
    Map<String, String> selectedOptions = const {},
    int quantity = 1,
  }) {
    Money unitPrice = product.price;

    // First check if there's a matching variant
    if (product.hasVariants && selectedOptions.isNotEmpty) {
      final variant = product.findVariant(selectedOptions);
      if (variant != null) {
        unitPrice = variant.price;
      }
    }

    // Add option price modifiers
    for (final entry in selectedOptions.entries) {
      final option = product.getOption(entry.key);
      if (option != null) {
        final value = option.getValueById(entry.value);
        if (value != null && !value.priceModifier.isZero) {
          unitPrice = unitPrice + value.priceModifier;
        }
      }
    }

    return unitPrice * quantity;
  }

  /// Calculates the price modifier total for selected options.
  static Money calculateOptionsTotal({
    required Product product,
    required Map<String, String> selectedOptions,
  }) {
    var total = Money.zero(currency: product.price.currency);

    for (final entry in selectedOptions.entries) {
      final option = product.getOption(entry.key);
      if (option != null) {
        final value = option.getValueById(entry.value);
        if (value != null) {
          total = total + value.priceModifier;
        }
      }
    }

    return total;
  }

  /// Calculates the total price modifiers for multiple option values.
  ///
  /// Useful for options that allow multiple selections.
  static Money calculateMultipleOptionsTotal({
    required ProductOption option,
    required List<String> selectedValueIds,
  }) {
    var total = const Money.zero();

    for (final valueId in selectedValueIds) {
      final value = option.getValueById(valueId);
      if (value != null) {
        total = total + value.priceModifier;
      }
    }

    return total;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cart Calculations
  // ─────────────────────────────────────────────────────────────────────────

  /// Calculates the subtotal of a cart (before discounts and taxes).
  static Money calculateCartSubtotal(Cart cart) {
    return cart.subtotal;
  }

  /// Calculates the total discount for a cart.
  static Money calculateCartDiscount(Cart cart) {
    var total = Money.zero(currency: cart.currency);

    // Item-level discounts
    for (final item in cart.items) {
      total = total + item.discountAmount;
    }

    // Cart-level discounts
    for (final discount in cart.discounts) {
      total = total + discount.calculate(cart.subtotal, currency: cart.currency);
    }

    return total;
  }

  /// Calculates the full cart total.
  static Money calculateCartTotal(Cart cart) {
    return cart.totalPrice;
  }

  /// Calculates the cart total with additional costs.
  static Money calculateCartTotalWithCosts({
    required Cart cart,
    Money? shipping,
    double? taxRate,
    Money? fees,
    Money? tip,
  }) {
    var total = cart.totalPrice;

    if (shipping != null) {
      total = total + shipping;
    }

    if (taxRate != null && taxRate > 0) {
      final tax = total.percentage(taxRate * 100);
      total = total + tax;
    }

    if (fees != null) {
      total = total + fees;
    }

    if (tip != null) {
      total = total + tip;
    }

    return total;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Discount Calculations
  // ─────────────────────────────────────────────────────────────────────────

  /// Applies a discount to a subtotal.
  static Money applyDiscount({
    required Money subtotal,
    required Discount discount,
  }) {
    final discountAmount = discount.calculate(subtotal, currency: subtotal.currency);
    final result = subtotal - discountAmount;
    return result.isNegative ? Money.zero(currency: subtotal.currency) : result;
  }

  /// Calculates the discount amount.
  static Money calculateDiscountAmount({
    required Money subtotal,
    required Discount discount,
  }) {
    return discount.calculate(subtotal, currency: subtotal.currency);
  }

  /// Calculates multiple discounts (considering stacking rules).
  static Money calculateMultipleDiscounts({
    required Money subtotal,
    required List<Discount> discounts,
    bool allowStacking = false,
  }) {
    if (discounts.isEmpty) return const Money.zero();

    var totalDiscount = Money.zero(currency: subtotal.currency);
    var currentSubtotal = subtotal;

    for (final discount in discounts) {
      if (!allowStacking && !discount.canCombine && totalDiscount.isPositive) {
        continue;
      }

      final amount = discount.calculate(currentSubtotal, currency: subtotal.currency);
      totalDiscount = totalDiscount + amount;

      // If stacking, reduce subtotal for next calculation
      if (allowStacking) {
        currentSubtotal = currentSubtotal - amount;
        if (currentSubtotal.isNegative) {
          currentSubtotal = Money.zero(currency: subtotal.currency);
        }
      }
    }

    return totalDiscount;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tax Calculations
  // ─────────────────────────────────────────────────────────────────────────

  /// Calculates tax amount.
  static Money calculateTax({
    required Money amount,
    required double taxRate,
  }) {
    return amount.percentage(taxRate * 100);
  }

  /// Calculates the pre-tax amount from a total with tax included.
  static Money calculatePreTaxAmount({
    required Money totalWithTax,
    required double taxRate,
  }) {
    return Money(
      totalWithTax.amount / (1 + taxRate),
      currency: totalWithTax.currency,
    );
  }

  /// Extracts tax from a total with tax included.
  static Money extractTax({
    required Money totalWithTax,
    required double taxRate,
  }) {
    final preTax = calculatePreTaxAmount(
      totalWithTax: totalWithTax,
      taxRate: taxRate,
    );
    return totalWithTax - preTax;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Price Breakdown
  // ─────────────────────────────────────────────────────────────────────────

  /// Generates a complete price breakdown for a cart.
  static PriceBreakdown generateBreakdown({
    required Cart cart,
    Money? shipping,
    double? taxRate,
    Money? fees,
    Money? tip,
    Money? freeShippingThreshold,
  }) {
    return cart.calculateBreakdown(
      shipping: shipping,
      taxRate: taxRate,
      fees: fees,
      tip: tip,
      freeShippingThreshold: freeShippingThreshold,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Utility Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Calculates the savings percentage.
  static double calculateSavingsPercentage({
    required Money originalPrice,
    required Money salePrice,
  }) {
    if (originalPrice.isZero) return 0;
    return ((originalPrice.amount - salePrice.amount) / originalPrice.amount) * 100;
  }

  /// Calculates the amount needed to reach a threshold.
  static Money amountToThreshold({
    required Money current,
    required Money threshold,
  }) {
    if (current >= threshold) return Money.zero(currency: current.currency);
    return threshold - current;
  }

  /// Calculates progress towards a threshold (0.0 to 1.0).
  static double progressToThreshold({
    required Money current,
    required Money threshold,
  }) {
    if (threshold.isZero) return 1.0;
    return (current.amount / threshold.amount).clamp(0.0, 1.0);
  }

  /// Splits a total evenly among a number of parts.
  static List<Money> splitEvenly({
    required Money total,
    required int parts,
  }) {
    if (parts <= 0) return [];
    if (parts == 1) return [total];

    final baseAmount = Money(
      (total.amount / parts).floorToDouble(),
      currency: total.currency,
    );

    final remainder = total - (baseAmount * parts);
    final result = List.generate(parts, (_) => baseAmount);

    // Add remainder to first part
    if (remainder.isPositive) {
      result[0] = result[0] + remainder;
    }

    return result;
  }

  /// Calculates the unit price when buying in bulk.
  static Money calculateBulkUnitPrice({
    required Money basePrice,
    required int quantity,
    required List<BulkPricingTier> tiers,
  }) {
    for (final tier in tiers.reversed) {
      if (quantity >= tier.minQuantity) {
        if (tier.pricePerUnit != null) {
          return tier.pricePerUnit!;
        }
        if (tier.discountPercentage != null) {
          return basePrice.withPercentageOff(tier.discountPercentage!);
        }
      }
    }
    return basePrice;
  }
}

/// Represents a bulk pricing tier.
class BulkPricingTier {
  /// The minimum quantity for this tier.
  final int minQuantity;

  /// The price per unit for this tier.
  final Money? pricePerUnit;

  /// The discount percentage for this tier.
  final double? discountPercentage;

  /// Creates a [BulkPricingTier].
  const BulkPricingTier({
    required this.minQuantity,
    this.pricePerUnit,
    this.discountPercentage,
  });
}
