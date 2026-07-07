import '../../core/models/product.dart';
import 'product_adapter.dart';

/// Configurable JSON product adapter with field mapping.
class JsonProductAdapter extends ProductAdapter<Map<String, dynamic>> {
  final JsonAdapterConfig config;

  JsonProductAdapter({required this.config});

  factory JsonProductAdapter.wooCommerce() => JsonProductAdapter(
        config: const JsonAdapterConfig(),
      );

  factory JsonProductAdapter.shopify() => JsonProductAdapter(
        config: const JsonAdapterConfig(
          nameField: 'title',
          priceField: 'variants.0.price',
          descriptionField: 'body_html',
        ),
      );

  @override
  Product fromResponse(Map<String, dynamic> response) {
    final transformed = _transformJson(response);
    return Product.fromJson(transformed);
  }

  Map<String, dynamic> _transformJson(Map<String, dynamic> json) {
    return {
      'id': _getValue(json, config.idField),
      'name': _getValue(json, config.nameField),
      'price': _getValue(json, config.priceField),
      if (config.descriptionField != null)
        'description': _getValue(json, config.descriptionField!),
      if (config.imagesField != null)
        'images': _getValue(json, config.imagesField!),
      if (config.skuField != null) 'sku': _getValue(json, config.skuField!),
    };
  }

  dynamic _getValue(Map<String, dynamic> json, String path) {
    final parts = path.split('.');
    dynamic current = json;
    for (final part in parts) {
      if (current == null) return null;
      if (current is Map) {
        current = current[part];
      } else if (current is List) {
        final index = int.tryParse(part);
        if (index == null || index >= current.length) return null;
        current = current[index];
      }
    }
    return current;
  }
}

/// Configuration for JSON field mapping.
class JsonAdapterConfig {
  final String idField;
  final String nameField;
  final String priceField;
  final String? descriptionField;
  final String? imagesField;
  final String? imageUrlField;
  final String? skuField;
  final String? stockField;
  final String defaultCurrency;

  const JsonAdapterConfig({
    this.idField = 'id',
    this.nameField = 'name',
    this.priceField = 'price',
    this.descriptionField = 'description',
    this.imagesField = 'images',
    this.imageUrlField = 'src',
    this.skuField,
    this.stockField,
    this.defaultCurrency = 'EGP',
  });
}
