import 'package:equatable/equatable.dart';

import '../enums/shipping_type.dart';
import 'money.dart';

/// Represents a shipping/delivery method.
class ShippingMethod extends Equatable {
  /// Unique identifier.
  final String id;

  /// Display name.
  final String name;

  /// Description.
  final String? description;

  /// Shipping type.
  final ShippingType type;

  /// Shipping cost.
  final Money cost;

  /// Original cost (if discounted).
  final Money? originalCost;

  /// Whether shipping is free.
  bool get isFree => cost.isZero;

  /// Estimated delivery time in minutes (minimum).
  final int? estimatedMinutesMin;

  /// Estimated delivery time in minutes (maximum).
  final int? estimatedMinutesMax;

  /// Estimated delivery date (minimum).
  final DateTime? estimatedDateMin;

  /// Estimated delivery date (maximum).
  final DateTime? estimatedDateMax;

  /// Available time slots for scheduled delivery.
  final List<DeliveryTimeSlot> availableTimeSlots;

  /// Whether this method is currently available.
  final bool isAvailable;

  /// Reason if not available.
  final String? unavailableReason;

  /// Minimum order amount required.
  final Money? minimumOrderAmount;

  /// Maximum order amount allowed.
  final Money? maximumOrderAmount;

  /// Carrier/provider name.
  final String? carrier;

  /// Carrier logo URL.
  final String? carrierLogoUrl;

  /// Icon name for display.
  final String? iconName;

  /// Sort order for display.
  final int sortOrder;

  /// Custom metadata.
  final Map<String, dynamic> metadata;

  /// Creates a [ShippingMethod].
  const ShippingMethod({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.cost,
    this.originalCost,
    this.estimatedMinutesMin,
    this.estimatedMinutesMax,
    this.estimatedDateMin,
    this.estimatedDateMax,
    this.availableTimeSlots = const [],
    this.isAvailable = true,
    this.unavailableReason,
    this.minimumOrderAmount,
    this.maximumOrderAmount,
    this.carrier,
    this.carrierLogoUrl,
    this.iconName,
    this.sortOrder = 0,
    this.metadata = const {},
  });

  /// Creates a free shipping method.
  factory ShippingMethod.free({
    String id = 'free',
    String name = 'Free Delivery',
    String? description,
    ShippingType type = ShippingType.free,
    int? estimatedMinutesMin,
    int? estimatedMinutesMax,
  }) {
    return ShippingMethod(
      id: id,
      name: name,
      description: description,
      type: type,
      cost: const Money.zero(),
      estimatedMinutesMin: estimatedMinutesMin,
      estimatedMinutesMax: estimatedMinutesMax,
    );
  }

  /// Creates a [ShippingMethod] from JSON.
  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    return ShippingMethod(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] != null
          ? ShippingType.values.firstWhere(
              (e) => e.name == json['type'],
              orElse: () => ShippingType.standard,
            )
          : ShippingType.standard,
      cost: json['cost'] != null
          ? Money.fromJson(json['cost'] as Map<String, dynamic>)
          : Money((json['price'] ?? json['amount'] ?? 0).toDouble()),
      originalCost: json['original_cost'] != null
          ? Money.fromJson(json['original_cost'] as Map<String, dynamic>)
          : null,
      estimatedMinutesMin: json['estimated_minutes_min'] ??
          json['estimatedMinutesMin'] as int?,
      estimatedMinutesMax: json['estimated_minutes_max'] ??
          json['estimatedMinutesMax'] as int?,
      estimatedDateMin: json['estimated_date_min'] != null
          ? DateTime.parse(json['estimated_date_min'] as String)
          : null,
      estimatedDateMax: json['estimated_date_max'] != null
          ? DateTime.parse(json['estimated_date_max'] as String)
          : null,
      availableTimeSlots: (json['available_time_slots'] as List<dynamic>?)
              ?.map((e) => DeliveryTimeSlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isAvailable: json['is_available'] ?? json['isAvailable'] as bool? ?? true,
      unavailableReason: json['unavailable_reason'] ??
          json['unavailableReason'] as String?,
      minimumOrderAmount: json['minimum_order_amount'] != null
          ? Money.fromJson(json['minimum_order_amount'] as Map<String, dynamic>)
          : null,
      maximumOrderAmount: json['maximum_order_amount'] != null
          ? Money.fromJson(json['maximum_order_amount'] as Map<String, dynamic>)
          : null,
      carrier: json['carrier'] as String?,
      carrierLogoUrl: json['carrier_logo_url'] ?? json['carrierLogoUrl'] as String?,
      iconName: json['icon_name'] ?? json['iconName'] as String?,
      sortOrder: json['sort_order'] ?? json['sortOrder'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.name,
        'cost': cost.toJson(),
        'original_cost': originalCost?.toJson(),
        'estimated_minutes_min': estimatedMinutesMin,
        'estimated_minutes_max': estimatedMinutesMax,
        'estimated_date_min': estimatedDateMin?.toIso8601String(),
        'estimated_date_max': estimatedDateMax?.toIso8601String(),
        'available_time_slots':
            availableTimeSlots.map((e) => e.toJson()).toList(),
        'is_available': isAvailable,
        'unavailable_reason': unavailableReason,
        'minimum_order_amount': minimumOrderAmount?.toJson(),
        'maximum_order_amount': maximumOrderAmount?.toJson(),
        'carrier': carrier,
        'carrier_logo_url': carrierLogoUrl,
        'icon_name': iconName,
        'sort_order': sortOrder,
        'metadata': metadata,
      };

  /// Returns formatted estimated time.
  String get estimatedTimeFormatted {
    if (estimatedMinutesMin == null && estimatedMinutesMax == null) {
      return '';
    }

    String formatMinutes(int minutes) {
      if (minutes < 60) {
        return '$minutes min';
      } else if (minutes < 1440) {
        final hours = minutes ~/ 60;
        return '$hours hour${hours > 1 ? 's' : ''}';
      } else {
        final days = minutes ~/ 1440;
        return '$days day${days > 1 ? 's' : ''}';
      }
    }

    if (estimatedMinutesMin != null && estimatedMinutesMax != null) {
      return '${formatMinutes(estimatedMinutesMin!)} - ${formatMinutes(estimatedMinutesMax!)}';
    } else if (estimatedMinutesMin != null) {
      return 'From ${formatMinutes(estimatedMinutesMin!)}';
    } else {
      return 'Up to ${formatMinutes(estimatedMinutesMax!)}';
    }
  }

  /// Returns true if this method has a discount.
  bool get hasDiscount => originalCost != null && originalCost! > cost;

  /// Creates a copy with updated values.
  ShippingMethod copyWith({
    String? id,
    String? name,
    String? description,
    ShippingType? type,
    Money? cost,
    Money? originalCost,
    int? estimatedMinutesMin,
    int? estimatedMinutesMax,
    DateTime? estimatedDateMin,
    DateTime? estimatedDateMax,
    List<DeliveryTimeSlot>? availableTimeSlots,
    bool? isAvailable,
    String? unavailableReason,
    Money? minimumOrderAmount,
    Money? maximumOrderAmount,
    String? carrier,
    String? carrierLogoUrl,
    String? iconName,
    int? sortOrder,
    Map<String, dynamic>? metadata,
  }) {
    return ShippingMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      cost: cost ?? this.cost,
      originalCost: originalCost ?? this.originalCost,
      estimatedMinutesMin: estimatedMinutesMin ?? this.estimatedMinutesMin,
      estimatedMinutesMax: estimatedMinutesMax ?? this.estimatedMinutesMax,
      estimatedDateMin: estimatedDateMin ?? this.estimatedDateMin,
      estimatedDateMax: estimatedDateMax ?? this.estimatedDateMax,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailableReason: unavailableReason ?? this.unavailableReason,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      maximumOrderAmount: maximumOrderAmount ?? this.maximumOrderAmount,
      carrier: carrier ?? this.carrier,
      carrierLogoUrl: carrierLogoUrl ?? this.carrierLogoUrl,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        cost,
        originalCost,
        estimatedMinutesMin,
        estimatedMinutesMax,
        estimatedDateMin,
        estimatedDateMax,
        availableTimeSlots,
        isAvailable,
        unavailableReason,
        minimumOrderAmount,
        maximumOrderAmount,
        carrier,
        carrierLogoUrl,
        iconName,
        sortOrder,
        metadata,
      ];
}

/// Represents a delivery time slot.
class DeliveryTimeSlot extends Equatable {
  /// Unique identifier.
  final String id;

  /// Date for this slot.
  final DateTime date;

  /// Start time.
  final String startTime;

  /// End time.
  final String endTime;

  /// Whether this slot is available.
  final bool isAvailable;

  /// Additional cost for this slot.
  final Money? additionalCost;

  /// Display label.
  final String? label;

  /// Creates a [DeliveryTimeSlot].
  const DeliveryTimeSlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.additionalCost,
    this.label,
  });

  /// Creates a [DeliveryTimeSlot] from JSON.
  factory DeliveryTimeSlot.fromJson(Map<String, dynamic> json) {
    return DeliveryTimeSlot(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] ?? json['startTime'] as String,
      endTime: json['end_time'] ?? json['endTime'] as String,
      isAvailable: json['is_available'] ?? json['isAvailable'] as bool? ?? true,
      additionalCost: json['additional_cost'] != null
          ? Money.fromJson(json['additional_cost'] as Map<String, dynamic>)
          : null,
      label: json['label'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'start_time': startTime,
        'end_time': endTime,
        'is_available': isAvailable,
        'additional_cost': additionalCost?.toJson(),
        'label': label,
      };

  /// Returns formatted time range.
  String get timeRange => '$startTime - $endTime';

  @override
  List<Object?> get props => [
        id,
        date,
        startTime,
        endTime,
        isAvailable,
        additionalCost,
        label,
      ];
}
