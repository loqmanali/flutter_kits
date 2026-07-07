import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/analytics_event.dart';
import '../../core/models/cart.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/money.dart';
import '../../core/models/order.dart';
import '../../core/models/product.dart';

/// Abstract interface for analytics services.
abstract class AnalyticsService {
  /// Logs an analytics event.
  Future<void> logEvent(AnalyticsEvent event);

  /// Sets a user property.
  Future<void> setUserProperty(String name, String? value);

  /// Sets the user ID.
  Future<void> setUserId(String? userId);

  /// Resets analytics data (e.g., on logout).
  Future<void> reset();
}

/// A no-op analytics service for testing/development.
class NoOpAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(AnalyticsEvent event) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> reset() async {}
}

/// An analytics service that prints to console.
class ConsoleAnalyticsService implements AnalyticsService {
  final bool enabled;

  ConsoleAnalyticsService({this.enabled = true});

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    if (!enabled) return;
    // ignore: avoid_print
    print('[Analytics] ${event.name}: ${event.params}');
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    if (!enabled) return;
    // ignore: avoid_print
    print('[Analytics] User Property: $name = $value');
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!enabled) return;
    // ignore: avoid_print
    print('[Analytics] User ID: $userId');
  }

  @override
  Future<void> reset() async {
    if (!enabled) return;
    // ignore: avoid_print
    print('[Analytics] Reset');
  }
}

/// A composite analytics service that forwards to multiple services.
class CompositeAnalyticsService implements AnalyticsService {
  final List<AnalyticsService> services;

  CompositeAnalyticsService(this.services);

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    await Future.wait(services.map((s) => s.logEvent(event)));
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    await Future.wait(services.map((s) => s.setUserProperty(name, value)));
  }

  @override
  Future<void> setUserId(String? userId) async {
    await Future.wait(services.map((s) => s.setUserId(userId)));
  }

  @override
  Future<void> reset() async {
    await Future.wait(services.map((s) => s.reset()));
  }
}

/// Provider for the analytics service.
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  // Default to no-op. Override this in your app.
  return NoOpAnalyticsService();
});

/// Notifier for analytics operations.
class AnalyticsNotifier extends Notifier<void> {
  AnalyticsService get _service => ref.read(analyticsServiceProvider);

  @override
  void build() {}

  /// Logs a raw analytics event.
  Future<void> logEvent(AnalyticsEvent event) async {
    await _service.logEvent(event);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRODUCT EVENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Logs when a product is viewed.
  Future<void> logProductViewed({
    required Product product,
    String? categoryId,
    String? categoryName,
    String? source,
  }) async {
    await _service.logEvent(
      ProductViewedEvent(
        productId: product.id,
        productName: product.name,
        categoryId: categoryId,
        categoryName: categoryName,
        price: product.price,
        source: source,
      ),
    );
  }

  /// Logs when a product list is viewed.
  Future<void> logProductListViewed({
    String? listId,
    String? listName,
    required List<Product> products,
    String? categoryId,
    String? searchQuery,
  }) async {
    await _service.logEvent(
      ProductListViewedEvent(
        listId: listId,
        listName: listName,
        productIds: products.map((p) => p.id).toList(),
        categoryId: categoryId,
        searchQuery: searchQuery,
      ),
    );
  }

  /// Logs when a product is clicked from a list.
  Future<void> logProductClicked({
    required Product product,
    String? listId,
    String? listName,
    int? position,
  }) async {
    await _service.logEvent(
      ProductClickedEvent(
        productId: product.id,
        productName: product.name,
        listId: listId,
        listName: listName,
        position: position,
        price: product.price,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CART EVENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Logs when an item is added to cart.
  Future<void> logAddToCart({
    required Product product,
    required int quantity,
    String? variantId,
    String? categoryId,
  }) async {
    await _service.logEvent(
      AddToCartEvent(
        productId: product.id,
        productName: product.name,
        quantity: quantity,
        price: product.price,
        variantId: variantId,
        categoryId: categoryId,
      ),
    );
  }

  /// Logs when an item is removed from cart.
  Future<void> logRemoveFromCart({
    required CartItem item,
  }) async {
    await _service.logEvent(
      RemoveFromCartEvent(
        productId: item.productId,
        productName: item.name,
        quantity: item.quantity,
        price: item.unitPrice,
        variantId: item.variantId,
      ),
    );
  }

  /// Logs when cart is viewed.
  Future<void> logViewCart({
    required Cart cart,
  }) async {
    await _service.logEvent(
      ViewCartEvent(
        cartValue: cart.subtotal,
        itemCount: cart.itemCount,
        productIds: cart.items.map((i) => i.productId).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CHECKOUT EVENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Logs when checkout begins.
  Future<void> logBeginCheckout({
    required Cart cart,
    String? couponCode,
  }) async {
    await _service.logEvent(
      BeginCheckoutEvent(
        cartValue: cart.subtotal,
        itemCount: cart.itemCount,
        couponCode: couponCode,
        productIds: cart.items.map((i) => i.productId).toList(),
      ),
    );
  }

  /// Logs when shipping info is added.
  Future<void> logAddShippingInfo({
    required Money cartValue,
    required String shippingTier,
    String? couponCode,
  }) async {
    await _service.logEvent(
      AddShippingInfoEvent(
        cartValue: cartValue,
        shippingTier: shippingTier,
        couponCode: couponCode,
      ),
    );
  }

  /// Logs when payment info is added.
  Future<void> logAddPaymentInfo({
    required Money cartValue,
    required String paymentType,
    String? couponCode,
  }) async {
    await _service.logEvent(
      AddPaymentInfoEvent(
        cartValue: cartValue,
        paymentType: paymentType,
        couponCode: couponCode,
      ),
    );
  }

  /// Logs when a purchase is completed.
  Future<void> logPurchase({
    required Order order,
  }) async {
    await _service.logEvent(
      PurchaseEvent(
        transactionId: order.id,
        value: order.summary.total,
        shipping: order.summary.shippingCost,
        tax: order.summary.tax,
        couponCode: order.couponCode,
        itemCount: order.itemCount,
        items: order.items
            .map(
              (item) => PurchaseItem(
                itemId: item.productId,
                itemName: item.name,
                quantity: item.quantity,
                price: item.unitPrice,
                variantId: item.variantId,
              ),
            )
            .toList(),
      ),
    );
  }

  /// Logs when a refund occurs.
  Future<void> logRefund({
    required String transactionId,
    required Money value,
    String? reason,
  }) async {
    await _service.logEvent(
      RefundEvent(
        transactionId: transactionId,
        value: value,
        reason: reason,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROMOTION EVENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Logs when a promotion is viewed.
  Future<void> logPromotionViewed({
    required String promotionId,
    required String promotionName,
    String? creativeName,
    String? creativeSlot,
    String? locationId,
  }) async {
    await _service.logEvent(
      PromotionViewedEvent(
        promotionId: promotionId,
        promotionName: promotionName,
        creativeName: creativeName,
        creativeSlot: creativeSlot,
        locationId: locationId,
      ),
    );
  }

  /// Logs when a promotion is clicked.
  Future<void> logPromotionClicked({
    required String promotionId,
    required String promotionName,
    String? creativeName,
    String? creativeSlot,
  }) async {
    await _service.logEvent(
      PromotionClickedEvent(
        promotionId: promotionId,
        promotionName: promotionName,
        creativeName: creativeName,
        creativeSlot: creativeSlot,
      ),
    );
  }

  /// Logs when a coupon is applied.
  Future<void> logCouponApplied({
    required String couponCode,
    Money? discountValue,
    required bool success,
    String? failureReason,
  }) async {
    await _service.logEvent(
      CouponAppliedEvent(
        couponCode: couponCode,
        discountValue: discountValue,
        success: success,
        failureReason: failureReason,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WISHLIST EVENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Logs when a product is added to wishlist.
  Future<void> logAddToWishlist({
    required Product product,
    String? categoryId,
  }) async {
    await _service.logEvent(
      AddToWishlistEvent(
        productId: product.id,
        productName: product.name,
        price: product.price,
        categoryId: categoryId,
      ),
    );
  }

  /// Logs when a product is removed from wishlist.
  Future<void> logRemoveFromWishlist({
    required String productId,
    required String productName,
  }) async {
    await _service.logEvent(
      RemoveFromWishlistEvent(
        productId: productId,
        productName: productName,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH EVENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Logs when a search is performed.
  Future<void> logSearch({
    required String searchTerm,
    required int resultCount,
    List<String>? filters,
  }) async {
    await _service.logEvent(
      SearchEvent(
        searchTerm: searchTerm,
        resultCount: resultCount,
        filters: filters,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARE EVENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Logs when content is shared.
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    await _service.logEvent(
      ShareEvent(
        contentType: contentType,
        itemId: itemId,
        method: method,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CUSTOM EVENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Logs a custom event.
  Future<void> logCustomEvent({
    required String name,
    Map<String, dynamic> params = const {},
  }) async {
    await _service.logEvent(
      CustomEvent(
        eventName: name,
        eventParams: params,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // USER MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sets a user property.
  Future<void> setUserProperty(String name, String? value) async {
    await _service.setUserProperty(name, value);
  }

  /// Sets the user ID.
  Future<void> setUserId(String? userId) async {
    await _service.setUserId(userId);
  }

  /// Resets analytics data.
  Future<void> reset() async {
    await _service.reset();
  }
}

/// Provider for analytics operations.
final analyticsProvider = NotifierProvider<AnalyticsNotifier, void>(
  AnalyticsNotifier.new,
);

/// Provider for quick access to log events.
final logAnalyticsEventProvider =
    Provider<Future<void> Function(AnalyticsEvent)>((ref) {
  final notifier = ref.read(analyticsProvider.notifier);
  return notifier.logEvent;
});
