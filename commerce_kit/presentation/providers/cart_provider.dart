import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/cart.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/discount.dart';
import '../../core/models/money.dart';
import '../../core/models/price_breakdown.dart';
import '../../core/models/product.dart';
import 'cart_config_provider.dart';

/// The main cart state.
class CartState {
  final Cart cart;
  final bool isLoading;
  final String? error;
  final bool isFloatingBarDismissed;

  const CartState({
    required this.cart,
    this.isLoading = false,
    this.error,
    this.isFloatingBarDismissed = false,
  });

  const CartState.initial()
      : cart = const Cart.empty(),
        isLoading = false,
        error = null,
        isFloatingBarDismissed = false;

  CartState copyWith({
    Cart? cart,
    bool? isLoading,
    String? error,
    bool? isFloatingBarDismissed,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isFloatingBarDismissed:
          isFloatingBarDismissed ?? this.isFloatingBarDismissed,
    );
  }

  // Convenience getters
  List<CartItem> get items => cart.items;
  bool get isEmpty => cart.isEmpty;
  bool get isNotEmpty => cart.isNotEmpty;
  int get itemCount => cart.itemCount;
  int get uniqueItemCount => cart.uniqueItemCount;
  Money get subtotal => cart.subtotal;
  Money get totalPrice => cart.totalPrice;
  Money get discountTotal => cart.discountTotal;
  bool get hasDiscounts => cart.hasDiscounts;
  String? get couponCode => cart.couponCode;
}

/// Cart notifier for state management.
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return const CartState.initial();
  }

  /// Adds an item to the cart.
  void addItem(CartItem item) {
    final config = ref.read(cartConfigProvider);
    final currentCart = state.cart;

    // Check max quantity
    final existingItem = currentCart.items.firstWhere(
      (i) => i.uniqueKey == item.uniqueKey,
      orElse: () => item.copyWith(quantity: 0),
    );

    final newQuantity = existingItem.quantity + item.quantity;
    if (newQuantity > config.maxQuantityPerItem) {
      state = state.copyWith(
        error: 'Maximum quantity of ${config.maxQuantityPerItem} exceeded',
      );
      return;
    }

    state = state.copyWith(
      cart: currentCart.addItem(item),
    );
  }

  /// Adds a product to the cart.
  void addProduct(
    Product product, {
    int quantity = 1,
    Map<String, SelectedOption>? selectedOptions,
    String? note,
  }) {
    final item = CartItem.fromProduct(
      product,
      cartItemId: 'cart_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
      quantity: quantity,
      selectedOptions: selectedOptions,
      note: note,
    );
    addItem(item);
  }

  /// Quick add by name and price.
  void quickAddItem({
    required String name,
    required double price,
    String? productId,
    String? imageUrl,
    int quantity = 1,
  }) {
    final id = productId ?? name.toLowerCase().replaceAll(' ', '-');
    final item = CartItem(
      id: 'cart_${id}_${DateTime.now().millisecondsSinceEpoch}',
      productId: id,
      name: name,
      price: Money(price),
      quantity: quantity,
      addedAt: DateTime.now(),
    );
    addItem(item);
  }

  /// Removes an item from the cart.
  void removeItem(String itemId) {
    state = state.copyWith(
      cart: state.cart.removeItem(itemId),
    );
  }

  /// Updates item quantity.
  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final config = ref.read(cartConfigProvider);
    if (quantity > config.maxQuantityPerItem) {
      state = state.copyWith(
        error: 'Maximum quantity of ${config.maxQuantityPerItem} exceeded',
      );
      return;
    }

    state = state.copyWith(
      cart: state.cart.updateQuantity(itemId, quantity),
    );
  }

  /// Increments item quantity.
  void incrementQuantity(String itemId) {
    final item = state.cart.getItem(itemId);
    if (item == null) return;
    updateQuantity(itemId, item.quantity + 1);
  }

  /// Decrements item quantity.
  void decrementQuantity(String itemId) {
    final item = state.cart.getItem(itemId);
    if (item == null) return;
    if (item.quantity <= 1) {
      removeItem(itemId);
    } else {
      updateQuantity(itemId, item.quantity - 1);
    }
  }

  /// Updates item note.
  void updateItemNote(String itemId, String? note) {
    state = state.copyWith(
      cart: state.cart.updateItemNote(itemId, note),
    );
  }

  /// Clears the cart.
  void clearCart() {
    state = state.copyWith(
      cart: state.cart.clear(),
    );
  }

  /// Applies a discount.
  void applyDiscount(Discount discount) {
    final error = discount.validate(subtotal: state.cart.subtotal);
    if (error != null) {
      state = state.copyWith(error: error);
      return;
    }
    state = state.copyWith(
      cart: state.cart.addDiscount(discount),
    );
  }

  /// Removes a discount.
  void removeDiscount(String discountId) {
    state = state.copyWith(
      cart: state.cart.removeDiscount(discountId),
    );
  }

  /// Applies a coupon code.
  void applyCoupon(String code) {
    state = state.copyWith(
      cart: state.cart.withCouponCode(code),
    );
  }

  /// Removes the coupon.
  void removeCoupon() {
    state = state.copyWith(
      cart: state.cart.withoutCouponCode(),
    );
  }

  /// Sets cart note.
  void setNote(String? note) {
    state = state.copyWith(
      cart: state.cart.withNote(note),
    );
  }

  /// Dismisses the floating bar.
  void dismissFloatingBar() {
    state = state.copyWith(isFloatingBarDismissed: true);
  }

  /// Shows the floating bar.
  void showFloatingBar() {
    state = state.copyWith(isFloatingBarDismissed: false);
  }

  /// Clears any error.
  void clearError() {
    state = state.copyWith();
  }
}

/// The main cart provider.
final commerceCartProvider =
    NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Selector Providers (for optimized rebuilds)
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for cart items only.
final cartItemsProvider = Provider<List<CartItem>>((ref) {
  return ref.watch(commerceCartProvider.select((s) => s.items));
});

/// Provider for item count.
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(commerceCartProvider.select((s) => s.itemCount));
});

/// Provider for cart total.
final cartTotalProvider = Provider<Money>((ref) {
  return ref.watch(commerceCartProvider.select((s) => s.totalPrice));
});

/// Provider for cart subtotal.
final cartSubtotalProvider = Provider<Money>((ref) {
  return ref.watch(commerceCartProvider.select((s) => s.subtotal));
});

/// Provider for cart empty state.
final cartIsEmptyProvider = Provider<bool>((ref) {
  return ref.watch(commerceCartProvider.select((s) => s.isEmpty));
});

/// Provider for cart error.
final cartErrorProvider = Provider<String?>((ref) {
  return ref.watch(commerceCartProvider.select((s) => s.error));
});

/// Provider for floating bar visibility.
final floatingBarVisibleProvider = Provider<bool>((ref) {
  final state = ref.watch(commerceCartProvider);
  return state.isNotEmpty && !state.isFloatingBarDismissed;
});

/// Provider for free shipping progress.
final freeShippingProgressProvider = Provider<double>((ref) {
  final threshold = ref.watch(freeShippingThresholdProvider);
  if (threshold == null) return 1.0;

  final subtotal = ref.watch(cartSubtotalProvider);
  return (subtotal.amount / threshold.amount).clamp(0.0, 1.0);
});

/// Provider for amount to free shipping.
final amountToFreeShippingProvider = Provider<Money?>((ref) {
  final threshold = ref.watch(freeShippingThresholdProvider);
  if (threshold == null) return null;

  final subtotal = ref.watch(cartSubtotalProvider);
  if (subtotal >= threshold) return null;

  return threshold - subtotal;
});

/// Provider for price breakdown.
final cartBreakdownProvider = Provider<PriceBreakdown>((ref) {
  final cart = ref.watch(commerceCartProvider).cart;
  final config = ref.watch(cartConfigProvider);

  return cart.calculateBreakdown(
    shipping: config.defaultShippingCost,
    taxRate: config.taxRate,
    freeShippingThreshold: config.freeShippingThreshold,
  );
});
