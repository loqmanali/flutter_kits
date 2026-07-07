import '../../core/models/cart.dart';
import '../../core/models/cart_item.dart';
import '../repositories/cart_repository.dart';

/// Use case for updating cart items.
class UpdateCartItemUseCase {
  final CartRepository _repository;

  UpdateCartItemUseCase(this._repository);

  /// Updates an item's quantity.
  Future<Cart> updateQuantity(String itemId, int quantity) async {
    return _repository.updateQuantity(itemId, quantity);
  }

  /// Increments an item's quantity.
  Future<Cart> increment(String itemId, [int amount = 1]) async {
    final cart = await _repository.getCart();
    final item = cart.getItem(itemId);
    if (item == null) return cart;
    return _repository.updateQuantity(itemId, item.quantity + amount);
  }

  /// Decrements an item's quantity.
  Future<Cart> decrement(String itemId, [int amount = 1]) async {
    final cart = await _repository.getCart();
    final item = cart.getItem(itemId);
    if (item == null) return cart;
    final newQuantity = item.quantity - amount;
    if (newQuantity <= 0) {
      return _repository.removeItem(itemId);
    }
    return _repository.updateQuantity(itemId, newQuantity);
  }

  /// Updates an item's note.
  Future<Cart> updateNote(String itemId, String? note) async {
    final cart = await _repository.getCart();
    final item = cart.getItem(itemId);
    if (item == null) return cart;
    return _repository.updateItem(itemId, item.withNote(note));
  }

  /// Replaces an item completely.
  Future<Cart> replaceItem(String itemId, CartItem newItem) async {
    return _repository.updateItem(itemId, newItem);
  }
}
