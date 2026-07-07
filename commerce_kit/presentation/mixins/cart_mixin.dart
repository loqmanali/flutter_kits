import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/cart_item.dart';
import '../../core/models/money.dart';
import '../../core/models/product.dart';
import '../providers/cart_provider.dart';

/// Mixin providing cart functionality for widgets.
///
/// ## Usage
///
/// ```dart
/// class MyWidget extends ConsumerWidget with CartMixin {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final itemCount = getCartItemCount(ref);
///
///     return ElevatedButton(
///       onPressed: () => addProductToCart(
///         ref,
///         context,
///         product: myProduct,
///       ),
///       child: Text('Add to Cart ($itemCount)'),
///     );
///   }
/// }
/// ```
mixin CartMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────────────────────

  /// Gets the cart item count.
  int getCartItemCount(WidgetRef ref) {
    return ref.read(cartItemCountProvider);
  }

  /// Gets the cart total.
  Money getCartTotal(WidgetRef ref) {
    return ref.read(cartTotalProvider);
  }

  /// Gets all cart items.
  List<CartItem> getCartItems(WidgetRef ref) {
    return ref.read(cartItemsProvider);
  }

  /// Checks if cart is empty.
  bool isCartEmpty(WidgetRef ref) {
    return ref.read(cartIsEmptyProvider);
  }

  /// Gets a specific item by product ID.
  CartItem? getCartItemByProductId(WidgetRef ref, String productId) {
    return ref.read(commerceCartProvider).cart.getItemByProductId(productId);
  }

  /// Gets quantity of a product in cart.
  int getProductQuantityInCart(WidgetRef ref, String productId) {
    return ref.read(commerceCartProvider).cart.getProductQuantity(productId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────────────

  /// Adds a product to the cart.
  void addProductToCart(
    WidgetRef ref,
    BuildContext context,
    Product product, {
    int quantity = 1,
    Map<String, SelectedOption>? selectedOptions,
    String? note,
    bool showSnackbar = true,
  }) {
    ref.read(commerceCartProvider.notifier).addProduct(
          product,
          quantity: quantity,
          selectedOptions: selectedOptions,
          note: note,
        );

    if (showSnackbar && context.mounted) {
      _showAddedSnackbar(context, product.name);
    }
  }

  /// Quick adds an item by name and price.
  void quickAddToCart(
    WidgetRef ref,
    BuildContext context, {
    required String name,
    required double price,
    String? productId,
    int quantity = 1,
    bool showSnackbar = true,
  }) {
    ref.read(commerceCartProvider.notifier).quickAddItem(
          name: name,
          price: price,
          productId: productId,
          quantity: quantity,
        );

    if (showSnackbar && context.mounted) {
      _showAddedSnackbar(context, name);
    }
  }

  /// Removes an item from cart.
  void removeFromCart(
    WidgetRef ref,
    String itemId, {
    BuildContext? context,
    bool showSnackbar = false,
  }) {
    final item = ref.read(commerceCartProvider).cart.getItem(itemId);
    ref.read(commerceCartProvider.notifier).removeItem(itemId);

    if (showSnackbar && context != null && context.mounted && item != null) {
      _showRemovedSnackbar(context, item.name);
    }
  }

  /// Updates item quantity.
  void updateCartQuantity(WidgetRef ref, String itemId, int quantity) {
    ref.read(commerceCartProvider.notifier).updateQuantity(itemId, quantity);
  }

  /// Increments item quantity.
  void incrementCartItem(WidgetRef ref, String itemId) {
    ref.read(commerceCartProvider.notifier).incrementQuantity(itemId);
  }

  /// Decrements item quantity.
  void decrementCartItem(WidgetRef ref, String itemId) {
    ref.read(commerceCartProvider.notifier).decrementQuantity(itemId);
  }

  /// Clears the cart.
  void clearCart(WidgetRef ref, {BuildContext? context, bool confirm = true}) {
    if (confirm && context != null) {
      _showClearConfirmation(context, () {
        ref.read(commerceCartProvider.notifier).clearCart();
      });
    } else {
      ref.read(commerceCartProvider.notifier).clearCart();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI Helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _showAddedSnackbar(BuildContext context, String itemName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName added to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            // Override this in your implementation to navigate to cart
          },
        ),
      ),
    );
  }

  void _showRemovedSnackbar(BuildContext context, String itemName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName removed from cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
