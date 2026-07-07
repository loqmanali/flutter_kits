import 'package:equatable/equatable.dart';

import 'money.dart';
import 'product_image.dart';

/// Represents a single value within a product option.
///
/// For example, for a "Size" option, values might be "Small", "Medium", "Large".
/// Each value can have its own price modifier, image, and availability status.
///
/// ## Usage
///
/// ```dart
/// final singleSize = ProductOptionValue(
///   id: 'single',
///   value: 'Single',
///   displayName: 'Single Patty',
///   priceModifier: Money.zero(),
/// );
///
/// final doubleSize = ProductOptionValue(
///   id: 'double',
///   value: 'Double',
///   displayName: 'Double Patty',
///   priceModifier: Money(25),
///   description: 'Extra juicy with two beef patties',
/// );
/// ```
class ProductOptionValue extends Equatable {
  /// Unique identifier for this option value.
  final String id;

  /// The actual value (used internally).
  final String value;

  /// The display name shown to customers.
  final String? displayName;

  /// Additional description for this value.
  final String? description;

  /// The price modifier when this value is selected.
  ///
  /// Positive value adds to the price, negative subtracts.
  /// Zero means no price change.
  final Money priceModifier;

  /// An image associated with this option value.
  ///
  /// Useful for color swatches or showing what the option looks like.
  final ProductImage? image;

  /// A color value (for color options).
  ///
  /// Format: hex color code (e.g., "#FF5733").
  final String? colorCode;

  /// Whether this option value is currently available.
  final bool isAvailable;

  /// Whether this is the default/pre-selected value.
  final bool isDefault;

  /// The display order (lower = displayed first).
  final int sortOrder;

  /// The SKU suffix added when this value is selected.
  ///
  /// Used to identify specific variants.
  final String? skuSuffix;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a [ProductOptionValue] instance.
  const ProductOptionValue({
    required this.id,
    required this.value,
    this.displayName,
    this.description,
    this.priceModifier = const Money.zero(),
    this.image,
    this.colorCode,
    this.isAvailable = true,
    this.isDefault = false,
    this.sortOrder = 0,
    this.skuSuffix,
    this.metadata,
  });

  /// Creates a simple option value with just a name and optional price.
  factory ProductOptionValue.simple({
    required String id,
    required String name,
    Money? priceModifier,
    bool isDefault = false,
  }) {
    return ProductOptionValue(
      id: id,
      value: name,
      displayName: name,
      priceModifier: priceModifier ?? const Money.zero(),
      isDefault: isDefault,
    );
  }

  /// Creates a color option value.
  factory ProductOptionValue.color({
    required String id,
    required String name,
    required String colorCode,
    Money? priceModifier,
    bool isDefault = false,
  }) {
    return ProductOptionValue(
      id: id,
      value: name,
      displayName: name,
      colorCode: colorCode,
      priceModifier: priceModifier ?? const Money.zero(),
      isDefault: isDefault,
    );
  }

  /// Creates a [ProductOptionValue] from JSON.
  factory ProductOptionValue.fromJson(Map<String, dynamic> json) {
    return ProductOptionValue(
      id: json['id']?.toString() ?? '',
      value: json['value'] ?? json['name'] ?? '',
      displayName: json['display_name'] ?? json['displayName'] ?? json['label'],
      description: json['description'],
      priceModifier: json['price_modifier'] != null
          ? Money.fromJson(json['price_modifier'] as Map<String, dynamic>)
          : json['price'] != null
              ? Money(
                  (json['price'] as num).toDouble(),
                )
              : const Money.zero(),
      image: json['image'] != null
          ? ProductImage.fromJson(json['image'] as Map<String, dynamic>)
          : null,
      colorCode: json['color_code'] ?? json['colorCode'] ?? json['color'],
      isAvailable: json['is_available'] ??
          json['isAvailable'] ??
          json['available'] ??
          true,
      isDefault:
          json['is_default'] ?? json['isDefault'] ?? json['default'] ?? false,
      sortOrder:
          json['sort_order'] ?? json['sortOrder'] ?? json['position'] ?? 0,
      skuSuffix: json['sku_suffix'] ?? json['skuSuffix'],
      metadata: json['metadata'],
    );
  }

  /// Converts this [ProductOptionValue] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'value': value,
        if (displayName != null) 'display_name': displayName,
        if (description != null) 'description': description,
        'price_modifier': priceModifier.toJson(),
        if (image != null) 'image': image!.toJson(),
        if (colorCode != null) 'color_code': colorCode,
        'is_available': isAvailable,
        'is_default': isDefault,
        'sort_order': sortOrder,
        if (skuSuffix != null) 'sku_suffix': skuSuffix,
        if (metadata != null) 'metadata': metadata,
      };

  /// Returns the effective display name.
  String get label => displayName ?? value;

  /// Returns the label with price modifier if applicable.
  String get labelWithPrice {
    if (priceModifier.isZero) {
      return label;
    }
    final sign = priceModifier.isPositive ? '+' : '';
    return '$label ($sign${priceModifier.formatted})';
  }

  /// Returns `true` if this value has a price modifier.
  bool get hasExtraCost => !priceModifier.isZero;

  /// Returns `true` if this is a color option value.
  bool get isColor => colorCode != null && colorCode!.isNotEmpty;

  /// Copies this [ProductOptionValue] with optional new values.
  ProductOptionValue copyWith({
    String? id,
    String? value,
    String? displayName,
    String? description,
    Money? priceModifier,
    ProductImage? image,
    String? colorCode,
    bool? isAvailable,
    bool? isDefault,
    int? sortOrder,
    String? skuSuffix,
    Map<String, dynamic>? metadata,
  }) {
    return ProductOptionValue(
      id: id ?? this.id,
      value: value ?? this.value,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      priceModifier: priceModifier ?? this.priceModifier,
      image: image ?? this.image,
      colorCode: colorCode ?? this.colorCode,
      isAvailable: isAvailable ?? this.isAvailable,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      skuSuffix: skuSuffix ?? this.skuSuffix,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        value,
        displayName,
        description,
        priceModifier,
        colorCode,
        isAvailable,
        isDefault,
        sortOrder,
      ];
}
