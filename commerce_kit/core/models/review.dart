import 'package:equatable/equatable.dart';

/// Represents a product review.
class Review extends Equatable {
  /// Unique identifier.
  final String id;

  /// Product ID.
  final String productId;

  /// User ID who wrote the review.
  final String userId;

  /// User display name.
  final String? userName;

  /// User avatar URL.
  final String? userAvatarUrl;

  /// Rating (1-5).
  final double rating;

  /// Review title.
  final String? title;

  /// Review content.
  final String content;

  /// Review images.
  final List<String> images;

  /// Whether this is a verified purchase.
  final bool isVerifiedPurchase;

  /// Review status.
  final ReviewStatus status;

  /// Created date.
  final DateTime createdAt;

  /// Updated date.
  final DateTime? updatedAt;

  /// Number of helpful votes.
  final int helpfulCount;

  /// Number of unhelpful votes.
  final int unhelpfulCount;

  /// Seller/admin response.
  final ReviewResponse? response;

  /// Variant info if applicable.
  final String? variantInfo;

  /// Metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a [Review].
  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    this.userName,
    this.userAvatarUrl,
    required this.rating,
    this.title,
    required this.content,
    this.images = const [],
    this.isVerifiedPurchase = false,
    this.status = ReviewStatus.approved,
    required this.createdAt,
    this.updatedAt,
    this.helpfulCount = 0,
    this.unhelpfulCount = 0,
    this.response,
    this.variantInfo,
    this.metadata,
  });

  /// Whether the review has images.
  bool get hasImages => images.isNotEmpty;

  /// Whether the review has a response.
  bool get hasResponse => response != null;

  /// Total votes.
  int get totalVotes => helpfulCount + unhelpfulCount;

  /// Helpfulness percentage.
  double get helpfulnessPercentage {
    if (totalVotes == 0) return 0;
    return helpfulCount / totalVotes * 100;
  }

  /// Creates a copy with updated fields.
  Review copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    double? rating,
    String? title,
    String? content,
    List<String>? images,
    bool? isVerifiedPurchase,
    ReviewStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? helpfulCount,
    int? unhelpfulCount,
    ReviewResponse? response,
    String? variantInfo,
    Map<String, dynamic>? metadata,
  }) {
    return Review(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      unhelpfulCount: unhelpfulCount ?? this.unhelpfulCount,
      response: response ?? this.response,
      variantInfo: variantInfo ?? this.variantInfo,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        userId,
        userName,
        userAvatarUrl,
        rating,
        title,
        content,
        images,
        isVerifiedPurchase,
        status,
        createdAt,
        updatedAt,
        helpfulCount,
        unhelpfulCount,
        response,
        variantInfo,
        metadata,
      ];
}

/// Review status enum.
enum ReviewStatus {
  /// Pending moderation.
  pending,

  /// Approved and visible.
  approved,

  /// Rejected.
  rejected,

  /// Flagged for review.
  flagged,
}

/// Extension for ReviewStatus.
extension ReviewStatusExtension on ReviewStatus {
  /// Display label.
  String get label {
    switch (this) {
      case ReviewStatus.pending:
        return 'Pending';
      case ReviewStatus.approved:
        return 'Approved';
      case ReviewStatus.rejected:
        return 'Rejected';
      case ReviewStatus.flagged:
        return 'Flagged';
    }
  }

  /// Whether the review is visible.
  bool get isVisible => this == ReviewStatus.approved;
}

/// Seller/admin response to a review.
class ReviewResponse extends Equatable {
  /// Response content.
  final String content;

  /// Responder name.
  final String? responderName;

  /// Response date.
  final DateTime respondedAt;

  /// Creates a [ReviewResponse].
  const ReviewResponse({
    required this.content,
    this.responderName,
    required this.respondedAt,
  });

  @override
  List<Object?> get props => [content, responderName, respondedAt];
}

/// Aggregated rating statistics for a product.
class RatingStats extends Equatable {
  /// Product ID.
  final String productId;

  /// Average rating (1-5).
  final double averageRating;

  /// Total number of reviews.
  final int totalReviews;

  /// Rating distribution (1-5 stars).
  final Map<int, int> distribution;

  /// Number of reviews with images.
  final int reviewsWithImages;

  /// Number of verified purchase reviews.
  final int verifiedPurchaseReviews;

  /// Creates [RatingStats].
  const RatingStats({
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
    this.distribution = const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
    this.reviewsWithImages = 0,
    this.verifiedPurchaseReviews = 0,
  });

  /// Creates empty stats.
  factory RatingStats.empty(String productId) {
    return RatingStats(
      productId: productId,
      averageRating: 0,
      totalReviews: 0,
    );
  }

  /// Creates stats from a list of reviews.
  factory RatingStats.fromReviews(String productId, List<Review> reviews) {
    if (reviews.isEmpty) {
      return RatingStats.empty(productId);
    }

    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    double totalRating = 0;
    int withImages = 0;
    int verified = 0;

    for (final review in reviews) {
      final ratingKey = review.rating.round().clamp(1, 5);
      distribution[ratingKey] = (distribution[ratingKey] ?? 0) + 1;
      totalRating += review.rating;
      if (review.hasImages) withImages++;
      if (review.isVerifiedPurchase) verified++;
    }

    return RatingStats(
      productId: productId,
      averageRating: totalRating / reviews.length,
      totalReviews: reviews.length,
      distribution: distribution,
      reviewsWithImages: withImages,
      verifiedPurchaseReviews: verified,
    );
  }

  /// Whether there are any reviews.
  bool get hasReviews => totalReviews > 0;

  /// Percentage of reviews for each rating.
  Map<int, double> get distributionPercentage {
    if (totalReviews == 0) {
      return {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    }
    return distribution.map(
      (key, value) => MapEntry(key, value / totalReviews * 100),
    );
  }

  /// Count for a specific rating.
  int countForRating(int rating) => distribution[rating] ?? 0;

  /// Percentage for a specific rating.
  double percentageForRating(int rating) {
    if (totalReviews == 0) return 0;
    return (distribution[rating] ?? 0) / totalReviews * 100;
  }

  @override
  List<Object?> get props => [
        productId,
        averageRating,
        totalReviews,
        distribution,
        reviewsWithImages,
        verifiedPurchaseReviews,
      ];
}

/// Sort options for reviews.
enum ReviewSortOption {
  /// Most recent first.
  mostRecent,

  /// Oldest first.
  oldest,

  /// Highest rating first.
  highestRating,

  /// Lowest rating first.
  lowestRating,

  /// Most helpful first.
  mostHelpful,

  /// With images first.
  withImages,

  /// Verified purchases first.
  verifiedFirst,
}

/// Extension for ReviewSortOption.
extension ReviewSortOptionExtension on ReviewSortOption {
  /// Display label.
  String get label {
    switch (this) {
      case ReviewSortOption.mostRecent:
        return 'Most Recent';
      case ReviewSortOption.oldest:
        return 'Oldest';
      case ReviewSortOption.highestRating:
        return 'Highest Rating';
      case ReviewSortOption.lowestRating:
        return 'Lowest Rating';
      case ReviewSortOption.mostHelpful:
        return 'Most Helpful';
      case ReviewSortOption.withImages:
        return 'With Images';
      case ReviewSortOption.verifiedFirst:
        return 'Verified Purchases';
    }
  }
}

/// Filter options for reviews.
class ReviewFilter extends Equatable {
  /// Filter by rating (null = all).
  final int? rating;

  /// Only verified purchases.
  final bool verifiedOnly;

  /// Only with images.
  final bool withImagesOnly;

  /// Sort option.
  final ReviewSortOption sortBy;

  /// Creates a [ReviewFilter].
  const ReviewFilter({
    this.rating,
    this.verifiedOnly = false,
    this.withImagesOnly = false,
    this.sortBy = ReviewSortOption.mostRecent,
  });

  /// Default filter.
  static const ReviewFilter defaults = ReviewFilter();

  /// Whether any filter is active.
  bool get hasActiveFilters =>
      rating != null || verifiedOnly || withImagesOnly;

  ReviewFilter copyWith({
    int? rating,
    bool? verifiedOnly,
    bool? withImagesOnly,
    ReviewSortOption? sortBy,
    bool clearRating = false,
  }) {
    return ReviewFilter(
      rating: clearRating ? null : (rating ?? this.rating),
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      withImagesOnly: withImagesOnly ?? this.withImagesOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [rating, verifiedOnly, withImagesOnly, sortBy];
}
