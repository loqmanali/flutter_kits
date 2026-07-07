/// Defines the type of product in the e-commerce system.
///
/// This enum helps categorize products and determine how they should be
/// handled throughout the application (pricing, inventory, display, etc.).
///
/// ## Usage
///
/// ```dart
/// final product = Product(
///   id: '1',
///   name: 'Burger',
///   type: ProductType.simple,
///   // ...
/// );
///
/// if (product.type == ProductType.variable) {
///   // Show variant selector
/// }
/// ```
enum ProductType {
  /// A simple product with no variants.
  ///
  /// Examples: A single burger, a drink, a side dish.
  /// Has a fixed price and attributes.
  simple,

  /// A product with multiple variants (size, color, etc.).
  ///
  /// Examples: A burger with size options (single, double, triple),
  /// a t-shirt with size and color options.
  /// Price may vary based on selected variant.
  variable,

  /// A grouped product containing multiple related products.
  ///
  /// Examples: A meal combo (burger + fries + drink),
  /// a family pack with multiple items.
  /// Each child product can be configured independently.
  grouped,

  /// A bundle of products sold together at a special price.
  ///
  /// Examples: A party box with fixed items,
  /// a promotional bundle with discount.
  /// Items cannot be modified individually.
  bundle,

  /// A digital/downloadable product.
  ///
  /// Examples: Gift cards, e-vouchers, digital recipes.
  /// No physical inventory tracking needed.
  digital,

  /// A subscription-based product.
  ///
  /// Examples: Monthly meal plan, loyalty membership.
  /// Has recurring billing and special handling.
  subscription,

  /// A configurable product with customizable options.
  ///
  /// Examples: A custom burger where you choose each ingredient,
  /// a pizza with customizable toppings.
  /// Options can affect the final price.
  configurable,

  /// A service-type product.
  ///
  /// Examples: Catering service, delivery service.
  /// May have time slots, locations, or other service-specific attributes.
  service,
}

/// Extension methods for [ProductType].
extension ProductTypeExtension on ProductType {
  /// Returns `true` if this product type can have variants.
  bool get canHaveVariants => this == ProductType.variable;

  /// Returns `true` if this product type can have child products.
  bool get canHaveChildren =>
      this == ProductType.grouped || this == ProductType.bundle;

  /// Returns `true` if this product type requires physical inventory.
  bool get requiresInventory =>
      this != ProductType.digital &&
      this != ProductType.subscription &&
      this != ProductType.service;

  /// Returns `true` if this product type supports customization.
  bool get isCustomizable =>
      this == ProductType.configurable || this == ProductType.variable;

  /// Returns the display name for this product type.
  String get displayName {
    switch (this) {
      case ProductType.simple:
        return 'Simple Product';
      case ProductType.variable:
        return 'Variable Product';
      case ProductType.grouped:
        return 'Grouped Product';
      case ProductType.bundle:
        return 'Bundle';
      case ProductType.digital:
        return 'Digital Product';
      case ProductType.subscription:
        return 'Subscription';
      case ProductType.configurable:
        return 'Configurable Product';
      case ProductType.service:
        return 'Service';
    }
  }
}
