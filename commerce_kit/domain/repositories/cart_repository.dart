import '../../core/models/cart.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/discount.dart';

/// Abstract repository interface for cart operations.
///
/// Implement this interface to provide cart functionality
/// with your preferred data source (local, remote, or both).
abstract class CartRepository {
  /// Gets the current cart.
  Future<Cart> getCart();

  /// Saves the cart.
  Future<void> saveCart(Cart cart);

  /// Adds an item to the cart.
  Future<Cart> addItem(CartItem item);

  /// Removes an item from the cart.
  Future<Cart> removeItem(String itemId);

  /// Updates an item in the cart.
  Future<Cart> updateItem(String itemId, CartItem item);

  /// Updates item quantity.
  Future<Cart> updateQuantity(String itemId, int quantity);

  /// Clears the cart.
  Future<Cart> clearCart();

  /// Applies a discount to the cart.
  Future<Cart> applyDiscount(Discount discount);

  /// Removes a discount from the cart.
  Future<Cart> removeDiscount(String discountId);

  /// Applies a coupon code.
  Future<Cart> applyCoupon(String code);

  /// Removes the coupon.
  Future<Cart> removeCoupon();

  /// Stream of cart changes.
  Stream<Cart> get cartStream;
}
