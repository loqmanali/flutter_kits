import '../../core/models/product.dart';
import '../../core/models/product_filter.dart';
import '../../core/models/search_result.dart';
import '../repositories/search_repository.dart';

/// Use case for searching products.
class SearchProductsUseCase {
  final SearchRepository _repository;

  SearchProductsUseCase(this._repository);

  /// Searches for products by query.
  Future<SearchResult<Product>> call(
    String query, {
    ProductFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    return _repository.search(
      query,
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// Use case for getting products with filters (no search query).
class GetProductsUseCase {
  final SearchRepository _repository;

  GetProductsUseCase(this._repository);

  /// Gets products with optional filters.
  Future<SearchResult<Product>> call({
    ProductFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    return _repository.getProducts(
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// Use case for getting search suggestions.
class GetSuggestionsUseCase {
  final SearchRepository _repository;

  GetSuggestionsUseCase(this._repository);

  /// Gets search suggestions for a partial query.
  Future<List<SearchSuggestion>> call(String query, {int limit = 10}) async {
    if (query.isEmpty) {
      return [];
    }
    return _repository.getSuggestions(query, limit: limit);
  }
}

/// Use case for getting available filters.
class GetAvailableFiltersUseCase {
  final SearchRepository _repository;

  GetAvailableFiltersUseCase(this._repository);

  /// Gets available filter options.
  Future<AvailableFilters> call({String? query, String? categoryId}) async {
    return _repository.getAvailableFilters(
      query: query,
      categoryId: categoryId,
    );
  }
}

/// Use case for getting products by category.
class GetProductsByCategoryUseCase {
  final SearchRepository _repository;

  GetProductsByCategoryUseCase(this._repository);

  /// Gets products in a category.
  Future<SearchResult<Product>> call(
    String categoryId, {
    ProductFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    return _repository.getProductsByCategory(
      categoryId,
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// Use case for getting products by brand.
class GetProductsByBrandUseCase {
  final SearchRepository _repository;

  GetProductsByBrandUseCase(this._repository);

  /// Gets products by brand.
  Future<SearchResult<Product>> call(
    String brandId, {
    ProductFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    return _repository.getProductsByBrand(
      brandId,
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// Use case for getting related products.
class GetRelatedProductsUseCase {
  final SearchRepository _repository;

  GetRelatedProductsUseCase(this._repository);

  /// Gets products related to a specific product.
  Future<List<Product>> call(String productId, {int limit = 10}) async {
    return _repository.getRelatedProducts(productId, limit: limit);
  }
}

/// Use case for getting recently viewed products.
class GetRecentlyViewedUseCase {
  final SearchRepository _repository;

  GetRecentlyViewedUseCase(this._repository);

  /// Gets recently viewed products.
  Future<List<Product>> call({int limit = 10}) async {
    return _repository.getRecentlyViewed(limit: limit);
  }
}

/// Use case for tracking product views.
class TrackProductViewUseCase {
  final SearchRepository _repository;

  TrackProductViewUseCase(this._repository);

  /// Adds a product to recently viewed.
  Future<void> call(String productId) async {
    return _repository.addToRecentlyViewed(productId);
  }
}

/// Use case for getting trending searches.
class GetTrendingSearchesUseCase {
  final SearchRepository _repository;

  GetTrendingSearchesUseCase(this._repository);

  /// Gets trending/popular search terms.
  Future<List<String>> call({int limit = 10}) async {
    return _repository.getTrendingSearches(limit: limit);
  }
}

/// Use case for managing search history.
class SearchHistoryUseCase {
  final SearchRepository _repository;

  SearchHistoryUseCase(this._repository);

  /// Saves a search to history.
  Future<void> save(String query) async {
    if (query.isNotEmpty) {
      return _repository.saveSearchHistory(query);
    }
  }

  /// Gets search history.
  Future<List<String>> get({int limit = 10}) async {
    return _repository.getSearchHistory(limit: limit);
  }

  /// Removes a search from history.
  Future<void> remove(String query) async {
    return _repository.removeFromHistory(query);
  }

  /// Clears all search history.
  Future<void> clear() async {
    return _repository.clearSearchHistory();
  }
}

/// Use case for combined search with history management.
class SearchWithHistoryUseCase {
  final SearchRepository _repository;

  SearchWithHistoryUseCase(this._repository);

  /// Searches and saves to history.
  Future<SearchResult<Product>> call(
    String query, {
    ProductFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    // Save to history
    if (query.isNotEmpty) {
      await _repository.saveSearchHistory(query);
    }

    // Perform search
    return _repository.search(
      query,
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
  }
}
