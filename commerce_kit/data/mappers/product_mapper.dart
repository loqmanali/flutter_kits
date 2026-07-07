import '../../core/models/money.dart';
import '../../core/models/product.dart';
import '../../core/models/product_image.dart';
import '../../core/models/product_option.dart';
import '../../core/models/product_variant.dart';

/// Utility class for mapping product data between formats.
class ProductMapper {
  ProductMapper._();

  /// Maps a simple JSON structure to a Product.
  static Product fromSimpleJson({
    required String id,
    required String name,
    required double price,
    String? description,
    String? imageUrl,
    String currency = 'EGP',
  }) {
    return Product.simple(
      id: id,
      name: name,
      price: Money(price, currency: currency),
      description: description,
      images: imageUrl != null
          ? [ProductImage.network(id: '0', url: imageUrl, isPrimary: true)]
          : [],
    );
  }

  /// Maps product with variants from structured data.
  static Product fromVariableData({
    required String id,
    required String name,
    required double basePrice,
    required List<Map<String, dynamic>> options,
    required List<Map<String, dynamic>> variants,
    String? description,
    List<String>? imageUrls,
    String currency = 'EGP',
  }) {
    return Product.variable(
      id: id,
      name: name,
      basePrice: Money(basePrice, currency: currency),
      description: description,
      options: options.map((o) => ProductOption.fromJson(o)).toList(),
      variants: variants.map((v) => ProductVariant.fromJson(v)).toList(),
      images: imageUrls
              ?.asMap()
              .entries
              .map(
                (e) => ProductImage.network(
                  id: e.key.toString(),
                  url: e.value,
                  isPrimary: e.key == 0,
                ),
              )
              .toList() ??
          [],
    );
  }
}
