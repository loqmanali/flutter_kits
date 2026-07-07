/// Defines the type of variant attribute for a product.
///
/// This enum categorizes the different ways a product can vary,
/// helping to determine how variant selectors should be displayed
/// and how variant combinations should be managed.
///
/// ## Usage
///
/// ```dart
/// final sizeOption = ProductOption(
///   id: 'size',
///   name: 'Size',
///   type: VariantType.size,
///   values: [
///     ProductOptionValue(id: 's', value: 'Single', priceModifier: Money(0)),
///     ProductOptionValue(id: 'd', value: 'Double', priceModifier: Money(25)),
///   ],
/// );
/// ```
enum VariantType {
  /// Size variant (e.g., Small, Medium, Large, Single, Double).
  ///
  /// Typically displayed as buttons or a dropdown.
  /// Often affects price.
  size,

  /// Color variant (e.g., Red, Blue, Green).
  ///
  /// Typically displayed as color swatches.
  /// May or may not affect price.
  color,

  /// Weight variant (e.g., 250g, 500g, 1kg).
  ///
  /// Common in food products.
  /// Usually affects price proportionally.
  weight,

  /// Material variant (e.g., Cotton, Polyester, Leather).
  ///
  /// Common in clothing or accessories.
  /// Often affects price.
  material,

  /// Flavor variant (e.g., Original, Spicy, BBQ).
  ///
  /// Common in food products.
  /// May or may not affect price.
  flavor,

  /// Temperature variant (e.g., Hot, Cold, Iced).
  ///
  /// Common in beverages.
  /// May or may not affect price.
  temperature,

  /// Quantity variant (e.g., 1 piece, 6 pieces, 12 pieces).
  ///
  /// For products sold in different quantities.
  /// Affects price based on quantity.
  quantity,

  /// Duration variant (e.g., 1 month, 6 months, 1 year).
  ///
  /// Common for subscriptions and services.
  /// Affects price based on duration.
  duration,

  /// Customization variant (e.g., With cheese, Without onions).
  ///
  /// For product customizations.
  /// May affect price.
  customization,

  /// Combo variant (e.g., Burger only, Burger + Fries, Full Meal).
  ///
  /// For meal combinations.
  /// Affects price based on included items.
  combo,

  /// Add-on variant (e.g., Extra cheese, Extra sauce).
  ///
  /// For additional items that can be added.
  /// Usually adds to the price.
  addon,

  /// Style variant (e.g., Grilled, Fried, Steamed).
  ///
  /// For preparation style options.
  /// May or may not affect price.
  style,

  /// Generic/Other variant type.
  ///
  /// For any variant that doesn't fit other categories.
  other,
}

/// Extension methods for [VariantType].
extension VariantTypeExtension on VariantType {
  /// Returns `true` if this variant type typically affects price.
  bool get typicallyAffectsPrice {
    switch (this) {
      case VariantType.size:
      case VariantType.weight:
      case VariantType.quantity:
      case VariantType.duration:
      case VariantType.combo:
      case VariantType.addon:
        return true;
      case VariantType.color:
      case VariantType.material:
      case VariantType.flavor:
      case VariantType.temperature:
      case VariantType.customization:
      case VariantType.style:
      case VariantType.other:
        return false;
    }
  }

  /// Returns `true` if this variant type should be displayed as color swatches.
  bool get isColorSwatch => this == VariantType.color;

  /// Returns `true` if this variant type allows multiple selections.
  bool get allowsMultipleSelection {
    switch (this) {
      case VariantType.addon:
      case VariantType.customization:
        return true;
      default:
        return false;
    }
  }

  /// Returns the display name for this variant type.
  String get displayName {
    switch (this) {
      case VariantType.size:
        return 'Size';
      case VariantType.color:
        return 'Color';
      case VariantType.weight:
        return 'Weight';
      case VariantType.material:
        return 'Material';
      case VariantType.flavor:
        return 'Flavor';
      case VariantType.temperature:
        return 'Temperature';
      case VariantType.quantity:
        return 'Quantity';
      case VariantType.duration:
        return 'Duration';
      case VariantType.customization:
        return 'Customization';
      case VariantType.combo:
        return 'Combo';
      case VariantType.addon:
        return 'Add-on';
      case VariantType.style:
        return 'Style';
      case VariantType.other:
        return 'Option';
    }
  }

  /// Returns a suggested icon name for this variant type.
  String get suggestedIcon {
    switch (this) {
      case VariantType.size:
        return 'straighten';
      case VariantType.color:
        return 'palette';
      case VariantType.weight:
        return 'scale';
      case VariantType.material:
        return 'texture';
      case VariantType.flavor:
        return 'restaurant';
      case VariantType.temperature:
        return 'thermostat';
      case VariantType.quantity:
        return 'numbers';
      case VariantType.duration:
        return 'schedule';
      case VariantType.customization:
        return 'tune';
      case VariantType.combo:
        return 'restaurant_menu';
      case VariantType.addon:
        return 'add_circle';
      case VariantType.style:
        return 'style';
      case VariantType.other:
        return 'more_horiz';
    }
  }
}
