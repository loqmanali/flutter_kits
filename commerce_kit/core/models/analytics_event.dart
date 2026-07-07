import 'package:equatable/equatable.dart';

import 'money.dart';

/// Base class for analytics events.
abstract class AnalyticsEvent extends Equatable {
  /// Event name.
  String get name;

  /// Event timestamp.
  final DateTime timestamp;

  /// Event parameters.
  Map<String, dynamic> get params;

  /// Creates an [AnalyticsEvent].
  AnalyticsEvent({DateTime? timestamp}) : timestamp = timestamp ?? DateTime.now();

  /// Converts to a map for analytics services.
  Map<String, dynamic> toMap() => {
        'event_name': name,
        'timestamp': timestamp.toIso8601String(),
        ...params,
      };

  @override
  List<Object?> get props => [name, timestamp, params];
}

// ═══════════════════════════════════════════════════════════════════════════
// PRODUCT EVENTS
// ═══════════════════════════════════════════════════════════════════════════

/// Event when a product is viewed.
class ProductViewedEvent extends AnalyticsEvent {
  final String productId;
  final String productName;
  final String? categoryId;
  final String? categoryName;
  final Money? price;
  final String? source;

  ProductViewedEvent({
    required this.productId,
    required this.productName,
    this.categoryId,
    this.categoryName,
    this.price,
    this.source,
    super.timestamp,
  });

  @override
  String get name => 'product_viewed';

  @override
  Map<String, dynamic> get params => {
        'product_id': productId,
        'product_name': productName,
        if (categoryId != null) 'category_id': categoryId,
        if (categoryName != null) 'category_name': categoryName,
        if (price != null) 'price': price!.amount,
        if (price != null) 'currency': price!.currency,
        if (source != null) 'source': source,
      };
}

/// Event when products are listed/searched.
class ProductListViewedEvent extends AnalyticsEvent {
  final String? listId;
  final String? listName;
  final List<String> productIds;
  final String? categoryId;
  final String? searchQuery;
  final int itemCount;

  ProductListViewedEvent({
    this.listId,
    this.listName,
    required this.productIds,
    this.categoryId,
    this.searchQuery,
    int? itemCount,
    super.timestamp,
  }) : itemCount = itemCount ?? productIds.length;

  @override
  String get name => 'product_list_viewed';

  @override
  Map<String, dynamic> get params => {
        if (listId != null) 'list_id': listId,
        if (listName != null) 'list_name': listName,
        'product_ids': productIds,
        'item_count': itemCount,
        if (categoryId != null) 'category_id': categoryId,
        if (searchQuery != null) 'search_query': searchQuery,
      };
}

/// Event when a product is clicked from a list.
class ProductClickedEvent extends AnalyticsEvent {
  final String productId;
  final String productName;
  final String? listId;
  final String? listName;
  final int? position;
  final Money? price;

  ProductClickedEvent({
    required this.productId,
    required this.productName,
    this.listId,
    this.listName,
    this.position,
    this.price,
    super.timestamp,
  });

  @override
  String get name => 'product_clicked';

  @override
  Map<String, dynamic> get params => {
        'product_id': productId,
        'product_name': productName,
        if (listId != null) 'list_id': listId,
        if (listName != null) 'list_name': listName,
        if (position != null) 'position': position,
        if (price != null) 'price': price!.amount,
        if (price != null) 'currency': price!.currency,
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// CART EVENTS
// ═══════════════════════════════════════════════════════════════════════════

/// Event when an item is added to cart.
class AddToCartEvent extends AnalyticsEvent {
  final String productId;
  final String productName;
  final int quantity;
  final Money price;
  final String? variantId;
  final String? categoryId;

  AddToCartEvent({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.variantId,
    this.categoryId,
    super.timestamp,
  });

  @override
  String get name => 'add_to_cart';

  @override
  Map<String, dynamic> get params => {
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'price': price.amount,
        'currency': price.currency,
        'value': (price * quantity).amount,
        if (variantId != null) 'variant_id': variantId,
        if (categoryId != null) 'category_id': categoryId,
      };
}

/// Event when an item is removed from cart.
class RemoveFromCartEvent extends AnalyticsEvent {
  final String productId;
  final String productName;
  final int quantity;
  final Money price;
  final String? variantId;

  RemoveFromCartEvent({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.variantId,
    super.timestamp,
  });

  @override
  String get name => 'remove_from_cart';

  @override
  Map<String, dynamic> get params => {
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'price': price.amount,
        'currency': price.currency,
        'value': (price * quantity).amount,
        if (variantId != null) 'variant_id': variantId,
      };
}

/// Event when cart is viewed.
class ViewCartEvent extends AnalyticsEvent {
  final Money cartValue;
  final int itemCount;
  final List<String> productIds;

  ViewCartEvent({
    required this.cartValue,
    required this.itemCount,
    required this.productIds,
    super.timestamp,
  });

  @override
  String get name => 'view_cart';

  @override
  Map<String, dynamic> get params => {
        'value': cartValue.amount,
        'currency': cartValue.currency,
        'item_count': itemCount,
        'product_ids': productIds,
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// CHECKOUT EVENTS
// ═══════════════════════════════════════════════════════════════════════════

/// Event when checkout is started.
class BeginCheckoutEvent extends AnalyticsEvent {
  final Money cartValue;
  final int itemCount;
  final String? couponCode;
  final List<String> productIds;

  BeginCheckoutEvent({
    required this.cartValue,
    required this.itemCount,
    this.couponCode,
    required this.productIds,
    super.timestamp,
  });

  @override
  String get name => 'begin_checkout';

  @override
  Map<String, dynamic> get params => {
        'value': cartValue.amount,
        'currency': cartValue.currency,
        'item_count': itemCount,
        'product_ids': productIds,
        if (couponCode != null) 'coupon': couponCode,
      };
}

/// Event when shipping info is added.
class AddShippingInfoEvent extends AnalyticsEvent {
  final Money cartValue;
  final String shippingTier;
  final String? couponCode;

  AddShippingInfoEvent({
    required this.cartValue,
    required this.shippingTier,
    this.couponCode,
    super.timestamp,
  });

  @override
  String get name => 'add_shipping_info';

  @override
  Map<String, dynamic> get params => {
        'value': cartValue.amount,
        'currency': cartValue.currency,
        'shipping_tier': shippingTier,
        if (couponCode != null) 'coupon': couponCode,
      };
}

/// Event when payment info is added.
class AddPaymentInfoEvent extends AnalyticsEvent {
  final Money cartValue;
  final String paymentType;
  final String? couponCode;

  AddPaymentInfoEvent({
    required this.cartValue,
    required this.paymentType,
    this.couponCode,
    super.timestamp,
  });

  @override
  String get name => 'add_payment_info';

  @override
  Map<String, dynamic> get params => {
        'value': cartValue.amount,
        'currency': cartValue.currency,
        'payment_type': paymentType,
        if (couponCode != null) 'coupon': couponCode,
      };
}

/// Event when a purchase is completed.
class PurchaseEvent extends AnalyticsEvent {
  final String transactionId;
  final Money value;
  final Money? shipping;
  final Money? tax;
  final String? couponCode;
  final int itemCount;
  final List<PurchaseItem> items;

  PurchaseEvent({
    required this.transactionId,
    required this.value,
    this.shipping,
    this.tax,
    this.couponCode,
    required this.itemCount,
    required this.items,
    super.timestamp,
  });

  @override
  String get name => 'purchase';

  @override
  Map<String, dynamic> get params => {
        'transaction_id': transactionId,
        'value': value.amount,
        'currency': value.currency,
        if (shipping != null) 'shipping': shipping!.amount,
        if (tax != null) 'tax': tax!.amount,
        if (couponCode != null) 'coupon': couponCode,
        'item_count': itemCount,
        'items': items.map((i) => i.toMap()).toList(),
      };
}

/// A purchase item for analytics.
class PurchaseItem extends Equatable {
  final String itemId;
  final String itemName;
  final String? categoryId;
  final String? categoryName;
  final int quantity;
  final Money price;
  final String? variantId;

  const PurchaseItem({
    required this.itemId,
    required this.itemName,
    this.categoryId,
    this.categoryName,
    required this.quantity,
    required this.price,
    this.variantId,
  });

  Map<String, dynamic> toMap() => {
        'item_id': itemId,
        'item_name': itemName,
        if (categoryId != null) 'category_id': categoryId,
        if (categoryName != null) 'category_name': categoryName,
        'quantity': quantity,
        'price': price.amount,
        if (variantId != null) 'variant_id': variantId,
      };

  @override
  List<Object?> get props => [
        itemId,
        itemName,
        categoryId,
        categoryName,
        quantity,
        price,
        variantId,
      ];
}

/// Event when a refund occurs.
class RefundEvent extends AnalyticsEvent {
  final String transactionId;
  final Money value;
  final String? reason;

  RefundEvent({
    required this.transactionId,
    required this.value,
    this.reason,
    super.timestamp,
  });

  @override
  String get name => 'refund';

  @override
  Map<String, dynamic> get params => {
        'transaction_id': transactionId,
        'value': value.amount,
        'currency': value.currency,
        if (reason != null) 'reason': reason,
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// PROMOTION EVENTS
// ═══════════════════════════════════════════════════════════════════════════

/// Event when a promotion is viewed.
class PromotionViewedEvent extends AnalyticsEvent {
  final String promotionId;
  final String promotionName;
  final String? creativeName;
  final String? creativeSlot;
  final String? locationId;

  PromotionViewedEvent({
    required this.promotionId,
    required this.promotionName,
    this.creativeName,
    this.creativeSlot,
    this.locationId,
    super.timestamp,
  });

  @override
  String get name => 'view_promotion';

  @override
  Map<String, dynamic> get params => {
        'promotion_id': promotionId,
        'promotion_name': promotionName,
        if (creativeName != null) 'creative_name': creativeName,
        if (creativeSlot != null) 'creative_slot': creativeSlot,
        if (locationId != null) 'location_id': locationId,
      };
}

/// Event when a promotion is clicked.
class PromotionClickedEvent extends AnalyticsEvent {
  final String promotionId;
  final String promotionName;
  final String? creativeName;
  final String? creativeSlot;

  PromotionClickedEvent({
    required this.promotionId,
    required this.promotionName,
    this.creativeName,
    this.creativeSlot,
    super.timestamp,
  });

  @override
  String get name => 'select_promotion';

  @override
  Map<String, dynamic> get params => {
        'promotion_id': promotionId,
        'promotion_name': promotionName,
        if (creativeName != null) 'creative_name': creativeName,
        if (creativeSlot != null) 'creative_slot': creativeSlot,
      };
}

/// Event when a coupon is applied.
class CouponAppliedEvent extends AnalyticsEvent {
  final String couponCode;
  final Money? discountValue;
  final bool success;
  final String? failureReason;

  CouponAppliedEvent({
    required this.couponCode,
    this.discountValue,
    required this.success,
    this.failureReason,
    super.timestamp,
  });

  @override
  String get name => success ? 'coupon_applied' : 'coupon_failed';

  @override
  Map<String, dynamic> get params => {
        'coupon_code': couponCode,
        'success': success,
        if (discountValue != null) 'discount_value': discountValue!.amount,
        if (failureReason != null) 'failure_reason': failureReason,
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// WISHLIST EVENTS
// ═══════════════════════════════════════════════════════════════════════════

/// Event when a product is added to wishlist.
class AddToWishlistEvent extends AnalyticsEvent {
  final String productId;
  final String productName;
  final Money? price;
  final String? categoryId;

  AddToWishlistEvent({
    required this.productId,
    required this.productName,
    this.price,
    this.categoryId,
    super.timestamp,
  });

  @override
  String get name => 'add_to_wishlist';

  @override
  Map<String, dynamic> get params => {
        'product_id': productId,
        'product_name': productName,
        if (price != null) 'price': price!.amount,
        if (price != null) 'currency': price!.currency,
        if (categoryId != null) 'category_id': categoryId,
      };
}

/// Event when a product is removed from wishlist.
class RemoveFromWishlistEvent extends AnalyticsEvent {
  final String productId;
  final String productName;

  RemoveFromWishlistEvent({
    required this.productId,
    required this.productName,
    super.timestamp,
  });

  @override
  String get name => 'remove_from_wishlist';

  @override
  Map<String, dynamic> get params => {
        'product_id': productId,
        'product_name': productName,
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// SEARCH EVENTS
// ═══════════════════════════════════════════════════════════════════════════

/// Event when a search is performed.
class SearchEvent extends AnalyticsEvent {
  final String searchTerm;
  final int resultCount;
  final List<String>? filters;

  SearchEvent({
    required this.searchTerm,
    required this.resultCount,
    this.filters,
    super.timestamp,
  });

  @override
  String get name => 'search';

  @override
  Map<String, dynamic> get params => {
        'search_term': searchTerm,
        'result_count': resultCount,
        if (filters != null) 'filters': filters,
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARE EVENT
// ═══════════════════════════════════════════════════════════════════════════

/// Event when content is shared.
class ShareEvent extends AnalyticsEvent {
  final String contentType;
  final String itemId;
  final String? method;

  ShareEvent({
    required this.contentType,
    required this.itemId,
    this.method,
    super.timestamp,
  });

  @override
  String get name => 'share';

  @override
  Map<String, dynamic> get params => {
        'content_type': contentType,
        'item_id': itemId,
        if (method != null) 'method': method,
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// CUSTOM EVENT
// ═══════════════════════════════════════════════════════════════════════════

/// A custom analytics event.
class CustomEvent extends AnalyticsEvent {
  final String eventName;
  final Map<String, dynamic> eventParams;

  CustomEvent({
    required this.eventName,
    this.eventParams = const {},
    super.timestamp,
  });

  @override
  String get name => eventName;

  @override
  Map<String, dynamic> get params => eventParams;
}
