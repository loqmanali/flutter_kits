import 'package:equatable/equatable.dart';

import 'money.dart';
import 'product_image.dart';

/// Represents an item in an order.
///
/// Similar to [CartItem] but immutable and represents a finalized order item.
class OrderItem extends Equatable {
  /// Unique identifier for this order item.
  final String id;

  /// The product ID.
  final String productId;

  /// The product variant ID (if applicable).
  final String? variantId;

  /// The product name.
  final String name;

  /// The product description (optional).
  final String? description;

  /// The product SKU.
  final String? sku;

  /// The unit price at time of order.
  final Money unitPrice;

  /// The original price (if discounted).
  final Money? originalPrice;

  /// The quantity ordered.
  final int quantity;

  /// The total price (unitPrice * quantity).
  Money get totalPrice => unitPrice * quantity;

  /// The discount amount applied to this item.
  final Money? discountAmount;

  /// The final price after discounts.
  Money get finalPrice =>
      discountAmount != null ? totalPrice - discountAmount! : totalPrice;

  /// Selected options for this item (e.g., size, color, toppings).
  final Map<String, SelectedOrderOption> selectedOptions;

  /// Special instructions or notes for this item.
  final String? note;

  /// Product images.
  final List<ProductImage> images;

  /// Primary image URL for convenience.
  String? get imageUrl => images.isNotEmpty ? images.first.url : null;

  /// Whether this item is a gift.
  final bool isGift;

  /// Gift message for this item.
  final String? giftMessage;

  /// Points earned from this item.
  final int pointsEarned;

  /// Points redeemed on this item.
  final int pointsRedeemed;

  /// Custom metadata.
  final Map<String, dynamic> metadata;

  /// Creates an [OrderItem].
  const OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.variantId,
    this.description,
    this.sku,
    this.originalPrice,
    this.discountAmount,
    this.selectedOptions = const {},
    this.note,
    this.images = const [],
    this.isGift = false,
    this.giftMessage,
    this.pointsEarned = 0,
    this.pointsRedeemed = 0,
    this.metadata = const {},
  });

  /// Creates an [OrderItem] from JSON.
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      productId: json['product_id'] ?? json['productId'] as String,
      name: json['name'] as String,
      unitPrice: json['unit_price'] != null
          ? Money.fromJson(json['unit_price'] as Map<String, dynamic>)
          : Money(
              (json['unitPrice'] ?? json['price'] ?? 0).toDouble(),
            ),
      quantity: json['quantity'] as int? ?? 1,
      variantId: json['variant_id'] ?? json['variantId'] as String?,
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      originalPrice: json['original_price'] != null
          ? Money.fromJson(json['original_price'] as Map<String, dynamic>)
          : json['originalPrice'] != null
              ? Money((json['originalPrice'] as num).toDouble())
              : null,
      discountAmount: json['discount_amount'] != null
          ? Money.fromJson(json['discount_amount'] as Map<String, dynamic>)
          : json['discountAmount'] != null
              ? Money((json['discountAmount'] as num).toDouble())
              : null,
      selectedOptions: json['selected_options'] != null
          ? (json['selected_options'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                SelectedOrderOption.fromJson(value as Map<String, dynamic>),
              ),
            )
          : {},
      note: json['note'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isGift: json['is_gift'] ?? json['isGift'] as bool? ?? false,
      giftMessage: json['gift_message'] ?? json['giftMessage'] as String?,
      pointsEarned:
          json['points_earned'] ?? json['pointsEarned'] as int? ?? 0,
      pointsRedeemed:
          json['points_redeemed'] ?? json['pointsRedeemed'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts this [OrderItem] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'variant_id': variantId,
        'name': name,
        'description': description,
        'sku': sku,
        'unit_price': unitPrice.toJson(),
        'original_price': originalPrice?.toJson(),
        'quantity': quantity,
        'discount_amount': discountAmount?.toJson(),
        'selected_options': selectedOptions.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'note': note,
        'images': images.map((e) => e.toJson()).toList(),
        'is_gift': isGift,
        'gift_message': giftMessage,
        'points_earned': pointsEarned,
        'points_redeemed': pointsRedeemed,
        'metadata': metadata,
      };

  /// Returns a summary of selected options.
  String get optionsSummary {
    if (selectedOptions.isEmpty) return '';
    return selectedOptions.values.map((o) => o.valueLabel).join(', ');
  }

  /// Returns true if this item has a discount.
  bool get hasDiscount =>
      discountAmount != null && discountAmount!.amount > 0 ||
      originalPrice != null && originalPrice! > unitPrice;

  /// Returns the discount percentage if applicable.
  double? get discountPercentage {
    if (originalPrice != null && originalPrice! > unitPrice) {
      return ((originalPrice!.amount - unitPrice.amount) /
              originalPrice!.amount) *
          100;
    }
    return null;
  }

  /// Creates a copy with updated values.
  OrderItem copyWith({
    String? id,
    String? productId,
    String? variantId,
    String? name,
    String? description,
    String? sku,
    Money? unitPrice,
    Money? originalPrice,
    int? quantity,
    Money? discountAmount,
    Map<String, SelectedOrderOption>? selectedOptions,
    String? note,
    List<ProductImage>? images,
    bool? isGift,
    String? giftMessage,
    int? pointsEarned,
    int? pointsRedeemed,
    Map<String, dynamic>? metadata,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      unitPrice: unitPrice ?? this.unitPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      discountAmount: discountAmount ?? this.discountAmount,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      note: note ?? this.note,
      images: images ?? this.images,
      isGift: isGift ?? this.isGift,
      giftMessage: giftMessage ?? this.giftMessage,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      pointsRedeemed: pointsRedeemed ?? this.pointsRedeemed,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        variantId,
        name,
        description,
        sku,
        unitPrice,
        originalPrice,
        quantity,
        discountAmount,
        selectedOptions,
        note,
        images,
        isGift,
        giftMessage,
        pointsEarned,
        pointsRedeemed,
        metadata,
      ];
}

/// Represents a selected option in an order item.
class SelectedOrderOption extends Equatable {
  /// The option ID (e.g., "size", "color").
  final String optionId;

  /// The option name for display.
  final String optionName;

  /// The selected value ID.
  final String valueId;

  /// The selected value label for display.
  final String valueLabel;

  /// Price modifier for this option.
  final Money priceModifier;

  /// Creates a [SelectedOrderOption].
  const SelectedOrderOption({
    required this.optionId,
    required this.optionName,
    required this.valueId,
    required this.valueLabel,
    this.priceModifier = const Money.zero(),
  });

  /// Creates a [SelectedOrderOption] from JSON.
  factory SelectedOrderOption.fromJson(Map<String, dynamic> json) {
    return SelectedOrderOption(
      optionId: json['option_id'] ?? json['optionId'] as String,
      optionName: json['option_name'] ?? json['optionName'] as String,
      valueId: json['value_id'] ?? json['valueId'] as String,
      valueLabel: json['value_label'] ?? json['valueLabel'] as String,
      priceModifier: json['price_modifier'] != null
          ? Money.fromJson(json['price_modifier'] as Map<String, dynamic>)
          : json['priceModifier'] != null
              ? Money((json['priceModifier'] as num).toDouble())
              : const Money.zero(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'option_id': optionId,
        'option_name': optionName,
        'value_id': valueId,
        'value_label': valueLabel,
        'price_modifier': priceModifier.toJson(),
      };

  @override
  List<Object?> get props => [
        optionId,
        optionName,
        valueId,
        valueLabel,
        priceModifier,
      ];
}
