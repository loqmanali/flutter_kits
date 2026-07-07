import 'package:equatable/equatable.dart';

import 'discount.dart';
import 'money.dart';
import 'product.dart';
import 'product_image.dart';
import 'product_option_value.dart';
import 'product_variant.dart';

/// Represents an item in the shopping cart.
///
/// A cart item contains all the information needed to identify and price
/// a product selection, including the quantity, selected options/variant,
/// and any item-level discounts.
///
/// ## Usage
///
/// ```dart
/// // Simple cart item
/// final item = CartItem(
///   id: 'cart-item-1',
///   productId: 'burger-1',
///   name: 'Classic Burger',
///   price: Money(99),
///   quantity: 2,
///   image: ProductImage.network(id: '1', url: 'https://...'),
/// );
///
/// // Cart item with options
/// final customItem = CartItem(
///   id: 'cart-item-2',
///   productId: 'burger-2',
///   name: 'Custom Burger',
///   price: Money(124),
///   quantity: 1,
///   selectedOptions: {
///     'size': SelectedOption(
///       optionId: 'size',
///       optionName: 'Size',
///       valueId: 'double',
///       valueName: 'Double',
///       priceModifier: Money(25),
///     ),
///   },
///   note: 'No onions please',
/// );
///
/// print(item.totalPrice); // Money(198)
/// ```
class CartItem extends Equatable {
  /// Unique identifier for this cart item.
  final String id;

  /// The product ID this item represents.
  final String productId;

  /// The variant ID if a variant is selected.
  final String? variantId;

  /// The product name.
  final String name;

  /// The SKU of the product or variant.
  final String? sku;

  /// The unit price (before quantity multiplication).
  final Money price;

  /// The original price before any discounts.
  final Money? compareAtPrice;

  /// The quantity of this item in the cart.
  final int quantity;

  /// The primary image for display.
  final ProductImage? image;

  /// Selected options for this item.
  final Map<String, SelectedOption> selectedOptions;

  /// Any applied item-level discount.
  final Discount? discount;

  /// Special instructions or notes.
  final String? note;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// The date this item was added to the cart.
  final DateTime? addedAt;

  /// Creates a [CartItem] instance.
  const CartItem({
    required this.id,
    required this.productId,
    this.variantId,
    required this.name,
    this.sku,
    required this.price,
    this.compareAtPrice,
    this.quantity = 1,
    this.image,
    this.selectedOptions = const {},
    this.discount,
    this.note,
    this.metadata,
    this.addedAt,
  });

  /// Creates a [CartItem] from a [Product].
  factory CartItem.fromProduct(
    Product product, {
    required String cartItemId,
    int quantity = 1,
    Map<String, SelectedOption>? selectedOptions,
    String? note,
  }) {
    return CartItem(
      id: cartItemId,
      productId: product.id,
      name: product.name,
      sku: product.sku,
      price: product.price,
      compareAtPrice: product.compareAtPrice,
      quantity: quantity,
      image: product.primaryImage,
      selectedOptions: selectedOptions ?? {},
      note: note,
      addedAt: DateTime.now(),
    );
  }

  /// Creates a [CartItem] from a [Product] with a specific [ProductVariant].
  factory CartItem.fromVariant(
    Product product,
    ProductVariant variant, {
    required String cartItemId,
    int quantity = 1,
    Map<String, SelectedOption>? additionalOptions,
    String? note,
  }) {
    return CartItem(
      id: cartItemId,
      productId: product.id,
      variantId: variant.id,
      name: variant.name ?? product.name,
      sku: variant.sku ?? product.sku,
      price: variant.price,
      compareAtPrice: variant.compareAtPrice,
      quantity: quantity,
      image: variant.primaryImage ?? product.primaryImage,
      selectedOptions: additionalOptions ?? {},
      note: note,
      addedAt: DateTime.now(),
    );
  }

  /// Creates a [CartItem] from JSON.
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? '',
      productId:
          json['product_id']?.toString() ?? json['productId']?.toString() ?? '',
      variantId:
          json['variant_id']?.toString() ?? json['variantId']?.toString(),
      name: json['name'] ?? json['title'] ?? '',
      sku: json['sku'],
      price: json['price'] != null
          ? (json['price'] is Map
              ? Money.fromJson(json['price'] as Map<String, dynamic>)
              : Money((json['price'] as num).toDouble()))
          : const Money.zero(),
      compareAtPrice:
          json['compare_at_price'] != null || json['compareAtPrice'] != null
              ? Money.fromJson({
                  'amount': json['compare_at_price'] ?? json['compareAtPrice'],
                })
              : null,
      quantity: json['quantity'] ?? 1,
      image: json['image'] != null
          ? ProductImage.fromJson(json['image'] as Map<String, dynamic>)
          : null,
      selectedOptions: _parseSelectedOptions(
        json['selected_options'] ?? json['selectedOptions'] ?? json['options'],
      ),
      discount: json['discount'] != null
          ? Discount.fromJson(json['discount'] as Map<String, dynamic>)
          : null,
      note: json['note'] ?? json['notes'] ?? json['special_instructions'],
      metadata: json['metadata'],
      addedAt: json['added_at'] != null || json['addedAt'] != null
          ? DateTime.tryParse(
              (json['added_at'] ?? json['addedAt']).toString(),
            )
          : null,
    );
  }

  /// Converts this [CartItem] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        if (variantId != null) 'variant_id': variantId,
        'name': name,
        if (sku != null) 'sku': sku,
        'price': price.toJson(),
        if (compareAtPrice != null)
          'compare_at_price': compareAtPrice!.toJson(),
        'quantity': quantity,
        if (image != null) 'image': image!.toJson(),
        'selected_options': selectedOptions.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        if (discount != null) 'discount': discount!.toJson(),
        if (note != null) 'note': note,
        if (metadata != null) 'metadata': metadata,
        if (addedAt != null) 'added_at': addedAt!.toIso8601String(),
      };

  // ─────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns the total price of selected options.
  Money get optionsTotal {
    if (selectedOptions.isEmpty) return Money.zero(currency: price.currency);

    return selectedOptions.values.fold(
      Money.zero(currency: price.currency),
      (total, option) => total + option.priceModifier,
    );
  }

  /// Returns the unit price including options.
  Money get unitPrice => price + optionsTotal;

  /// Returns the total price for this item (unit price × quantity).
  Money get subtotal => unitPrice * quantity;

  /// Returns the discount amount for this item.
  Money get discountAmount {
    if (discount == null) return Money.zero(currency: price.currency);
    return discount!.calculate(subtotal, currency: price.currency);
  }

  /// Returns the total price after discount.
  Money get totalPrice => subtotal - discountAmount;

  /// Returns `true` if this item is on sale.
  bool get isOnSale =>
      compareAtPrice != null && compareAtPrice!.amount > price.amount;

  /// Returns the savings amount per unit if on sale.
  Money? get savings {
    if (!isOnSale) return null;
    return compareAtPrice! - price;
  }

  /// Returns `true` if this item has selected options.
  bool get hasOptions => selectedOptions.isNotEmpty;

  /// Returns `true` if this item has a note.
  bool get hasNote => note != null && note!.isNotEmpty;

  /// Returns a formatted string of selected options.
  String get optionsSummary {
    if (selectedOptions.isEmpty) return '';
    return selectedOptions.values.map((o) => o.valueName).join(', ');
  }

  /// Returns a unique key for this item (product + variant + options).
  ///
  /// Used to identify identical items for merging.
  String get uniqueKey {
    final buffer = StringBuffer(productId);
    if (variantId != null) {
      buffer.write('|$variantId');
    }
    if (selectedOptions.isNotEmpty) {
      final sortedKeys = selectedOptions.keys.toList()..sort();
      for (final key in sortedKeys) {
        buffer.write('|$key:${selectedOptions[key]!.valueId}');
      }
    }
    return buffer.toString();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates a copy with updated quantity.
  CartItem withQuantity(int newQuantity) {
    return copyWith(quantity: newQuantity);
  }

  /// Creates a copy with incremented quantity.
  CartItem increment([int amount = 1]) {
    return copyWith(quantity: quantity + amount);
  }

  /// Creates a copy with decremented quantity.
  ///
  /// Returns null if quantity would become 0 or negative.
  CartItem? decrement([int amount = 1]) {
    final newQuantity = quantity - amount;
    if (newQuantity <= 0) return null;
    return copyWith(quantity: newQuantity);
  }

  /// Creates a copy with an applied discount.
  CartItem withDiscount(Discount discount) {
    return copyWith(discount: discount);
  }

  /// Creates a copy with the discount removed.
  CartItem withoutDiscount() {
    return CartItem(
      id: id,
      productId: productId,
      variantId: variantId,
      name: name,
      sku: sku,
      price: price,
      compareAtPrice: compareAtPrice,
      quantity: quantity,
      image: image,
      selectedOptions: selectedOptions,
      note: note,
      metadata: metadata,
      addedAt: addedAt,
    );
  }

  /// Creates a copy with an updated note.
  CartItem withNote(String? note) {
    return copyWith(note: note);
  }

  /// Copies this [CartItem] with optional new values.
  CartItem copyWith({
    String? id,
    String? productId,
    String? variantId,
    String? name,
    String? sku,
    Money? price,
    Money? compareAtPrice,
    int? quantity,
    ProductImage? image,
    Map<String, SelectedOption>? selectedOptions,
    Discount? discount,
    String? note,
    Map<String, dynamic>? metadata,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      discount: discount ?? this.discount,
      note: note ?? this.note,
      metadata: metadata ?? this.metadata,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  static Map<String, SelectedOption> _parseSelectedOptions(dynamic options) {
    if (options == null) return {};
    if (options is Map) {
      return Map.fromEntries(
        options.entries.map((entry) {
          final key = entry.key.toString();
          if (entry.value is Map) {
            return MapEntry(
              key,
              SelectedOption.fromJson(entry.value as Map<String, dynamic>),
            );
          }
          return MapEntry(
            key,
            SelectedOption(
              optionId: key,
              optionName: key,
              valueId: entry.value.toString(),
              valueName: entry.value.toString(),
            ),
          );
        }),
      );
    }
    if (options is List) {
      final result = <String, SelectedOption>{};
      for (final opt in options) {
        if (opt is Map<String, dynamic>) {
          final option = SelectedOption.fromJson(opt);
          result[option.optionId] = option;
        }
      }
      return result;
    }
    return {};
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        variantId,
        name,
        price,
        quantity,
        selectedOptions,
        note,
      ];
}

/// Represents a selected option value for a cart item.
class SelectedOption extends Equatable {
  /// The option ID.
  final String optionId;

  /// The option name (for display).
  final String optionName;

  /// The selected value ID.
  final String valueId;

  /// The selected value name (for display).
  final String valueName;

  /// The price modifier for this selection.
  final Money priceModifier;

  /// Creates a [SelectedOption] instance.
  const SelectedOption({
    required this.optionId,
    required this.optionName,
    required this.valueId,
    required this.valueName,
    this.priceModifier = const Money.zero(),
  });

  /// Creates a [SelectedOption] from a [ProductOptionValue].
  factory SelectedOption.fromOptionValue(
    String optionId,
    String optionName,
    ProductOptionValue value,
  ) {
    return SelectedOption(
      optionId: optionId,
      optionName: optionName,
      valueId: value.id,
      valueName: value.label,
      priceModifier: value.priceModifier,
    );
  }

  /// Creates a [SelectedOption] from JSON.
  factory SelectedOption.fromJson(Map<String, dynamic> json) {
    return SelectedOption(
      optionId:
          json['option_id']?.toString() ?? json['optionId']?.toString() ?? '',
      optionName: json['option_name'] ?? json['optionName'] ?? '',
      valueId:
          json['value_id']?.toString() ?? json['valueId']?.toString() ?? '',
      valueName: json['value_name'] ?? json['valueName'] ?? '',
      priceModifier:
          json['price_modifier'] != null || json['priceModifier'] != null
              ? (json['price_modifier'] ?? json['priceModifier']) is Map
                  ? Money.fromJson(
                      (json['price_modifier'] ?? json['priceModifier'])
                          as Map<String, dynamic>,
                    )
                  : Money(
                      ((json['price_modifier'] ?? json['priceModifier']) as num)
                          .toDouble(),
                    )
              : const Money.zero(),
    );
  }

  /// Converts this [SelectedOption] to JSON.
  Map<String, dynamic> toJson() => {
        'option_id': optionId,
        'option_name': optionName,
        'value_id': valueId,
        'value_name': valueName,
        'price_modifier': priceModifier.toJson(),
      };

  /// Returns `true` if this selection has a price modifier.
  bool get hasExtraCost => !priceModifier.isZero;

  /// Returns a display string.
  String get displayText {
    if (hasExtraCost) {
      final sign = priceModifier.isPositive ? '+' : '';
      return '$valueName ($sign${priceModifier.formatted})';
    }
    return valueName;
  }

  @override
  List<Object?> get props => [optionId, valueId, priceModifier];
}
