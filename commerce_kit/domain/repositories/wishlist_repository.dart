import '../../core/models/product.dart';
import '../../core/models/wishlist.dart';

/// Abstract repository interface for wishlist operations.
///
/// Implement this interface to provide wishlist functionality
/// with your preferred data source (local, remote, or both).
///
/// ## Usage
///
/// ```dart
/// class ApiWishlistRepository implements WishlistRepository {
///   final ApiClient _client;
///   final LocalStorage _localStorage;
///
///   ApiWishlistRepository(this._client, this._localStorage);
///
///   @override
///   Future<Wishlist> getWishlist() async {
///     try {
///       final response = await _client.get('/wishlist');
///       return Wishlist.fromJson(response.data);
///     } catch (e) {
///       // Fallback to local storage
///       return _localStorage.getWishlist() ?? Wishlist.empty();
///     }
///   }
///
///   // ... implement other methods
/// }
/// ```
abstract class WishlistRepository {
  /// Gets the current user's default wishlist.
  ///
  /// Returns the wishlist or an empty wishlist if none exists.
  Future<Wishlist> getWishlist();

  /// Gets all wishlists for the current user.
  ///
  /// Supports multiple wishlists feature.
  Future<List<Wishlist>> getAllWishlists();

  /// Gets a specific wishlist by ID.
  ///
  /// Returns the wishlist or null if not found.
  Future<Wishlist?> getWishlistById(String wishlistId);

  /// Creates a new wishlist.
  ///
  /// [name] - Name for the new wishlist.
  /// [description] - Optional description.
  /// [isPublic] - Whether the wishlist is publicly shareable.
  ///
  /// Returns the created wishlist.
  Future<Wishlist> createWishlist({
    required String name,
    String? description,
    bool isPublic = false,
  });

  /// Updates a wishlist's details.
  ///
  /// [wishlistId] - ID of the wishlist to update.
  /// [name] - New name (optional).
  /// [description] - New description (optional).
  /// [isPublic] - New visibility setting (optional).
  ///
  /// Returns the updated wishlist.
  Future<Wishlist> updateWishlist(
    String wishlistId, {
    String? name,
    String? description,
    bool? isPublic,
  });

  /// Deletes a wishlist.
  ///
  /// [wishlistId] - ID of the wishlist to delete.
  Future<void> deleteWishlist(String wishlistId);

  /// Adds a product to a wishlist.
  ///
  /// [product] - The product to add.
  /// [wishlistId] - Optional wishlist ID (uses default if not provided).
  /// [note] - Optional note for the item.
  /// [notification] - Optional notification settings.
  ///
  /// Returns the updated wishlist.
  Future<Wishlist> addProduct(
    Product product, {
    String? wishlistId,
    String? note,
    WishlistNotification? notification,
  });

  /// Removes a product from a wishlist.
  ///
  /// [productId] - ID of the product to remove.
  /// [wishlistId] - Optional wishlist ID (uses default if not provided).
  ///
  /// Returns the updated wishlist.
  Future<Wishlist> removeProduct(
    String productId, {
    String? wishlistId,
  });

  /// Checks if a product is in the wishlist.
  ///
  /// [productId] - ID of the product to check.
  /// [wishlistId] - Optional wishlist ID (checks default if not provided).
  Future<bool> isInWishlist(String productId, {String? wishlistId});

  /// Updates a wishlist item.
  ///
  /// [productId] - ID of the product.
  /// [wishlistId] - Optional wishlist ID.
  /// [note] - New note (optional).
  /// [priority] - New priority (optional).
  /// [notification] - New notification settings (optional).
  ///
  /// Returns the updated wishlist.
  Future<Wishlist> updateItem(
    String productId, {
    String? wishlistId,
    String? note,
    int? priority,
    WishlistNotification? notification,
  });

  /// Marks an item as purchased.
  ///
  /// [productId] - ID of the product.
  /// [wishlistId] - Optional wishlist ID.
  ///
  /// Returns the updated wishlist.
  Future<Wishlist> markAsPurchased(
    String productId, {
    String? wishlistId,
  });

  /// Moves an item to another wishlist.
  ///
  /// [productId] - ID of the product to move.
  /// [fromWishlistId] - Source wishlist ID.
  /// [toWishlistId] - Destination wishlist ID.
  ///
  /// Returns the updated destination wishlist.
  Future<Wishlist> moveItem(
    String productId, {
    required String fromWishlistId,
    required String toWishlistId,
  });

  /// Clears all items from a wishlist.
  ///
  /// [wishlistId] - Optional wishlist ID (clears default if not provided).
  ///
  /// Returns the empty wishlist.
  Future<Wishlist> clearWishlist({String? wishlistId});

  /// Saves the wishlist locally (for offline support).
  ///
  /// [wishlist] - The wishlist to save.
  Future<void> saveLocally(Wishlist wishlist);

  /// Syncs local wishlist with remote.
  ///
  /// Returns the synced wishlist.
  Future<Wishlist> sync();

  /// Stream of wishlist changes.
  Stream<Wishlist> get wishlistStream;
}
