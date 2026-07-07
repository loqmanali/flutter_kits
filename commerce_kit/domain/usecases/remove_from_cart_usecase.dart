import '../../core/models/cart.dart';
import '../repositories/cart_repository.dart';

/// Use case for removing items from the cart.
class RemoveFromCartUseCase {
  final CartRepository _repository;

  RemoveFromCartUseCase(this._repository);

  /// Removes an item from the cart by ID.
  Future<Cart> call(String itemId) async {
    return _repository.removeItem(itemId);
  }

  /// Removes an item by product ID.
  Future<Cart> byProductId(String productId) async {
    final cart = await _repository.getCart();
    final item = cart.getItemByProductId(productId);
    if (item == null) return cart;
    return _repository.removeItem(item.id);
  }
}
