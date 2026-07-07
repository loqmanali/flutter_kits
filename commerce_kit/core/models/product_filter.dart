import 'package:equatable/equatable.dart';

import '../enums/product_type.dart';
import '../enums/sort_option.dart';
import '../enums/stock_status.dart';
import 'money.dart';

/// Represents a set of filters for product search/listing.
class ProductFilter extends Equatable {
  /// Search query string.
  final String? query;

  /// Category IDs to filter by.
  final List<String> categoryIds;

  /// Minimum price filter.
  final Money? minPrice;

  /// Maximum price filter.
  final Money? maxPrice;

  /// Stock statuses to include.
  final List<StockStatus> stockStatuses;

  /// Product types to include.
  final List<ProductType> productTypes;

  /// Tags to filter by.
  final List<String> tags;

  /// Attribute filters (e.g., {"color": ["red", "blue"], "size": ["M", "L"]}).
  final Map<String, List<String>> attributes;

  /// Only show products on sale.
  final bool onSaleOnly;

  /// Only show featured products.
  final bool featuredOnly;

  /// Only show products in stock.
  final bool inStockOnly;

  /// Minimum rating filter (0-5).
  final double? minRating;

  /// Brand IDs to filter by.
  final List<String> brandIds;

  /// Sort option.
  final SortOption sortBy;

  /// Creates a [ProductFilter].
  const ProductFilter({
    this.query,
    this.categoryIds = const [],
    this.minPrice,
    this.maxPrice,
    this.stockStatuses = const [],
    this.productTypes = const [],
    this.tags = const [],
    this.attributes = const {},
    this.onSaleOnly = false,
    this.featuredOnly = false,
    this.inStockOnly = false,
    this.minRating,
    this.brandIds = const [],
    this.sortBy = SortOption.relevance,
  });

  /// Creates an empty filter (no filtering).
  const ProductFilter.none() : this();

  /// Creates a filter for a specific category.
  factory ProductFilter.byCategory(String categoryId) {
    return ProductFilter(categoryIds: [categoryId]);
  }

  /// Creates a filter for search results.
  factory ProductFilter.search(String query) {
    return ProductFilter(query: query);
  }

  /// Creates a filter for sale items.
  factory ProductFilter.onSale() {
    return const ProductFilter(
      onSaleOnly: true,
      sortBy: SortOption.discount,
    );
  }

  /// Creates a filter for featured items.
  factory ProductFilter.featured() {
    return const ProductFilter(
      featuredOnly: true,
      sortBy: SortOption.featured,
    );
  }

  /// Creates a price range filter.
  factory ProductFilter.priceRange(Money min, Money max) {
    return ProductFilter(
      minPrice: min,
      maxPrice: max,
      sortBy: SortOption.priceLowToHigh,
    );
  }

  /// Whether any filter is active.
  bool get hasActiveFilters {
    return query != null ||
        categoryIds.isNotEmpty ||
        minPrice != null ||
        maxPrice != null ||
        stockStatuses.isNotEmpty ||
        productTypes.isNotEmpty ||
        tags.isNotEmpty ||
        attributes.isNotEmpty ||
        onSaleOnly ||
        featuredOnly ||
        inStockOnly ||
        minRating != null ||
        brandIds.isNotEmpty;
  }

  /// Count of active filters.
  int get activeFilterCount {
    int count = 0;
    if (query != null && query!.isNotEmpty) count++;
    if (categoryIds.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (stockStatuses.isNotEmpty) count++;
    if (productTypes.isNotEmpty) count++;
    if (tags.isNotEmpty) count += tags.length;
    if (attributes.isNotEmpty) count += attributes.length;
    if (onSaleOnly) count++;
    if (featuredOnly) count++;
    if (inStockOnly) count++;
    if (minRating != null) count++;
    if (brandIds.isNotEmpty) count++;
    return count;
  }

  /// Whether this filter has a price range.
  bool get hasPriceRange => minPrice != null || maxPrice != null;

  /// Whether this filter has a search query.
  bool get hasQuery => query != null && query!.isNotEmpty;

  /// Creates a copy with updated fields.
  ProductFilter copyWith({
    String? query,
    List<String>? categoryIds,
    Money? minPrice,
    Money? maxPrice,
    List<StockStatus>? stockStatuses,
    List<ProductType>? productTypes,
    List<String>? tags,
    Map<String, List<String>>? attributes,
    bool? onSaleOnly,
    bool? featuredOnly,
    bool? inStockOnly,
    double? minRating,
    List<String>? brandIds,
    SortOption? sortBy,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearQuery = false,
    bool clearMinRating = false,
  }) {
    return ProductFilter(
      query: clearQuery ? null : (query ?? this.query),
      categoryIds: categoryIds ?? this.categoryIds,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      stockStatuses: stockStatuses ?? this.stockStatuses,
      productTypes: productTypes ?? this.productTypes,
      tags: tags ?? this.tags,
      attributes: attributes ?? this.attributes,
      onSaleOnly: onSaleOnly ?? this.onSaleOnly,
      featuredOnly: featuredOnly ?? this.featuredOnly,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      brandIds: brandIds ?? this.brandIds,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Clears all filters.
  ProductFilter clear() => const ProductFilter.none();

  /// Clears filters but keeps sort option.
  ProductFilter clearFiltersKeepSort() => ProductFilter(sortBy: sortBy);

  /// Adds a category to the filter.
  ProductFilter addCategory(String categoryId) {
    if (categoryIds.contains(categoryId)) return this;
    return copyWith(categoryIds: [...categoryIds, categoryId]);
  }

  /// Removes a category from the filter.
  ProductFilter removeCategory(String categoryId) {
    return copyWith(
      categoryIds: categoryIds.where((id) => id != categoryId).toList(),
    );
  }

  /// Adds a tag to the filter.
  ProductFilter addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag]);
  }

  /// Removes a tag from the filter.
  ProductFilter removeTag(String tag) {
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  /// Adds an attribute value to the filter.
  ProductFilter addAttribute(String attributeKey, String value) {
    final current = attributes[attributeKey] ?? [];
    if (current.contains(value)) return this;
    return copyWith(
      attributes: {
        ...attributes,
        attributeKey: [...current, value],
      },
    );
  }

  /// Removes an attribute value from the filter.
  ProductFilter removeAttribute(String attributeKey, String value) {
    final current = attributes[attributeKey] ?? [];
    final updated = current.where((v) => v != value).toList();
    if (updated.isEmpty) {
      final newAttributes = Map<String, List<String>>.from(attributes);
      newAttributes.remove(attributeKey);
      return copyWith(attributes: newAttributes);
    }
    return copyWith(
      attributes: {
        ...attributes,
        attributeKey: updated,
      },
    );
  }

  /// Converts to query parameters map for API requests.
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (query != null && query!.isNotEmpty) {
      params['q'] = query;
    }

    if (categoryIds.isNotEmpty) {
      params['category'] = categoryIds.join(',');
    }

    if (minPrice != null) {
      params['min_price'] = minPrice!.amount;
    }

    if (maxPrice != null) {
      params['max_price'] = maxPrice!.amount;
    }

    if (stockStatuses.isNotEmpty) {
      params['stock_status'] = stockStatuses.map((s) => s.name).join(',');
    }

    if (productTypes.isNotEmpty) {
      params['type'] = productTypes.map((t) => t.name).join(',');
    }

    if (tags.isNotEmpty) {
      params['tags'] = tags.join(',');
    }

    if (attributes.isNotEmpty) {
      for (final entry in attributes.entries) {
        params['attr_${entry.key}'] = entry.value.join(',');
      }
    }

    if (onSaleOnly) params['on_sale'] = true;
    if (featuredOnly) params['featured'] = true;
    if (inStockOnly) params['in_stock'] = true;

    if (minRating != null) {
      params['min_rating'] = minRating;
    }

    if (brandIds.isNotEmpty) {
      params['brand'] = brandIds.join(',');
    }

    params['sort'] = sortBy.apiParam;

    return params;
  }

  @override
  List<Object?> get props => [
        query,
        categoryIds,
        minPrice,
        maxPrice,
        stockStatuses,
        productTypes,
        tags,
        attributes,
        onSaleOnly,
        featuredOnly,
        inStockOnly,
        minRating,
        brandIds,
        sortBy,
      ];
}

/// Represents filter options available for a product list.
class AvailableFilters extends Equatable {
  /// Price range (min/max).
  final FilterPriceRange? priceRange;

  /// Available categories.
  final List<FilterOption> categories;

  /// Available brands.
  final List<FilterOption> brands;

  /// Available tags.
  final List<FilterOption> tags;

  /// Available attributes.
  final Map<String, List<FilterOption>> attributes;

  /// Creates [AvailableFilters].
  const AvailableFilters({
    this.priceRange,
    this.categories = const [],
    this.brands = const [],
    this.tags = const [],
    this.attributes = const {},
  });

  /// Creates empty available filters.
  const AvailableFilters.empty() : this();

  /// Creates from a list of products.
  // ignore: avoid_unused_constructor_parameters
  factory AvailableFilters.fromProducts(List<dynamic> products) {
    // Implementation would analyze products to extract available filters
    // This is a placeholder - actual implementation depends on Product model
    // ignore: unused_local_variable
    final _ = products; // Acknowledge parameter for future implementation
    return const AvailableFilters.empty();
  }

  @override
  List<Object?> get props => [priceRange, categories, brands, tags, attributes];
}

/// Represents a filter option with count.
class FilterOption extends Equatable {
  /// Option ID.
  final String id;

  /// Display label.
  final String label;

  /// Number of products matching this option.
  final int count;

  /// Creates a [FilterOption].
  const FilterOption({
    required this.id,
    required this.label,
    this.count = 0,
  });

  @override
  List<Object?> get props => [id, label, count];
}

/// Represents a price range for filtering.
///
/// Note: Named FilterPriceRange to avoid conflict with PriceRange in product.dart
class FilterPriceRange extends Equatable {
  /// Minimum price.
  final Money min;

  /// Maximum price.
  final Money max;

  /// Creates a [FilterPriceRange].
  const FilterPriceRange({
    required this.min,
    required this.max,
  });

  /// Range span.
  Money get span => max - min;

  @override
  List<Object?> get props => [min, max];
}
