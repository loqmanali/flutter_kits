import '../core/models/money.dart';

/// Configuration for cart behavior.
///
/// Use this to customize cart limits, thresholds, and behavior.
///
/// ## Usage
///
/// ```dart
/// final config = CartConfig(
///   maxQuantityPerItem: 10,
///   maxUniqueItems: 50,
///   freeShippingThreshold: Money(500),
///   persistenceEnabled: true,
/// );
/// ```
class CartConfig {
  /// Maximum quantity allowed per item.
  final int maxQuantityPerItem;

  /// Minimum quantity allowed per item.
  final int minQuantityPerItem;

  /// Maximum number of unique items in cart.
  final int? maxUniqueItems;

  /// Maximum total items in cart (sum of quantities).
  final int? maxTotalItems;

  /// Minimum order amount for checkout.
  final Money? minimumOrderAmount;

  /// Maximum order amount.
  final Money? maximumOrderAmount;

  /// Free shipping threshold.
  final Money? freeShippingThreshold;

  /// Default shipping cost.
  final Money? defaultShippingCost;

  /// Tax rate (e.g., 0.14 for 14%).
  final double? taxRate;

  /// Whether tax is included in prices.
  final bool taxIncluded;

  /// Whether to persist cart to local storage.
  final bool persistenceEnabled;

  /// Whether to allow items out of stock to be added.
  final bool allowOutOfStock;

  /// Whether to merge identical items (same product + options).
  final bool mergeIdenticalItems;

  /// Whether to show stock warnings.
  final bool showStockWarnings;

  /// Low stock threshold for warnings.
  final int lowStockThreshold;

  /// Default currency.
  final String defaultCurrency;

  /// Creates a [CartConfig] instance.
  const CartConfig({
    this.maxQuantityPerItem = 99,
    this.minQuantityPerItem = 1,
    this.maxUniqueItems,
    this.maxTotalItems,
    this.minimumOrderAmount,
    this.maximumOrderAmount,
    this.freeShippingThreshold,
    this.defaultShippingCost,
    this.taxRate,
    this.taxIncluded = false,
    this.persistenceEnabled = true,
    this.allowOutOfStock = false,
    this.mergeIdenticalItems = true,
    this.showStockWarnings = true,
    this.lowStockThreshold = 5,
    this.defaultCurrency = 'EGP',
  });

  /// Default configuration.
  static const CartConfig defaults = CartConfig();

  /// Configuration for restaurants/food delivery.
  factory CartConfig.restaurant({
    Money? freeDeliveryThreshold,
    Money? minimumOrder,
    String currency = 'EGP',
  }) {
    return CartConfig(
      maxQuantityPerItem: 20,
      freeShippingThreshold: freeDeliveryThreshold,
      minimumOrderAmount: minimumOrder,
      mergeIdenticalItems: false, // Each customization is unique
      defaultCurrency: currency,
    );
  }

  /// Configuration for e-commerce/retail.
  factory CartConfig.retail({
    Money? freeShippingThreshold,
    double? taxRate,
    String currency = 'EGP',
  }) {
    return CartConfig(
      freeShippingThreshold: freeShippingThreshold,
      taxRate: taxRate,
      defaultCurrency: currency,
    );
  }

  /// Creates a copy with modified values.
  CartConfig copyWith({
    int? maxQuantityPerItem,
    int? minQuantityPerItem,
    int? maxUniqueItems,
    int? maxTotalItems,
    Money? minimumOrderAmount,
    Money? maximumOrderAmount,
    Money? freeShippingThreshold,
    Money? defaultShippingCost,
    double? taxRate,
    bool? taxIncluded,
    bool? persistenceEnabled,
    bool? allowOutOfStock,
    bool? mergeIdenticalItems,
    bool? showStockWarnings,
    int? lowStockThreshold,
    String? defaultCurrency,
  }) {
    return CartConfig(
      maxQuantityPerItem: maxQuantityPerItem ?? this.maxQuantityPerItem,
      minQuantityPerItem: minQuantityPerItem ?? this.minQuantityPerItem,
      maxUniqueItems: maxUniqueItems ?? this.maxUniqueItems,
      maxTotalItems: maxTotalItems ?? this.maxTotalItems,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      maximumOrderAmount: maximumOrderAmount ?? this.maximumOrderAmount,
      freeShippingThreshold:
          freeShippingThreshold ?? this.freeShippingThreshold,
      defaultShippingCost: defaultShippingCost ?? this.defaultShippingCost,
      taxRate: taxRate ?? this.taxRate,
      taxIncluded: taxIncluded ?? this.taxIncluded,
      persistenceEnabled: persistenceEnabled ?? this.persistenceEnabled,
      allowOutOfStock: allowOutOfStock ?? this.allowOutOfStock,
      mergeIdenticalItems: mergeIdenticalItems ?? this.mergeIdenticalItems,
      showStockWarnings: showStockWarnings ?? this.showStockWarnings,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    );
  }
}
