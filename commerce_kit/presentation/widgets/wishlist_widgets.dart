import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/product.dart';
import '../../core/models/wishlist.dart';
import '../providers/wishlist_provider.dart';

/// A button to toggle wishlist status.
class WishlistButton extends StatelessWidget {
  /// Whether the item is in the wishlist.
  final bool isInWishlist;

  /// Callback when toggled.
  final VoidCallback? onToggle;

  /// Button size.
  final double size;

  /// Icon when in wishlist.
  final IconData activeIcon;

  /// Icon when not in wishlist.
  final IconData inactiveIcon;

  /// Active color.
  final Color? activeColor;

  /// Inactive color.
  final Color? inactiveColor;

  /// Whether to show as outlined button.
  final bool outlined;

  const WishlistButton({
    super.key,
    required this.isInWishlist,
    this.onToggle,
    this.size = 24,
    this.activeIcon = Icons.favorite,
    this.inactiveIcon = Icons.favorite_border,
    this.activeColor,
    this.inactiveColor,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isInWishlist
        ? (activeColor ?? Colors.red)
        : (inactiveColor ?? theme.colorScheme.onSurfaceVariant);

    if (outlined) {
      return OutlinedButton(
        onPressed: onToggle,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(size / 3),
          minimumSize: Size(size * 1.5, size * 1.5),
        ),
        child: Icon(
          isInWishlist ? activeIcon : inactiveIcon,
          color: color,
          size: size,
        ),
      );
    }

    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        isInWishlist ? activeIcon : inactiveIcon,
        color: color,
        size: size,
      ),
    );
  }
}

/// A connected wishlist button.
class ConnectedWishlistButton extends ConsumerWidget {
  /// The product.
  final Product product;

  /// Button size.
  final double size;

  /// Active color.
  final Color? activeColor;

  /// Inactive color.
  final Color? inactiveColor;

  /// Whether to show as outlined button.
  final bool outlined;

  const ConnectedWishlistButton({
    super.key,
    required this.product,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInWishlist = ref.watch(isInWishlistProvider(product.id));
    final notifier = ref.read(wishlistProvider.notifier);

    return WishlistButton(
      isInWishlist: isInWishlist,
      size: size,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      outlined: outlined,
      onToggle: () => notifier.toggleProduct(product),
    );
  }
}

/// A badge showing wishlist count.
class WishlistBadge extends StatelessWidget {
  /// Number of items.
  final int count;

  /// Child widget.
  final Widget child;

  /// Badge color.
  final Color? badgeColor;

  /// Text color.
  final Color? textColor;

  /// Show badge when count is 0.
  final bool showWhenZero;

  const WishlistBadge({
    super.key,
    required this.count,
    required this.child,
    this.badgeColor,
    this.textColor,
    this.showWhenZero = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0 && !showWhenZero) {
      return child;
    }

    return Badge(
      label: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: badgeColor ?? Colors.red,
      child: child,
    );
  }
}

/// A connected wishlist badge.
class ConnectedWishlistBadge extends ConsumerWidget {
  /// Child widget.
  final Widget child;

  /// Badge color.
  final Color? badgeColor;

  /// Show badge when count is 0.
  final bool showWhenZero;

  const ConnectedWishlistBadge({
    super.key,
    required this.child,
    this.badgeColor,
    this.showWhenZero = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(wishlistItemCountProvider);

    return WishlistBadge(
      count: count,
      badgeColor: badgeColor,
      showWhenZero: showWhenZero,
      child: child,
    );
  }
}

/// A widget to display a wishlist item.
class WishlistItemWidget extends StatelessWidget {
  /// The wishlist item.
  final WishlistItem item;

  /// Callback when remove is pressed.
  final VoidCallback? onRemove;

  /// Callback when add to cart is pressed.
  final VoidCallback? onAddToCart;

  /// Callback when item is tapped.
  final VoidCallback? onTap;

  /// Show add to cart button.
  final bool showAddToCart;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  const WishlistItemWidget({
    super.key,
    required this.item,
    this.onRemove,
    this.onAddToCart,
    this.onTap,
    this.showAddToCart = true,
    this.backgroundColor,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = item.product;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.productImageUrl != null
                  ? Image.network(
                      item.productImageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                    )
                  : _buildPlaceholder(theme),
            ),
            const SizedBox(width: 12),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName ?? 'Unknown Product',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product != null) ...[
                    Row(
                      children: [
                        Text(
                          product.price.formatted,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (item.isOnSale && product.compareAtPrice != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            product.compareAtPrice!.formatted,
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (showAddToCart && product != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onAddToCart,
                            icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                            label: const Text('Add to Cart'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      if (showAddToCart && product != null)
                        const SizedBox(width: 8),
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// A widget to display the wishlist.
class WishlistListWidget extends StatelessWidget {
  /// Wishlist items.
  final List<WishlistItem> items;

  /// Callback when remove is pressed.
  final void Function(WishlistItem item)? onRemove;

  /// Callback when add to cart is pressed.
  final void Function(WishlistItem item)? onAddToCart;

  /// Callback when item is tapped.
  final void Function(WishlistItem item)? onItemTap;

  /// Empty state widget.
  final Widget? emptyWidget;

  /// Show add to cart button.
  final bool showAddToCart;

  /// Item spacing.
  final double spacing;

  const WishlistListWidget({
    super.key,
    required this.items,
    this.onRemove,
    this.onAddToCart,
    this.onItemTap,
    this.emptyWidget,
    this.showAddToCart = true,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyWidget ?? _buildEmptyState(context);
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        final item = items[index];
        return WishlistItemWidget(
          item: item,
          showAddToCart: showAddToCart,
          onRemove: onRemove != null ? () => onRemove!(item) : null,
          onAddToCart: onAddToCart != null ? () => onAddToCart!(item) : null,
          onTap: onItemTap != null ? () => onItemTap!(item) : null,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save items you love to your wishlist',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A connected wishlist list widget.
class ConnectedWishlistListWidget extends ConsumerWidget {
  /// Callback when add to cart is pressed.
  final void Function(WishlistItem item)? onAddToCart;

  /// Callback when item is tapped.
  final void Function(WishlistItem item)? onItemTap;

  /// Empty state widget.
  final Widget? emptyWidget;

  /// Show add to cart button.
  final bool showAddToCart;

  const ConnectedWishlistListWidget({
    super.key,
    this.onAddToCart,
    this.onItemTap,
    this.emptyWidget,
    this.showAddToCart = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(wishlistItemsProvider);
    final notifier = ref.read(wishlistProvider.notifier);

    return WishlistListWidget(
      items: items,
      showAddToCart: showAddToCart,
      emptyWidget: emptyWidget,
      onRemove: (item) => notifier.removeProduct(item.productId),
      onAddToCart: onAddToCart,
      onItemTap: onItemTap,
    );
  }
}

/// A compact wishlist summary widget.
class WishlistSummaryWidget extends StatelessWidget {
  /// Number of items.
  final int itemCount;

  /// Number of items on sale.
  final int onSaleCount;

  /// Callback to view wishlist.
  final VoidCallback? onViewWishlist;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  const WishlistSummaryWidget({
    super.key,
    required this.itemCount,
    this.onSaleCount = 0,
    this.onViewWishlist,
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
        children: [
          const Icon(
            Icons.favorite,
            color: Colors.red,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wishlist',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$itemCount item${itemCount == 1 ? '' : 's'}${onSaleCount > 0 ? ' • $onSaleCount on sale' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onViewWishlist != null)
            TextButton(
              onPressed: onViewWishlist,
              child: const Text('View'),
            ),
        ],
      ),
    );
  }
}

/// A connected wishlist summary widget.
class ConnectedWishlistSummaryWidget extends ConsumerWidget {
  /// Callback to view wishlist.
  final VoidCallback? onViewWishlist;

  /// Background color.
  final Color? backgroundColor;

  const ConnectedWishlistSummaryWidget({
    super.key,
    this.onViewWishlist,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(wishlistItemCountProvider);
    final onSaleItems = ref.watch(onSaleWishlistItemsProvider);

    return WishlistSummaryWidget(
      itemCount: itemCount,
      onSaleCount: onSaleItems.length,
      onViewWishlist: onViewWishlist,
      backgroundColor: backgroundColor,
    );
  }
}
