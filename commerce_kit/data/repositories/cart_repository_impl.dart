import 'dart:async';

import '../../core/exceptions/commerce_exception.dart';
import '../../core/models/cart.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/discount.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';

/// Implementation of [CartRepository] with local persistence.
class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _localDataSource;
  final StreamController<Cart> _cartController = StreamController.broadcast();

  Cart _currentCart = const Cart.empty();

  CartRepositoryImpl(this._localDataSource);

  @override
  Stream<Cart> get cartStream => _cartController.stream;

  @override
  Future<Cart> getCart() async {
    final savedCart = await _localDataSource.loadCart();
    if (savedCart != null) {
      _currentCart = savedCart;
    }
    return _currentCart;
  }

  @override
  Future<void> saveCart(Cart cart) async {
    _currentCart = cart;
    await _localDataSource.saveCart(cart);
    _cartController.add(cart);
  }

  @override
  Future<Cart> addItem(CartItem item) async {
    final updatedCart = _currentCart.addItem(item);
    await saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> removeItem(String itemId) async {
    if (_currentCart.getItem(itemId) == null) {
      throw CartException.itemNotFound(itemId);
    }
    final updatedCart = _currentCart.removeItem(itemId);
    await saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> updateItem(String itemId, CartItem item) async {
    if (_currentCart.getItem(itemId) == null) {
      throw CartException.itemNotFound(itemId);
    }
    final updatedCart = _currentCart.updateItem(itemId, (_) => item);
    await saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      return removeItem(itemId);
    }
    final updatedCart = _currentCart.updateQuantity(itemId, quantity);
    await saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> clearCart() async {
    final updatedCart = _currentCart.clear();
    await saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> applyDiscount(Discount discount) async {
    final error = discount.validate(subtotal: _currentCart.subtotal);
    if (error != null) {
      throw DiscountException(message: error);
    }
    final updatedCart = _currentCart.addDiscount(discount);
    await saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> removeDiscount(String discountId) async {
    final updatedCart = _currentCart.removeDiscount(discountId);
    await saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> applyCoupon(String code) async {
    final updatedCart = _currentCart.withCouponCode(code);
    await saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> removeCoupon() async {
    final updatedCart = _currentCart.withoutCouponCode();
    await saveCart(updatedCart);
    return updatedCart;
  }

  /// Disposes resources.
  void dispose() {
    _cartController.close();
  }
}
