import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/money.dart';

/// Extension methods for [Cart].
extension CartExtensions on Cart {
  /// Returns items sorted by added date (newest first).
  List<CartItem> get itemsByDateAdded {
    final sorted = List<CartItem>.from(items);
    sorted.sort((a, b) {
      if (a.addedAt == null && b.addedAt == null) return 0;
      if (a.addedAt == null) return 1;
      if (b.addedAt == null) return -1;
      return b.addedAt!.compareTo(a.addedAt!);
    });
    return sorted;
  }

  /// Returns items sorted by price (highest first).
  List<CartItem> get itemsByPrice {
    final sorted = List<CartItem>.from(items);
    sorted.sort((a, b) => b.totalPrice.amount.compareTo(a.totalPrice.amount));
    return sorted;
  }

  /// Returns items sorted by name.
  List<CartItem> get itemsByName {
    final sorted = List<CartItem>.from(items);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  /// Returns the average item price.
  Money get averageItemPrice {
    if (isEmpty) return Money.zero(currency: currency);
    return Money(subtotal.amount / itemCount, currency: currency);
  }

  /// Returns the most expensive item.
  CartItem? get mostExpensiveItem {
    if (isEmpty) return null;
    return items.reduce(
      (a, b) => a.totalPrice.amount > b.totalPrice.amount ? a : b,
    );
  }

  /// Returns the least expensive item.
  CartItem? get leastExpensiveItem {
    if (isEmpty) return null;
    return items.reduce(
      (a, b) => a.totalPrice.amount < b.totalPrice.amount ? a : b,
    );
  }

  /// Groups items by product ID.
  Map<String, List<CartItem>> get itemsByProductId {
    final grouped = <String, List<CartItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.productId, () => []).add(item);
    }
    return grouped;
  }

  /// Returns items with notes.
  List<CartItem> get itemsWithNotes {
    return items.where((item) => item.hasNote).toList();
  }

  /// Returns items with discounts.
  List<CartItem> get itemsWithDiscounts {
    return items.where((item) => item.discount != null).toList();
  }

  /// Returns items on sale.
  List<CartItem> get itemsOnSale {
    return items.where((item) => item.isOnSale).toList();
  }

  /// Checks if free shipping threshold is met.
  bool meetsThreshold(Money threshold) {
    return subtotal >= threshold;
  }

  /// Returns the amount remaining to meet a threshold.
  Money amountToThreshold(Money threshold) {
    if (meetsThreshold(threshold)) return Money.zero(currency: currency);
    return threshold - subtotal;
  }

  /// Returns the progress towards a threshold (0.0 to 1.0).
  double progressToThreshold(Money threshold) {
    if (threshold.isZero) return 1.0;
    return (subtotal.amount / threshold.amount).clamp(0.0, 1.0);
  }

  /// Creates a summary string for the cart.
  String get summary {
    if (isEmpty) return 'Cart is empty';
    return '$itemCount ${itemCount == 1 ? 'item' : 'items'} - ${totalPrice.formatted}';
  }

  /// Creates a detailed summary string.
  String get detailedSummary {
    if (isEmpty) return 'Cart is empty';

    final buffer = StringBuffer();
    buffer.writeln('Cart Summary:');
    buffer.writeln('─' * 30);

    for (final item in items) {
      buffer.writeln('${item.quantity}x ${item.name}');
      if (item.hasOptions) {
        buffer.writeln('   ${item.optionsSummary}');
      }
      buffer.writeln('   ${item.totalPrice.formatted}');
    }

    buffer.writeln('─' * 30);
    buffer.writeln('Subtotal: ${subtotal.formatted}');

    if (hasDiscounts) {
      buffer.writeln('Discount: -${discountTotal.formatted}');
    }

    buffer.writeln('Total: ${totalPrice.formatted}');

    return buffer.toString();
  }
}

/// Extension methods for [CartItem].
extension CartItemExtensions on CartItem {
  /// Returns `true` if quantity can be incremented.
  bool canIncrement({int? maxQuantity}) {
    if (maxQuantity == null) return true;
    return quantity < maxQuantity;
  }

  /// Returns `true` if quantity can be decremented.
  bool get canDecrement => quantity > 1;

  /// Returns `true` if this is the only item (quantity = 1).
  bool get isSingleUnit => quantity == 1;

  /// Returns a display string for quantity.
  String get quantityDisplay => 'Qty: $quantity';

  /// Returns a formatted price per unit string.
  String get pricePerUnit => '${unitPrice.formatted}/unit';

  /// Creates a summary string.
  String get summary {
    final buffer = StringBuffer();
    buffer.write('$quantity × $name');
    if (hasOptions) {
      buffer.write(' ($optionsSummary)');
    }
    buffer.write(' = ${totalPrice.formatted}');
    return buffer.toString();
  }
}

/// Extension methods for List<CartItem>.
extension CartItemListExtensions on List<CartItem> {
  /// Returns the total quantity of all items.
  int get totalQuantity => fold(0, (sum, item) => sum + item.quantity);

  /// Returns the total price of all items.
  Money totalPrice({String currency = 'EGP'}) {
    if (isEmpty) return Money.zero(currency: currency);
    return fold(
      Money.zero(currency: currency),
      (sum, item) => sum + item.totalPrice,
    );
  }

  /// Finds an item by product ID.
  CartItem? findByProductId(String productId) {
    try {
      return firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  /// Finds an item by unique key.
  CartItem? findByUniqueKey(String uniqueKey) {
    try {
      return firstWhere((item) => item.uniqueKey == uniqueKey);
    } catch (_) {
      return null;
    }
  }

  /// Returns items containing a specific product.
  List<CartItem> whereProduct(String productId) {
    return where((item) => item.productId == productId).toList();
  }
}
