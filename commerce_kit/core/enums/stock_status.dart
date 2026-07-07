/// Defines the stock/availability status of a product or variant.
///
/// This enum helps manage inventory display and purchasing restrictions.
///
/// ## Usage
///
/// ```dart
/// final product = Product(
///   id: '1',
///   name: 'Burger',
///   stockStatus: StockStatus.inStock,
///   stockQuantity: 50,
/// );
///
/// if (!product.stockStatus.canPurchase) {
///   showOutOfStockMessage();
/// }
/// ```
enum StockStatus {
  /// Product is in stock and available for purchase.
  ///
  /// Normal purchasing flow applies.
  inStock,

  /// Product is out of stock.
  ///
  /// Cannot be added to cart unless backorders are enabled.
  outOfStock,

  /// Product is on backorder.
  ///
  /// Can be purchased but will ship when available.
  /// May have extended delivery time.
  onBackorder,

  /// Product has low stock.
  ///
  /// Still available but quantity is limited.
  /// May show "Only X left" message.
  lowStock,

  /// Product is pre-order only.
  ///
  /// Can be purchased before official release.
  /// Has a future availability date.
  preOrder,

  /// Product is discontinued.
  ///
  /// No longer available for purchase.
  /// May show "No longer available" message.
  discontinued,

  /// Product is coming soon.
  ///
  /// Not yet available for purchase.
  /// May allow notification signup.
  comingSoon,

  /// Product availability is managed externally.
  ///
  /// Stock is checked in real-time from external source.
  /// May have variable availability.
  external,

  /// Product doesn't track inventory.
  ///
  /// Always considered in stock (e.g., digital products).
  /// No quantity limits.
  notTracked,
}

/// Extension methods for [StockStatus].
extension StockStatusExtension on StockStatus {
  /// Returns `true` if the product can be purchased with this status.
  bool get canPurchase {
    switch (this) {
      case StockStatus.inStock:
      case StockStatus.onBackorder:
      case StockStatus.lowStock:
      case StockStatus.preOrder:
      case StockStatus.notTracked:
        return true;
      case StockStatus.outOfStock:
      case StockStatus.discontinued:
      case StockStatus.comingSoon:
      case StockStatus.external:
        return false;
    }
  }

  /// Returns `true` if the product should show a warning message.
  bool get shouldShowWarning {
    switch (this) {
      case StockStatus.lowStock:
      case StockStatus.onBackorder:
      case StockStatus.preOrder:
        return true;
      default:
        return false;
    }
  }

  /// Returns `true` if the product should show an unavailable state.
  bool get isUnavailable {
    switch (this) {
      case StockStatus.outOfStock:
      case StockStatus.discontinued:
      case StockStatus.comingSoon:
        return true;
      default:
        return false;
    }
  }

  /// Returns `true` if a notification option should be shown.
  bool get showNotifyOption {
    switch (this) {
      case StockStatus.outOfStock:
      case StockStatus.comingSoon:
      case StockStatus.preOrder:
        return true;
      default:
        return false;
    }
  }

  /// Returns the display text for this status.
  String get displayText {
    switch (this) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
      case StockStatus.onBackorder:
        return 'On Backorder';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.preOrder:
        return 'Pre-Order';
      case StockStatus.discontinued:
        return 'Discontinued';
      case StockStatus.comingSoon:
        return 'Coming Soon';
      case StockStatus.external:
        return 'Check Availability';
      case StockStatus.notTracked:
        return 'Available';
    }
  }

  /// Returns the color name suggestion for this status.
  String get suggestedColor {
    switch (this) {
      case StockStatus.inStock:
      case StockStatus.notTracked:
        return 'green';
      case StockStatus.lowStock:
      case StockStatus.onBackorder:
      case StockStatus.preOrder:
        return 'orange';
      case StockStatus.outOfStock:
      case StockStatus.discontinued:
        return 'red';
      case StockStatus.comingSoon:
      case StockStatus.external:
        return 'blue';
    }
  }

  /// Returns a message to display to the user.
  String getMessage({int? quantity}) {
    switch (this) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.outOfStock:
        return 'Currently unavailable';
      case StockStatus.onBackorder:
        return 'Available on backorder';
      case StockStatus.lowStock:
        if (quantity != null) {
          return 'Only $quantity left in stock';
        }
        return 'Limited stock available';
      case StockStatus.preOrder:
        return 'Available for pre-order';
      case StockStatus.discontinued:
        return 'This product has been discontinued';
      case StockStatus.comingSoon:
        return 'Coming soon';
      case StockStatus.external:
        return 'Availability varies';
      case StockStatus.notTracked:
        return 'Available';
    }
  }
}
