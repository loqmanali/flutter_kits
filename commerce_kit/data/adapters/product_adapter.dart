import '../../core/models/product.dart';

/// Abstract adapter for converting API responses to [Product] models.
///
/// Implement this interface to map your specific API response format
/// to the commerce kit's internal [Product] model.
///
/// ## Usage
///
/// ```dart
/// class MyProductAdapter extends ProductAdapter<MyApiProduct> {
///   @override
///   Product fromResponse(MyApiProduct response) {
///     return Product(
///       id: response.productId,
///       name: response.title,
///       price: Money(response.cost),
///     );
///   }
/// }
/// ```
abstract class ProductAdapter<T> {
  /// Converts an API response to a [Product].
  Product fromResponse(T response);

  /// Converts a [Product] back to an API response format.
  T toResponse(Product product) {
    throw UnimplementedError('toResponse not implemented');
  }

  /// Converts a list of API responses to a list of [Product]s.
  List<Product> fromResponseList(List<T> responses) {
    return responses.map(fromResponse).toList();
  }

  /// Safely converts an API response, returning null on error.
  Product? tryFromResponse(T response) {
    try {
      return fromResponse(response);
    } catch (_) {
      return null;
    }
  }
}

/// Adapter for Map<String, dynamic> (JSON) to [Product].
class MapProductAdapter extends ProductAdapter<Map<String, dynamic>> {
  final Map<String, dynamic> Function(Map<String, dynamic>)? transformer;

  MapProductAdapter({this.transformer});

  @override
  Product fromResponse(Map<String, dynamic> response) {
    final json = transformer != null ? transformer!(response) : response;
    return Product.fromJson(json);
  }

  @override
  Map<String, dynamic> toResponse(Product product) => product.toJson();
}
