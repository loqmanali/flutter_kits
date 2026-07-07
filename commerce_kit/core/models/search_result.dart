import 'package:equatable/equatable.dart';

import 'product_filter.dart';

/// Represents a paginated search/filter result.
class SearchResult<T> extends Equatable {
  /// The items in this page.
  final List<T> items;

  /// Current page number (1-indexed).
  final int page;

  /// Number of items per page.
  final int pageSize;

  /// Total number of items across all pages.
  final int totalItems;

  /// Total number of pages.
  final int totalPages;

  /// Whether there's a next page.
  final bool hasNextPage;

  /// Whether there's a previous page.
  final bool hasPreviousPage;

  /// The filter/query that produced these results.
  final ProductFilter? filter;

  /// Facets/available filters for refinement.
  final AvailableFilters? availableFilters;

  /// Search suggestions (for autocomplete).
  final List<String> suggestions;

  /// Related search terms.
  final List<String> relatedSearches;

  /// Time taken for the search (in milliseconds).
  final int? searchTimeMs;

  /// Creates a [SearchResult].
  const SearchResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
    this.filter,
    this.availableFilters,
    this.suggestions = const [],
    this.relatedSearches = const [],
    this.searchTimeMs,
  });

  /// Creates an empty search result.
  const SearchResult.empty()
      : items = const [],
        page = 1,
        pageSize = 0,
        totalItems = 0,
        totalPages = 0,
        hasNextPage = false,
        hasPreviousPage = false,
        filter = null,
        availableFilters = null,
        suggestions = const [],
        relatedSearches = const [],
        searchTimeMs = null;

  /// Creates a search result from a single page of items.
  factory SearchResult.fromItems(
    List<T> items, {
    int page = 1,
    int pageSize = 20,
    int? totalItems,
    ProductFilter? filter,
  }) {
    final total = totalItems ?? items.length;
    final totalPages = (total / pageSize).ceil();

    return SearchResult(
      items: items,
      page: page,
      pageSize: pageSize,
      totalItems: total,
      totalPages: totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
      filter: filter,
    );
  }

  /// Whether the result is empty.
  bool get isEmpty => items.isEmpty;

  /// Whether the result has items.
  bool get isNotEmpty => items.isNotEmpty;

  /// Number of items in this page.
  int get itemCount => items.length;

  /// Whether this is the first page.
  bool get isFirstPage => page == 1;

  /// Whether this is the last page.
  bool get isLastPage => page >= totalPages;

  /// Start index of items in this page (0-indexed).
  int get startIndex => (page - 1) * pageSize;

  /// End index of items in this page (0-indexed).
  int get endIndex => startIndex + items.length - 1;

  /// Range text (e.g., "1-20 of 100").
  String get rangeText {
    if (isEmpty) return '0 results';
    final start = startIndex + 1;
    final end = startIndex + items.length;
    return '$start-$end of $totalItems';
  }

  /// Creates a copy with updated fields.
  SearchResult<T> copyWith({
    List<T>? items,
    int? page,
    int? pageSize,
    int? totalItems,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
    ProductFilter? filter,
    AvailableFilters? availableFilters,
    List<String>? suggestions,
    List<String>? relatedSearches,
    int? searchTimeMs,
  }) {
    return SearchResult(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
      filter: filter ?? this.filter,
      availableFilters: availableFilters ?? this.availableFilters,
      suggestions: suggestions ?? this.suggestions,
      relatedSearches: relatedSearches ?? this.relatedSearches,
      searchTimeMs: searchTimeMs ?? this.searchTimeMs,
    );
  }

  /// Maps items to a different type.
  SearchResult<R> map<R>(R Function(T item) mapper) {
    return SearchResult(
      items: items.map(mapper).toList(),
      page: page,
      pageSize: pageSize,
      totalItems: totalItems,
      totalPages: totalPages,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
      filter: filter,
      availableFilters: availableFilters,
      suggestions: suggestions,
      relatedSearches: relatedSearches,
      searchTimeMs: searchTimeMs,
    );
  }

  @override
  List<Object?> get props => [
        items,
        page,
        pageSize,
        totalItems,
        totalPages,
        hasNextPage,
        hasPreviousPage,
        filter,
        availableFilters,
        suggestions,
        relatedSearches,
        searchTimeMs,
      ];
}

/// Represents a search suggestion for autocomplete.
class SearchSuggestion extends Equatable {
  /// The suggested text.
  final String text;

  /// Type of suggestion.
  final SuggestionType type;

  /// Optional image URL.
  final String? imageUrl;

  /// Optional count of matching products.
  final int? count;

  /// Optional metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a [SearchSuggestion].
  const SearchSuggestion({
    required this.text,
    this.type = SuggestionType.query,
    this.imageUrl,
    this.count,
    this.metadata,
  });

  @override
  List<Object?> get props => [text, type, imageUrl, count, metadata];
}

/// Types of search suggestions.
enum SuggestionType {
  /// A search query suggestion.
  query,

  /// A product suggestion.
  product,

  /// A category suggestion.
  category,

  /// A brand suggestion.
  brand,

  /// A recent search.
  recent,

  /// A popular search.
  popular,
}

/// Extension methods for [SuggestionType].
extension SuggestionTypeExtension on SuggestionType {
  /// Display label.
  String get label {
    switch (this) {
      case SuggestionType.query:
        return 'Search';
      case SuggestionType.product:
        return 'Product';
      case SuggestionType.category:
        return 'Category';
      case SuggestionType.brand:
        return 'Brand';
      case SuggestionType.recent:
        return 'Recent';
      case SuggestionType.popular:
        return 'Popular';
    }
  }

  /// Icon name suggestion.
  String get iconName {
    switch (this) {
      case SuggestionType.query:
        return 'search';
      case SuggestionType.product:
        return 'shopping_bag';
      case SuggestionType.category:
        return 'category';
      case SuggestionType.brand:
        return 'store';
      case SuggestionType.recent:
        return 'history';
      case SuggestionType.popular:
        return 'trending_up';
    }
  }
}
