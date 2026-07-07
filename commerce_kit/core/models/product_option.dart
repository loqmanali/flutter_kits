import 'package:equatable/equatable.dart';

import '../enums/variant_type.dart';
import 'product_option_value.dart';

/// Represents a customizable option for a product.
///
/// Options allow customers to customize a product (e.g., choose size, add extras).
/// Each option can have multiple values to choose from.
///
/// ## Types of Options
///
/// - **Single Selection**: Customer must choose exactly one value (radio/dropdown)
/// - **Multiple Selection**: Customer can choose multiple values (checkboxes)
/// - **Required Options**: Must be selected before adding to cart
/// - **Optional Options**: Can be skipped (add-ons, extras)
///
/// ## Usage
///
/// ```dart
/// // Size option (single required selection)
/// final sizeOption = ProductOption(
///   id: 'size',
///   name: 'Size',
///   type: VariantType.size,
///   isRequired: true,
///   allowMultiple: false,
///   values: [
///     ProductOptionValue.simple(id: 's', name: 'Single'),
///     ProductOptionValue.simple(id: 'd', name: 'Double', priceModifier: Money(25)),
///   ],
/// );
///
/// // Extras option (multiple optional selection)
/// final extrasOption = ProductOption(
///   id: 'extras',
///   name: 'Extras',
///   type: VariantType.addon,
///   isRequired: false,
///   allowMultiple: true,
///   maxSelections: 5,
///   values: [
///     ProductOptionValue.simple(id: 'cheese', name: 'Extra Cheese', priceModifier: Money(15)),
///     ProductOptionValue.simple(id: 'bacon', name: 'Bacon', priceModifier: Money(20)),
///   ],
/// );
/// ```
class ProductOption extends Equatable {
  /// Unique identifier for this option.
  final String id;

  /// The display name of this option.
  final String name;

  /// A description explaining this option.
  final String? description;

  /// The type of variant this option represents.
  final VariantType type;

  /// The available values for this option.
  final List<ProductOptionValue> values;

  /// Whether this option must be selected.
  final bool isRequired;

  /// Whether multiple values can be selected.
  final bool allowMultiple;

  /// The minimum number of selections (if allowMultiple is true).
  final int minSelections;

  /// The maximum number of selections (if allowMultiple is true).
  ///
  /// Null means no limit.
  final int? maxSelections;

  /// The display order (lower = displayed first).
  final int sortOrder;

  /// An icon name to display with this option.
  final String? icon;

  /// The display style for this option.
  final OptionDisplayStyle displayStyle;

  /// Whether this option should be displayed prominently.
  final bool isHighlighted;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a [ProductOption] instance.
  const ProductOption({
    required this.id,
    required this.name,
    this.description,
    this.type = VariantType.other,
    required this.values,
    this.isRequired = false,
    this.allowMultiple = false,
    this.minSelections = 0,
    this.maxSelections,
    this.sortOrder = 0,
    this.icon,
    this.displayStyle = OptionDisplayStyle.buttons,
    this.isHighlighted = false,
    this.metadata,
  });

  /// Creates a size option.
  factory ProductOption.size({
    required String id,
    required String name,
    required List<ProductOptionValue> values,
    bool isRequired = true,
  }) {
    return ProductOption(
      id: id,
      name: name,
      type: VariantType.size,
      values: values,
      isRequired: isRequired,
    );
  }

  /// Creates a combo/meal option.
  factory ProductOption.combo({
    required String id,
    required String name,
    required List<ProductOptionValue> values,
    bool isRequired = false,
  }) {
    return ProductOption(
      id: id,
      name: name,
      type: VariantType.combo,
      values: values,
      isRequired: isRequired,
      displayStyle: OptionDisplayStyle.cards,
    );
  }

  /// Creates an extras/add-ons option.
  factory ProductOption.extras({
    required String id,
    required String name,
    required List<ProductOptionValue> values,
    int? maxSelections,
  }) {
    return ProductOption(
      id: id,
      name: name,
      type: VariantType.addon,
      values: values,
      allowMultiple: true,
      maxSelections: maxSelections,
      displayStyle: OptionDisplayStyle.checkboxes,
    );
  }

  /// Creates a color option.
  factory ProductOption.color({
    required String id,
    required String name,
    required List<ProductOptionValue> values,
    bool isRequired = true,
  }) {
    return ProductOption(
      id: id,
      name: name,
      type: VariantType.color,
      values: values,
      isRequired: isRequired,
      displayStyle: OptionDisplayStyle.swatches,
    );
  }

  /// Creates a [ProductOption] from JSON.
  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['title'] ?? json['label'] ?? '',
      description: json['description'],
      type: _parseVariantType(json['type']),
      values: (json['values'] as List<dynamic>?)
              ?.map(
                (v) => ProductOptionValue.fromJson(v as Map<String, dynamic>),
              )
              .toList() ??
          [],
      isRequired: json['is_required'] ??
          json['isRequired'] ??
          json['required'] ??
          false,
      allowMultiple: json['allow_multiple'] ??
          json['allowMultiple'] ??
          json['multiple'] ??
          false,
      minSelections:
          json['min_selections'] ?? json['minSelections'] ?? json['min'] ?? 0,
      maxSelections:
          json['max_selections'] ?? json['maxSelections'] ?? json['max'],
      sortOrder:
          json['sort_order'] ?? json['sortOrder'] ?? json['position'] ?? 0,
      icon: json['icon'],
      displayStyle:
          _parseDisplayStyle(json['display_style'] ?? json['displayStyle']),
      isHighlighted: json['is_highlighted'] ?? json['isHighlighted'] ?? false,
      metadata: json['metadata'],
    );
  }

  /// Converts this [ProductOption] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
        'type': type.name,
        'values': values.map((v) => v.toJson()).toList(),
        'is_required': isRequired,
        'allow_multiple': allowMultiple,
        'min_selections': minSelections,
        if (maxSelections != null) 'max_selections': maxSelections,
        'sort_order': sortOrder,
        if (icon != null) 'icon': icon,
        'display_style': displayStyle.name,
        'is_highlighted': isHighlighted,
        if (metadata != null) 'metadata': metadata,
      };

  /// Returns the default value(s) for this option.
  List<ProductOptionValue> get defaultValues {
    return values.where((v) => v.isDefault).toList();
  }

  /// Returns the first default value, or null if none.
  ProductOptionValue? get defaultValue {
    final defaults = defaultValues;
    return defaults.isNotEmpty ? defaults.first : null;
  }

  /// Returns only available values.
  List<ProductOptionValue> get availableValues {
    return values.where((v) => v.isAvailable).toList();
  }

  /// Returns `true` if this option has any available values.
  bool get hasAvailableValues => availableValues.isNotEmpty;

  /// Returns `true` if any value has a price modifier.
  bool get hasPriceModifiers {
    return values.any((v) => !v.priceModifier.isZero);
  }

  /// Returns `true` if this is a color option.
  bool get isColorOption => type == VariantType.color;

  /// Returns `true` if this is an add-on option.
  bool get isAddonOption => type == VariantType.addon;

  /// Validates the given selection(s) against this option's rules.
  ///
  /// Returns null if valid, or an error message if invalid.
  String? validateSelection(List<String> selectedIds) {
    final selectedCount = selectedIds.length;

    if (isRequired && selectedCount == 0) {
      return 'Please select a $name';
    }

    if (!allowMultiple && selectedCount > 1) {
      return 'Only one $name can be selected';
    }

    if (selectedCount < minSelections) {
      return 'Please select at least $minSelections ${minSelections == 1 ? "option" : "options"}';
    }

    if (maxSelections != null && selectedCount > maxSelections!) {
      return 'Maximum $maxSelections ${maxSelections == 1 ? "option" : "options"} allowed';
    }

    // Check if all selected IDs are valid
    final validIds = values.map((v) => v.id).toSet();
    for (final id in selectedIds) {
      if (!validIds.contains(id)) {
        return 'Invalid selection';
      }
    }

    // Check if all selected values are available
    for (final id in selectedIds) {
      final value = values.firstWhere(
        (v) => v.id == id,
        orElse: () => values.first,
      );
      if (!value.isAvailable) {
        return '${value.label} is not available';
      }
    }

    return null;
  }

  /// Returns the value with the given ID.
  ProductOptionValue? getValueById(String id) {
    try {
      return values.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Copies this [ProductOption] with optional new values.
  ProductOption copyWith({
    String? id,
    String? name,
    String? description,
    VariantType? type,
    List<ProductOptionValue>? values,
    bool? isRequired,
    bool? allowMultiple,
    int? minSelections,
    int? maxSelections,
    int? sortOrder,
    String? icon,
    OptionDisplayStyle? displayStyle,
    bool? isHighlighted,
    Map<String, dynamic>? metadata,
  }) {
    return ProductOption(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      values: values ?? this.values,
      isRequired: isRequired ?? this.isRequired,
      allowMultiple: allowMultiple ?? this.allowMultiple,
      minSelections: minSelections ?? this.minSelections,
      maxSelections: maxSelections ?? this.maxSelections,
      sortOrder: sortOrder ?? this.sortOrder,
      icon: icon ?? this.icon,
      displayStyle: displayStyle ?? this.displayStyle,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      metadata: metadata ?? this.metadata,
    );
  }

  static VariantType _parseVariantType(String? type) {
    switch (type?.toLowerCase()) {
      case 'size':
        return VariantType.size;
      case 'color':
        return VariantType.color;
      case 'weight':
        return VariantType.weight;
      case 'flavor':
        return VariantType.flavor;
      case 'addon':
      case 'add-on':
      case 'extra':
        return VariantType.addon;
      case 'combo':
      case 'meal':
        return VariantType.combo;
      case 'customization':
        return VariantType.customization;
      default:
        return VariantType.other;
    }
  }

  static OptionDisplayStyle _parseDisplayStyle(String? style) {
    switch (style?.toLowerCase()) {
      case 'buttons':
        return OptionDisplayStyle.buttons;
      case 'dropdown':
        return OptionDisplayStyle.dropdown;
      case 'swatches':
        return OptionDisplayStyle.swatches;
      case 'checkboxes':
        return OptionDisplayStyle.checkboxes;
      case 'cards':
        return OptionDisplayStyle.cards;
      case 'radio':
        return OptionDisplayStyle.radio;
      default:
        return OptionDisplayStyle.buttons;
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        values,
        isRequired,
        allowMultiple,
        minSelections,
        maxSelections,
        sortOrder,
        displayStyle,
      ];
}

/// The display style for a product option.
enum OptionDisplayStyle {
  /// Display as buttons (toggle buttons).
  buttons,

  /// Display as a dropdown select.
  dropdown,

  /// Display as color swatches.
  swatches,

  /// Display as checkboxes (for multiple selection).
  checkboxes,

  /// Display as cards with images/details.
  cards,

  /// Display as radio buttons.
  radio,
}
