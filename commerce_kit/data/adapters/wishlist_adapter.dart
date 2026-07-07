import '../../core/models/product.dart';
import '../../core/models/wishlist.dart';

/// Abstract adapter for converting API responses to [Wishlist] models.
///
/// Implement this interface to map your specific API response format
/// to the commerce kit's internal [Wishlist] model.
///
/// ## Usage
///
/// ```dart
/// class MyWishlistAdapter extends WishlistAdapter<MyApiWishlist> {
///   @override
///   Wishlist fromResponse(MyApiWishlist response) {
///     return Wishlist(
///       id: response.wishlistId,
///       name: response.name,
///       items: response.items.map((i) => WishlistItem(...)).toList(),
///       createdAt: DateTime.parse(response.created),
///       updatedAt: DateTime.parse(response.updated),
///     );
///   }
/// }
/// ```
abstract class WishlistAdapter<T> {
  /// Converts an API response to a [Wishlist].
  Wishlist fromResponse(T response);

  /// Converts a [Wishlist] back to an API response format.
  T toResponse(Wishlist wishlist) {
    throw UnimplementedError('toResponse not implemented');
  }

  /// Safely converts an API response, returning null on error.
  Wishlist? tryFromResponse(T response) {
    try {
      return fromResponse(response);
    } catch (_) {
      return null;
    }
  }
}

/// Abstract adapter for converting API responses to [WishlistItem] models.
abstract class WishlistItemAdapter<T> {
  /// Converts an API response to a [WishlistItem].
  WishlistItem fromResponse(T response);

  /// Converts a [WishlistItem] back to an API response format.
  T toResponse(WishlistItem item) {
    throw UnimplementedError('toResponse not implemented');
  }

  /// Converts a list of API responses to a list of [WishlistItem]s.
  List<WishlistItem> fromResponseList(List<T> responses) {
    return responses.map(fromResponse).toList();
  }
}

/// Adapter for Map< String, dynamic> (JSON) to [Wishlist].
///
/// ## Default JSON Structure
///
/// ```json
/// {
///   "id": "wishlist_123",
///   "user_id": "user_456",
///   "name": "My Wishlist",
///   "description": "Things I want to buy",
///   "items": [...],
///   "is_default": true,
///   "is_public": false,
///   "share_url": "https://example.com/wishlist/123",
///   "created_at": "2025-01-15T10:30:00Z",
///   "updated_at": "2025-01-20T14:00:00Z"
/// }
/// ```
class JsonWishlistAdapter extends WishlistAdapter<Map<String, dynamic>> {
  /// Field mappings for custom JSON structures.
  final WishlistFieldMapping? fieldMapping;

  /// Optional transformer to preprocess JSON before conversion.
  final Map<String, dynamic> Function(Map<String, dynamic>)? transformer;

  /// Item adapter for converting wishlist items.
  final JsonWishlistItemAdapter? itemAdapter;

  JsonWishlistAdapter({
    this.fieldMapping,
    this.transformer,
    this.itemAdapter,
  });

  @override
  Wishlist fromResponse(Map<String, dynamic> response) {
    final json = transformer != null ? transformer!(response) : response;
    final mapping = fieldMapping ?? WishlistFieldMapping.defaults;
    final adapter = itemAdapter ?? JsonWishlistItemAdapter();

    return Wishlist(
      id: json[mapping.id]?.toString() ?? '',
      userId: json[mapping.userId]?.toString(),
      name: json[mapping.name]?.toString() ?? 'My Wishlist',
      description: json[mapping.description]?.toString(),
      items: _parseItems(json[mapping.items], adapter),
      isDefault: json[mapping.isDefault] == true,
      isPublic: json[mapping.isPublic] == true,
      shareUrl: json[mapping.shareUrl]?.toString(),
      createdAt: _parseDateTime(json[mapping.createdAt]) ?? DateTime.now(),
      updatedAt: _parseDateTime(json[mapping.updatedAt]) ?? DateTime.now(),
      metadata: json[mapping.metadata] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toResponse(Wishlist wishlist) {
    final mapping = fieldMapping ?? WishlistFieldMapping.defaults;
    final adapter = itemAdapter ?? JsonWishlistItemAdapter();

    return {
      mapping.id: wishlist.id,
      if (wishlist.userId != null) mapping.userId: wishlist.userId,
      mapping.name: wishlist.name,
      if (wishlist.description != null)
        mapping.description: wishlist.description,
      mapping.items: wishlist.items.map((i) => adapter.toResponse(i)).toList(),
      mapping.isDefault: wishlist.isDefault,
      mapping.isPublic: wishlist.isPublic,
      if (wishlist.shareUrl != null) mapping.shareUrl: wishlist.shareUrl,
      mapping.createdAt: wishlist.createdAt.toIso8601String(),
      mapping.updatedAt: wishlist.updatedAt.toIso8601String(),
      if (wishlist.metadata != null) mapping.metadata: wishlist.metadata,
    };
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  List<WishlistItem> _parseItems(
    dynamic value,
    JsonWishlistItemAdapter adapter,
  ) {
    if (value == null) return [];
    if (value is! List) return [];
    return value
        .whereType<Map<String, dynamic>>()
        .map((json) => adapter.fromResponse(json))
        .toList();
  }
}

/// Adapter for Map< String, dynamic> (JSON) to [WishlistItem].
///
/// ## Default JSON Structure
///
/// ```json
/// {
///   "id": "item_123",
///   "product_id": "prod_456",
///   "product": {...},
///   "note": "Birthday gift idea",
///   "variant_id": "var_789",
///   "priority": 1,
///   "added_at": "2025-01-15T10:30:00Z",
///   "is_purchased": false,
///   "notification": {
///     "on_price_drop": true,
///     "price_drop_threshold": 10,
///     "on_back_in_stock": true,
///     "on_sale": true
///   }
/// }
/// ```
class JsonWishlistItemAdapter
    extends WishlistItemAdapter<Map<String, dynamic>> {
  /// Field mappings for custom JSON structures.
  final WishlistItemFieldMapping? fieldMapping;

  /// Optional transformer to preprocess JSON before conversion.
  final Map<String, dynamic> Function(Map<String, dynamic>)? transformer;

  JsonWishlistItemAdapter({this.fieldMapping, this.transformer});

  @override
  WishlistItem fromResponse(Map<String, dynamic> response) {
    final json = transformer != null ? transformer!(response) : response;
    final mapping = fieldMapping ?? WishlistItemFieldMapping.defaults;

    return WishlistItem(
      id: json[mapping.id]?.toString() ?? '',
      productId: json[mapping.productId]?.toString() ?? '',
      product: _parseProduct(json[mapping.product]),
      note: json[mapping.note]?.toString(),
      variantId: json[mapping.variantId]?.toString(),
      priority: _parseInt(json[mapping.priority]) ?? 0,
      addedAt: _parseDateTime(json[mapping.addedAt]) ?? DateTime.now(),
      isPurchased: json[mapping.isPurchased] == true,
      purchasedAt: _parseDateTime(json[mapping.purchasedAt]),
      notification: _parseNotification(json[mapping.notification]),
      metadata: json[mapping.metadata] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toResponse(WishlistItem item) {
    final mapping = fieldMapping ?? WishlistItemFieldMapping.defaults;

    return {
      mapping.id: item.id,
      mapping.productId: item.productId,
      if (item.product != null) mapping.product: item.product!.toJson(),
      if (item.note != null) mapping.note: item.note,
      if (item.variantId != null) mapping.variantId: item.variantId,
      mapping.priority: item.priority,
      mapping.addedAt: item.addedAt.toIso8601String(),
      mapping.isPurchased: item.isPurchased,
      if (item.purchasedAt != null)
        mapping.purchasedAt: item.purchasedAt!.toIso8601String(),
      if (item.notification != null)
        mapping.notification: {
          'on_price_drop': item.notification!.onPriceDrop,
          'price_drop_threshold': item.notification!.priceDropThreshold,
          'on_back_in_stock': item.notification!.onBackInStock,
          'on_sale': item.notification!.onSale,
        },
      if (item.metadata != null) mapping.metadata: item.metadata,
    };
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  Product? _parseProduct(dynamic value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic>) return null;
    try {
      return Product.fromJson(value);
    } catch (_) {
      return null;
    }
  }

  WishlistNotification? _parseNotification(dynamic value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic>) return null;

    return WishlistNotification(
      onPriceDrop: value['on_price_drop'] == true,
      priceDropThreshold: _parseDouble(value['price_drop_threshold']),
      onBackInStock: value['on_back_in_stock'] == true,
      onSale: value['on_sale'] == true,
    );
  }
}

/// Field mapping for [Wishlist] JSON conversion.
class WishlistFieldMapping {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String items;
  final String isDefault;
  final String isPublic;
  final String shareUrl;
  final String createdAt;
  final String updatedAt;
  final String metadata;

  const WishlistFieldMapping({
    this.id = 'id',
    this.userId = 'user_id',
    this.name = 'name',
    this.description = 'description',
    this.items = 'items',
    this.isDefault = 'is_default',
    this.isPublic = 'is_public',
    this.shareUrl = 'share_url',
    this.createdAt = 'created_at',
    this.updatedAt = 'updated_at',
    this.metadata = 'metadata',
  });

  /// Default field mapping using snake_case.
  static const defaults = WishlistFieldMapping();

  /// CamelCase field mapping.
  static const camelCase = WishlistFieldMapping(
    userId: 'userId',
    isDefault: 'isDefault',
    isPublic: 'isPublic',
    shareUrl: 'shareUrl',
    createdAt: 'createdAt',
    updatedAt: 'updatedAt',
  );
}

/// Field mapping for [WishlistItem] JSON conversion.
class WishlistItemFieldMapping {
  final String id;
  final String productId;
  final String product;
  final String note;
  final String variantId;
  final String priority;
  final String addedAt;
  final String isPurchased;
  final String purchasedAt;
  final String notification;
  final String metadata;

  const WishlistItemFieldMapping({
    this.id = 'id',
    this.productId = 'product_id',
    this.product = 'product',
    this.note = 'note',
    this.variantId = 'variant_id',
    this.priority = 'priority',
    this.addedAt = 'added_at',
    this.isPurchased = 'is_purchased',
    this.purchasedAt = 'purchased_at',
    this.notification = 'notification',
    this.metadata = 'metadata',
  });

  /// Default field mapping using snake_case.
  static const defaults = WishlistItemFieldMapping();

  /// CamelCase field mapping.
  static const camelCase = WishlistItemFieldMapping(
    productId: 'productId',
    variantId: 'variantId',
    addedAt: 'addedAt',
    isPurchased: 'isPurchased',
    purchasedAt: 'purchasedAt',
  );
}
