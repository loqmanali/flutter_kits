import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/review.dart';
import '../providers/review_provider.dart';

/// A widget to display star rating.
class StarRatingWidget extends StatelessWidget {
  /// The rating value (0-5).
  final double rating;

  /// Size of each star.
  final double size;

  /// Color for filled stars.
  final Color? activeColor;

  /// Color for empty stars.
  final Color? inactiveColor;

  /// Whether to show half stars.
  final bool allowHalfRating;

  /// Spacing between stars.
  final double spacing;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.size = 20,
    this.activeColor,
    this.inactiveColor,
    this.allowHalfRating = true,
    this.spacing = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = activeColor ?? Colors.amber;
    final inactive = inactiveColor ?? theme.colorScheme.outlineVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData icon;

        if (rating >= starValue) {
          icon = Icons.star;
        } else if (allowHalfRating && rating >= starValue - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return Padding(
          padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
          child: Icon(
            icon,
            size: size,
            color: rating >= starValue - 0.5 ? active : inactive,
          ),
        );
      }),
    );
  }
}

/// An interactive star rating input widget.
class StarRatingInput extends StatelessWidget {
  /// Current rating value.
  final double rating;

  /// Callback when rating changes.
  final ValueChanged<double>? onRatingChanged;

  /// Size of each star.
  final double size;

  /// Color for filled stars.
  final Color? activeColor;

  /// Color for empty stars.
  final Color? inactiveColor;

  /// Whether to allow half ratings.
  final bool allowHalfRating;

  /// Spacing between stars.
  final double spacing;

  const StarRatingInput({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.size = 32,
    this.activeColor,
    this.inactiveColor,
    this.allowHalfRating = false,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = activeColor ?? Colors.amber;
    final inactive = inactiveColor ?? theme.colorScheme.outlineVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = rating >= starValue;
        final isHalfFilled =
            allowHalfRating && rating >= starValue - 0.5 && rating < starValue;

        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(starValue.toDouble())
              : null,
          child: Padding(
            padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
            child: Icon(
              isFilled
                  ? Icons.star
                  : isHalfFilled
                      ? Icons.star_half
                      : Icons.star_border,
              size: size,
              color: isFilled || isHalfFilled ? active : inactive,
            ),
          ),
        );
      }),
    );
  }
}

/// A compact rating display with count.
class RatingDisplayWidget extends StatelessWidget {
  /// Average rating.
  final double rating;

  /// Total review count.
  final int reviewCount;

  /// Size of the star icon.
  final double starSize;

  /// Text style for rating.
  final TextStyle? ratingStyle;

  /// Text style for count.
  final TextStyle? countStyle;

  /// Whether to show review count.
  final bool showCount;

  /// Callback when tapped.
  final VoidCallback? onTap;

  const RatingDisplayWidget({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.starSize = 16,
    this.ratingStyle,
    this.countStyle,
    this.showCount = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: starSize,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: ratingStyle ??
              theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        if (showCount) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: countStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// A connected rating display widget.
class ConnectedRatingDisplayWidget extends ConsumerWidget {
  /// Product ID.
  final String productId;

  /// Size of the star icon.
  final double starSize;

  /// Whether to show review count.
  final bool showCount;

  /// Callback when tapped.
  final VoidCallback? onTap;

  const ConnectedRatingDisplayWidget({
    super.key,
    required this.productId,
    this.starSize = 16,
    this.showCount = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rating = ref.watch(averageRatingProvider(productId));
    final count = ref.watch(reviewCountProvider(productId));

    return RatingDisplayWidget(
      rating: rating,
      reviewCount: count,
      starSize: starSize,
      showCount: showCount,
      onTap: onTap,
    );
  }
}

/// A widget to display rating distribution bars.
class RatingDistributionWidget extends StatelessWidget {
  /// Rating statistics.
  final RatingStats stats;

  /// Bar height.
  final double barHeight;

  /// Active bar color.
  final Color? activeColor;

  /// Inactive bar color.
  final Color? inactiveColor;

  /// Whether to show counts.
  final bool showCounts;

  /// Callback when a rating bar is tapped.
  final ValueChanged<int>? onRatingTap;

  const RatingDistributionWidget({
    super.key,
    required this.stats,
    this.barHeight = 8,
    this.activeColor,
    this.inactiveColor,
    this.showCounts = true,
    this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = activeColor ?? Colors.amber;
    final inactive = inactiveColor ?? theme.colorScheme.surfaceContainerHighest;

    return Column(
      children: List.generate(5, (index) {
        final rating = 5 - index;
        final percentage = stats.percentageForRating(rating);
        final count = stats.countForRating(rating);

        return InkWell(
          onTap: onRatingTap != null ? () => onRatingTap!(rating) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  child: Text(
                    '$rating',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.star, size: 14, color: active),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(barHeight / 2),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: barHeight,
                      backgroundColor: inactive,
                      valueColor: AlwaysStoppedAnimation(active),
                    ),
                  ),
                ),
                if (showCounts) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 32,
                    child: Text(
                      count.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// A comprehensive rating summary widget.
class RatingSummaryWidget extends StatelessWidget {
  /// Rating statistics.
  final RatingStats stats;

  /// Star size for the main rating.
  final double mainStarSize;

  /// Callback when write review is pressed.
  final VoidCallback? onWriteReview;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  const RatingSummaryWidget({
    super.key,
    required this.stats,
    this.mainStarSize = 24,
    this.onWriteReview,
    this.backgroundColor,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Average rating
          Column(
            children: [
              Text(
                stats.averageRating.toStringAsFixed(1),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              StarRatingWidget(
                rating: stats.averageRating,
                size: mainStarSize,
              ),
              const SizedBox(height: 4),
              Text(
                '${stats.totalReviews} review${stats.totalReviews == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Right side - Distribution
          Expanded(
            child: RatingDistributionWidget(
              stats: stats,
              showCounts: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// A connected rating summary widget.
class ConnectedRatingSummaryWidget extends ConsumerWidget {
  /// Product ID.
  final String productId;

  /// Callback when write review is pressed.
  final VoidCallback? onWriteReview;

  /// Background color.
  final Color? backgroundColor;

  const ConnectedRatingSummaryWidget({
    super.key,
    required this.productId,
    this.onWriteReview,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(ratingStatsProvider(productId));

    if (stats == null) {
      return const SizedBox.shrink();
    }

    return RatingSummaryWidget(
      stats: stats,
      onWriteReview: onWriteReview,
      backgroundColor: backgroundColor,
    );
  }
}

/// A widget to display a single review.
class ReviewItemWidget extends StatelessWidget {
  /// The review.
  final Review review;

  /// Callback when helpful is pressed.
  final VoidCallback? onHelpful;

  /// Callback when not helpful is pressed.
  final VoidCallback? onNotHelpful;

  /// Callback when report is pressed.
  final VoidCallback? onReport;

  /// Callback when an image is tapped.
  final ValueChanged<int>? onImageTap;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Whether to show vote buttons.
  final bool showVoteButtons;

  const ReviewItemWidget({
    super.key,
    required this.review,
    this.onHelpful,
    this.onNotHelpful,
    this.onReport,
    this.onImageTap,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.showVoteButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - User info and rating
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: review.userAvatarUrl != null
                    ? NetworkImage(review.userAvatarUrl!)
                    : null,
                child: review.userAvatarUrl == null
                    ? Text(
                        (review.userName ?? 'U')[0].toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName ?? 'Anonymous',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (review.isVerifiedPurchase) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified,
                                  size: 12,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(review.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating
              StarRatingWidget(
                rating: review.rating,
                size: 16,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          if (review.title != null && review.title!.isNotEmpty) ...[
            Text(
              review.title!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Content
          Text(
            review.content,
            style: theme.textTheme.bodyMedium,
          ),

          // Variant info
          if (review.variantInfo != null && review.variantInfo!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Variant: ${review.variantInfo}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Images
          if (review.hasImages) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: onImageTap != null ? () => onImageTap!(index) : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        review.images[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.broken_image,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Seller response
          if (review.hasResponse) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        review.response!.responderName ?? 'Seller Response',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.response!.content,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],

          // Vote buttons
          if (showVoteButtons) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Was this helpful?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                _VoteButton(
                  icon: Icons.thumb_up_outlined,
                  count: review.helpfulCount,
                  onPressed: onHelpful,
                ),
                const SizedBox(width: 8),
                _VoteButton(
                  icon: Icons.thumb_down_outlined,
                  count: review.unhelpfulCount,
                  onPressed: onNotHelpful,
                ),
                const Spacer(),
                if (onReport != null)
                  IconButton(
                    onPressed: onReport,
                    icon: const Icon(Icons.flag_outlined),
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onPressed;

  const _VoteButton({
    required this.icon,
    required this.count,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A widget to display a list of reviews.
class ReviewListWidget extends StatelessWidget {
  /// Reviews to display.
  final List<Review> reviews;

  /// Callback when helpful is pressed.
  final void Function(Review review, bool helpful)? onVote;

  /// Callback when report is pressed.
  final void Function(Review review)? onReport;

  /// Callback when an image is tapped.
  final void Function(Review review, int imageIndex)? onImageTap;

  /// Empty state widget.
  final Widget? emptyWidget;

  /// Item spacing.
  final double spacing;

  /// Whether to show vote buttons.
  final bool showVoteButtons;

  const ReviewListWidget({
    super.key,
    required this.reviews,
    this.onVote,
    this.onReport,
    this.onImageTap,
    this.emptyWidget,
    this.spacing = 12,
    this.showVoteButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return emptyWidget ?? _buildEmptyState(context);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ReviewItemWidget(
          review: review,
          showVoteButtons: showVoteButtons,
          onHelpful: onVote != null ? () => onVote!(review, true) : null,
          onNotHelpful: onVote != null ? () => onVote!(review, false) : null,
          onReport: onReport != null ? () => onReport!(review) : null,
          onImageTap: onImageTap != null
              ? (imageIndex) => onImageTap!(review, imageIndex)
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to review this product',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A connected review list widget.
class ConnectedReviewListWidget extends ConsumerWidget {
  /// Product ID.
  final String productId;

  /// Callback when report is pressed.
  final void Function(Review review)? onReport;

  /// Callback when an image is tapped.
  final void Function(Review review, int imageIndex)? onImageTap;

  /// Empty state widget.
  final Widget? emptyWidget;

  /// Whether to show vote buttons.
  final bool showVoteButtons;

  const ConnectedReviewListWidget({
    super.key,
    required this.productId,
    this.onReport,
    this.onImageTap,
    this.emptyWidget,
    this.showVoteButtons = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(filteredReviewsProvider(productId));
    final notifier = ref.read(reviewsNotifierProvider.notifier);

    return ReviewListWidget(
      reviews: reviews,
      showVoteButtons: showVoteButtons,
      emptyWidget: emptyWidget,
      onVote: (review, helpful) => notifier.vote(productId, review.id, helpful),
      onReport: onReport,
      onImageTap: onImageTap,
    );
  }
}

/// A filter chip bar for reviews.
class ReviewFilterBar extends StatelessWidget {
  /// Current filter.
  final ReviewFilter filter;

  /// Rating stats for showing counts.
  final RatingStats? stats;

  /// Callback when filter changes.
  final ValueChanged<ReviewFilter>? onFilterChanged;

  const ReviewFilterBar({
    super.key,
    required this.filter,
    this.stats,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Sort dropdown
          PopupMenuButton<ReviewSortOption>(
            initialValue: filter.sortBy,
            onSelected: (value) {
              onFilterChanged?.call(filter.copyWith(sortBy: value));
            },
            itemBuilder: (context) => ReviewSortOption.values
                .map(
                  (option) => PopupMenuItem<ReviewSortOption>(
                    value: option,
                    child: Text(option.label),
                  ),
                )
                .toList(),
            child: Chip(
              avatar: const Icon(Icons.sort, size: 18),
              label: Text(filter.sortBy.label),
            ),
          ),
          const SizedBox(width: 8),

          // Rating filter chips
          ...List.generate(5, (index) {
            final rating = 5 - index;
            final isSelected = filter.rating == rating;
            final count = stats?.countForRating(rating) ?? 0;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$rating'),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.star,
                      size: 14,
                      color: isSelected
                          ? theme.colorScheme.onSecondaryContainer
                          : Colors.amber,
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '($count)',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ],
                ),
                onSelected: (selected) {
                  onFilterChanged?.call(
                    filter.copyWith(
                      rating: selected ? rating : null,
                      clearRating: !selected,
                    ),
                  );
                },
              ),
            );
          }),

          // Verified only
          FilterChip(
            selected: filter.verifiedOnly,
            avatar: filter.verifiedOnly
                ? null
                : const Icon(Icons.verified_outlined, size: 18),
            label: const Text('Verified'),
            onSelected: (selected) {
              onFilterChanged?.call(filter.copyWith(verifiedOnly: selected));
            },
          ),
          const SizedBox(width: 8),

          // With images only
          FilterChip(
            selected: filter.withImagesOnly,
            avatar: filter.withImagesOnly
                ? null
                : const Icon(Icons.image_outlined, size: 18),
            label: const Text('With Photos'),
            onSelected: (selected) {
              onFilterChanged?.call(filter.copyWith(withImagesOnly: selected));
            },
          ),
        ],
      ),
    );
  }
}

/// A connected review filter bar.
class ConnectedReviewFilterBar extends ConsumerWidget {
  /// Product ID.
  final String productId;

  const ConnectedReviewFilterBar({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(reviewFilterProvider(productId));
    final stats = ref.watch(ratingStatsProvider(productId));
    final notifier = ref.read(reviewsNotifierProvider.notifier);

    return ReviewFilterBar(
      filter: filter,
      stats: stats,
      onFilterChanged: (newFilter) => notifier.setFilter(productId, newFilter),
    );
  }
}

/// A form widget for writing a review.
class WriteReviewForm extends StatefulWidget {
  /// Product ID.
  final String productId;

  /// User ID.
  final String userId;

  /// User name.
  final String? userName;

  /// Callback when review is submitted.
  final Future<bool> Function(Review review)? onSubmit;

  /// Callback when cancelled.
  final VoidCallback? onCancel;

  /// Initial rating.
  final double initialRating;

  /// Whether to allow image upload.
  final bool allowImages;

  /// Callback to pick images.
  final Future<List<String>> Function()? onPickImages;

  const WriteReviewForm({
    super.key,
    required this.productId,
    required this.userId,
    this.userName,
    this.onSubmit,
    this.onCancel,
    this.initialRating = 0,
    this.allowImages = true,
    this.onPickImages,
  });

  @override
  State<WriteReviewForm> createState() => _WriteReviewFormState();
}

class _WriteReviewFormState extends State<WriteReviewForm> {
  late double _rating;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<String> _images = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final review = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: widget.productId,
      userId: widget.userId,
      userName: widget.userName,
      rating: _rating,
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      content: _contentController.text.trim(),
      images: _images,
      createdAt: DateTime.now(),
    );

    final success = await widget.onSubmit?.call(review) ?? false;

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
        widget.onCancel?.call();
      }
    }
  }

  Future<void> _pickImages() async {
    if (widget.onPickImages != null) {
      final images = await widget.onPickImages!();
      if (mounted && images.isNotEmpty) {
        setState(() => _images.addAll(images));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Rating
        Text(
          'Your Rating',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: StarRatingInput(
            rating: _rating,
            size: 40,
            onRatingChanged: (value) => setState(() => _rating = value),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Review Title (optional)',
            hintText: 'Summarize your experience',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),

        // Content
        TextField(
          controller: _contentController,
          decoration: const InputDecoration(
            labelText: 'Your Review',
            hintText: 'Share your experience with this product',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),

        // Images
        if (widget.allowImages) ...[
          Row(
            children: [
              Text(
                'Add Photos',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (widget.onPickImages != null)
                TextButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Add'),
                ),
            ],
          ),
          if (_images.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _images[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _images.removeAt(index));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],

        // Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : widget.onCancel,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A connected write review form.
class ConnectedWriteReviewForm extends ConsumerWidget {
  /// Product ID.
  final String productId;

  /// User ID.
  final String userId;

  /// User name.
  final String? userName;

  /// Callback when cancelled.
  final VoidCallback? onCancel;

  /// Callback to pick images.
  final Future<List<String>> Function()? onPickImages;

  const ConnectedWriteReviewForm({
    super.key,
    required this.productId,
    required this.userId,
    this.userName,
    this.onCancel,
    this.onPickImages,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(reviewsNotifierProvider.notifier);

    return WriteReviewForm(
      productId: productId,
      userId: userId,
      userName: userName,
      onSubmit: (review) => notifier.submitReview(review),
      onCancel: onCancel,
      onPickImages: onPickImages,
    );
  }
}

/// A complete reviews section widget.
class ReviewsSectionWidget extends StatelessWidget {
  /// Rating statistics.
  final RatingStats stats;

  /// Reviews to display.
  final List<Review> reviews;

  /// Current filter.
  final ReviewFilter filter;

  /// Whether loading.
  final bool isLoading;

  /// Error message.
  final String? error;

  /// Callback when filter changes.
  final ValueChanged<ReviewFilter>? onFilterChanged;

  /// Callback when load more is pressed.
  final VoidCallback? onLoadMore;

  /// Callback when write review is pressed.
  final VoidCallback? onWriteReview;

  /// Callback when vote is pressed.
  final void Function(Review review, bool helpful)? onVote;

  /// Whether there are more reviews.
  final bool hasMore;

  /// Maximum reviews to show initially.
  final int initialDisplayCount;

  const ReviewsSectionWidget({
    super.key,
    required this.stats,
    required this.reviews,
    required this.filter,
    this.isLoading = false,
    this.error,
    this.onFilterChanged,
    this.onLoadMore,
    this.onWriteReview,
    this.onVote,
    this.hasMore = false,
    this.initialDisplayCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Reviews',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (onWriteReview != null)
              TextButton.icon(
                onPressed: onWriteReview,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Write Review'),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Rating summary
        if (stats.hasReviews) ...[
          RatingSummaryWidget(stats: stats),
          const SizedBox(height: 16),

          // Filter bar
          ReviewFilterBar(
            filter: filter,
            stats: stats,
            onFilterChanged: onFilterChanged,
          ),
          const SizedBox(height: 16),
        ],

        // Error
        if (error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Reviews list
        ReviewListWidget(
          reviews: reviews,
          onVote: onVote,
        ),

        // Loading indicator
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),

        // Load more button
        if (hasMore && !isLoading && reviews.isNotEmpty) ...[
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: onLoadMore,
              child: const Text('Load More Reviews'),
            ),
          ),
        ],
      ],
    );
  }
}

/// A connected reviews section widget.
class ConnectedReviewsSectionWidget extends ConsumerWidget {
  /// Product ID.
  final String productId;

  /// Callback when write review is pressed.
  final VoidCallback? onWriteReview;

  const ConnectedReviewsSectionWidget({
    super.key,
    required this.productId,
    this.onWriteReview,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewsProvider(productId));
    final notifier = ref.read(reviewsNotifierProvider.notifier);

    return ReviewsSectionWidget(
      stats: state.stats ?? RatingStats.empty(productId),
      reviews: state.filteredReviews,
      filter: state.filter,
      isLoading: state.isLoading,
      error: state.error,
      hasMore: state.hasMore,
      onFilterChanged: (filter) => notifier.setFilter(productId, filter),
      onLoadMore: () => notifier.loadReviews(productId),
      onWriteReview: onWriteReview,
      onVote: (review, helpful) => notifier.vote(productId, review.id, helpful),
    );
  }
}
