import 'package:equatable/equatable.dart';

import 'cart_item.dart';
import 'discount.dart';
import 'money.dart';
import 'price_breakdown.dart';

/// Represents the shopping cart state.
///
/// The [Cart] model contains all cart items, applied discounts,
/// and computed totals. It's immutable and follows the value object pattern.
///
/// ## Usage
///
/// ```dart
/// // Create an empty cart
/// final cart = Cart.empty();
///
/// // Add items
/// final updatedCart = cart.addItem(cartItem);
///
/// // Get totals
/// print(updatedCart.totalPrice.formatted);
/// print(updatedCart.itemCount);
///
/// // Apply discount
/// final discountedCart = updatedCart.withDiscount(discount);
/// ```
class Cart extends Equatable {
  /// Unique identifier for this cart.
  final String? id;

  /// The user ID this cart belongs to (null for guest carts).
  final String? userId;

  /// The items in this cart.
  final List<CartItem> items;

  /// Applied cart-level discounts.
  final List<Discount> discounts;

  /// The coupon code if applied.
  final String? couponCode;

  /// Special instructions for the order.
  final String? note;

  /// The currency for this cart.
  final String currency;

  /// The date this cart was created.
  final DateTime? createdAt;

  /// The date this cart was last updated.
  final DateTime? updatedAt;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a [Cart] instance.
  const Cart({
    this.id,
    this.userId,
    this.items = const [],
    this.discounts = const [],
    this.couponCode,
    this.note,
    this.currency = 'EGP',
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// Creates an empty cart.
  const Cart.empty({String currency = 'EGP'})
      : this(currency: currency, items: const []);

  /// Creates a [Cart] from JSON.
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? json['userId']?.toString(),
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => CartItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      discounts: (json['discounts'] as List<dynamic>?)
              ?.map((d) => Discount.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      couponCode: json['coupon_code'] ?? json['couponCode'],
      note: json['note'] ?? json['notes'],
      currency: json['currency'] ?? 'EGP',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      metadata: json['metadata'],
    );
  }

  /// Converts this [Cart] to JSON.
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (userId != null) 'user_id': userId,
        'items': items.map((i) => i.toJson()).toList(),
        'discounts': discounts.map((d) => d.toJson()).toList(),
        if (couponCode != null) 'coupon_code': couponCode,
        if (note != null) 'note': note,
        'currency': currency,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };

  // ─────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns `true` if the cart is empty.
  bool get isEmpty => items.isEmpty;

  /// Returns `true` if the cart has items.
  bool get isNotEmpty => items.isNotEmpty;

  /// Returns the total number of items (sum of quantities).
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Returns the number of unique products in the cart.
  int get uniqueItemCount => items.length;

  /// Returns the subtotal (sum of all item totals before cart-level discounts).
  Money get subtotal {
    if (items.isEmpty) return Money.zero(currency: currency);
    return items.fold(
      Money.zero(currency: currency),
      (sum, item) => sum + item.totalPrice,
    );
  }

  /// Returns the total discount amount from cart-level discounts.
  Money get discountTotal {
    if (discounts.isEmpty) return Money.zero(currency: currency);
    return discounts.fold(
      Money.zero(currency: currency),
      (sum, discount) => sum + discount.calculate(subtotal, currency: currency),
    );
  }

  /// Returns the total price after all discounts.
  Money get totalPrice {
    final total = subtotal - discountTotal;
    return total.isNegative ? Money.zero(currency: currency) : total;
  }

  /// Returns `true` if the cart has any discounts applied.
  bool get hasDiscounts =>
      discounts.isNotEmpty || items.any((i) => i.discount != null);

  /// Returns `true` if a coupon is applied.
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;

  /// Returns `true` if the cart has a note.
  bool get hasNote => note != null && note!.isNotEmpty;

  /// Returns all product IDs in the cart.
  List<String> get productIds => items.map((i) => i.productId).toList();

  /// Returns all unique product IDs in the cart.
  Set<String> get uniqueProductIds => items.map((i) => i.productId).toSet();

  /// Returns the total savings from all discounts.
  Money get totalSavings {
    final itemSavings = items.fold(
      Money.zero(currency: currency),
      (sum, item) => sum + item.discountAmount,
    );
    return itemSavings + discountTotal;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Item Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Adds an item to the cart.
  ///
  /// If an item with the same unique key exists, quantities are merged.
  Cart addItem(CartItem item) {
    final existingIndex =
        items.indexWhere((i) => i.uniqueKey == item.uniqueKey);

    if (existingIndex >= 0) {
      // Merge quantities
      final existingItem = items[existingIndex];
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity,
      );
      final updatedItems = List<CartItem>.from(items);
      updatedItems[existingIndex] = updatedItem;
      return _updateWith(items: updatedItems);
    }

    return _updateWith(items: [...items, item]);
  }

  /// Removes an item from the cart by ID.
  Cart removeItem(String itemId) {
    final updatedItems = items.where((i) => i.id != itemId).toList();
    return _updateWith(items: updatedItems);
  }

  /// Updates an item in the cart.
  Cart updateItem(String itemId, CartItem Function(CartItem) update) {
    final index = items.indexWhere((i) => i.id == itemId);
    if (index < 0) return this;

    final updatedItem = update(items[index]);
    final updatedItems = List<CartItem>.from(items);
    updatedItems[index] = updatedItem;
    return _updateWith(items: updatedItems);
  }

  /// Updates the quantity of an item.
  Cart updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) return removeItem(itemId);
    return updateItem(itemId, (item) => item.withQuantity(quantity));
  }

  /// Increments the quantity of an item.
  Cart incrementQuantity(String itemId, [int amount = 1]) {
    return updateItem(itemId, (item) => item.increment(amount));
  }

  /// Decrements the quantity of an item.
  ///
  /// Removes the item if quantity becomes zero.
  Cart decrementQuantity(String itemId, [int amount = 1]) {
    final index = items.indexWhere((i) => i.id == itemId);
    if (index < 0) return this;

    final decremented = items[index].decrement(amount);
    if (decremented == null) {
      return removeItem(itemId);
    }

    final updatedItems = List<CartItem>.from(items);
    updatedItems[index] = decremented;
    return _updateWith(items: updatedItems);
  }

  /// Updates the note for an item.
  Cart updateItemNote(String itemId, String? note) {
    return updateItem(itemId, (item) => item.withNote(note));
  }

  /// Gets an item by ID.
  CartItem? getItem(String itemId) {
    try {
      return items.firstWhere((i) => i.id == itemId);
    } catch (_) {
      return null;
    }
  }

  /// Gets an item by product ID.
  CartItem? getItemByProductId(String productId) {
    try {
      return items.firstWhere((i) => i.productId == productId);
    } catch (_) {
      return null;
    }
  }

  /// Returns `true` if the cart contains a product with the given ID.
  bool containsProduct(String productId) {
    return items.any((i) => i.productId == productId);
  }

  /// Returns the total quantity of a product in the cart.
  int getProductQuantity(String productId) {
    return items
        .where((i) => i.productId == productId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Discount Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Adds a discount to the cart.
  Cart addDiscount(Discount discount) {
    if (discounts.any((d) => d.id == discount.id)) {
      return this;
    }
    return _updateWith(
      discounts: [...discounts, discount],
      couponCode: discount.code ?? couponCode,
    );
  }

  /// Removes a discount from the cart.
  Cart removeDiscount(String discountId) {
    final removed = discounts.firstWhere(
      (d) => d.id == discountId,
      orElse: () => discounts.first,
    );
    return _updateWith(
      discounts: discounts.where((d) => d.id != discountId).toList(),
      couponCode: removed.code == couponCode ? null : couponCode,
    );
  }

  /// Removes all discounts from the cart.
  Cart clearDiscounts() {
    return _updateWith(discounts: []);
  }

  /// Applies a coupon code.
  Cart withCouponCode(String code) {
    return _updateWith(couponCode: code);
  }

  /// Removes the coupon code.
  Cart withoutCouponCode() {
    return _updateWith();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cart Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Clears all items from the cart.
  Cart clear() {
    return Cart(
      id: id,
      userId: userId,
      currency: currency,
      metadata: metadata,
    );
  }

  /// Sets the cart note.
  Cart withNote(String? note) {
    return _updateWith(note: note);
  }

  /// Merges another cart into this one.
  Cart merge(Cart other) {
    var merged = this;
    for (final item in other.items) {
      merged = merged.addItem(item);
    }
    for (final discount in other.discounts) {
      if (!merged.discounts.any((d) => d.id == discount.id)) {
        merged = merged.addDiscount(discount);
      }
    }
    return merged;
  }

  /// Calculates the full price breakdown.
  PriceBreakdown calculateBreakdown({
    Money? shipping,
    double? taxRate,
    Money? fees,
    Money? tip,
    Money? freeShippingThreshold,
  }) {
    final appliedDiscounts = discounts
        .map(
          (d) => AppliedDiscount(
            discount: d,
            amount: d.calculate(subtotal, currency: currency),
          ),
        )
        .toList();

    return PriceBreakdown.calculate(
      subtotal: subtotal,
      discount: discountTotal,
      shipping: shipping,
      taxRate: taxRate,
      fees: fees,
      tip: tip,
      currency: currency,
      freeShippingThreshold: freeShippingThreshold,
      appliedDiscounts: appliedDiscounts,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────────────────────────────────

  Cart _updateWith({
    List<CartItem>? items,
    List<Discount>? discounts,
    String? couponCode,
    String? note,
  }) {
    return Cart(
      id: id,
      userId: userId,
      items: items ?? this.items,
      discounts: discounts ?? this.discounts,
      couponCode: couponCode ?? this.couponCode,
      note: note ?? this.note,
      currency: currency,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      metadata: metadata,
    );
  }

  /// Copies this [Cart] with optional new values.
  Cart copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    List<Discount>? discounts,
    String? couponCode,
    String? note,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      discounts: discounts ?? this.discounts,
      couponCode: couponCode ?? this.couponCode,
      note: note ?? this.note,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        discounts,
        couponCode,
        note,
        currency,
      ];
}
