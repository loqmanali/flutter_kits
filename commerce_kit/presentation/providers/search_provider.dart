import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/sort_option.dart';
import '../../core/models/money.dart';
import '../../core/models/product.dart';
import '../../core/models/product_filter.dart';
import '../../core/models/search_result.dart';
import '../../core/utils/product_sorter.dart';

/// State for product search.
class SearchState {
  /// Current search query.
  final String query;

  /// Current filter.
  final ProductFilter filter;

  /// Search results.
  final SearchResult<Product>? results;

  /// Whether search is in progress.
  final bool isLoading;

  /// Error message if any.
  final String? error;

  /// Recent searches.
  final List<String> recentSearches;

  /// Search suggestions.
  final List<SearchSuggestion> suggestions;

  const SearchState({
    this.query = '',
    this.filter = const ProductFilter.none(),
    this.results,
    this.isLoading = false,
    this.error,
    this.recentSearches = const [],
    this.suggestions = const [],
  });

  /// Whether there are any results.
  bool get hasResults => results != null && results!.items.isNotEmpty;

  /// Whether the search is empty (no query and no filters).
  bool get isEmpty => query.isEmpty && !filter.hasActiveFilters;

  /// Total result count.
  int get totalCount => results?.totalItems ?? 0;

  SearchState copyWith({
    String? query,
    ProductFilter? filter,
    SearchResult<Product>? results,
    bool? isLoading,
    String? error,
    List<String>? recentSearches,
    List<SearchSuggestion>? suggestions,
    bool clearError = false,
    bool clearResults = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      results: clearResults ? null : (results ?? this.results),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      recentSearches: recentSearches ?? this.recentSearches,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

/// Notifier for search functionality.
class SearchNotifier extends Notifier<SearchState> {
  /// Search callback - implement this to perform actual search.
  Future<SearchResult<Product>> Function(
    String query,
    ProductFilter filter, {
    int page,
    int pageSize,
  })? _searchCallback;

  /// Suggestions callback - implement this to get suggestions.
  Future<List<SearchSuggestion>> Function(String query)? _suggestionsCallback;

  @override
  SearchState build() {
    return const SearchState();
  }

  /// Sets the search callback.
  void setSearchCallback(
    Future<SearchResult<Product>> Function(
      String query,
      ProductFilter filter, {
      int page,
      int pageSize,
    }) callback,
  ) {
    _searchCallback = callback;
  }

  /// Sets the suggestions callback.
  void setSuggestionsCallback(
    Future<List<SearchSuggestion>> Function(String query) callback,
  ) {
    _suggestionsCallback = callback;
  }

  /// Updates the search query.
  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  /// Updates the filter.
  void setFilter(ProductFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Updates the sort option.
  void setSortOption(SortOption sortOption) {
    state = state.copyWith(
      filter: state.filter.copyWith(sortBy: sortOption),
    );
  }

  /// Performs search with current query and filter.
  Future<void> search({int page = 1, int pageSize = 20}) async {
    if (_searchCallback == null) {
      state = state.copyWith(
        error: 'Search callback not configured',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final results = await _searchCallback!(
        state.query,
        state.filter,
        page: page,
        pageSize: pageSize,
      );

      // Add to recent searches if query is not empty
      List<String> recentSearches = state.recentSearches;
      if (state.query.isNotEmpty) {
        recentSearches = [
          state.query,
          ...state.recentSearches.where((s) => s != state.query),
        ].take(10).toList();
      }

      state = state.copyWith(
        results: results,
        isLoading: false,
        recentSearches: recentSearches,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Loads more results (pagination).
  Future<void> loadMore() async {
    if (_searchCallback == null ||
        state.results == null ||
        !state.results!.hasNextPage ||
        state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.results!.page + 1;
      final newResults = await _searchCallback!(
        state.query,
        state.filter,
        page: nextPage,
        pageSize: state.results!.pageSize,
      );

      // Merge results
      final mergedResults = SearchResult<Product>(
        items: [...state.results!.items, ...newResults.items],
        totalItems: newResults.totalItems,
        totalPages: newResults.totalPages,
        page: newResults.page,
        pageSize: newResults.pageSize,
        hasNextPage: newResults.hasNextPage,
        hasPreviousPage: newResults.hasPreviousPage,
        filter: newResults.filter,
        availableFilters: newResults.availableFilters,
      );

      state = state.copyWith(
        results: mergedResults,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Gets suggestions for the current query.
  Future<void> getSuggestions(String query) async {
    if (_suggestionsCallback == null || query.isEmpty) {
      state = state.copyWith(suggestions: []);
      return;
    }

    try {
      final suggestions = await _suggestionsCallback!(query);
      state = state.copyWith(suggestions: suggestions);
    } catch (e) {
      // Silently fail for suggestions
      state = state.copyWith(suggestions: []);
    }
  }

  /// Clears suggestions.
  void clearSuggestions() {
    state = state.copyWith(suggestions: []);
  }

  /// Clears the search.
  void clear() {
    state = state.copyWith(
      query: '',
      filter: const ProductFilter.none(),
      clearResults: true,
      clearError: true,
      suggestions: [],
    );
  }

  /// Clears only the query.
  void clearQuery() {
    state = state.copyWith(query: '', suggestions: []);
  }

  /// Clears only the filter.
  void clearFilter() {
    state = state.copyWith(filter: const ProductFilter.none());
  }

  /// Removes a recent search.
  void removeRecentSearch(String search) {
    state = state.copyWith(
      recentSearches: state.recentSearches.where((s) => s != search).toList(),
    );
  }

  /// Clears all recent searches.
  void clearRecentSearches() {
    state = state.copyWith(recentSearches: []);
  }

  /// Applies a category filter.
  void filterByCategory(String categoryId) {
    state = state.copyWith(
      filter: state.filter.addCategory(categoryId),
    );
  }

  /// Removes a category filter.
  void removeCategoryFilter(String categoryId) {
    state = state.copyWith(
      filter: state.filter.removeCategory(categoryId),
    );
  }

  /// Sets price range filter.
  void setPriceRange(Money? minPrice, Money? maxPrice) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        minPrice: minPrice,
        maxPrice: maxPrice,
        clearMinPrice: minPrice == null,
        clearMaxPrice: maxPrice == null,
      ),
    );
  }

  /// Toggles on-sale filter.
  void toggleOnSale(bool value) {
    state = state.copyWith(
      filter: state.filter.copyWith(onSaleOnly: value),
    );
  }

  /// Toggles in-stock filter.
  void toggleInStock(bool value) {
    state = state.copyWith(
      filter: state.filter.copyWith(inStockOnly: value),
    );
  }

  /// Local sort (without API call).
  void sortResultsLocally(SortOption sortOption) {
    if (state.results == null) return;

    final sortedItems = ProductSorter.sort(
      state.results!.items,
      sortOption,
    );

    state = state.copyWith(
      filter: state.filter.copyWith(sortBy: sortOption),
      results: SearchResult<Product>(
        items: sortedItems,
        totalItems: state.results!.totalItems,
        totalPages: state.results!.totalPages,
        page: state.results!.page,
        pageSize: state.results!.pageSize,
        hasNextPage: state.results!.hasNextPage,
        hasPreviousPage: state.results!.hasPreviousPage,
        filter: state.results!.filter,
        availableFilters: state.results!.availableFilters,
      ),
    );
  }
}

/// Provider for search state.
final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);

/// Provider for current search query.
final searchQueryProvider = Provider<String>((ref) {
  return ref.watch(searchProvider.select((s) => s.query));
});

/// Provider for current filter.
final searchFilterProvider = Provider<ProductFilter>((ref) {
  return ref.watch(searchProvider.select((s) => s.filter));
});

/// Provider for search results.
final searchResultsProvider = Provider<SearchResult<Product>?>((ref) {
  return ref.watch(searchProvider.select((s) => s.results));
});

/// Provider for search loading state.
final searchLoadingProvider = Provider<bool>((ref) {
  return ref.watch(searchProvider.select((s) => s.isLoading));
});

/// Provider for search error.
final searchErrorProvider = Provider<String?>((ref) {
  return ref.watch(searchProvider.select((s) => s.error));
});

/// Provider for recent searches.
final recentSearchesProvider = Provider<List<String>>((ref) {
  return ref.watch(searchProvider.select((s) => s.recentSearches));
});

/// Provider for search suggestions.
final searchSuggestionsProvider = Provider<List<SearchSuggestion>>((ref) {
  return ref.watch(searchProvider.select((s) => s.suggestions));
});

/// Provider for active filter count.
final activeFilterCountProvider = Provider<int>((ref) {
  return ref.watch(searchProvider.select((s) => s.filter.activeFilterCount));
});

/// Provider for has active filters.
final hasActiveFiltersProvider = Provider<bool>((ref) {
  return ref.watch(searchProvider.select((s) => s.filter.hasActiveFilters));
});
