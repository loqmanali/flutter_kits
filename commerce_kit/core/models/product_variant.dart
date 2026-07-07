import 'package:equatable/equatable.dart';

import '../enums/stock_status.dart';
import 'money.dart';
import 'product_image.dart';

/// Represents a specific variant of a variable product.
///
/// A variant is a unique combination of option values that creates a distinct
/// purchasable item. For example, a "Double Burger with Cheese" might be a
/// variant of the base "Burger" product.
///
/// ## Difference from Options
///
/// - **Options**: Define what choices are available (Size: S/M/L)
/// - **Variants**: Define specific combinations with their own SKU, price, stock
///
/// ## Usage
///
/// ```dart
/// final variant = ProductVariant(
///   id: 'burger-double-cheese',
///   sku: 'BRG-DBL-CH',
///   name: 'Double Burger with Cheese',
///   price: Money(150),
///   selectedOptions: {
///     'size': 'double',
///     'cheese': 'yes',
///   },
///   stockQuantity: 50,
///   stockStatus: StockStatus.inStock,
/// );
/// ```
class ProductVariant extends Equatable {
  /// Unique identifier for this variant.
  final String id;

  /// Stock Keeping Unit - unique product code.
  final String? sku;

  /// The variant name (e.g., "Double - With Cheese").
  final String? name;

  /// The variant's price (overrides base product price).
  final Money price;

  /// The original price before any discounts.
  final Money? compareAtPrice;

  /// The cost price (for profit calculations).
  final Money? costPrice;

  /// Map of option ID to selected value ID.
  ///
  /// Example: {'size': 'double', 'cheese': 'yes'}
  final Map<String, String> selectedOptions;

  /// Images specific to this variant.
  final List<ProductImage> images;

  /// The stock status of this variant.
  final StockStatus stockStatus;

  /// The available quantity in stock.
  final int? stockQuantity;

  /// Whether this variant is available for purchase.
  final bool isAvailable;

  /// Whether this is the default variant.
  final bool isDefault;

  /// The weight of this variant (for shipping).
  final double? weight;

  /// The weight unit (kg, g, lb, oz).
  final String? weightUnit;

  /// Barcode/UPC/EAN for this variant.
  final String? barcode;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a [ProductVariant] instance.
  const ProductVariant({
    required this.id,
    this.sku,
    this.name,
    required this.price,
    this.compareAtPrice,
    this.costPrice,
    this.selectedOptions = const {},
    this.images = const [],
    this.stockStatus = StockStatus.inStock,
    this.stockQuantity,
    this.isAvailable = true,
    this.isDefault = false,
    this.weight,
    this.weightUnit,
    this.barcode,
    this.metadata,
  });

  /// Creates a [ProductVariant] from JSON.
  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id']?.toString() ?? '',
      sku: json['sku'],
      name: json['name'] ?? json['title'],
      price: json['price'] != null
          ? (json['price'] is Map
              ? Money.fromJson(json['price'] as Map<String, dynamic>)
              : Money((json['price'] as num).toDouble()))
          : const Money.zero(),
      compareAtPrice: json['compare_at_price'] != null ||
              json['compareAtPrice'] != null ||
              json['original_price'] != null
          ? Money.fromJson({
              'amount': json['compare_at_price'] ??
                  json['compareAtPrice'] ??
                  json['original_price'],
            })
          : null,
      costPrice: json['cost_price'] != null || json['costPrice'] != null
          ? Money.fromJson(
              {'amount': json['cost_price'] ?? json['costPrice']},
            )
          : null,
      selectedOptions: _parseOptions(
        json['selected_options'] ??
            json['selectedOptions'] ??
            json['options'] ??
            json['attributes'],
      ),
      images: (json['images'] as List<dynamic>?)
              ?.map((i) => ProductImage.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      stockStatus:
          _parseStockStatus(json['stock_status'] ?? json['stockStatus']),
      stockQuantity: json['stock_quantity'] ??
          json['stockQuantity'] ??
          json['quantity'] ??
          json['inventory_quantity'],
      isAvailable: json['is_available'] ??
          json['isAvailable'] ??
          json['available'] ??
          true,
      isDefault:
          json['is_default'] ?? json['isDefault'] ?? json['default'] ?? false,
      weight: (json['weight'] as num?)?.toDouble(),
      weightUnit: json['weight_unit'] ?? json['weightUnit'],
      barcode: json['barcode'] ?? json['upc'] ?? json['ean'],
      metadata: json['metadata'],
    );
  }

  /// Converts this [ProductVariant] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        if (sku != null) 'sku': sku,
        if (name != null) 'name': name,
        'price': price.toJson(),
        if (compareAtPrice != null)
          'compare_at_price': compareAtPrice!.toJson(),
        if (costPrice != null) 'cost_price': costPrice!.toJson(),
        'selected_options': selectedOptions,
        'images': images.map((i) => i.toJson()).toList(),
        'stock_status': stockStatus.name,
        if (stockQuantity != null) 'stock_quantity': stockQuantity,
        'is_available': isAvailable,
        'is_default': isDefault,
        if (weight != null) 'weight': weight,
        if (weightUnit != null) 'weight_unit': weightUnit,
        if (barcode != null) 'barcode': barcode,
        if (metadata != null) 'metadata': metadata,
      };

  /// Returns the primary image for this variant.
  ProductImage? get primaryImage {
    if (images.isEmpty) return null;
    try {
      return images.firstWhere((i) => i.isPrimary);
    } catch (_) {
      return images.first;
    }
  }

  /// Returns `true` if this variant is on sale.
  bool get isOnSale =>
      compareAtPrice != null && compareAtPrice!.amount > price.amount;

  /// Returns the discount percentage if on sale.
  double? get discountPercentage {
    if (!isOnSale) return null;
    return ((compareAtPrice!.amount - price.amount) / compareAtPrice!.amount) *
        100;
  }

  /// Returns the savings amount if on sale.
  Money? get savings {
    if (!isOnSale) return null;
    return compareAtPrice! - price;
  }

  /// Returns `true` if this variant can be purchased.
  bool get canPurchase => isAvailable && stockStatus.canPurchase;

  /// Returns `true` if stock is low.
  bool get isLowStock =>
      stockStatus == StockStatus.lowStock ||
      (stockQuantity != null && stockQuantity! > 0 && stockQuantity! <= 5);

  /// Returns a formatted string of selected options.
  String get optionsSummary {
    return selectedOptions.values.join(' / ');
  }

  /// Generates a unique key based on selected options.
  String get optionsKey {
    final sorted = selectedOptions.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((e) => '${e.key}:${e.value}').join('|');
  }

  /// Checks if this variant matches the given option selections.
  bool matchesOptions(Map<String, String> options) {
    for (final entry in options.entries) {
      if (selectedOptions[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  /// Copies this [ProductVariant] with optional new values.
  ProductVariant copyWith({
    String? id,
    String? sku,
    String? name,
    Money? price,
    Money? compareAtPrice,
    Money? costPrice,
    Map<String, String>? selectedOptions,
    List<ProductImage>? images,
    StockStatus? stockStatus,
    int? stockQuantity,
    bool? isAvailable,
    bool? isDefault,
    double? weight,
    String? weightUnit,
    String? barcode,
    Map<String, dynamic>? metadata,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      costPrice: costPrice ?? this.costPrice,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      images: images ?? this.images,
      stockStatus: stockStatus ?? this.stockStatus,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isAvailable: isAvailable ?? this.isAvailable,
      isDefault: isDefault ?? this.isDefault,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      barcode: barcode ?? this.barcode,
      metadata: metadata ?? this.metadata,
    );
  }

  static Map<String, String> _parseOptions(dynamic options) {
    if (options == null) return {};
    if (options is Map) {
      return Map<String, String>.from(
        options.map((key, value) => MapEntry(key.toString(), value.toString())),
      );
    }
    if (options is List) {
      final result = <String, String>{};
      for (final opt in options) {
        if (opt is Map) {
          final key = opt['option_id'] ?? opt['optionId'] ?? opt['name'] ?? '';
          final value = opt['value_id'] ?? opt['valueId'] ?? opt['value'] ?? '';
          result[key.toString()] = value.toString();
        }
      }
      return result;
    }
    return {};
  }

  static StockStatus _parseStockStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'in_stock':
      case 'instock':
        return StockStatus.inStock;
      case 'out_of_stock':
      case 'outofstock':
        return StockStatus.outOfStock;
      case 'on_backorder':
      case 'backorder':
        return StockStatus.onBackorder;
      case 'low_stock':
      case 'lowstock':
        return StockStatus.lowStock;
      case 'preorder':
      case 'pre_order':
        return StockStatus.preOrder;
      default:
        return StockStatus.inStock;
    }
  }

  @override
  List<Object?> get props => [
        id,
        sku,
        name,
        price,
        compareAtPrice,
        selectedOptions,
        stockStatus,
        stockQuantity,
        isAvailable,
        isDefault,
      ];
}
