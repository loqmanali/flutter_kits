/// Defines the type of operation performed on the cart.
///
/// This enum is useful for tracking cart events, analytics,
/// and handling different cart operations uniformly.
///
/// ## Usage
///
/// ```dart
/// void onCartOperation(CartOperation operation, CartItem item) {
///   switch (operation) {
///     case CartOperation.add:
///       analytics.trackAddToCart(item);
///       break;
///     case CartOperation.remove:
///       analytics.trackRemoveFromCart(item);
///       break;
///     // ...
///   }
/// }
/// ```
enum CartOperation {
  /// Item was added to the cart.
  add,

  /// Item was removed from the cart.
  remove,

  /// Item quantity was increased.
  incrementQuantity,

  /// Item quantity was decreased.
  decrementQuantity,

  /// Item quantity was updated to a specific value.
  updateQuantity,

  /// Item options/variants were updated.
  updateOptions,

  /// Item note/special instructions were updated.
  updateNote,

  /// Entire cart was cleared.
  clear,

  /// Discount/coupon was applied.
  applyDiscount,

  /// Discount/coupon was removed.
  removeDiscount,

  /// Cart was loaded from storage.
  load,

  /// Cart was saved to storage.
  save,

  /// Cart was synced with server.
  sync,

  /// Cart was merged (e.g., guest cart with user cart).
  merge,

  /// Cart item was moved to wishlist.
  moveToWishlist,

  /// Cart item was moved from wishlist.
  moveFromWishlist,
}

/// Extension methods for [CartOperation].
extension CartOperationExtension on CartOperation {
  /// Returns `true` if this operation adds items to the cart.
  bool get isAddOperation =>
      this == CartOperation.add || this == CartOperation.moveFromWishlist;

  /// Returns `true` if this operation removes items from the cart.
  bool get isRemoveOperation =>
      this == CartOperation.remove ||
      this == CartOperation.clear ||
      this == CartOperation.moveToWishlist;

  /// Returns `true` if this operation modifies existing items.
  bool get isUpdateOperation {
    switch (this) {
      case CartOperation.incrementQuantity:
      case CartOperation.decrementQuantity:
      case CartOperation.updateQuantity:
      case CartOperation.updateOptions:
      case CartOperation.updateNote:
        return true;
      default:
        return false;
    }
  }

  /// Returns `true` if this operation affects pricing.
  bool get affectsPricing {
    switch (this) {
      case CartOperation.add:
      case CartOperation.remove:
      case CartOperation.incrementQuantity:
      case CartOperation.decrementQuantity:
      case CartOperation.updateQuantity:
      case CartOperation.updateOptions:
      case CartOperation.clear:
      case CartOperation.applyDiscount:
      case CartOperation.removeDiscount:
      case CartOperation.merge:
        return true;
      default:
        return false;
    }
  }

  /// Returns `true` if this operation should be tracked for analytics.
  bool get shouldTrack {
    switch (this) {
      case CartOperation.add:
      case CartOperation.remove:
      case CartOperation.clear:
      case CartOperation.applyDiscount:
      case CartOperation.moveToWishlist:
        return true;
      default:
        return false;
    }
  }

  /// Returns `true` if this operation requires persistence.
  bool get requiresPersistence {
    switch (this) {
      case CartOperation.load:
        return false;
      default:
        return true;
    }
  }

  /// Returns the display name for this operation.
  String get displayName {
    switch (this) {
      case CartOperation.add:
        return 'Add to Cart';
      case CartOperation.remove:
        return 'Remove from Cart';
      case CartOperation.incrementQuantity:
        return 'Increase Quantity';
      case CartOperation.decrementQuantity:
        return 'Decrease Quantity';
      case CartOperation.updateQuantity:
        return 'Update Quantity';
      case CartOperation.updateOptions:
        return 'Update Options';
      case CartOperation.updateNote:
        return 'Update Note';
      case CartOperation.clear:
        return 'Clear Cart';
      case CartOperation.applyDiscount:
        return 'Apply Discount';
      case CartOperation.removeDiscount:
        return 'Remove Discount';
      case CartOperation.load:
        return 'Load Cart';
      case CartOperation.save:
        return 'Save Cart';
      case CartOperation.sync:
        return 'Sync Cart';
      case CartOperation.merge:
        return 'Merge Carts';
      case CartOperation.moveToWishlist:
        return 'Move to Wishlist';
      case CartOperation.moveFromWishlist:
        return 'Move from Wishlist';
    }
  }

  /// Returns the past tense of this operation for notifications.
  String get pastTense {
    switch (this) {
      case CartOperation.add:
        return 'Added to cart';
      case CartOperation.remove:
        return 'Removed from cart';
      case CartOperation.incrementQuantity:
        return 'Quantity increased';
      case CartOperation.decrementQuantity:
        return 'Quantity decreased';
      case CartOperation.updateQuantity:
        return 'Quantity updated';
      case CartOperation.updateOptions:
        return 'Options updated';
      case CartOperation.updateNote:
        return 'Note updated';
      case CartOperation.clear:
        return 'Cart cleared';
      case CartOperation.applyDiscount:
        return 'Discount applied';
      case CartOperation.removeDiscount:
        return 'Discount removed';
      case CartOperation.load:
        return 'Cart loaded';
      case CartOperation.save:
        return 'Cart saved';
      case CartOperation.sync:
        return 'Cart synced';
      case CartOperation.merge:
        return 'Carts merged';
      case CartOperation.moveToWishlist:
        return 'Moved to wishlist';
      case CartOperation.moveFromWishlist:
        return 'Added from wishlist';
    }
  }
}
