import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/product.dart';
import '../../core/models/wishlist.dart';

/// State for wishlist management.
class WishlistState {
  /// The current wishlist.
  final Wishlist wishlist;

  /// Whether an operation is in progress.
  final bool isLoading;

  /// Error message if any.
  final String? error;

  /// All user wishlists (for multiple wishlists support).
  final List<Wishlist> allWishlists;

  const WishlistState({
    required this.wishlist,
    this.isLoading = false,
    this.error,
    this.allWishlists = const [],
  });

  /// Creates initial state.
  factory WishlistState.initial() {
    return WishlistState(
      wishlist: Wishlist.empty(),
    );
  }

  WishlistState copyWith({
    Wishlist? wishlist,
    bool? isLoading,
    String? error,
    List<Wishlist>? allWishlists,
    bool clearError = false,
  }) {
    return WishlistState(
      wishlist: wishlist ?? this.wishlist,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      allWishlists: allWishlists ?? this.allWishlists,
    );
  }
}

/// Notifier for wishlist operations.
class WishlistNotifier extends Notifier<WishlistState> {
  /// Callback to persist wishlist changes.
  Future<void> Function(Wishlist wishlist)? _persistCallback;

  /// Callback to load wishlist.
  Future<Wishlist?> Function()? _loadCallback;

  @override
  WishlistState build() {
    return WishlistState.initial();
  }

  /// Sets persistence callback.
  void setPersistCallback(Future<void> Function(Wishlist wishlist) callback) {
    _persistCallback = callback;
  }

  /// Sets load callback.
  void setLoadCallback(Future<Wishlist?> Function() callback) {
    _loadCallback = callback;
  }

  /// Loads the wishlist from storage/API.
  Future<void> load() async {
    if (_loadCallback == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final wishlist = await _loadCallback!();
      if (wishlist != null) {
        state = state.copyWith(
          wishlist: wishlist,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Adds a product to the wishlist.
  Future<void> addProduct(Product product, {String? note}) async {
    if (state.wishlist.containsProduct(product.id)) return;

    final updatedWishlist = state.wishlist.addProduct(product, note: note);
    state = state.copyWith(wishlist: updatedWishlist);

    await _persist();
  }

  /// Removes a product from the wishlist.
  Future<void> removeProduct(String productId) async {
    if (!state.wishlist.containsProduct(productId)) return;

    final updatedWishlist = state.wishlist.removeProduct(productId);
    state = state.copyWith(wishlist: updatedWishlist);

    await _persist();
  }

  /// Toggles a product in the wishlist.
  Future<void> toggleProduct(Product product, {String? note}) async {
    if (state.wishlist.containsProduct(product.id)) {
      await removeProduct(product.id);
    } else {
      await addProduct(product, note: note);
    }
  }

  /// Checks if a product is in the wishlist.
  bool containsProduct(String productId) {
    return state.wishlist.containsProduct(productId);
  }

  /// Updates a wishlist item note.
  Future<void> updateItemNote(String productId, String? note) async {
    final updatedWishlist = state.wishlist.updateItem(
      productId,
      (item) => item.copyWith(note: note),
    );
    state = state.copyWith(wishlist: updatedWishlist);

    await _persist();
  }

  /// Updates a wishlist item priority.
  Future<void> updateItemPriority(String productId, int priority) async {
    final updatedWishlist = state.wishlist.updateItem(
      productId,
      (item) => item.copyWith(priority: priority),
    );
    state = state.copyWith(wishlist: updatedWishlist);

    await _persist();
  }

  /// Marks a wishlist item as purchased.
  Future<void> markAsPurchased(String productId) async {
    final updatedWishlist = state.wishlist.updateItem(
      productId,
      (item) => item.markPurchased(),
    );
    state = state.copyWith(wishlist: updatedWishlist);

    await _persist();
  }

  /// Clears the wishlist.
  Future<void> clear() async {
    final updatedWishlist = state.wishlist.clear();
    state = state.copyWith(wishlist: updatedWishlist);

    await _persist();
  }

  /// Updates wishlist metadata.
  Future<void> updateWishlistName(String name) async {
    final updatedWishlist = state.wishlist.copyWith(name: name);
    state = state.copyWith(wishlist: updatedWishlist);

    await _persist();
  }

  /// Sets wishlist visibility.
  Future<void> setPublic(bool isPublic) async {
    final updatedWishlist = state.wishlist.copyWith(isPublic: isPublic);
    state = state.copyWith(wishlist: updatedWishlist);

    await _persist();
  }

  /// Sets notification preferences for an item.
  Future<void> setItemNotification(
    String productId,
    WishlistNotification notification,
  ) async {
    final updatedWishlist = state.wishlist.updateItem(
      productId,
      (item) => item.copyWith(notification: notification),
    );
    state = state.copyWith(wishlist: updatedWishlist);

    await _persist();
  }

  /// Persists changes.
  Future<void> _persist() async {
    if (_persistCallback != null) {
      try {
        await _persistCallback!(state.wishlist);
      } catch (e) {
        state = state.copyWith(error: 'Failed to save wishlist: $e');
      }
    }
  }
}

/// Provider for wishlist state.
final wishlistProvider = NotifierProvider<WishlistNotifier, WishlistState>(
  WishlistNotifier.new,
);

/// Provider for the current wishlist.
final currentWishlistProvider = Provider<Wishlist>((ref) {
  return ref.watch(wishlistProvider.select((s) => s.wishlist));
});

/// Provider for wishlist items.
final wishlistItemsProvider = Provider<List<WishlistItem>>((ref) {
  return ref.watch(wishlistProvider.select((s) => s.wishlist.items));
});

/// Provider for wishlist item count.
final wishlistItemCountProvider = Provider<int>((ref) {
  return ref.watch(wishlistProvider.select((s) => s.wishlist.itemCount));
});

/// Provider for wishlist loading state.
final wishlistLoadingProvider = Provider<bool>((ref) {
  return ref.watch(wishlistProvider.select((s) => s.isLoading));
});

/// Provider for wishlist error.
final wishlistErrorProvider = Provider<String?>((ref) {
  return ref.watch(wishlistProvider.select((s) => s.error));
});

/// Provider for checking if a product is in the wishlist.
final isInWishlistProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(
    wishlistProvider.select((s) => s.wishlist.containsProduct(productId)),
  );
});

/// Provider for wishlist product IDs.
final wishlistProductIdsProvider = Provider<List<String>>((ref) {
  return ref.watch(wishlistProvider.select((s) => s.wishlist.productIds));
});

/// Provider for unpurchased wishlist items.
final unpurchasedWishlistItemsProvider = Provider<List<WishlistItem>>((ref) {
  return ref.watch(
    wishlistProvider.select(
      (s) => s.wishlist.items.where((i) => !i.isPurchased).toList(),
    ),
  );
});

/// Provider for purchased wishlist items.
final purchasedWishlistItemsProvider = Provider<List<WishlistItem>>((ref) {
  return ref.watch(
    wishlistProvider.select(
      (s) => s.wishlist.items.where((i) => i.isPurchased).toList(),
    ),
  );
});

/// Provider for on-sale wishlist items.
final onSaleWishlistItemsProvider = Provider<List<WishlistItem>>((ref) {
  return ref.watch(
    wishlistProvider.select(
      (s) => s.wishlist.items.where((i) => i.isOnSale).toList(),
    ),
  );
});
