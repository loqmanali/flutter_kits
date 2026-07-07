import 'package:equatable/equatable.dart';

import '../enums/product_type.dart';
import '../enums/stock_status.dart';
import 'money.dart';
import 'product_attribute.dart';
import 'product_image.dart';
import 'product_option.dart';
import 'product_variant.dart';

/// Represents a product in the e-commerce system.
///
/// This is the core product model that supports all product types:
/// simple, variable, grouped, bundle, digital, subscription, configurable.
///
/// ## Features
///
/// - Full variant support with options
/// - Multiple images
/// - Pricing with discounts
/// - Stock management
/// - Attributes and metadata
/// - Category and tag support
///
/// ## Usage
///
/// ```dart
/// // Simple product
/// final burger = Product(
///   id: '1',
///   name: 'Classic Burger',
///   slug: 'classic-burger',
///   type: ProductType.simple,
///   price: Money(99),
///   description: 'A delicious classic burger',
///   images: [ProductImage.network(id: '1', url: 'https://...')],
/// );
///
/// // Variable product with options
/// final customBurger = Product(
///   id: '2',
///   name: 'Custom Burger',
///   slug: 'custom-burger',
///   type: ProductType.variable,
///   price: Money(99), // Base price
///   options: [
///     ProductOption.size(
///       id: 'size',
///       name: 'Size',
///       values: [
///         ProductOptionValue.simple(id: 's', name: 'Single'),
///         ProductOptionValue.simple(id: 'd', name: 'Double', priceModifier: Money(25)),
///       ],
///     ),
///   ],
///   variants: [
///     ProductVariant(id: 'v1', price: Money(99), selectedOptions: {'size': 's'}),
///     ProductVariant(id: 'v2', price: Money(124), selectedOptions: {'size': 'd'}),
///   ],
/// );
/// ```
class Product extends Equatable {
  /// Unique identifier for this product.
  final String id;

  /// Stock Keeping Unit - unique product code.
  final String? sku;

  /// The product name.
  final String name;

  /// URL-friendly slug for this product.
  final String? slug;

  /// The product type.
  final ProductType type;

  /// Short description for product listings.
  final String? shortDescription;

  /// Full product description.
  final String? description;

  /// The base price of the product.
  final Money price;

  /// The original price before any discounts.
  final Money? compareAtPrice;

  /// The cost price (for profit calculations).
  final Money? costPrice;

  /// Product images.
  final List<ProductImage> images;

  /// Product options (for variable/configurable products).
  final List<ProductOption> options;

  /// Product variants (for variable products).
  final List<ProductVariant> variants;

  /// Product attributes (non-variant characteristics).
  final List<ProductAttribute> attributes;

  /// The stock status.
  final StockStatus stockStatus;

  /// The available quantity in stock.
  final int? stockQuantity;

  /// Whether the product is currently available.
  final bool isAvailable;

  /// Whether the product is featured.
  final bool isFeatured;

  /// Whether the product is new.
  final bool isNew;

  /// Category IDs this product belongs to.
  final List<String> categoryIds;

  /// Category names for display.
  final List<String> categoryNames;

  /// Tag IDs for this product.
  final List<String> tagIds;

  /// Tag names for display.
  final List<String> tagNames;

  /// The brand/manufacturer name.
  final String? brand;

  /// The weight of the product (for shipping).
  final double? weight;

  /// The weight unit (kg, g, lb, oz).
  final String? weightUnit;

  /// Product dimensions.
  final ProductDimensions? dimensions;

  /// Average rating (1-5).
  final double? rating;

  /// Number of reviews.
  final int? reviewCount;

  /// Related product IDs.
  final List<String> relatedProductIds;

  /// Upsell product IDs.
  final List<String> upsellProductIds;

  /// Cross-sell product IDs.
  final List<String> crossSellProductIds;

  /// SEO title.
  final String? seoTitle;

  /// SEO description.
  final String? seoDescription;

  /// The date this product was created.
  final DateTime? createdAt;

  /// The date this product was last updated.
  final DateTime? updatedAt;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a [Product] instance.
  const Product({
    required this.id,
    this.sku,
    required this.name,
    this.slug,
    this.type = ProductType.simple,
    this.shortDescription,
    this.description,
    required this.price,
    this.compareAtPrice,
    this.costPrice,
    this.images = const [],
    this.options = const [],
    this.variants = const [],
    this.attributes = const [],
    this.stockStatus = StockStatus.inStock,
    this.stockQuantity,
    this.isAvailable = true,
    this.isFeatured = false,
    this.isNew = false,
    this.categoryIds = const [],
    this.categoryNames = const [],
    this.tagIds = const [],
    this.tagNames = const [],
    this.brand,
    this.weight,
    this.weightUnit,
    this.dimensions,
    this.rating,
    this.reviewCount,
    this.relatedProductIds = const [],
    this.upsellProductIds = const [],
    this.crossSellProductIds = const [],
    this.seoTitle,
    this.seoDescription,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// Creates a simple product.
  factory Product.simple({
    required String id,
    required String name,
    required Money price,
    String? sku,
    String? slug,
    String? description,
    List<ProductImage> images = const [],
    List<ProductAttribute> attributes = const [],
    StockStatus stockStatus = StockStatus.inStock,
    int? stockQuantity,
  }) {
    return Product(
      id: id,
      sku: sku,
      name: name,
      slug: slug,
      // ignore: avoid_redundant_argument_values
      type: ProductType.simple,
      description: description,
      price: price,
      images: images,
      attributes: attributes,
      stockStatus: stockStatus,
      stockQuantity: stockQuantity,
    );
  }

  /// Creates a variable product with options.
  factory Product.variable({
    required String id,
    required String name,
    required Money basePrice,
    required List<ProductOption> options,
    List<ProductVariant> variants = const [],
    String? sku,
    String? slug,
    String? description,
    List<ProductImage> images = const [],
  }) {
    return Product(
      id: id,
      sku: sku,
      name: name,
      slug: slug,
      type: ProductType.variable,
      description: description,
      price: basePrice,
      images: images,
      options: options,
      variants: variants,
    );
  }

  /// Creates a [Product] from JSON.
  ///
  /// Supports multiple JSON formats from different e-commerce backends.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      sku: json['sku'],
      name: json['name'] ?? json['title'] ?? '',
      slug: json['slug'] ?? json['handle'],
      type: _parseProductType(json['type'] ?? json['product_type']),
      shortDescription: json['short_description'] ?? json['shortDescription'],
      description: json['description'] ?? json['body_html'] ?? json['body'],
      price: _parsePrice(json),
      compareAtPrice: _parseCompareAtPrice(json),
      costPrice: json['cost_price'] != null
          ? Money.fromJson({'amount': json['cost_price']})
          : null,
      images: _parseImages(json),
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => ProductOption.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      variants: (json['variants'] as List<dynamic>?)
              ?.map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((a) => ProductAttribute.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      stockStatus: _parseStockStatus(json),
      stockQuantity: json['stock_quantity'] ??
          json['stockQuantity'] ??
          json['inventory_quantity'],
      isAvailable:
          json['is_available'] ?? json['available'] ?? json['in_stock'] ?? true,
      isFeatured: json['is_featured'] ?? json['featured'] ?? false,
      isNew: json['is_new'] ?? json['new'] ?? false,
      categoryIds: _parseStringList(json['category_ids'] ?? json['categories']),
      categoryNames:
          _parseStringList(json['category_names'] ?? json['categoryNames']),
      tagIds: _parseStringList(json['tag_ids'] ?? json['tags']),
      tagNames: _parseStringList(json['tag_names'] ?? json['tagNames']),
      brand: json['brand'] ?? json['vendor'] ?? json['manufacturer'],
      weight: (json['weight'] as num?)?.toDouble(),
      weightUnit: json['weight_unit'] ?? json['weightUnit'],
      dimensions: json['dimensions'] != null
          ? ProductDimensions.fromJson(
              json['dimensions'] as Map<String, dynamic>,
            )
          : null,
      rating: (json['rating'] ?? json['average_rating'] as num?)?.toDouble(),
      reviewCount:
          json['review_count'] ?? json['reviewCount'] ?? json['reviews_count'],
      relatedProductIds:
          _parseStringList(json['related_ids'] ?? json['related']),
      upsellProductIds: _parseStringList(json['upsell_ids'] ?? json['upsells']),
      crossSellProductIds:
          _parseStringList(json['cross_sell_ids'] ?? json['crossSells']),
      seoTitle: json['seo_title'] ?? json['meta_title'],
      seoDescription: json['seo_description'] ?? json['meta_description'],
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
      metadata: json['metadata'] ?? json['meta'],
    );
  }

  /// Converts this [Product] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        if (sku != null) 'sku': sku,
        'name': name,
        if (slug != null) 'slug': slug,
        'type': type.name,
        if (shortDescription != null) 'short_description': shortDescription,
        if (description != null) 'description': description,
        'price': price.toJson(),
        if (compareAtPrice != null)
          'compare_at_price': compareAtPrice!.toJson(),
        if (costPrice != null) 'cost_price': costPrice!.toJson(),
        'images': images.map((i) => i.toJson()).toList(),
        'options': options.map((o) => o.toJson()).toList(),
        'variants': variants.map((v) => v.toJson()).toList(),
        'attributes': attributes.map((a) => a.toJson()).toList(),
        'stock_status': stockStatus.name,
        if (stockQuantity != null) 'stock_quantity': stockQuantity,
        'is_available': isAvailable,
        'is_featured': isFeatured,
        'is_new': isNew,
        'category_ids': categoryIds,
        'category_names': categoryNames,
        'tag_ids': tagIds,
        'tag_names': tagNames,
        if (brand != null) 'brand': brand,
        if (weight != null) 'weight': weight,
        if (weightUnit != null) 'weight_unit': weightUnit,
        if (dimensions != null) 'dimensions': dimensions!.toJson(),
        if (rating != null) 'rating': rating,
        if (reviewCount != null) 'review_count': reviewCount,
        'related_ids': relatedProductIds,
        'upsell_ids': upsellProductIds,
        'cross_sell_ids': crossSellProductIds,
        if (seoTitle != null) 'seo_title': seoTitle,
        if (seoDescription != null) 'seo_description': seoDescription,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };

  // ─────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns the primary image for this product.
  ProductImage? get primaryImage {
    if (images.isEmpty) return null;
    try {
      return images.firstWhere((i) => i.isPrimary);
    } catch (_) {
      return images.first;
    }
  }

  /// Returns `true` if this product is on sale.
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

  /// Returns `true` if this product can be purchased.
  bool get canPurchase => isAvailable && stockStatus.canPurchase;

  /// Returns `true` if this product has variants.
  bool get hasVariants => variants.isNotEmpty;

  /// Returns `true` if this product has options.
  bool get hasOptions => options.isNotEmpty;

  /// Returns `true` if this product requires option selection.
  bool get requiresOptionSelection =>
      type == ProductType.variable || type == ProductType.configurable;

  /// Returns `true` if this product has required options.
  bool get hasRequiredOptions => options.any((o) => o.isRequired);

  /// Returns the default variant if available.
  ProductVariant? get defaultVariant {
    if (variants.isEmpty) return null;
    try {
      return variants.firstWhere((v) => v.isDefault);
    } catch (_) {
      return variants.first;
    }
  }

  /// Returns the price range for variable products.
  PriceRange? get priceRange {
    if (variants.isEmpty) return null;
    final prices = variants.map((v) => v.price).toList();
    prices.sort((a, b) => a.amount.compareTo(b.amount));
    return PriceRange(min: prices.first, max: prices.last);
  }

  /// Returns `true` if stock is low.
  bool get isLowStock =>
      stockStatus == StockStatus.lowStock ||
      (stockQuantity != null && stockQuantity! > 0 && stockQuantity! <= 5);

  // ─────────────────────────────────────────────────────────────────────────
  // Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Gets the effective price for the given option selections.
  Money getPrice({Map<String, String>? selectedOptions}) {
    if (selectedOptions == null || selectedOptions.isEmpty) {
      return price;
    }

    // Check if there's a matching variant
    final matchingVariant = findVariant(selectedOptions);
    if (matchingVariant != null) {
      return matchingVariant.price;
    }

    // Calculate price from options
    var total = price;
    for (final entry in selectedOptions.entries) {
      final option = options.firstWhere(
        (o) => o.id == entry.key,
        orElse: () => options.first,
      );
      final value = option.getValueById(entry.value);
      if (value != null) {
        total = total + value.priceModifier;
      }
    }
    return total;
  }

  /// Finds a variant matching the given option selections.
  ProductVariant? findVariant(Map<String, String> selectedOptions) {
    for (final variant in variants) {
      if (variant.matchesOptions(selectedOptions)) {
        return variant;
      }
    }
    return null;
  }

  /// Gets an attribute by ID.
  ProductAttribute? getAttribute(String id) {
    try {
      return attributes.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Gets an option by ID.
  ProductOption? getOption(String id) {
    try {
      return options.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Validates the given option selections.
  ///
  /// Returns a map of option ID to error message, or empty if all valid.
  Map<String, String> validateOptions(Map<String, String> selectedOptions) {
    final errors = <String, String>{};

    for (final option in options) {
      final selected = selectedOptions[option.id];
      final selectedList = selected != null ? [selected] : <String>[];
      final error = option.validateSelection(selectedList);
      if (error != null) {
        errors[option.id] = error;
      }
    }

    return errors;
  }

  /// Copies this [Product] with optional new values.
  Product copyWith({
    String? id,
    String? sku,
    String? name,
    String? slug,
    ProductType? type,
    String? shortDescription,
    String? description,
    Money? price,
    Money? compareAtPrice,
    Money? costPrice,
    List<ProductImage>? images,
    List<ProductOption>? options,
    List<ProductVariant>? variants,
    List<ProductAttribute>? attributes,
    StockStatus? stockStatus,
    int? stockQuantity,
    bool? isAvailable,
    bool? isFeatured,
    bool? isNew,
    List<String>? categoryIds,
    List<String>? categoryNames,
    List<String>? tagIds,
    List<String>? tagNames,
    String? brand,
    double? weight,
    String? weightUnit,
    ProductDimensions? dimensions,
    double? rating,
    int? reviewCount,
    List<String>? relatedProductIds,
    List<String>? upsellProductIds,
    List<String>? crossSellProductIds,
    String? seoTitle,
    String? seoDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      type: type ?? this.type,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      costPrice: costPrice ?? this.costPrice,
      images: images ?? this.images,
      options: options ?? this.options,
      variants: variants ?? this.variants,
      attributes: attributes ?? this.attributes,
      stockStatus: stockStatus ?? this.stockStatus,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      categoryIds: categoryIds ?? this.categoryIds,
      categoryNames: categoryNames ?? this.categoryNames,
      tagIds: tagIds ?? this.tagIds,
      tagNames: tagNames ?? this.tagNames,
      brand: brand ?? this.brand,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      dimensions: dimensions ?? this.dimensions,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      relatedProductIds: relatedProductIds ?? this.relatedProductIds,
      upsellProductIds: upsellProductIds ?? this.upsellProductIds,
      crossSellProductIds: crossSellProductIds ?? this.crossSellProductIds,
      seoTitle: seoTitle ?? this.seoTitle,
      seoDescription: seoDescription ?? this.seoDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────────────────────────────────

  static ProductType _parseProductType(String? type) {
    switch (type?.toLowerCase()) {
      case 'simple':
        return ProductType.simple;
      case 'variable':
      case 'variant':
        return ProductType.variable;
      case 'grouped':
      case 'group':
        return ProductType.grouped;
      case 'bundle':
        return ProductType.bundle;
      case 'digital':
      case 'downloadable':
        return ProductType.digital;
      case 'subscription':
        return ProductType.subscription;
      case 'configurable':
        return ProductType.configurable;
      case 'service':
        return ProductType.service;
      default:
        return ProductType.simple;
    }
  }

  static Money _parsePrice(Map<String, dynamic> json) {
    if (json['price'] != null) {
      if (json['price'] is Map) {
        return Money.fromJson(json['price'] as Map<String, dynamic>);
      }
      return Money((json['price'] as num).toDouble());
    }
    if (json['regular_price'] != null) {
      return Money((json['regular_price'] as num).toDouble());
    }
    return const Money.zero();
  }

  static Money? _parseCompareAtPrice(Map<String, dynamic> json) {
    final value = json['compare_at_price'] ??
        json['compareAtPrice'] ??
        json['original_price'] ??
        json['sale_price'];
    if (value == null) return null;
    if (value is Map) {
      return Money.fromJson(value as Map<String, dynamic>);
    }
    return Money((value as num).toDouble());
  }

  static StockStatus _parseStockStatus(Map<String, dynamic> json) {
    final status = json['stock_status'] ?? json['stockStatus'];
    if (status != null) {
      switch (status.toString().toLowerCase()) {
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
        default:
          return StockStatus.inStock;
      }
    }
    // Infer from availability
    if (json['available'] == false || json['in_stock'] == false) {
      return StockStatus.outOfStock;
    }
    return StockStatus.inStock;
  }

  static List<ProductImage> _parseImages(Map<String, dynamic> json) {
    final images = json['images'];
    if (images == null) {
      // Check for single image field
      final imageUrl = json['image'] ?? json['image_url'] ?? json['thumbnail'];
      if (imageUrl != null) {
        return [
          ProductImage.network(
            id: '0',
            url: imageUrl.toString(),
            isPrimary: true,
          ),
        ];
      }
      return [];
    }

    if (images is List) {
      return images.asMap().entries.map((entry) {
        final img = entry.value;
        if (img is String) {
          return ProductImage.network(
            id: entry.key.toString(),
            url: img,
            isPrimary: entry.key == 0,
          );
        }
        if (img is Map<String, dynamic>) {
          return ProductImage.fromJson(img);
        }
        return ProductImage.network(
          id: entry.key.toString(),
          url: img.toString(),
          isPrimary: entry.key == 0,
        );
      }).toList();
    }

    return [];
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      return value.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        sku,
        name,
        slug,
        type,
        price,
        compareAtPrice,
        stockStatus,
        isAvailable,
      ];
}

/// Represents a price range for variable products.
class PriceRange extends Equatable {
  /// The minimum price.
  final Money min;

  /// The maximum price.
  final Money max;

  /// Creates a [PriceRange] instance.
  const PriceRange({required this.min, required this.max});

  /// Returns `true` if min and max are the same.
  bool get isSinglePrice => min.amount == max.amount;

  /// Returns formatted price range string.
  String get formatted {
    if (isSinglePrice) return min.formatted;
    return '${min.formatted} - ${max.formatted}';
  }

  @override
  List<Object?> get props => [min, max];
}

/// Represents product dimensions.
class ProductDimensions extends Equatable {
  /// Length of the product.
  final double? length;

  /// Width of the product.
  final double? width;

  /// Height of the product.
  final double? height;

  /// Unit of measurement (cm, in, m).
  final String unit;

  /// Creates a [ProductDimensions] instance.
  const ProductDimensions({
    this.length,
    this.width,
    this.height,
    this.unit = 'cm',
  });

  /// Creates [ProductDimensions] from JSON.
  factory ProductDimensions.fromJson(Map<String, dynamic> json) {
    return ProductDimensions(
      length: (json['length'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      unit: json['unit'] ?? 'cm',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        if (length != null) 'length': length,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        'unit': unit,
      };

  /// Returns formatted dimensions string.
  String get formatted {
    final parts = <String>[];
    if (length != null) parts.add('L: $length$unit');
    if (width != null) parts.add('W: $width$unit');
    if (height != null) parts.add('H: $height$unit');
    return parts.join(' × ');
  }

  @override
  List<Object?> get props => [length, width, height, unit];
}
