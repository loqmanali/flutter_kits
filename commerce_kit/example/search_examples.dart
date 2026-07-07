// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../commerce_kit.dart';

/// Examples demonstrating the Search & Filtering functionality.
///
/// This file shows how to:
/// - Search for products
/// - Apply filters (price, category, rating, etc.)
/// - Handle pagination
/// - Use search suggestions
/// - Parse search results from API
class SearchExamples {
  /// Run all search examples.
  static void runAll() {
    print('\n════════════════════════════════════════════════════════════════');
    print('SEARCH & FILTERING EXAMPLES');
    print('════════════════════════════════════════════════════════════════\n');

    _filterExamples();
    _searchResultExamples();
    _adapterExamples();
  }

  /// Examples of using ProductFilter.
  static void _filterExamples() {
    print('▶ ProductFilter Examples');
    print('─' * 60);

    // Create a basic search filter
    final searchFilter = ProductFilter.search('burger');
    print('  Search query: ${searchFilter.query}');
    print('  Has active filters: ${searchFilter.hasActiveFilters}');

    // Create a category filter
    final categoryFilter = ProductFilter.byCategory('cat_burgers');
    print('\n  Category filter: ${categoryFilter.categoryIds}');

    // Create a sale filter
    final saleFilter = ProductFilter.onSale();
    print('  Sale filter - onSaleOnly: ${saleFilter.onSaleOnly}');
    print('  Sale filter - sortBy: ${saleFilter.sortBy}');

    // Create a complex filter
    const complexFilter = ProductFilter(
      query: 'cheese',
      categoryIds: ['cat_burgers', 'cat_sandwiches'],
      minPrice: Money(10),
      maxPrice: Money(30),
      onSaleOnly: true,
      inStockOnly: true,
      minRating: 4.0,
      sortBy: SortOption.priceLowToHigh,
    );

    print('\n  Complex filter:');
    print('  Query: ${complexFilter.query}');
    print('  Categories: ${complexFilter.categoryIds.length}');
    print(
      '  Price range: ${complexFilter.minPrice?.formatted} - ${complexFilter.maxPrice?.formatted}',
    );
    print('  On sale only: ${complexFilter.onSaleOnly}');
    print('  In stock only: ${complexFilter.inStockOnly}');
    print('  Min rating: ${complexFilter.minRating}');
    print('  Active filter count: ${complexFilter.activeFilterCount}');

    // Modify filter
    final updatedFilter = complexFilter.copyWith(
      sortBy: SortOption.rating,
      minRating: 4.5,
    );
    print('\n  Updated filter:');
    print('  Sort by: ${updatedFilter.sortBy}');
    print('  Min rating: ${updatedFilter.minRating}');

    // Add/remove categories
    final withCategory = complexFilter.addCategory('cat_premium');
    print(
      '\n  After adding category: ${withCategory.categoryIds.length} categories',
    );

    final withoutCategory = withCategory.removeCategory('cat_burgers');
    print(
      '  After removing category: ${withoutCategory.categoryIds.length} categories',
    );

    // Clear filters
    final cleared = complexFilter.clear();
    print('\n  After clear: hasActiveFilters = ${cleared.hasActiveFilters}');

    // Convert to query params for API
    final queryParams = complexFilter.toQueryParams();
    print('\n  Query params for API:');
    queryParams.forEach((key, value) {
      print('    $key: $value');
    });
  }

  /// Examples of SearchResult model.
  static void _searchResultExamples() {
    print('\n▶ SearchResult Examples');
    print('─' * 60);

    // Create sample products
    final products = [
      const Product(
        id: 'burger_1',
        name: 'Classic Burger',
        price: Money(15.99),
      ),
      const Product(
        id: 'burger_2',
        name: 'Cheese Burger',
        price: Money(17.99),
      ),
      const Product(
        id: 'burger_3',
        name: 'Double Burger',
        price: Money(22.99),
      ),
    ];

    // Create a search result
    final result = SearchResult.fromItems(
      products,
      totalItems: 45,
    );

    print('  Search result:');
    print('  Items in page: ${result.itemCount}');
    print('  Page: ${result.page} of ${result.totalPages}');
    print('  Total items: ${result.totalItems}');
    print('  Has next page: ${result.hasNextPage}');
    print('  Has previous page: ${result.hasPreviousPage}');
    print('  Range: ${result.rangeText}');
    print('  Is first page: ${result.isFirstPage}');
    print('  Is last page: ${result.isLastPage}');

    // Empty result
    const emptyResult = SearchResult<Product>.empty();
    print('\n  Empty result:');
    print('  Is empty: ${emptyResult.isEmpty}');
    print('  Range: ${emptyResult.rangeText}');

    // Create search suggestion
    const suggestion = SearchSuggestion(
      text: 'cheese burger',
      count: 15,
    );

    print('\n  Search suggestion:');
    print('  Text: ${suggestion.text}');
    print('  Type: ${suggestion.type.label}');
    print('  Icon: ${suggestion.type.iconName}');
    print('  Count: ${suggestion.count}');
  }

  /// Examples of using Search adapters.
  static void _adapterExamples() {
    print('\n▶ Adapter Examples');
    print('─' * 60);

    // Example API response
    final apiResponse = {
      'items': [
        {
          'id': 'burger_1',
          'name': 'Classic Burger',
          'description': 'Our signature burger',
          'price': {'amount': 15.99, 'currency': 'EGP'},
        },
        {
          'id': 'burger_2',
          'name': 'Cheese Burger',
          'description': 'With melted cheese',
          'price': {'amount': 17.99, 'currency': 'EGP'},
        },
      ],
      'page': 1,
      'page_size': 20,
      'total_items': 45,
      'total_pages': 3,
      'has_next_page': true,
      'has_previous_page': false,
      'suggestions': ['classic burger', 'cheese burger special'],
      'related_searches': ['fries', 'drinks', 'combo meals'],
      'search_time_ms': 42,
      'available_filters': {
        'categories': [
          {'id': 'cat_burgers', 'name': 'Burgers', 'count': 25},
          {'id': 'cat_sandwiches', 'name': 'Sandwiches', 'count': 15},
        ],
        'brands': [
          {'id': 'brand_premium', 'name': 'Premium', 'count': 10},
        ],
        'price_range': {
          'min': 10.0,
          'max': 50.0,
          'currency': 'EGP',
        },
      },
    };

    // Parse using adapter
    final adapter = JsonSearchResultAdapter();
    final result = adapter.fromResponse(apiResponse);

    print('  Parsed search result:');
    print('  Items: ${result.itemCount}');
    print('  Page: ${result.page}/${result.totalPages}');
    print('  Total: ${result.totalItems}');
    print('  Search time: ${result.searchTimeMs}ms');
    print('  Suggestions: ${result.suggestions.join(', ')}');
    print('  Related: ${result.relatedSearches.join(', ')}');

    if (result.availableFilters != null) {
      print('\n  Available filters:');
      print('  Categories: ${result.availableFilters!.categories.length}');
      print('  Brands: ${result.availableFilters!.brands.length}');
      if (result.availableFilters!.priceRange != null) {
        print(
          '  Price range: ${result.availableFilters!.priceRange!.min.formatted} - ${result.availableFilters!.priceRange!.max.formatted}',
        );
      }
    }

    // Laravel-style pagination
    final laravelResponse = {
      'data': [
        {
          'id': 'burger_1',
          'name': 'Classic Burger',
          'price': {'amount': 15.99},
        },
      ],
      'current_page': 2,
      'per_page': 10,
      'total': 100,
      'last_page': 10,
      'has_more_pages': true,
    };

    final laravelAdapter = JsonSearchResultAdapter(
      fieldMapping: SearchResultFieldMapping.laravel,
    );
    final laravelResult = laravelAdapter.fromResponse(laravelResponse);

    print('\n  Laravel-style result:');
    print('  Page: ${laravelResult.page}/${laravelResult.totalPages}');
    print('  Total: ${laravelResult.totalItems}');
    print('  Has more: ${laravelResult.hasNextPage}');

    // Search suggestions adapter
    final suggestionResponse = {
      'text': 'double cheese burger',
      'type': 'product',
      'image_url': 'https://example.com/burger.jpg',
      'count': 5,
    };

    final suggestionAdapter = JsonSearchSuggestionAdapter();
    final suggestion = suggestionAdapter.fromResponse(suggestionResponse);

    print('\n  Parsed suggestion:');
    print('  Text: ${suggestion.text}');
    print('  Type: ${suggestion.type}');
    print('  Has image: ${suggestion.imageUrl != null}');
  }
}

/// Example of using SearchProvider in a widget.
///
/// ```dart
/// class SearchScreen extends ConsumerStatefulWidget {
///   @override
///   ConsumerState<SearchScreen> createState() => _SearchScreenState();
/// }
///
/// class _SearchScreenState extends ConsumerState<SearchScreen> {
///   final _controller = TextEditingController();
///
///   @override
///   Widget build(BuildContext context) {
///     final searchState = ref.watch(searchProvider);
///
///     return Scaffold(
///       appBar: AppBar(
///         title: TextField(
///           controller: _controller,
///           decoration: InputDecoration(
///             hintText: 'Search products...',
///           ),
///           onSubmitted: (query) {
///             ref.read(searchProvider.notifier).search(query);
///           },
///         ),
///       ),
///       body: Column(
///         children: [
///           // Filter chips
///           if (searchState.availableFilters != null)
///             FilterChipBar(
///               filters: searchState.availableFilters!,
///               onFilterSelected: (filter) {
///                 ref.read(searchProvider.notifier).applyFilter(filter);
///               },
///             ),
///
///           // Results
///           Expanded(
///             child: searchState.isLoading
///                 ? const CircularProgressIndicator()
///                 : ListView.builder(
///                     itemCount: searchState.results.length,
///                     itemBuilder: (ctx, i) => ProductCard(
///                       product: searchState.results[i],
///                     ),
///                   ),
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
void searchProviderUsageExample(WidgetRef ref) {
  // Get the search notifier
  final notifier = ref.read(searchProvider.notifier);

  // Set search query
  notifier.setQuery('burger');

  // Perform a search (uses current query and filter)
  notifier.search();

  // Set a filter
  notifier.setFilter(
    const ProductFilter(
      categoryIds: ['cat_burgers'],
      minPrice: Money(10),
      maxPrice: Money(30),
      sortBy: SortOption.priceLowToHigh,
    ),
  );

  // Filter by category
  notifier.filterByCategory('cat_burgers');
  notifier.removeCategoryFilter('cat_sandwiches');

  // Set price range
  notifier.setPriceRange(const Money(10), const Money(50));

  // Toggle filters
  notifier.toggleOnSale(true);
  notifier.toggleInStock(true);

  // Set sort option
  notifier.setSortOption(SortOption.priceLowToHigh);

  // Sort results locally (without API call)
  notifier.sortResultsLocally(SortOption.rating);

  // Clear filter
  notifier.clearFilter();

  // Load more results (pagination)
  notifier.loadMore();

  // Get suggestions
  notifier.getSuggestions('burg');

  // Clear suggestions
  notifier.clearSuggestions();

  // Clear recent searches
  notifier.clearRecentSearches();

  // Remove specific recent search
  notifier.removeRecentSearch('old search');

  // Clear all search state
  notifier.clear();

  // Clear only query
  notifier.clearQuery();

  // Watch search results
  final results = ref.watch(searchResultsProvider);
  print('Found ${results?.totalItems ?? 0} products');

  // Watch current query
  final query = ref.watch(searchQueryProvider);
  print('Current query: $query');

  // Watch current filter
  final filter = ref.watch(searchFilterProvider);
  print('Active filters: ${filter.activeFilterCount}');

  // Watch recent searches
  final recent = ref.watch(recentSearchesProvider);
  print('Recent searches: ${recent.length}');

  // Watch suggestions
  final suggestions = ref.watch(searchSuggestionsProvider);
  print('Suggestions: ${suggestions.length}');

  // Watch loading state
  final isLoading = ref.watch(searchLoadingProvider);
  print('Is loading: $isLoading');

  // Watch active filter count
  final filterCount = ref.watch(activeFilterCountProvider);
  print('Active filter count: $filterCount');
}
