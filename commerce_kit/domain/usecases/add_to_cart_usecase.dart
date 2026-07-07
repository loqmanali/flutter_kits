import '../../core/models/cart.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/product.dart';
import '../../core/utils/cart_validator.dart';
import '../repositories/cart_repository.dart';

/// Use case for adding items to the cart.
class AddToCartUseCase {
  final CartRepository _repository;

  AddToCartUseCase(this._repository);

  /// Adds a cart item to the cart.
  Future<Cart> call(CartItem item) async {
    return _repository.addItem(item);
  }

  /// Adds a product to the cart with validation.
  Future<Cart> addProduct({
    required Product product,
    int quantity = 1,
    Map<String, SelectedOption>? selectedOptions,
    String? note,
    int? maxQuantity,
  }) async {
    // Validate
    final errors = CartValidator.validateAddToCart(
      product: product,
      quantity: quantity,
      maxQuantity: maxQuantity,
    );

    if (errors.isNotEmpty) {
      throw AddToCartException(errors);
    }

    final item = CartItem.fromProduct(
      product,
      cartItemId: 'cart_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
      quantity: quantity,
      selectedOptions: selectedOptions,
      note: note,
    );

    return _repository.addItem(item);
  }
}

/// Exception thrown when adding to cart fails.
class AddToCartException implements Exception {
  final List<String> errors;
  AddToCartException(this.errors);

  @override
  String toString() => errors.join(', ');
}
