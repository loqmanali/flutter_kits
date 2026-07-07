import '../../core/models/review.dart';

/// Abstract repository interface for review operations.
///
/// Implement this interface to provide review functionality
/// with your preferred data source (local, remote, or both).
///
/// ## Usage
///
/// ```dart
/// class ApiReviewRepository implements ReviewRepository {
///   final ApiClient _client;
///
///   ApiReviewRepository(this._client);
///
///   @override
///   Future<List<Review>> getReviews(
///     String productId, {
///     int page = 1,
///     int pageSize = 20,
///     ReviewFilter? filter,
///   }) async {
///     final response = await _client.get('/products/$productId/reviews', {
///       'page': page,
///       'per_page': pageSize,
///       if (filter?.rating != null) 'rating': filter!.rating,
///       if (filter?.verifiedOnly ?? false) 'verified': true,
///     });
///     return response.data.map((json) => Review.fromJson(json)).toList();
///   }
///
///   // ... implement other methods
/// }
/// ```
abstract class ReviewRepository {
  /// Gets reviews for a product.
  ///
  /// [productId] - The product to get reviews for.
  /// [page] - Page number (1-indexed).
  /// [pageSize] - Number of reviews per page.
  /// [filter] - Optional filter to apply.
  ///
  /// Returns a list of reviews for the specified page.
  Future<List<Review>> getReviews(
    String productId, {
    int page = 1,
    int pageSize = 20,
    ReviewFilter? filter,
  });

  /// Gets a single review by ID.
  ///
  /// Returns the review or null if not found.
  Future<Review?> getReviewById(String reviewId);

  /// Gets rating statistics for a product.
  ///
  /// Returns aggregated rating statistics.
  Future<RatingStats> getRatingStats(String productId);

  /// Submits a new review.
  ///
  /// [review] - The review to submit.
  ///
  /// Returns the created review with server-assigned ID.
  Future<Review> submitReview(Review review);

  /// Updates an existing review.
  ///
  /// [reviewId] - ID of the review to update.
  /// [review] - Updated review data.
  ///
  /// Returns the updated review.
  Future<Review> updateReview(String reviewId, Review review);

  /// Deletes a review.
  ///
  /// [reviewId] - ID of the review to delete.
  Future<void> deleteReview(String reviewId);

  /// Votes on a review's helpfulness.
  ///
  /// [reviewId] - ID of the review to vote on.
  /// [helpful] - True if helpful, false if not helpful.
  Future<void> voteReview(String reviewId, {required bool helpful});

  /// Reports a review for moderation.
  ///
  /// [reviewId] - ID of the review to report.
  /// [reason] - Reason for reporting.
  Future<void> reportReview(String reviewId, String reason);

  /// Checks if the current user can review a product.
  ///
  /// Typically returns true if user has purchased the product
  /// and hasn't already reviewed it.
  Future<bool> canReview(String productId);

  /// Gets the current user's review for a product.
  ///
  /// Returns the user's review or null if they haven't reviewed.
  Future<Review?> getUserReview(String productId);

  /// Gets reviews by the current user.
  ///
  /// [page] - Page number (1-indexed).
  /// [pageSize] - Number of reviews per page.
  Future<List<Review>> getUserReviews({
    int page = 1,
    int pageSize = 20,
  });
}
