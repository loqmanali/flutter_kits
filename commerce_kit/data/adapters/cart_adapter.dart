import '../../core/models/cart.dart';
import '../../core/models/cart_item.dart';

/// Abstract adapter for converting API responses to cart models.
abstract class CartAdapter<TCart, TCartItem> {
  Cart cartFromResponse(TCart response);
  CartItem cartItemFromResponse(TCartItem response);

  TCart cartToResponse(Cart cart) {
    throw UnimplementedError('cartToResponse not implemented');
  }

  TCartItem cartItemToResponse(CartItem item) {
    throw UnimplementedError('cartItemToResponse not implemented');
  }

  List<CartItem> cartItemsFromResponse(List<TCartItem> responses) {
    return responses.map(cartItemFromResponse).toList();
  }
}

/// Adapter for Map<String, dynamic> (JSON) to cart models.
class MapCartAdapter
    extends CartAdapter<Map<String, dynamic>, Map<String, dynamic>> {
  @override
  Cart cartFromResponse(Map<String, dynamic> response) =>
      Cart.fromJson(response);

  @override
  Map<String, dynamic> cartToResponse(Cart cart) => cart.toJson();

  @override
  CartItem cartItemFromResponse(Map<String, dynamic> response) =>
      CartItem.fromJson(response);

  @override
  Map<String, dynamic> cartItemToResponse(CartItem item) => item.toJson();
}
