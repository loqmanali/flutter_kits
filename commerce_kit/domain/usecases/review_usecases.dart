import '../../core/models/review.dart';
import '../repositories/review_repository.dart';

/// Use case for getting reviews for a product.
class GetReviewsUseCase {
  final ReviewRepository _repository;

  GetReviewsUseCase(this._repository);

  /// Gets paginated reviews for a product.
  Future<List<Review>> call(
    String productId, {
    int page = 1,
    int pageSize = 20,
    ReviewFilter? filter,
  }) async {
    return _repository.getReviews(
      productId,
      page: page,
      pageSize: pageSize,
      filter: filter,
    );
  }
}

/// Use case for getting rating statistics.
class GetRatingStatsUseCase {
  final ReviewRepository _repository;

  GetRatingStatsUseCase(this._repository);

  /// Gets rating statistics for a product.
  Future<RatingStats> call(String productId) async {
    return _repository.getRatingStats(productId);
  }
}

/// Use case for submitting a review.
class SubmitReviewUseCase {
  final ReviewRepository _repository;

  SubmitReviewUseCase(this._repository);

  /// Submits a new review.
  ///
  /// Validates the review before submitting.
  Future<Review> call(Review review) async {
    // Validate review
    final errors = _validateReview(review);
    if (errors.isNotEmpty) {
      throw ReviewValidationException(errors);
    }

    return _repository.submitReview(review);
  }

  /// Creates and submits a review.
  Future<Review> submit({
    required String productId,
    required String userId,
    required double rating,
    required String content,
    String? userName,
    String? title,
    List<String> images = const [],
  }) async {
    final review = Review(
      id: '', // Will be assigned by server
      productId: productId,
      userId: userId,
      userName: userName,
      rating: rating,
      title: title,
      content: content,
      images: images,
      createdAt: DateTime.now(),
    );

    return call(review);
  }

  List<String> _validateReview(Review review) {
    final errors = <String>[];

    if (review.productId.isEmpty) {
      errors.add('Product ID is required');
    }

    if (review.userId.isEmpty) {
      errors.add('User ID is required');
    }

    if (review.rating < 1 || review.rating > 5) {
      errors.add('Rating must be between 1 and 5');
    }

    if (review.content.isEmpty) {
      errors.add('Review content is required');
    }

    if (review.content.length < 10) {
      errors.add('Review must be at least 10 characters');
    }

    if (review.content.length > 5000) {
      errors.add('Review must be less than 5000 characters');
    }

    return errors;
  }
}

/// Use case for updating a review.
class UpdateReviewUseCase {
  final ReviewRepository _repository;

  UpdateReviewUseCase(this._repository);

  /// Updates an existing review.
  Future<Review> call(String reviewId, Review review) async {
    return _repository.updateReview(reviewId, review);
  }
}

/// Use case for deleting a review.
class DeleteReviewUseCase {
  final ReviewRepository _repository;

  DeleteReviewUseCase(this._repository);

  /// Deletes a review.
  Future<void> call(String reviewId) async {
    return _repository.deleteReview(reviewId);
  }
}

/// Use case for voting on a review.
class VoteReviewUseCase {
  final ReviewRepository _repository;

  VoteReviewUseCase(this._repository);

  /// Votes a review as helpful.
  Future<void> voteHelpful(String reviewId) async {
    return _repository.voteReview(reviewId, helpful: true);
  }

  /// Votes a review as not helpful.
  Future<void> voteNotHelpful(String reviewId) async {
    return _repository.voteReview(reviewId, helpful: false);
  }

  /// Votes on a review.
  Future<void> call(String reviewId, {required bool helpful}) async {
    return _repository.voteReview(reviewId, helpful: helpful);
  }
}

/// Use case for reporting a review.
class ReportReviewUseCase {
  final ReviewRepository _repository;

  ReportReviewUseCase(this._repository);

  /// Reports a review for moderation.
  Future<void> call(String reviewId, String reason) async {
    if (reason.isEmpty) {
      throw ReviewValidationException(['Reason is required']);
    }
    return _repository.reportReview(reviewId, reason);
  }
}

/// Use case for checking if user can review.
class CanReviewUseCase {
  final ReviewRepository _repository;

  CanReviewUseCase(this._repository);

  /// Checks if the current user can review a product.
  Future<bool> call(String productId) async {
    return _repository.canReview(productId);
  }
}

/// Use case for getting user's review for a product.
class GetUserReviewUseCase {
  final ReviewRepository _repository;

  GetUserReviewUseCase(this._repository);

  /// Gets the current user's review for a product.
  Future<Review?> call(String productId) async {
    return _repository.getUserReview(productId);
  }
}

/// Exception thrown when review validation fails.
class ReviewValidationException implements Exception {
  final List<String> errors;

  ReviewValidationException(this.errors);

  @override
  String toString() => errors.join(', ');
}
