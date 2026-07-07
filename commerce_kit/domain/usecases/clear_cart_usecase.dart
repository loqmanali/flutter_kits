import '../../core/models/cart.dart';
import '../repositories/cart_repository.dart';

/// Use case for clearing the cart.
class ClearCartUseCase {
  final CartRepository _repository;

  ClearCartUseCase(this._repository);

  /// Clears all items from the cart.
  Future<Cart> call() async {
    return _repository.clearCart();
  }
}
