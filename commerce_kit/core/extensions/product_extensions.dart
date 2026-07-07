import '../enums/product_type.dart';
import '../enums/stock_status.dart';
import '../models/money.dart';
import '../models/product.dart';
import '../models/product_option.dart';
import '../models/product_option_value.dart';
import '../models/product_variant.dart';

/// Extension methods for [Product].
extension ProductExtensions on Product {
  /// Returns `true` if this product is simple (no variants).
  bool get isSimple => type == ProductType.simple;

  /// Returns `true` if this product is variable (has variants).
  bool get isVariable => type == ProductType.variable;

  /// Returns `true` if this product is configurable.
  bool get isConfigurable => type == ProductType.configurable;

  /// Returns `true` if this product is a bundle.
  bool get isBundle => type == ProductType.bundle;

  /// Returns `true` if this product is digital.
  bool get isDigital => type == ProductType.digital;

  /// Returns all required options.
  List<ProductOption> get requiredOptions {
    return options.where((o) => o.isRequired).toList();
  }

  /// Returns all optional (non-required) options.
  List<ProductOption> get optionalOptions {
    return options.where((o) => !o.isRequired).toList();
  }

  /// Returns all addon options.
  List<ProductOption> get addonOptions {
    return options.where((o) => o.isAddonOption).toList();
  }

  /// Returns the lowest possible price.
  Money get lowestPrice {
    if (variants.isEmpty) return price;
    final prices = variants.map((v) => v.price).toList();
    prices.sort((a, b) => a.amount.compareTo(b.amount));
    return prices.first;
  }

  /// Returns the highest possible price.
  Money get highestPrice {
    if (variants.isEmpty) return price;
    final prices = variants.map((v) => v.price).toList();
    prices.sort((a, b) => b.amount.compareTo(a.amount));
    return prices.first;
  }

  /// Returns a formatted price display string.
  String get priceDisplay {
    if (!hasVariants) return price.formatted;

    final range = priceRange;
    if (range == null || range.isSinglePrice) return price.formatted;

    return 'From ${range.min.formatted}';
  }

  /// Returns available variants (in stock).
  List<ProductVariant> get availableVariants {
    return variants.where((v) => v.canPurchase).toList();
  }

  /// Returns unavailable variants (out of stock).
  List<ProductVariant> get unavailableVariants {
    return variants.where((v) => !v.canPurchase).toList();
  }

  /// Returns variants on sale.
  List<ProductVariant> get saleVariants {
    return variants.where((v) => v.isOnSale).toList();
  }

  /// Checks if a specific option combination is available.
  bool isOptionCombinationAvailable(Map<String, String> selectedOptions) {
    final variant = findVariant(selectedOptions);
    return variant?.canPurchase ?? true;
  }

  /// Gets available values for an option based on current selections.
  ///
  /// This is useful for filtering out unavailable combinations.
  List<ProductOptionValue> getAvailableValuesForOption(
    String optionId,
    Map<String, String> currentSelections,
  ) {
    final option = getOption(optionId);
    if (option == null) return [];

    if (variants.isEmpty) {
      return option.availableValues;
    }

    // Filter values based on what combinations are available
    return option.values.where((value) {
      final testSelection = Map<String, String>.from(currentSelections);
      testSelection[optionId] = value.id;

      // Check if any variant matches this combination
      for (final variant in availableVariants) {
        if (variant.matchesOptions(testSelection)) {
          return true;
        }
      }

      // If no variants defined for this combination, consider it available
      return findVariant(testSelection) == null;
    }).toList();
  }

  /// Gets the default selections for all options.
  Map<String, String> get defaultSelections {
    final selections = <String, String>{};
    for (final option in options) {
      final defaultValue = option.defaultValue;
      if (defaultValue != null) {
        selections[option.id] = defaultValue.id;
      } else if (option.values.isNotEmpty) {
        selections[option.id] = option.values.first.id;
      }
    }
    return selections;
  }

  /// Validates if all required options are selected.
  bool areRequiredOptionsSelected(Map<String, String> selections) {
    for (final option in requiredOptions) {
      if (!selections.containsKey(option.id)) {
        return false;
      }
    }
    return true;
  }

  /// Returns a summary string.
  String get summary {
    final buffer = StringBuffer(name);

    if (isOnSale) {
      buffer.write(' (On Sale!)');
    }

    buffer.write(' - $priceDisplay');

    if (!stockStatus.canPurchase) {
      buffer.write(' [${stockStatus.displayText}]');
    }

    return buffer.toString();
  }
}

/// Extension methods for [ProductVariant].
extension ProductVariantExtensions on ProductVariant {
  /// Returns the formatted price with comparison.
  String get priceWithComparison {
    if (isOnSale) {
      return '${price.formatted} (was ${compareAtPrice!.formatted})';
    }
    return price.formatted;
  }

  /// Returns the discount badge text.
  String? get discountBadge {
    if (!isOnSale) return null;
    final percentage = discountPercentage;
    if (percentage == null) return null;
    return '-${percentage.toStringAsFixed(0)}%';
  }

  /// Returns the stock badge text.
  String? get stockBadge {
    if (stockStatus.shouldShowWarning) {
      return stockStatus.getMessage(quantity: stockQuantity);
    }
    return null;
  }
}

/// Extension methods for [ProductOption].
extension ProductOptionExtensions on ProductOption {
  /// Returns the value with the minimum price modifier.
  ProductOptionValue? get cheapestValue {
    if (values.isEmpty) return null;
    return values.reduce(
      (a, b) => a.priceModifier.amount < b.priceModifier.amount ? a : b,
    );
  }

  /// Returns the value with the maximum price modifier.
  ProductOptionValue? get mostExpensiveValue {
    if (values.isEmpty) return null;
    return values.reduce(
      (a, b) => a.priceModifier.amount > b.priceModifier.amount ? a : b,
    );
  }

  /// Returns values sorted by price modifier (ascending).
  List<ProductOptionValue> get valuesByPrice {
    final sorted = List<ProductOptionValue>.from(values);
    sorted.sort(
      (a, b) => a.priceModifier.amount.compareTo(b.priceModifier.amount),
    );
    return sorted;
  }

  /// Returns values sorted by sort order.
  List<ProductOptionValue> get valuesBySortOrder {
    final sorted = List<ProductOptionValue>.from(values);
    sorted.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }

  /// Returns the price range text for this option.
  String? get priceRangeText {
    if (!hasPriceModifiers) return null;

    final minPrice = cheapestValue?.priceModifier;
    final maxPrice = mostExpensiveValue?.priceModifier;

    if (minPrice == null || maxPrice == null) return null;

    if (minPrice.amount == maxPrice.amount) {
      if (minPrice.isZero) return null;
      return '+${minPrice.formatted}';
    }

    return '+${minPrice.formatted} - +${maxPrice.formatted}';
  }
}

/// Extension methods for List<Product>.
extension ProductListExtensions on List<Product> {
  /// Filters products that are in stock.
  List<Product> get inStock {
    return where((p) => p.canPurchase).toList();
  }

  /// Filters products that are out of stock.
  List<Product> get outOfStock {
    return where((p) => !p.canPurchase).toList();
  }

  /// Filters products that are on sale.
  List<Product> get onSale {
    return where((p) => p.isOnSale).toList();
  }

  /// Filters featured products.
  List<Product> get featured {
    return where((p) => p.isFeatured).toList();
  }

  /// Filters new products.
  List<Product> get newProducts {
    return where((p) => p.isNew).toList();
  }

  /// Sorts products by price (ascending).
  List<Product> get sortedByPriceAsc {
    final sorted = List<Product>.from(this);
    sorted.sort((a, b) => a.price.amount.compareTo(b.price.amount));
    return sorted;
  }

  /// Sorts products by price (descending).
  List<Product> get sortedByPriceDesc {
    final sorted = List<Product>.from(this);
    sorted.sort((a, b) => b.price.amount.compareTo(a.price.amount));
    return sorted;
  }

  /// Sorts products by name.
  List<Product> get sortedByName {
    final sorted = List<Product>.from(this);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  /// Sorts products by rating (highest first).
  List<Product> get sortedByRating {
    final sorted = List<Product>.from(this);
    sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return sorted;
  }

  /// Filters products by category.
  List<Product> byCategory(String categoryId) {
    return where((p) => p.categoryIds.contains(categoryId)).toList();
  }

  /// Filters products by tag.
  List<Product> byTag(String tagId) {
    return where((p) => p.tagIds.contains(tagId)).toList();
  }

  /// Filters products by brand.
  List<Product> byBrand(String brand) {
    return where((p) => p.brand == brand).toList();
  }

  /// Filters products within a price range.
  List<Product> inPriceRange(Money min, Money max) {
    return where((p) => p.price >= min && p.price <= max).toList();
  }

  /// Searches products by name.
  List<Product> search(String query) {
    final lowerQuery = query.toLowerCase();
    return where(
      (p) =>
          p.name.toLowerCase().contains(lowerQuery) ||
          (p.description?.toLowerCase().contains(lowerQuery) ?? false),
    ).toList();
  }
}
