import '../../core/models/money.dart';
import '../../core/models/product.dart';
import '../../core/models/product_filter.dart';
import '../../core/models/search_result.dart';

/// Abstract adapter for converting API responses to [SearchResult] models.
///
/// Implement this interface to map your specific API response format
/// to the commerce kit's internal [SearchResult] model.
///
/// ## Usage
///
/// ```dart
/// class MySearchAdapter extends SearchResultAdapter<MyApiSearchResult> {
///   @override
///   SearchResult<Product> fromResponse(MyApiSearchResult response) {
///     return SearchResult(
///       items: response.products.map((p) => Product(...)).toList(),
///       page: response.currentPage,
///       pageSize: response.perPage,
///       totalItems: response.total,
///       totalPages: response.lastPage,
///       hasNextPage: response.currentPage < response.lastPage,
///       hasPreviousPage: response.currentPage > 1,
///     );
///   }
/// }
/// ```
abstract class SearchResultAdapter<T> {
  /// Converts an API response to a [SearchResult].
  SearchResult<Product> fromResponse(T response);

  /// Converts a [SearchResult] back to an API response format.
  T toResponse(SearchResult<Product> result) {
    throw UnimplementedError('toResponse not implemented');
  }

  /// Safely converts an API response, returning null on error.
  SearchResult<Product>? tryFromResponse(T response) {
    try {
      return fromResponse(response);
    } catch (_) {
      return null;
    }
  }
}

/// Abstract adapter for converting API responses to [SearchSuggestion] models.
abstract class SearchSuggestionAdapter<T> {
  /// Converts an API response to a [SearchSuggestion].
  SearchSuggestion fromResponse(T response);

  /// Converts a list of API responses to a list of [SearchSuggestion]s.
  List<SearchSuggestion> fromResponseList(List<T> responses) {
    return responses.map(fromResponse).toList();
  }
}

/// Abstract adapter for converting API responses to [AvailableFilters] models.
abstract class AvailableFiltersAdapter<T> {
  /// Converts an API response to [AvailableFilters].
  AvailableFilters fromResponse(T response);
}

/// Adapter for Map (JSON) to [SearchResult].
///
/// ## Default JSON Structure
///
/// ```json
/// {
///   "items": [...],
///   "page": 1,
///   "page_size": 20,
///   "total_items": 100,
///   "total_pages": 5,
///   "has_next_page": true,
///   "has_previous_page": false,
///   "suggestions": ["burger", "cheese burger"],
///   "related_searches": ["fries", "drinks"],
///   "search_time_ms": 45,
///   "available_filters": {...}
/// }
/// ```
class JsonSearchResultAdapter
    extends SearchResultAdapter<Map<String, dynamic>> {
  /// Field mappings for custom JSON structures.
  final SearchResultFieldMapping? fieldMapping;

  /// Optional transformer to preprocess JSON before conversion.
  final Map<String, dynamic> Function(Map<String, dynamic>)? transformer;

  /// Product converter function.
  final Product Function(Map<String, dynamic>)? productFromJson;

  JsonSearchResultAdapter({
    this.fieldMapping,
    this.transformer,
    this.productFromJson,
  });

  @override
  SearchResult<Product> fromResponse(Map<String, dynamic> response) {
    final json = transformer != null ? transformer!(response) : response;
    final mapping = fieldMapping ?? SearchResultFieldMapping.defaults;

    final items = _parseProducts(json[mapping.items]);
    final page = _parseInt(json[mapping.page]) ?? 1;
    final pageSize = _parseInt(json[mapping.pageSize]) ?? 20;
    final totalItems = _parseInt(json[mapping.totalItems]) ?? items.length;
    final totalPages =
        _parseInt(json[mapping.totalPages]) ?? (totalItems / pageSize).ceil();

    return SearchResult<Product>(
      items: items,
      page: page,
      pageSize: pageSize,
      totalItems: totalItems,
      totalPages: totalPages,
      hasNextPage: json[mapping.hasNextPage] == true || page < totalPages,
      hasPreviousPage: json[mapping.hasPreviousPage] == true || page > 1,
      filter: _parseFilter(json[mapping.filter]),
      availableFilters: _parseAvailableFilters(json[mapping.availableFilters]),
      suggestions: _parseStringList(json[mapping.suggestions]),
      relatedSearches: _parseStringList(json[mapping.relatedSearches]),
      searchTimeMs: _parseInt(json[mapping.searchTimeMs]),
    );
  }

  @override
  Map<String, dynamic> toResponse(SearchResult<Product> result) {
    final mapping = fieldMapping ?? SearchResultFieldMapping.defaults;

    return {
      mapping.items: result.items.map((p) => p.toJson()).toList(),
      mapping.page: result.page,
      mapping.pageSize: result.pageSize,
      mapping.totalItems: result.totalItems,
      mapping.totalPages: result.totalPages,
      mapping.hasNextPage: result.hasNextPage,
      mapping.hasPreviousPage: result.hasPreviousPage,
      mapping.suggestions: result.suggestions,
      mapping.relatedSearches: result.relatedSearches,
      if (result.searchTimeMs != null)
        mapping.searchTimeMs: result.searchTimeMs,
    };
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  List<Product> _parseProducts(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];

    final converter = productFromJson ?? Product.fromJson;
    return value
        .whereType<Map<String, dynamic>>()
        .map((json) {
          try {
            return converter(json);
          } catch (_) {
            return null;
          }
        })
        .whereType<Product>()
        .toList();
  }

  ProductFilter? _parseFilter(dynamic value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic>) return null;
    try {
      final minPriceVal = _parseDouble(value['min_price']);
      final maxPriceVal = _parseDouble(value['max_price']);

      return ProductFilter(
        query: value['query']?.toString(),
        categoryIds: _parseStringList(value['category_ids']),
        brandIds: _parseStringList(value['brand_ids']),
        minPrice: minPriceVal != null ? Money(minPriceVal) : null,
        maxPrice: maxPriceVal != null ? Money(maxPriceVal) : null,
        inStockOnly: value['in_stock'] == true,
        onSaleOnly: value['on_sale'] == true,
        minRating: _parseDouble(value['min_rating']),
      );
    } catch (_) {
      return null;
    }
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  AvailableFilters? _parseAvailableFilters(dynamic value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic>) return null;
    try {
      return JsonAvailableFiltersAdapter().fromResponse(value);
    } catch (_) {
      return null;
    }
  }
}

/// Adapter for Map (JSON) to [SearchSuggestion].
///
/// ## Default JSON Structure
///
/// ```json
/// {
///   "text": "cheese burger",
///   "type": "query",
///   "image_url": "https://example.com/img.jpg",
///   "count": 15,
///   "metadata": {...}
/// }
/// ```
class JsonSearchSuggestionAdapter
    extends SearchSuggestionAdapter<Map<String, dynamic>> {
  /// Field mappings for custom JSON structures.
  final SearchSuggestionFieldMapping? fieldMapping;

  /// Optional transformer to preprocess JSON before conversion.
  final Map<String, dynamic> Function(Map<String, dynamic>)? transformer;

  JsonSearchSuggestionAdapter({this.fieldMapping, this.transformer});

  @override
  SearchSuggestion fromResponse(Map<String, dynamic> response) {
    final json = transformer != null ? transformer!(response) : response;
    final mapping = fieldMapping ?? SearchSuggestionFieldMapping.defaults;

    return SearchSuggestion(
      text: json[mapping.text]?.toString() ?? '',
      type: _parseType(json[mapping.type]),
      imageUrl: json[mapping.imageUrl]?.toString(),
      count: _parseInt(json[mapping.count]),
      metadata: json[mapping.metadata] as Map<String, dynamic>?,
    );
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  SuggestionType _parseType(dynamic value) {
    if (value == null) return SuggestionType.query;
    final str = value.toString().toLowerCase();
    return SuggestionType.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => SuggestionType.query,
    );
  }
}

/// Adapter for Map (JSON) to [AvailableFilters].
///
/// ## Default JSON Structure
///
/// ```json
/// {
///   "categories": [
///     {"id": "cat1", "name": "Burgers", "count": 25}
///   ],
///   "brands": [
///     {"id": "brand1", "name": "Premium", "count": 10}
///   ],
///   "price_range": {
///     "min": 5.00,
///     "max": 50.00
///   },
///   "attributes": {
///     "size": [
///       {"value": "small", "label": "Small", "count": 15}
///     ]
///   },
///   "rating_options": [4, 3, 2, 1]
/// }
/// ```
class JsonAvailableFiltersAdapter
    extends AvailableFiltersAdapter<Map<String, dynamic>> {
  /// Field mappings for custom JSON structures.
  final AvailableFiltersFieldMapping? fieldMapping;

  /// Optional transformer to preprocess JSON before conversion.
  final Map<String, dynamic> Function(Map<String, dynamic>)? transformer;

  JsonAvailableFiltersAdapter({this.fieldMapping, this.transformer});

  @override
  AvailableFilters fromResponse(Map<String, dynamic> response) {
    final json = transformer != null ? transformer!(response) : response;
    final mapping = fieldMapping ?? AvailableFiltersFieldMapping.defaults;

    return AvailableFilters(
      categories: _parseFilterOptions(json[mapping.categories]),
      brands: _parseFilterOptions(json[mapping.brands]),
      priceRange: _parsePriceRange(json[mapping.priceRange]),
      attributes: _parseAttributes(json[mapping.attributes]),
    );
  }

  List<FilterOption> _parseFilterOptions(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];

    return value.whereType<Map<String, dynamic>>().map((json) {
      return FilterOption(
        id: json['id']?.toString() ?? '',
        label: json['name']?.toString() ?? json['label']?.toString() ?? '',
        count: _parseInt(json['count']) ?? 0,
      );
    }).toList();
  }

  FilterPriceRange? _parsePriceRange(dynamic value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic>) return null;

    final currency = value['currency']?.toString() ?? 'USD';
    return FilterPriceRange(
      min: Money(_parseDouble(value['min']) ?? 0, currency: currency),
      max: Money(_parseDouble(value['max']) ?? 0, currency: currency),
    );
  }

  Map<String, List<FilterOption>> _parseAttributes(dynamic value) {
    if (value == null) return {};
    if (value is! Map<String, dynamic>) return {};

    final result = <String, List<FilterOption>>{};
    for (final entry in value.entries) {
      if (entry.value is List) {
        result[entry.key] = _parseFilterOptions(entry.value);
      }
    }
    return result;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// Field mapping for [SearchResult] JSON conversion.
class SearchResultFieldMapping {
  final String items;
  final String page;
  final String pageSize;
  final String totalItems;
  final String totalPages;
  final String hasNextPage;
  final String hasPreviousPage;
  final String filter;
  final String availableFilters;
  final String suggestions;
  final String relatedSearches;
  final String searchTimeMs;

  const SearchResultFieldMapping({
    this.items = 'items',
    this.page = 'page',
    this.pageSize = 'page_size',
    this.totalItems = 'total_items',
    this.totalPages = 'total_pages',
    this.hasNextPage = 'has_next_page',
    this.hasPreviousPage = 'has_previous_page',
    this.filter = 'filter',
    this.availableFilters = 'available_filters',
    this.suggestions = 'suggestions',
    this.relatedSearches = 'related_searches',
    this.searchTimeMs = 'search_time_ms',
  });

  /// Default field mapping using snake_case.
  static const defaults = SearchResultFieldMapping();

  /// CamelCase field mapping.
  static const camelCase = SearchResultFieldMapping(
    pageSize: 'pageSize',
    totalItems: 'totalItems',
    totalPages: 'totalPages',
    hasNextPage: 'hasNextPage',
    hasPreviousPage: 'hasPreviousPage',
    availableFilters: 'availableFilters',
    relatedSearches: 'relatedSearches',
    searchTimeMs: 'searchTimeMs',
  );

  /// Laravel pagination style mapping.
  static const laravel = SearchResultFieldMapping(
    items: 'data',
    page: 'current_page',
    pageSize: 'per_page',
    totalItems: 'total',
    totalPages: 'last_page',
    hasNextPage: 'has_more_pages',
  );
}

/// Field mapping for [SearchSuggestion] JSON conversion.
class SearchSuggestionFieldMapping {
  final String text;
  final String type;
  final String imageUrl;
  final String count;
  final String metadata;

  const SearchSuggestionFieldMapping({
    this.text = 'text',
    this.type = 'type',
    this.imageUrl = 'image_url',
    this.count = 'count',
    this.metadata = 'metadata',
  });

  /// Default field mapping using snake_case.
  static const defaults = SearchSuggestionFieldMapping();

  /// CamelCase field mapping.
  static const camelCase = SearchSuggestionFieldMapping(
    imageUrl: 'imageUrl',
  );
}

/// Field mapping for [AvailableFilters] JSON conversion.
class AvailableFiltersFieldMapping {
  final String categories;
  final String brands;
  final String priceRange;
  final String attributes;

  const AvailableFiltersFieldMapping({
    this.categories = 'categories',
    this.brands = 'brands',
    this.priceRange = 'price_range',
    this.attributes = 'attributes',
  });

  /// Default field mapping using snake_case.
  static const defaults = AvailableFiltersFieldMapping();

  /// CamelCase field mapping.
  static const camelCase = AvailableFiltersFieldMapping(
    priceRange: 'priceRange',
  );
}
