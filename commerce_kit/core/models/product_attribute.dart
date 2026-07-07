import 'package:equatable/equatable.dart';

/// Represents an attribute of a product.
///
/// Attributes are key-value pairs that describe product characteristics
/// that don't affect pricing or inventory (unlike variants).
///
/// ## Examples
///
/// - Ingredients: "Beef, Lettuce, Tomato, Cheese"
/// - Calories: "550 kcal"
/// - Allergens: "Contains: Gluten, Dairy"
/// - Preparation time: "10-15 minutes"
///
/// ## Usage
///
/// ```dart
/// final attributes = [
///   ProductAttribute(
///     id: 'ingredients',
///     name: 'Ingredients',
///     value: 'Beef, Lettuce, Tomato, Special Sauce',
///   ),
///   ProductAttribute(
///     id: 'calories',
///     name: 'Calories',
///     value: '550',
///     unit: 'kcal',
///   ),
///   ProductAttribute.list(
///     id: 'allergens',
///     name: 'Allergens',
///     values: ['Gluten', 'Dairy', 'Eggs'],
///   ),
/// ];
/// ```
class ProductAttribute extends Equatable {
  /// Unique identifier for this attribute.
  final String id;

  /// The display name of this attribute.
  final String name;

  /// The attribute value (for single-value attributes).
  final String? value;

  /// The attribute values (for multi-value attributes).
  final List<String>? values;

  /// The unit of measurement (e.g., "kcal", "g", "ml").
  final String? unit;

  /// An icon name to display with this attribute.
  final String? icon;

  /// Whether this attribute should be displayed prominently.
  final bool isHighlighted;

  /// Whether this attribute should be visible to customers.
  final bool isVisible;

  /// The display order (lower = displayed first).
  final int sortOrder;

  /// The attribute type for special handling.
  final AttributeType type;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a [ProductAttribute] instance.
  const ProductAttribute({
    required this.id,
    required this.name,
    this.value,
    this.values,
    this.unit,
    this.icon,
    this.isHighlighted = false,
    this.isVisible = true,
    this.sortOrder = 0,
    this.type = AttributeType.text,
    this.metadata,
  });

  /// Creates a single-value attribute.
  factory ProductAttribute.single({
    required String id,
    required String name,
    required String value,
    String? unit,
    String? icon,
    bool isHighlighted = false,
    int sortOrder = 0,
  }) {
    return ProductAttribute(
      id: id,
      name: name,
      value: value,
      unit: unit,
      icon: icon,
      isHighlighted: isHighlighted,
      sortOrder: sortOrder,
    );
  }

  /// Creates a multi-value (list) attribute.
  factory ProductAttribute.list({
    required String id,
    required String name,
    required List<String> values,
    String? icon,
    bool isHighlighted = false,
    int sortOrder = 0,
  }) {
    return ProductAttribute(
      id: id,
      name: name,
      values: values,
      icon: icon,
      isHighlighted: isHighlighted,
      sortOrder: sortOrder,
      type: AttributeType.list,
    );
  }

  /// Creates a boolean attribute.
  factory ProductAttribute.boolean({
    required String id,
    required String name,
    required bool value,
    String? icon,
    int sortOrder = 0,
  }) {
    return ProductAttribute(
      id: id,
      name: name,
      value: value.toString(),
      icon: icon,
      sortOrder: sortOrder,
      type: AttributeType.boolean,
    );
  }

  /// Creates a numeric attribute.
  factory ProductAttribute.numeric({
    required String id,
    required String name,
    required num value,
    String? unit,
    String? icon,
    int sortOrder = 0,
  }) {
    return ProductAttribute(
      id: id,
      name: name,
      value: value.toString(),
      unit: unit,
      icon: icon,
      sortOrder: sortOrder,
      type: AttributeType.number,
    );
  }

  /// Creates a [ProductAttribute] from JSON.
  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['label'] ?? '',
      value: json['value']?.toString(),
      values: json['values'] != null
          ? List<String>.from(json['values'].map((v) => v.toString()))
          : null,
      unit: json['unit'],
      icon: json['icon'],
      isHighlighted: json['is_highlighted'] ?? json['isHighlighted'] ?? false,
      isVisible: json['is_visible'] ?? json['isVisible'] ?? true,
      sortOrder: json['sort_order'] ?? json['sortOrder'] ?? json['position'] ?? 0,
      type: _parseType(json['type']),
      metadata: json['metadata'],
    );
  }

  /// Converts this [ProductAttribute] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (value != null) 'value': value,
        if (values != null) 'values': values,
        if (unit != null) 'unit': unit,
        if (icon != null) 'icon': icon,
        'is_highlighted': isHighlighted,
        'is_visible': isVisible,
        'sort_order': sortOrder,
        'type': type.name,
        if (metadata != null) 'metadata': metadata,
      };

  /// Returns `true` if this is a multi-value attribute.
  bool get isMultiValue => values != null && values!.isNotEmpty;

  /// Returns the display value (formatted with unit if present).
  String get displayValue {
    if (isMultiValue) {
      return values!.join(', ');
    }
    if (unit != null && value != null) {
      return '$value $unit';
    }
    return value ?? '';
  }

  /// Returns the boolean value (for boolean attributes).
  bool? get boolValue {
    if (type != AttributeType.boolean) return null;
    return value?.toLowerCase() == 'true';
  }

  /// Returns the numeric value (for numeric attributes).
  num? get numericValue {
    if (type != AttributeType.number) return null;
    return num.tryParse(value ?? '');
  }

  /// Copies this [ProductAttribute] with optional new values.
  ProductAttribute copyWith({
    String? id,
    String? name,
    String? value,
    List<String>? values,
    String? unit,
    String? icon,
    bool? isHighlighted,
    bool? isVisible,
    int? sortOrder,
    AttributeType? type,
    Map<String, dynamic>? metadata,
  }) {
    return ProductAttribute(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
      values: values ?? this.values,
      unit: unit ?? this.unit,
      icon: icon ?? this.icon,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isVisible: isVisible ?? this.isVisible,
      sortOrder: sortOrder ?? this.sortOrder,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  static AttributeType _parseType(String? type) {
    switch (type) {
      case 'list':
        return AttributeType.list;
      case 'boolean':
      case 'bool':
        return AttributeType.boolean;
      case 'number':
      case 'numeric':
        return AttributeType.number;
      case 'date':
        return AttributeType.date;
      case 'html':
        return AttributeType.html;
      default:
        return AttributeType.text;
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        value,
        values,
        unit,
        icon,
        isHighlighted,
        isVisible,
        sortOrder,
        type,
      ];
}

/// The type of a product attribute.
enum AttributeType {
  /// Plain text attribute.
  text,

  /// List of values.
  list,

  /// Boolean (yes/no) attribute.
  boolean,

  /// Numeric attribute.
  number,

  /// Date attribute.
  date,

  /// HTML content attribute.
  html,
}
