import '../../core/models/cart.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/money.dart';
import '../../core/models/product.dart';
import '../../core/models/product_image.dart';

/// Utility class for mapping cart data between formats.
class CartMapper {
  CartMapper._();

  /// Creates a CartItem from basic data.
  static CartItem createCartItem({
    required String productId,
    required String name,
    required double price,
    int quantity = 1,
    String? imageUrl,
    String? note,
    String currency = 'EGP',
  }) {
    return CartItem(
      id: 'cart_${productId}_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      name: name,
      price: Money(price, currency: currency),
      quantity: quantity,
      image: imageUrl != null
          ? ProductImage.network(id: '0', url: imageUrl)
          : null,
      note: note,
      addedAt: DateTime.now(),
    );
  }

  /// Creates a CartItem from a Product.
  static CartItem fromProduct(
    Product product, {
    int quantity = 1,
    String? note,
    Map<String, SelectedOption>? selectedOptions,
  }) {
    return CartItem.fromProduct(
      product,
      cartItemId: 'cart_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
      quantity: quantity,
      note: note,
      selectedOptions: selectedOptions,
    );
  }

  /// Converts cart to a summary map for API requests.
  static Map<String, dynamic> cartToApiRequest(Cart cart) {
    return {
      'items': cart.items
          .map(
            (item) => {
              'product_id': item.productId,
              'variant_id': item.variantId,
              'quantity': item.quantity,
              'note': item.note,
              'options': item.selectedOptions.map(
                (k, v) => MapEntry(k, {'value_id': v.valueId}),
              ),
            },
          )
          .toList(),
      'coupon_code': cart.couponCode,
      'note': cart.note,
    };
  }

  /// Creates a cart from API response.
  static Cart cartFromApiResponse(Map<String, dynamic> response) {
    return Cart.fromJson(response);
  }
}
