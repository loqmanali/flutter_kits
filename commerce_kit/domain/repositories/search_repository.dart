import '../../core/models/product.dart';
import '../../core/models/product_filter.dart';
import '../../core/models/search_result.dart';

/// Abstract repository interface for search operations.
///
/// Implement this interface to provide product search functionality
/// with your preferred data source (API, local database, Elasticsearch, etc.).
///
/// ## Usage
///
/// ```dart
/// class ApiSearchRepository implements SearchRepository {
///   final ApiClient _client;
///
///   ApiSearchRepository(this._client);
///
///   @override
///   Future<SearchResult<Product>> search(
///     String query, {
///     ProductFilter? filter,
///     int page = 1,
///     int pageSize = 20,
///   }) async {
///     final response = await _client.get('/products/search', {
///       'q': query,
///       'page': page,
///       'per_page': pageSize,
///       ...?filter?.toQueryParams(),
///     });
///     return SearchResult.fromJson(response.data);
///   }
///
///   // ... implement other methods
/// }
/// ```
abstract class SearchRepository {
  /// Searches for products.
  ///
  /// [query] - The search query string.
  /// [filter] - Optional filter to apply.
  /// [page] - Page number (1-indexed).
  /// [pageSize] - Number of results per page.
  ///
  /// Returns paginated search results.
  Future<SearchResult<Product>> search(
    String query, {
    ProductFilter? filter,
    int page = 1,
    int pageSize = 20,
  });

  /// Gets products by filter without a search query.
  ///
  /// [filter] - Filter to apply.
  /// [page] - Page number (1-indexed).
  /// [pageSize] - Number of results per page.
  ///
  /// Returns paginated product results.
  Future<SearchResult<Product>> getProducts({
    ProductFilter? filter,
    int page = 1,
    int pageSize = 20,
  });

  /// Gets search suggestions/autocomplete.
  ///
  /// [query] - Partial search query.
  /// [limit] - Maximum number of suggestions.
  ///
  /// Returns a list of search suggestions.
  Future<List<SearchSuggestion>> getSuggestions(
    String query, {
    int limit = 10,
  });

  /// Gets available filters for current search/category.
  ///
  /// [query] - Optional search query.
  /// [categoryId] - Optional category ID.
  ///
  /// Returns available filter options.
  Future<AvailableFilters> getAvailableFilters({
    String? query,
    String? categoryId,
  });

  /// Gets products by category.
  ///
  /// [categoryId] - The category ID.
  /// [filter] - Optional additional filter.
  /// [page] - Page number (1-indexed).
  /// [pageSize] - Number of results per page.
  ///
  /// Returns paginated product results.
  Future<SearchResult<Product>> getProductsByCategory(
    String categoryId, {
    ProductFilter? filter,
    int page = 1,
    int pageSize = 20,
  });

  /// Gets products by brand.
  ///
  /// [brandId] - The brand ID.
  /// [filter] - Optional additional filter.
  /// [page] - Page number (1-indexed).
  /// [pageSize] - Number of results per page.
  ///
  /// Returns paginated product results.
  Future<SearchResult<Product>> getProductsByBrand(
    String brandId, {
    ProductFilter? filter,
    int page = 1,
    int pageSize = 20,
  });

  /// Gets related products.
  ///
  /// [productId] - The product to find related products for.
  /// [limit] - Maximum number of related products.
  ///
  /// Returns a list of related products.
  Future<List<Product>> getRelatedProducts(
    String productId, {
    int limit = 10,
  });

  /// Gets recently viewed products.
  ///
  /// [limit] - Maximum number of products to return.
  ///
  /// Returns a list of recently viewed products.
  Future<List<Product>> getRecentlyViewed({int limit = 10});

  /// Adds a product to recently viewed.
  ///
  /// [productId] - The product ID that was viewed.
  Future<void> addToRecentlyViewed(String productId);

  /// Clears recently viewed products.
  Future<void> clearRecentlyViewed();

  /// Gets trending/popular searches.
  ///
  /// [limit] - Maximum number of searches to return.
  ///
  /// Returns a list of popular search terms.
  Future<List<String>> getTrendingSearches({int limit = 10});

  /// Saves a search to history.
  ///
  /// [query] - The search query to save.
  Future<void> saveSearchHistory(String query);

  /// Gets search history.
  ///
  /// [limit] - Maximum number of searches to return.
  ///
  /// Returns a list of recent search queries.
  Future<List<String>> getSearchHistory({int limit = 10});

  /// Removes a search from history.
  ///
  /// [query] - The search query to remove.
  Future<void> removeFromHistory(String query);

  /// Clears all search history.
  Future<void> clearSearchHistory();
}
