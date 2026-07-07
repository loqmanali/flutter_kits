import '../../core/models/product.dart';
import '../../core/models/wishlist.dart';
import '../repositories/wishlist_repository.dart';

/// Use case for getting the current wishlist.
class GetWishlistUseCase {
  final WishlistRepository _repository;

  GetWishlistUseCase(this._repository);

  /// Gets the current user's default wishlist.
  Future<Wishlist> call() async {
    return _repository.getWishlist();
  }
}

/// Use case for getting all wishlists.
class GetAllWishlistsUseCase {
  final WishlistRepository _repository;

  GetAllWishlistsUseCase(this._repository);

  /// Gets all wishlists for the current user.
  Future<List<Wishlist>> call() async {
    return _repository.getAllWishlists();
  }
}

/// Use case for adding a product to the wishlist.
class AddToWishlistUseCase {
  final WishlistRepository _repository;

  AddToWishlistUseCase(this._repository);

  /// Adds a product to the wishlist.
  Future<Wishlist> call(
    Product product, {
    String? wishlistId,
    String? note,
    WishlistNotification? notification,
  }) async {
    return _repository.addProduct(
      product,
      wishlistId: wishlistId,
      note: note,
      notification: notification,
    );
  }
}

/// Use case for removing a product from the wishlist.
class RemoveFromWishlistUseCase {
  final WishlistRepository _repository;

  RemoveFromWishlistUseCase(this._repository);

  /// Removes a product from the wishlist.
  Future<Wishlist> call(String productId, {String? wishlistId}) async {
    return _repository.removeProduct(productId, wishlistId: wishlistId);
  }
}

/// Use case for toggling a product in the wishlist.
class ToggleWishlistUseCase {
  final WishlistRepository _repository;

  ToggleWishlistUseCase(this._repository);

  /// Adds product if not in wishlist, removes if already in.
  Future<WishlistToggleResult> call(
    Product product, {
    String? wishlistId,
    String? note,
    WishlistNotification? notification,
  }) async {
    final isInWishlist = await _repository.isInWishlist(
      product.id,
      wishlistId: wishlistId,
    );

    if (isInWishlist) {
      final wishlist = await _repository.removeProduct(
        product.id,
        wishlistId: wishlistId,
      );
      return WishlistToggleResult(
        wishlist: wishlist,
        wasAdded: false,
      );
    } else {
      final wishlist = await _repository.addProduct(
        product,
        wishlistId: wishlistId,
        note: note,
        notification: notification,
      );
      return WishlistToggleResult(
        wishlist: wishlist,
        wasAdded: true,
      );
    }
  }
}

/// Result of toggling a product in the wishlist.
class WishlistToggleResult {
  /// The updated wishlist.
  final Wishlist wishlist;

  /// Whether the product was added (true) or removed (false).
  final bool wasAdded;

  const WishlistToggleResult({
    required this.wishlist,
    required this.wasAdded,
  });
}

/// Use case for checking if a product is in the wishlist.
class IsInWishlistUseCase {
  final WishlistRepository _repository;

  IsInWishlistUseCase(this._repository);

  /// Checks if a product is in the wishlist.
  Future<bool> call(String productId, {String? wishlistId}) async {
    return _repository.isInWishlist(productId, wishlistId: wishlistId);
  }
}

/// Use case for creating a new wishlist.
class CreateWishlistUseCase {
  final WishlistRepository _repository;

  CreateWishlistUseCase(this._repository);

  /// Creates a new wishlist.
  Future<Wishlist> call({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    if (name.isEmpty) {
      throw WishlistValidationException(['Wishlist name is required']);
    }

    return _repository.createWishlist(
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
}

/// Use case for updating a wishlist.
class UpdateWishlistUseCase {
  final WishlistRepository _repository;

  UpdateWishlistUseCase(this._repository);

  /// Updates a wishlist's details.
  Future<Wishlist> call(
    String wishlistId, {
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    return _repository.updateWishlist(
      wishlistId,
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
}

/// Use case for deleting a wishlist.
class DeleteWishlistUseCase {
  final WishlistRepository _repository;

  DeleteWishlistUseCase(this._repository);

  /// Deletes a wishlist.
  Future<void> call(String wishlistId) async {
    return _repository.deleteWishlist(wishlistId);
  }
}

/// Use case for updating notification settings.
class UpdateWishlistNotificationUseCase {
  final WishlistRepository _repository;

  UpdateWishlistNotificationUseCase(this._repository);

  /// Updates notification settings for a wishlist item.
  Future<Wishlist> call(
    String productId,
    WishlistNotification notification, {
    String? wishlistId,
  }) async {
    return _repository.updateItem(
      productId,
      wishlistId: wishlistId,
      notification: notification,
    );
  }
}

/// Use case for marking an item as purchased.
class MarkAsPurchasedUseCase {
  final WishlistRepository _repository;

  MarkAsPurchasedUseCase(this._repository);

  /// Marks a wishlist item as purchased.
  Future<Wishlist> call(String productId, {String? wishlistId}) async {
    return _repository.markAsPurchased(productId, wishlistId: wishlistId);
  }
}

/// Use case for moving an item between wishlists.
class MoveWishlistItemUseCase {
  final WishlistRepository _repository;

  MoveWishlistItemUseCase(this._repository);

  /// Moves an item from one wishlist to another.
  Future<Wishlist> call(
    String productId, {
    required String fromWishlistId,
    required String toWishlistId,
  }) async {
    return _repository.moveItem(
      productId,
      fromWishlistId: fromWishlistId,
      toWishlistId: toWishlistId,
    );
  }
}

/// Use case for clearing a wishlist.
class ClearWishlistUseCase {
  final WishlistRepository _repository;

  ClearWishlistUseCase(this._repository);

  /// Clears all items from a wishlist.
  Future<Wishlist> call({String? wishlistId}) async {
    return _repository.clearWishlist(wishlistId: wishlistId);
  }
}

/// Use case for syncing wishlist.
class SyncWishlistUseCase {
  final WishlistRepository _repository;

  SyncWishlistUseCase(this._repository);

  /// Syncs local wishlist with remote.
  Future<Wishlist> call() async {
    return _repository.sync();
  }
}

/// Exception thrown when wishlist validation fails.
class WishlistValidationException implements Exception {
  final List<String> errors;

  WishlistValidationException(this.errors);

  @override
  String toString() => errors.join(', ');
}
