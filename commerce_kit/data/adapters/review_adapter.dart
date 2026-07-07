import '../../core/models/review.dart';

/// Abstract adapter for converting API responses to [Review] models.
///
/// Implement this interface to map your specific API response format
/// to the commerce kit's internal [Review] model.
///
/// ## Usage
///
/// ```dart
/// class MyReviewAdapter extends ReviewAdapter<MyApiReview> {
///   @override
///   Review fromResponse(MyApiReview response) {
///     return Review(
///       id: response.reviewId,
///       productId: response.productId,
///       userId: response.userId,
///       rating: response.stars.toDouble(),
///       content: response.comment,
///       createdAt: DateTime.parse(response.date),
///     );
///   }
/// }
/// ```
abstract class ReviewAdapter<T> {
  /// Converts an API response to a [Review].
  Review fromResponse(T response);

  /// Converts a [Review] back to an API response format.
  T toResponse(Review review) {
    throw UnimplementedError('toResponse not implemented');
  }

  /// Converts a list of API responses to a list of [Review]s.
  List<Review> fromResponseList(List<T> responses) {
    return responses.map(fromResponse).toList();
  }

  /// Safely converts an API response, returning null on error.
  Review? tryFromResponse(T response) {
    try {
      return fromResponse(response);
    } catch (_) {
      return null;
    }
  }
}

/// Adapter for converting [RatingStats] from API responses.
abstract class RatingStatsAdapter<T> {
  /// Converts an API response to [RatingStats].
  RatingStats fromResponse(T response);

  /// Converts [RatingStats] back to an API response format.
  T toResponse(RatingStats stats) {
    throw UnimplementedError('toResponse not implemented');
  }
}

/// Adapter for Map<String, dynamic> (JSON) to [Review].
///
/// ## Default JSON Structure
///
/// ```json
/// {
///   "id": "review_123",
///   "product_id": "prod_456",
///   "user_id": "user_789",
///   "user_name": "John Doe",
///   "user_avatar_url": "https://example.com/avatar.jpg",
///   "rating": 4.5,
///   "title": "Great product!",
///   "content": "Really enjoyed using this product...",
///   "images": ["https://example.com/img1.jpg"],
///   "is_verified_purchase": true,
///   "status": "approved",
///   "created_at": "2025-01-15T10:30:00Z",
///   "helpful_count": 10,
///   "unhelpful_count": 2,
///   "response": {
///     "content": "Thank you for your review!",
///     "responder_name": "Store Owner",
///     "responded_at": "2025-01-16T09:00:00Z"
///   }
/// }
/// ```
class JsonReviewAdapter extends ReviewAdapter<Map<String, dynamic>> {
  /// Field mappings for custom JSON structures.
  final ReviewFieldMapping? fieldMapping;

  /// Optional transformer to preprocess JSON before conversion.
  final Map<String, dynamic> Function(Map<String, dynamic>)? transformer;

  JsonReviewAdapter({this.fieldMapping, this.transformer});

  @override
  Review fromResponse(Map<String, dynamic> response) {
    final json = transformer != null ? transformer!(response) : response;
    final mapping = fieldMapping ?? ReviewFieldMapping.defaults;

    return Review(
      id: json[mapping.id]?.toString() ?? '',
      productId: json[mapping.productId]?.toString() ?? '',
      userId: json[mapping.userId]?.toString() ?? '',
      userName: json[mapping.userName]?.toString(),
      userAvatarUrl: json[mapping.userAvatarUrl]?.toString(),
      rating: _parseDouble(json[mapping.rating]) ?? 0,
      title: json[mapping.title]?.toString(),
      content: json[mapping.content]?.toString() ?? '',
      images: _parseStringList(json[mapping.images]),
      isVerifiedPurchase: json[mapping.isVerifiedPurchase] == true,
      status: _parseStatus(json[mapping.status]),
      createdAt: _parseDateTime(json[mapping.createdAt]) ?? DateTime.now(),
      updatedAt: _parseDateTime(json[mapping.updatedAt]),
      helpfulCount: _parseInt(json[mapping.helpfulCount]) ?? 0,
      unhelpfulCount: _parseInt(json[mapping.unhelpfulCount]) ?? 0,
      response: _parseResponse(json[mapping.response]),
      variantInfo: json[mapping.variantInfo]?.toString(),
      metadata: json[mapping.metadata] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toResponse(Review review) {
    final mapping = fieldMapping ?? ReviewFieldMapping.defaults;

    return {
      mapping.id: review.id,
      mapping.productId: review.productId,
      mapping.userId: review.userId,
      if (review.userName != null) mapping.userName: review.userName,
      if (review.userAvatarUrl != null)
        mapping.userAvatarUrl: review.userAvatarUrl,
      mapping.rating: review.rating,
      if (review.title != null) mapping.title: review.title,
      mapping.content: review.content,
      mapping.images: review.images,
      mapping.isVerifiedPurchase: review.isVerifiedPurchase,
      mapping.status: review.status.name,
      mapping.createdAt: review.createdAt.toIso8601String(),
      if (review.updatedAt != null)
        mapping.updatedAt: review.updatedAt!.toIso8601String(),
      mapping.helpfulCount: review.helpfulCount,
      mapping.unhelpfulCount: review.unhelpfulCount,
      if (review.response != null)
        mapping.response: {
          'content': review.response!.content,
          'responder_name': review.response!.responderName,
          'responded_at': review.response!.respondedAt.toIso8601String(),
        },
      if (review.variantInfo != null) mapping.variantInfo: review.variantInfo,
      if (review.metadata != null) mapping.metadata: review.metadata,
    };
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  ReviewStatus _parseStatus(dynamic value) {
    if (value == null) return ReviewStatus.approved;
    final str = value.toString().toLowerCase();
    return ReviewStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => ReviewStatus.approved,
    );
  }

  ReviewResponse? _parseResponse(dynamic value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic>) return null;

    return ReviewResponse(
      content: value['content']?.toString() ?? '',
      responderName: value['responder_name']?.toString(),
      respondedAt: _parseDateTime(value['responded_at']) ?? DateTime.now(),
    );
  }
}

/// Adapter for Map<String, dynamic> (JSON) to [RatingStats].
class JsonRatingStatsAdapter extends RatingStatsAdapter<Map<String, dynamic>> {
  /// Field mappings for custom JSON structures.
  final RatingStatsFieldMapping? fieldMapping;

  /// Optional transformer to preprocess JSON.
  final Map<String, dynamic> Function(Map<String, dynamic>)? transformer;

  JsonRatingStatsAdapter({this.fieldMapping, this.transformer});

  @override
  RatingStats fromResponse(Map<String, dynamic> response) {
    final json = transformer != null ? transformer!(response) : response;
    final mapping = fieldMapping ?? RatingStatsFieldMapping.defaults;

    return RatingStats(
      productId: json[mapping.productId]?.toString() ?? '',
      averageRating: _parseDouble(json[mapping.averageRating]) ?? 0,
      totalReviews: _parseInt(json[mapping.totalReviews]) ?? 0,
      distribution: _parseDistribution(json[mapping.distribution]),
      reviewsWithImages: _parseInt(json[mapping.reviewsWithImages]) ?? 0,
      verifiedPurchaseReviews:
          _parseInt(json[mapping.verifiedPurchaseReviews]) ?? 0,
    );
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<int, int> _parseDistribution(dynamic value) {
    if (value == null) return {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    if (value is Map) {
      final result = <int, int>{};
      for (final entry in value.entries) {
        final key = int.tryParse(entry.key.toString());
        final val = _parseInt(entry.value);
        if (key != null && val != null) {
          result[key] = val;
        }
      }
      // Ensure all ratings 1-5 exist
      for (int i = 1; i <= 5; i++) {
        result.putIfAbsent(i, () => 0);
      }
      return result;
    }

    if (value is List && value.length >= 5) {
      return {
        1: _parseInt(value[0]) ?? 0,
        2: _parseInt(value[1]) ?? 0,
        3: _parseInt(value[2]) ?? 0,
        4: _parseInt(value[3]) ?? 0,
        5: _parseInt(value[4]) ?? 0,
      };
    }

    return {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  }
}

/// Field mapping for [Review] JSON conversion.
class ReviewFieldMapping {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String rating;
  final String title;
  final String content;
  final String images;
  final String isVerifiedPurchase;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String helpfulCount;
  final String unhelpfulCount;
  final String response;
  final String variantInfo;
  final String metadata;

  const ReviewFieldMapping({
    this.id = 'id',
    this.productId = 'product_id',
    this.userId = 'user_id',
    this.userName = 'user_name',
    this.userAvatarUrl = 'user_avatar_url',
    this.rating = 'rating',
    this.title = 'title',
    this.content = 'content',
    this.images = 'images',
    this.isVerifiedPurchase = 'is_verified_purchase',
    this.status = 'status',
    this.createdAt = 'created_at',
    this.updatedAt = 'updated_at',
    this.helpfulCount = 'helpful_count',
    this.unhelpfulCount = 'unhelpful_count',
    this.response = 'response',
    this.variantInfo = 'variant_info',
    this.metadata = 'metadata',
  });

  /// Default field mapping using snake_case.
  static const defaults = ReviewFieldMapping();

  /// CamelCase field mapping.
  static const camelCase = ReviewFieldMapping(
    productId: 'productId',
    userId: 'userId',
    userName: 'userName',
    userAvatarUrl: 'userAvatarUrl',
    isVerifiedPurchase: 'isVerifiedPurchase',
    createdAt: 'createdAt',
    updatedAt: 'updatedAt',
    helpfulCount: 'helpfulCount',
    unhelpfulCount: 'unhelpfulCount',
    variantInfo: 'variantInfo',
  );
}

/// Field mapping for [RatingStats] JSON conversion.
class RatingStatsFieldMapping {
  final String productId;
  final String averageRating;
  final String totalReviews;
  final String distribution;
  final String reviewsWithImages;
  final String verifiedPurchaseReviews;

  const RatingStatsFieldMapping({
    this.productId = 'product_id',
    this.averageRating = 'average_rating',
    this.totalReviews = 'total_reviews',
    this.distribution = 'distribution',
    this.reviewsWithImages = 'reviews_with_images',
    this.verifiedPurchaseReviews = 'verified_purchase_reviews',
  });

  /// Default field mapping using snake_case.
  static const defaults = RatingStatsFieldMapping();

  /// CamelCase field mapping.
  static const camelCase = RatingStatsFieldMapping(
    productId: 'productId',
    averageRating: 'averageRating',
    totalReviews: 'totalReviews',
    reviewsWithImages: 'reviewsWithImages',
    verifiedPurchaseReviews: 'verifiedPurchaseReviews',
  );
}
