import 'package:equatable/equatable.dart';

import 'money.dart';
import 'product.dart';

/// Represents a wishlist containing products.
class Wishlist extends Equatable {
  /// Unique identifier.
  final String id;

  /// User ID who owns this wishlist.
  final String? userId;

  /// Wishlist name (for multiple wishlists support).
  final String name;

  /// Description.
  final String? description;

  /// Items in the wishlist.
  final List<WishlistItem> items;

  /// Whether this is the default wishlist.
  final bool isDefault;

  /// Whether this wishlist is public/shareable.
  final bool isPublic;

  /// Share URL for public wishlists.
  final String? shareUrl;

  /// Created timestamp.
  final DateTime createdAt;

  /// Last updated timestamp.
  final DateTime updatedAt;

  /// Metadata for custom data.
  final Map<String, dynamic>? metadata;

  /// Creates a [Wishlist].
  const Wishlist({
    required this.id,
    this.userId,
    this.name = 'My Wishlist',
    this.description,
    this.items = const [],
    this.isDefault = true,
    this.isPublic = false,
    this.shareUrl,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Creates an empty wishlist.
  factory Wishlist.empty({String? userId}) {
    final now = DateTime.now();
    return Wishlist(
      id: 'default',
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Number of items in the wishlist.
  int get itemCount => items.length;

  /// Whether the wishlist is empty.
  bool get isEmpty => items.isEmpty;

  /// Whether the wishlist is not empty.
  bool get isNotEmpty => items.isNotEmpty;

  /// All product IDs in the wishlist.
  List<String> get productIds => items.map((i) => i.productId).toList();

  /// Checks if a product is in the wishlist.
  bool containsProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  /// Gets a wishlist item by product ID.
  WishlistItem? getItem(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  /// Creates a copy with updated fields.
  Wishlist copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<WishlistItem>? items,
    bool? isDefault,
    bool? isPublic,
    String? shareUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Wishlist(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      isDefault: isDefault ?? this.isDefault,
      isPublic: isPublic ?? this.isPublic,
      shareUrl: shareUrl ?? this.shareUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Adds a product to the wishlist.
  Wishlist addProduct(Product product, {String? note}) {
    if (containsProduct(product.id)) return this;

    final newItem = WishlistItem(
      id: '${id}_${product.id}',
      productId: product.id,
      product: product,
      note: note,
      addedAt: DateTime.now(),
    );

    return copyWith(
      items: [...items, newItem],
      updatedAt: DateTime.now(),
    );
  }

  /// Removes a product from the wishlist.
  Wishlist removeProduct(String productId) {
    return copyWith(
      items: items.where((item) => item.productId != productId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Updates a wishlist item.
  Wishlist updateItem(String productId, WishlistItem Function(WishlistItem) update) {
    return copyWith(
      items: items.map((item) {
        if (item.productId == productId) {
          return update(item);
        }
        return item;
      }).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Clears all items from the wishlist.
  Wishlist clear() {
    return copyWith(
      items: [],
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        items,
        isDefault,
        isPublic,
        shareUrl,
        createdAt,
        updatedAt,
        metadata,
      ];
}

/// Represents an item in a wishlist.
class WishlistItem extends Equatable {
  /// Unique identifier.
  final String id;

  /// Product ID.
  final String productId;

  /// The product (may be null if only ID is known).
  final Product? product;

  /// User note for this item.
  final String? note;

  /// Variant ID if applicable.
  final String? variantId;

  /// Priority (for sorting).
  final int priority;

  /// When the item was added.
  final DateTime addedAt;

  /// Whether the item has been purchased.
  final bool isPurchased;

  /// Purchased date.
  final DateTime? purchasedAt;

  /// Notification settings.
  final WishlistNotification? notification;

  /// Metadata for custom data.
  final Map<String, dynamic>? metadata;

  /// Creates a [WishlistItem].
  const WishlistItem({
    required this.id,
    required this.productId,
    this.product,
    this.note,
    this.variantId,
    this.priority = 0,
    required this.addedAt,
    this.isPurchased = false,
    this.purchasedAt,
    this.notification,
    this.metadata,
  });

  /// Product name (from product or null).
  String? get productName => product?.name;

  /// Product image URL.
  String? get productImageUrl => product?.images.firstOrNull?.url;

  /// Current price.
  Money? get currentPrice => product?.price;

  /// Whether the product is on sale.
  bool get isOnSale => product?.isOnSale ?? false;

  /// Creates a copy with updated fields.
  WishlistItem copyWith({
    String? id,
    String? productId,
    Product? product,
    String? note,
    String? variantId,
    int? priority,
    DateTime? addedAt,
    bool? isPurchased,
    DateTime? purchasedAt,
    WishlistNotification? notification,
    Map<String, dynamic>? metadata,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      note: note ?? this.note,
      variantId: variantId ?? this.variantId,
      priority: priority ?? this.priority,
      addedAt: addedAt ?? this.addedAt,
      isPurchased: isPurchased ?? this.isPurchased,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      notification: notification ?? this.notification,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Marks as purchased.
  WishlistItem markPurchased() {
    return copyWith(
      isPurchased: true,
      purchasedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        product,
        note,
        variantId,
        priority,
        addedAt,
        isPurchased,
        purchasedAt,
        notification,
        metadata,
      ];
}

/// Notification preferences for wishlist items.
class WishlistNotification extends Equatable {
  /// Notify when price drops.
  final bool onPriceDrop;

  /// Price drop threshold percentage.
  final double? priceDropThreshold;

  /// Notify when back in stock.
  final bool onBackInStock;

  /// Notify on sale.
  final bool onSale;

  /// Creates [WishlistNotification].
  const WishlistNotification({
    this.onPriceDrop = false,
    this.priceDropThreshold,
    this.onBackInStock = false,
    this.onSale = false,
  });

  /// Default notification settings.
  static const WishlistNotification defaults = WishlistNotification(
    onPriceDrop: true,
    priceDropThreshold: 10,
    onBackInStock: true,
    onSale: true,
  );

  /// All notifications enabled.
  static const WishlistNotification all = WishlistNotification(
    onPriceDrop: true,
    onBackInStock: true,
    onSale: true,
  );

  /// No notifications.
  static const WishlistNotification none = WishlistNotification();

  WishlistNotification copyWith({
    bool? onPriceDrop,
    double? priceDropThreshold,
    bool? onBackInStock,
    bool? onSale,
  }) {
    return WishlistNotification(
      onPriceDrop: onPriceDrop ?? this.onPriceDrop,
      priceDropThreshold: priceDropThreshold ?? this.priceDropThreshold,
      onBackInStock: onBackInStock ?? this.onBackInStock,
      onSale: onSale ?? this.onSale,
    );
  }

  @override
  List<Object?> get props => [
        onPriceDrop,
        priceDropThreshold,
        onBackInStock,
        onSale,
      ];
}
