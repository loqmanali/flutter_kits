import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/cart.dart';

/// Local data source for cart persistence.
///
/// Uses SharedPreferences for simple local storage.
/// Can be extended or replaced with Hive, SQLite, etc.
abstract class CartLocalDataSource {
  /// Saves the cart to local storage.
  Future<void> saveCart(Cart cart);

  /// Loads the cart from local storage.
  Future<Cart?> loadCart();

  /// Clears the cart from local storage.
  Future<void> clearCart();

  /// Checks if a cart exists in local storage.
  Future<bool> hasCart();
}

/// SharedPreferences implementation of [CartLocalDataSource].
class SharedPrefsCartDataSource implements CartLocalDataSource {
  static const String _cartKey = 'commerce_kit_cart';

  final SharedPreferences _prefs;

  SharedPrefsCartDataSource(this._prefs);

  /// Creates an instance asynchronously.
  static Future<SharedPrefsCartDataSource> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsCartDataSource(prefs);
  }

  @override
  Future<void> saveCart(Cart cart) async {
    final json = jsonEncode(cart.toJson());
    await _prefs.setString(_cartKey, json);
  }

  @override
  Future<Cart?> loadCart() async {
    final json = _prefs.getString(_cartKey);
    if (json == null) return null;

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return Cart.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearCart() async {
    await _prefs.remove(_cartKey);
  }

  @override
  Future<bool> hasCart() async {
    return _prefs.containsKey(_cartKey);
  }
}

/// In-memory implementation for testing.
class InMemoryCartDataSource implements CartLocalDataSource {
  Cart? _cart;

  @override
  Future<void> saveCart(Cart cart) async {
    _cart = cart;
  }

  @override
  Future<Cart?> loadCart() async {
    return _cart;
  }

  @override
  Future<void> clearCart() async {
    _cart = null;
  }

  @override
  Future<bool> hasCart() async {
    return _cart != null;
  }
}
