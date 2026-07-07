import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/review.dart';

/// State for reviews of a product.
class ReviewsState {
  /// Product ID.
  final String productId;

  /// Reviews list.
  final List<Review> reviews;

  /// Rating statistics.
  final RatingStats? stats;

  /// Current filter.
  final ReviewFilter filter;

  /// Whether loading.
  final bool isLoading;

  /// Error message.
  final String? error;

  /// Current page for pagination.
  final int page;

  /// Whether there are more reviews to load.
  final bool hasMore;

  const ReviewsState({
    required this.productId,
    this.reviews = const [],
    this.stats,
    this.filter = const ReviewFilter(),
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
  });

  /// Creates initial state.
  factory ReviewsState.initial(String productId) {
    return ReviewsState(productId: productId);
  }

  /// Filtered and sorted reviews.
  List<Review> get filteredReviews {
    var result = reviews.where((r) => r.status.isVisible).toList();

    // Apply filters
    if (filter.rating != null) {
      result = result.where((r) => r.rating.round() == filter.rating).toList();
    }
    if (filter.verifiedOnly) {
      result = result.where((r) => r.isVerifiedPurchase).toList();
    }
    if (filter.withImagesOnly) {
      result = result.where((r) => r.hasImages).toList();
    }

    // Apply sorting
    switch (filter.sortBy) {
      case ReviewSortOption.mostRecent:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case ReviewSortOption.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case ReviewSortOption.highestRating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
      case ReviewSortOption.lowestRating:
        result.sort((a, b) => a.rating.compareTo(b.rating));
      case ReviewSortOption.mostHelpful:
        result.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
      case ReviewSortOption.withImages:
        result.sort((a, b) {
          if (a.hasImages && !b.hasImages) return -1;
          if (!a.hasImages && b.hasImages) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
      case ReviewSortOption.verifiedFirst:
        result.sort((a, b) {
          if (a.isVerifiedPurchase && !b.isVerifiedPurchase) return -1;
          if (!a.isVerifiedPurchase && b.isVerifiedPurchase) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
    }

    return result;
  }

  ReviewsState copyWith({
    String? productId,
    List<Review>? reviews,
    RatingStats? stats,
    ReviewFilter? filter,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
    bool clearError = false,
    bool clearStats = false,
  }) {
    return ReviewsState(
      productId: productId ?? this.productId,
      reviews: reviews ?? this.reviews,
      stats: clearStats ? null : (stats ?? this.stats),
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Global state for all product reviews.
class AllReviewsState {
  /// Map of product ID to reviews state.
  final Map<String, ReviewsState> productReviews;

  const AllReviewsState({
    this.productReviews = const {},
  });

  /// Gets or creates state for a product.
  ReviewsState getForProduct(String productId) {
    return productReviews[productId] ?? ReviewsState.initial(productId);
  }

  AllReviewsState copyWith({
    Map<String, ReviewsState>? productReviews,
  }) {
    return AllReviewsState(
      productReviews: productReviews ?? this.productReviews,
    );
  }

  AllReviewsState updateProduct(String productId, ReviewsState state) {
    return AllReviewsState(
      productReviews: {...productReviews, productId: state},
    );
  }
}

/// Notifier for all reviews.
class ReviewsNotifier extends Notifier<AllReviewsState> {
  /// Callback to load reviews.
  Future<List<Review>> Function(
    String productId, {
    int page,
    ReviewFilter filter,
  })? _loadReviewsCallback;

  /// Callback to load stats.
  Future<RatingStats> Function(String productId)? _loadStatsCallback;

  /// Callback to submit a review.
  Future<Review> Function(Review review)? _submitReviewCallback;

  /// Callback to vote on a review.
  Future<void> Function(String reviewId, bool helpful)? _voteCallback;

  @override
  AllReviewsState build() {
    return const AllReviewsState();
  }

  /// Sets the load reviews callback.
  void setLoadReviewsCallback(
    Future<List<Review>> Function(
      String productId, {
      int page,
      ReviewFilter filter,
    }) callback,
  ) {
    _loadReviewsCallback = callback;
  }

  /// Sets the load stats callback.
  void setLoadStatsCallback(
    Future<RatingStats> Function(String productId) callback,
  ) {
    _loadStatsCallback = callback;
  }

  /// Sets the submit review callback.
  void setSubmitReviewCallback(
    Future<Review> Function(Review review) callback,
  ) {
    _submitReviewCallback = callback;
  }

  /// Sets the vote callback.
  void setVoteCallback(
    Future<void> Function(String reviewId, bool helpful) callback,
  ) {
    _voteCallback = callback;
  }

  /// Gets state for a product.
  ReviewsState _getProductState(String productId) {
    return state.getForProduct(productId);
  }

  /// Updates state for a product.
  void _updateProductState(String productId, ReviewsState productState) {
    state = state.updateProduct(productId, productState);
  }

  /// Loads reviews for a product.
  Future<void> loadReviews(String productId, {bool refresh = false}) async {
    if (_loadReviewsCallback == null) return;

    var productState = _getProductState(productId);

    if (refresh) {
      productState = productState.copyWith(page: 1, reviews: [], hasMore: true);
      _updateProductState(productId, productState);
    }

    if (!productState.hasMore && !refresh) return;

    productState = productState.copyWith(isLoading: true, clearError: true);
    _updateProductState(productId, productState);

    try {
      final reviews = await _loadReviewsCallback!(
        productId,
        page: productState.page,
        filter: productState.filter,
      );

      productState = _getProductState(productId);
      productState = productState.copyWith(
        reviews: refresh ? reviews : [...productState.reviews, ...reviews],
        isLoading: false,
        page: productState.page + 1,
        hasMore: reviews.isNotEmpty,
      );
      _updateProductState(productId, productState);

      // Update stats if we don't have them yet
      if (_getProductState(productId).stats == null) {
        await loadStats(productId);
      }
    } catch (e) {
      productState = _getProductState(productId);
      _updateProductState(
        productId,
        productState.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  /// Loads rating stats for a product.
  Future<void> loadStats(String productId) async {
    var productState = _getProductState(productId);

    if (_loadStatsCallback == null) {
      // Calculate from local reviews
      final stats = RatingStats.fromReviews(productId, productState.reviews);
      _updateProductState(productId, productState.copyWith(stats: stats));
      return;
    }

    try {
      final stats = await _loadStatsCallback!(productId);
      productState = _getProductState(productId);
      _updateProductState(productId, productState.copyWith(stats: stats));
    } catch (e) {
      // Calculate from local reviews as fallback
      productState = _getProductState(productId);
      final stats = RatingStats.fromReviews(productId, productState.reviews);
      _updateProductState(productId, productState.copyWith(stats: stats));
    }
  }

  /// Sets the filter for a product.
  void setFilter(String productId, ReviewFilter filter) {
    final productState = _getProductState(productId);
    _updateProductState(productId, productState.copyWith(filter: filter));
  }

  /// Sets the sort option for a product.
  void setSortOption(String productId, ReviewSortOption sortOption) {
    final productState = _getProductState(productId);
    _updateProductState(
      productId,
      productState.copyWith(
        filter: productState.filter.copyWith(sortBy: sortOption),
      ),
    );
  }

  /// Filters by rating for a product.
  void filterByRating(String productId, int? rating) {
    final productState = _getProductState(productId);
    _updateProductState(
      productId,
      productState.copyWith(
        filter: productState.filter.copyWith(
          rating: rating,
          clearRating: rating == null,
        ),
      ),
    );
  }

  /// Toggles verified only filter for a product.
  void toggleVerifiedOnly(String productId, bool value) {
    final productState = _getProductState(productId);
    _updateProductState(
      productId,
      productState.copyWith(
        filter: productState.filter.copyWith(verifiedOnly: value),
      ),
    );
  }

  /// Toggles with images only filter for a product.
  void toggleWithImagesOnly(String productId, bool value) {
    final productState = _getProductState(productId);
    _updateProductState(
      productId,
      productState.copyWith(
        filter: productState.filter.copyWith(withImagesOnly: value),
      ),
    );
  }

  /// Clears all filters for a product.
  void clearFilters(String productId) {
    final productState = _getProductState(productId);
    _updateProductState(
      productId,
      productState.copyWith(filter: const ReviewFilter()),
    );
  }

  /// Submits a new review.
  Future<bool> submitReview(Review review) async {
    if (_submitReviewCallback == null) {
      final productState = _getProductState(review.productId);
      _updateProductState(
        review.productId,
        productState.copyWith(error: 'Submit callback not configured'),
      );
      return false;
    }

    var productState = _getProductState(review.productId);
    _updateProductState(
      review.productId,
      productState.copyWith(isLoading: true, clearError: true),
    );

    try {
      final submittedReview = await _submitReviewCallback!(review);
      productState = _getProductState(review.productId);
      _updateProductState(
        review.productId,
        productState.copyWith(
          reviews: [submittedReview, ...productState.reviews],
          isLoading: false,
        ),
      );
      await loadStats(review.productId); // Refresh stats
      return true;
    } catch (e) {
      productState = _getProductState(review.productId);
      _updateProductState(
        review.productId,
        productState.copyWith(isLoading: false, error: e.toString()),
      );
      return false;
    }
  }

  /// Votes on a review.
  Future<void> vote(String productId, String reviewId, bool helpful) async {
    if (_voteCallback != null) {
      try {
        await _voteCallback!(reviewId, helpful);
      } catch (_) {
        // Silently fail for votes
      }
    }

    // Optimistic update
    final productState = _getProductState(productId);
    _updateProductState(
      productId,
      productState.copyWith(
        reviews: productState.reviews.map((r) {
          if (r.id == reviewId) {
            return r.copyWith(
              helpfulCount: helpful ? r.helpfulCount + 1 : r.helpfulCount,
              unhelpfulCount: helpful ? r.unhelpfulCount : r.unhelpfulCount + 1,
            );
          }
          return r;
        }).toList(),
      ),
    );
  }

  /// Clears error for a product.
  void clearError(String productId) {
    final productState = _getProductState(productId);
    _updateProductState(
      productId,
      productState.copyWith(clearError: true),
    );
  }
}

/// Main reviews provider.
final reviewsNotifierProvider =
    NotifierProvider<ReviewsNotifier, AllReviewsState>(ReviewsNotifier.new);

/// Provider for reviews state for a specific product.
final reviewsProvider = Provider.family<ReviewsState, String>((ref, productId) {
  return ref.watch(reviewsNotifierProvider).getForProduct(productId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Selector Providers (for optimized rebuilds)
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for rating stats for a product.
final ratingStatsProvider = Provider.family<RatingStats?, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).stats;
});

/// Provider for filtered reviews for a product.
final filteredReviewsProvider =
    Provider.family<List<Review>, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).filteredReviews;
});

/// Provider for review count for a product.
final reviewCountProvider = Provider.family<int, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).stats?.totalReviews ?? 0;
});

/// Provider for average rating for a product.
final averageRatingProvider = Provider.family<double, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).stats?.averageRating ?? 0;
});

/// Provider for reviews loading state.
final reviewsLoadingProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).isLoading;
});

/// Provider for reviews error.
final reviewsErrorProvider = Provider.family<String?, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).error;
});

/// Provider for current review filter.
final reviewFilterProvider =
    Provider.family<ReviewFilter, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).filter;
});

/// Provider for whether there are more reviews to load.
final hasMoreReviewsProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).hasMore;
});

/// Provider for current page number.
final reviewsPageProvider = Provider.family<int, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).page;
});

/// Provider for all reviews (unfiltered).
final allReviewsProvider =
    Provider.family<List<Review>, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).reviews;
});

/// Provider for reviews with images only.
final reviewsWithImagesProvider =
    Provider.family<List<Review>, String>((ref, productId) {
  final reviews = ref.watch(reviewsProvider(productId)).reviews;
  return reviews.where((r) => r.hasImages && r.status.isVisible).toList();
});

/// Provider for verified purchase reviews only.
final verifiedReviewsProvider =
    Provider.family<List<Review>, String>((ref, productId) {
  final reviews = ref.watch(reviewsProvider(productId)).reviews;
  return reviews.where((r) => r.isVerifiedPurchase && r.status.isVisible).toList();
});

/// Provider for reviews by specific rating.
final reviewsByRatingProvider =
    Provider.family<List<Review>, ({String productId, int rating})>(
        (ref, params) {
  final reviews = ref.watch(reviewsProvider(params.productId)).reviews;
  return reviews
      .where((r) => r.rating.round() == params.rating && r.status.isVisible)
      .toList();
});

/// Provider for rating distribution percentages.
final ratingDistributionProvider =
    Provider.family<Map<int, double>, String>((ref, productId) {
  final stats = ref.watch(ratingStatsProvider(productId));
  return stats?.distributionPercentage ?? {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
});

/// Provider for rating distribution counts.
final ratingDistributionCountsProvider =
    Provider.family<Map<int, int>, String>((ref, productId) {
  final stats = ref.watch(ratingStatsProvider(productId));
  return stats?.distribution ?? {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
});

/// Provider for whether product has any reviews.
final hasReviewsProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).stats?.hasReviews ?? false;
});

/// Provider for verified purchase review count.
final verifiedReviewCountProvider =
    Provider.family<int, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).stats?.verifiedPurchaseReviews ?? 0;
});

/// Provider for reviews with images count.
final reviewsWithImagesCountProvider =
    Provider.family<int, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).stats?.reviewsWithImages ?? 0;
});

/// Provider for whether any filter is active.
final hasActiveReviewFiltersProvider =
    Provider.family<bool, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).filter.hasActiveFilters;
});

/// Provider for current sort option.
final reviewSortOptionProvider =
    Provider.family<ReviewSortOption, String>((ref, productId) {
  return ref.watch(reviewsProvider(productId)).filter.sortBy;
});

/// Provider for a specific review by ID.
final reviewByIdProvider =
    Provider.family<Review?, ({String productId, String reviewId})>(
        (ref, params) {
  final reviews = ref.watch(reviewsProvider(params.productId)).reviews;
  return reviews.cast<Review?>().firstWhere(
        (r) => r?.id == params.reviewId,
        orElse: () => null,
      );
});

/// Provider for most helpful reviews (top N).
final topHelpfulReviewsProvider =
    Provider.family<List<Review>, ({String productId, int count})>(
        (ref, params) {
  final reviews = ref.watch(filteredReviewsProvider(params.productId));
  final sorted = List<Review>.from(reviews)
    ..sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
  return sorted.take(params.count).toList();
});

/// Provider for most recent reviews (top N).
final recentReviewsProvider =
    Provider.family<List<Review>, ({String productId, int count})>(
        (ref, params) {
  final reviews = ref.watch(allReviewsProvider(params.productId));
  final visible = reviews.where((r) => r.status.isVisible).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return visible.take(params.count).toList();
});

/// Provider for review summary text.
final reviewSummaryTextProvider =
    Provider.family<String, String>((ref, productId) {
  final stats = ref.watch(ratingStatsProvider(productId));
  if (stats == null || !stats.hasReviews) {
    return 'No reviews yet';
  }
  final rating = stats.averageRating.toStringAsFixed(1);
  final count = stats.totalReviews;
  return '$rating out of 5 ($count review${count == 1 ? '' : 's'})';
});

// ─────────────────────────────────────────────────────────────────────────────
// User Review Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider to find user's review for a product.
final userReviewForProductProvider =
    Provider.family<Review?, ({String productId, String userId})>(
        (ref, params) {
  final reviews = ref.watch(allReviewsProvider(params.productId));
  return reviews.cast<Review?>().firstWhere(
        (r) => r?.userId == params.userId,
        orElse: () => null,
      );
});

/// Provider to check if user has reviewed a product.
final hasUserReviewedProductProvider =
    Provider.family<bool, ({String productId, String userId})>((ref, params) {
  final review = ref.watch(userReviewForProductProvider(params));
  return review != null;
});
