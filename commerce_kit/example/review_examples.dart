// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../commerce_kit.dart';

/// Examples demonstrating the Review System functionality.
///
/// This file shows how to:
/// - Load and display product reviews
/// - Submit new reviews
/// - Filter and sort reviews
/// - Display rating statistics
/// - Use review adapters for API integration
class ReviewExamples {
  /// Run all review examples.
  static void runAll() {
    print('\n════════════════════════════════════════════════════════════════');
    print('REVIEW SYSTEM EXAMPLES');
    print('════════════════════════════════════════════════════════════════\n');

    _modelExamples();
    _adapterExamples();
    _filterExamples();
  }

  /// Examples of using Review models directly.
  static void _modelExamples() {
    print('▶ Model Examples');
    print('─' * 60);

    // Create a review
    final review = Review(
      id: 'review_001',
      productId: 'burger_classic',
      userId: 'user_123',
      userName: 'Ahmed Mohamed',
      rating: 4.5,
      title: 'Delicious burger!',
      content:
          'The classic burger was amazing. Fresh ingredients and great taste.',
      images: const ['https://example.com/review_img1.jpg'],
      isVerifiedPurchase: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      helpfulCount: 15,
      unhelpfulCount: 2,
    );

    print('  Review: ${review.title}');
    print('  Rating: ${review.rating} stars');
    print('  Verified: ${review.isVerifiedPurchase}');
    print('  Has images: ${review.hasImages}');
    print('  Helpfulness: ${review.helpfulnessPercentage.toStringAsFixed(1)}%');

    // Create rating stats from reviews
    final reviews = [
      review,
      Review(
        id: 'review_002',
        productId: 'burger_classic',
        userId: 'user_456',
        rating: 5.0,
        content: 'Best burger in town!',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Review(
        id: 'review_003',
        productId: 'burger_classic',
        userId: 'user_789',
        rating: 4.0,
        content: 'Good but could use more sauce.',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    final stats = RatingStats.fromReviews('burger_classic', reviews);
    print('\n  Rating Stats:');
    print('  Average: ${stats.averageRating.toStringAsFixed(1)}');
    print('  Total reviews: ${stats.totalReviews}');
    print(
      '  5 stars: ${stats.countForRating(5)} (${stats.percentageForRating(5).toStringAsFixed(0)}%)',
    );
    print(
      '  4 stars: ${stats.countForRating(4)} (${stats.percentageForRating(4).toStringAsFixed(0)}%)',
    );
  }

  /// Examples of using Review adapters for API integration.
  static void _adapterExamples() {
    print('\n▶ Adapter Examples');
    print('─' * 60);

    // Example API response
    final apiResponse = {
      'id': 'rev_12345',
      'product_id': 'prod_burger',
      'user_id': 'usr_999',
      'user_name': 'Sara Ahmed',
      'rating': 5,
      'title': 'Amazing!',
      'content': 'This is the best burger I have ever had.',
      'images': [
        'https://example.com/img1.jpg',
        'https://example.com/img2.jpg',
      ],
      'is_verified_purchase': true,
      'status': 'approved',
      'created_at': '2025-01-15T14:30:00Z',
      'helpful_count': 25,
      'unhelpful_count': 3,
      'response': {
        'content': 'Thank you for your wonderful review!',
        'responder_name': 'Burger Republic Team',
        'responded_at': '2025-01-16T10:00:00Z',
      },
    };

    // Use default adapter
    final adapter = JsonReviewAdapter();
    final review = adapter.fromResponse(apiResponse);

    print('  Parsed review from API:');
    print('  ID: ${review.id}');
    print('  Title: ${review.title}');
    print('  Rating: ${review.rating}');
    print('  Has response: ${review.hasResponse}');
    if (review.hasResponse) {
      print('  Response: ${review.response!.content}');
    }

    // Using custom field mapping (e.g., for camelCase API)
    final camelCaseResponse = {
      'id': 'rev_67890',
      'productId': 'prod_fries',
      'userId': 'usr_111',
      'userName': 'Mohamed Ali',
      'rating': 4,
      'content': 'Great fries!',
      'isVerifiedPurchase': false,
      'status': 'approved',
      'createdAt': '2025-01-20T16:00:00Z',
      'helpfulCount': 5,
      'unhelpfulCount': 0,
    };

    final camelAdapter = JsonReviewAdapter(
      fieldMapping: ReviewFieldMapping.camelCase,
    );
    final review2 = camelAdapter.fromResponse(camelCaseResponse);
    print('\n  Parsed from camelCase API:');
    print('  User: ${review2.userName}');
    print('  Content: ${review2.content}');

    // Rating stats adapter
    final statsResponse = {
      'product_id': 'prod_burger',
      'average_rating': 4.7,
      'total_reviews': 156,
      'distribution': {'1': 2, '2': 5, '3': 12, '4': 45, '5': 92},
      'reviews_with_images': 34,
      'verified_purchase_reviews': 120,
    };

    final statsAdapter = JsonRatingStatsAdapter();
    final stats = statsAdapter.fromResponse(statsResponse);
    print('\n  Parsed rating stats:');
    print('  Average: ${stats.averageRating}');
    print('  Total: ${stats.totalReviews}');
    print('  With images: ${stats.reviewsWithImages}');
  }

  /// Examples of filtering and sorting reviews.
  static void _filterExamples() {
    print('\n▶ Filter & Sort Examples');
    print('─' * 60);

    // Create a filter for verified reviews with high ratings
    const filter = ReviewFilter(
      verifiedOnly: true,
      rating: 4,
      sortBy: ReviewSortOption.mostHelpful,
    );

    print('  Filter settings:');
    print('  Verified only: ${filter.verifiedOnly}');
    print('  Rating filter: ${filter.rating}+ stars');
    print('  Sort by: ${filter.sortBy.label}');
    print('  Has active filters: ${filter.hasActiveFilters}');

    // Modify filter
    final updatedFilter = filter.copyWith(
      withImagesOnly: true,
      sortBy: ReviewSortOption.mostRecent,
    );

    print('\n  Updated filter:');
    print('  With images only: ${updatedFilter.withImagesOnly}');
    print('  Sort by: ${updatedFilter.sortBy.label}');

    // Clear rating filter
    final noRatingFilter = updatedFilter.copyWith(clearRating: true);
    print('\n  After clearing rating: ${noRatingFilter.rating}');
  }
}

/// Example of using ReviewProvider in a widget.
///
/// ```dart
/// class ProductReviewsScreen extends ConsumerWidget {
///   final String productId;
///
///   const ProductReviewsScreen({required this.productId});
///
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Watch reviews for this product
///     final reviewsState = ref.watch(reviewsProvider(productId));
///     final ratingStats = ref.watch(ratingStatsProvider(productId));
///
///     return Column(
///       children: [
///         // Rating summary
///         if (ratingStats != null)
///           RatingSummaryWidget(stats: ratingStats),
///
///         // Filter bar
///         ReviewFilterBar(
///           onFilterChanged: (filter) {
///             ref.read(reviewsNotifierProvider.notifier)
///                 .setFilter(productId, filter);
///           },
///         ),
///
///         // Reviews list
///         if (reviewsState.isLoading)
///           const CircularProgressIndicator()
///         else if (reviewsState.error != null)
///           Text('Error: ${reviewsState.error}')
///         else
///           ListView.builder(
///             itemCount: reviewsState.filteredReviews.length,
///             itemBuilder: (ctx, i) => ReviewCard(
///               review: reviewsState.filteredReviews[i],
///             ),
///           ),
///       ],
///     );
///   }
/// }
/// ```
void reviewProviderUsageExample(WidgetRef ref, String productId) {
  // Get the main notifier
  final notifier = ref.read(reviewsNotifierProvider.notifier);

  // Load reviews for a product
  notifier.loadReviews(productId);

  // Refresh reviews
  notifier.loadReviews(productId, refresh: true);

  // Apply filter
  notifier.setFilter(
    productId,
    const ReviewFilter(
      verifiedOnly: true,
      sortBy: ReviewSortOption.mostHelpful,
    ),
  );

  // Set sort option
  notifier.setSortOption(productId, ReviewSortOption.mostRecent);

  // Filter by rating
  notifier.filterByRating(productId, 5); // Only 5-star reviews

  // Toggle filters
  notifier.toggleVerifiedOnly(productId, true);
  notifier.toggleWithImagesOnly(productId, true);

  // Clear all filters
  notifier.clearFilters(productId);

  // Load rating stats
  notifier.loadStats(productId);

  // Submit a new review (requires a Review object)
  final newReview = Review(
    id: '', // Will be assigned by server
    productId: productId,
    userId: 'current_user_id',
    userName: 'Current User',
    rating: 5,
    content: 'Excellent product!',
    title: 'Highly recommended',
    createdAt: DateTime.now(),
  );
  notifier.submitReview(newReview);

  // Vote on a review (helpful = true, not helpful = false)
  notifier.vote(productId, 'review_123', true);
}
