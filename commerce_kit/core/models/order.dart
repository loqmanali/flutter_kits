import 'package:equatable/equatable.dart';

import '../enums/order_status.dart';
import '../enums/payment_method.dart';
import '../enums/payment_status.dart';
import 'money.dart';
import 'order_item.dart';
import 'order_summary.dart';
import 'shipping_address.dart';
import 'shipping_method.dart';

/// Represents a complete order.
class Order extends Equatable {
  /// Unique order identifier.
  final String id;

  /// Order number for display (may differ from id).
  final String orderNumber;

  /// User/customer ID.
  final String? userId;

  /// Order status.
  final OrderStatus status;

  /// Payment status.
  final PaymentStatus paymentStatus;

  /// Payment method used.
  final PaymentMethod paymentMethod;

  /// Order items.
  final List<OrderItem> items;

  /// Number of items.
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Number of unique items.
  int get uniqueItemCount => items.length;

  /// Order summary (totals, discounts, etc.).
  final OrderSummary summary;

  /// Shipping address.
  final ShippingAddress? shippingAddress;

  /// Billing address (if different from shipping).
  final ShippingAddress? billingAddress;

  /// Shipping method selected.
  final ShippingMethod? shippingMethod;

  /// Selected delivery time slot.
  final DeliveryTimeSlot? deliveryTimeSlot;

  /// Estimated delivery date/time (minimum).
  final DateTime? estimatedDeliveryMin;

  /// Estimated delivery date/time (maximum).
  final DateTime? estimatedDeliveryMax;

  /// Actual delivery date/time.
  final DateTime? actualDeliveryTime;

  /// Order notes from customer.
  final String? customerNote;

  /// Internal notes.
  final String? internalNote;

  /// Applied coupon code.
  final String? couponCode;

  /// Wallet amount used.
  final Money walletUsed;

  /// Points redeemed.
  final int pointsRedeemed;

  /// Points earned from this order.
  final int pointsEarned;

  /// Cashback earned.
  final Money cashbackEarned;

  /// Order creation time.
  final DateTime createdAt;

  /// Last update time.
  final DateTime updatedAt;

  /// Order confirmation time.
  final DateTime? confirmedAt;

  /// Order completion time.
  final DateTime? completedAt;

  /// Order cancellation time.
  final DateTime? cancelledAt;

  /// Cancellation reason.
  final String? cancellationReason;

  /// Tracking number.
  final String? trackingNumber;

  /// Tracking URL.
  final String? trackingUrl;

  /// Driver/courier information.
  final DeliveryDriver? driver;

  /// Order source (app, web, etc.).
  final String? source;

  /// Device/platform.
  final String? platform;

  /// Custom metadata.
  final Map<String, dynamic> metadata;

  /// Creates an [Order].
  const Order({
    required this.id,
    required this.orderNumber,
    this.userId,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.items,
    required this.summary,
    this.shippingAddress,
    this.billingAddress,
    this.shippingMethod,
    this.deliveryTimeSlot,
    this.estimatedDeliveryMin,
    this.estimatedDeliveryMax,
    this.actualDeliveryTime,
    this.customerNote,
    this.internalNote,
    this.couponCode,
    this.walletUsed = const Money.zero(),
    this.pointsRedeemed = 0,
    this.pointsEarned = 0,
    this.cashbackEarned = const Money.zero(),
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.trackingNumber,
    this.trackingUrl,
    this.driver,
    this.source,
    this.platform,
    this.metadata = const {},
  });

  /// Creates an [Order] from JSON.
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber:
          json['order_number'] ?? json['orderNumber'] ?? json['id'] as String,
      userId: json['user_id'] ?? json['userId'] as String?,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) =>
            e.name ==
            (json['payment_status'] ?? json['paymentStatus'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) =>
            e.name ==
            (json['payment_method'] ?? json['paymentMethod'] ?? 'card'),
        orElse: () => PaymentMethod.card,
      ),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] != null
          ? OrderSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : const OrderSummary.empty(),
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(
              json['shipping_address'] as Map<String, dynamic>,
            )
          : json['shippingAddress'] != null
              ? ShippingAddress.fromJson(
                  json['shippingAddress'] as Map<String, dynamic>,
                )
              : null,
      billingAddress: json['billing_address'] != null
          ? ShippingAddress.fromJson(
              json['billing_address'] as Map<String, dynamic>,
            )
          : json['billingAddress'] != null
              ? ShippingAddress.fromJson(
                  json['billingAddress'] as Map<String, dynamic>,
                )
              : null,
      shippingMethod: json['shipping_method'] != null
          ? ShippingMethod.fromJson(
              json['shipping_method'] as Map<String, dynamic>,
            )
          : json['shippingMethod'] != null
              ? ShippingMethod.fromJson(
                  json['shippingMethod'] as Map<String, dynamic>,
                )
              : null,
      deliveryTimeSlot: json['delivery_time_slot'] != null
          ? DeliveryTimeSlot.fromJson(
              json['delivery_time_slot'] as Map<String, dynamic>,
            )
          : json['deliveryTimeSlot'] != null
              ? DeliveryTimeSlot.fromJson(
                  json['deliveryTimeSlot'] as Map<String, dynamic>,
                )
              : null,
      estimatedDeliveryMin: json['estimated_delivery_min'] != null
          ? DateTime.parse(json['estimated_delivery_min'] as String)
          : json['estimatedDeliveryMin'] != null
              ? DateTime.parse(json['estimatedDeliveryMin'] as String)
              : null,
      estimatedDeliveryMax: json['estimated_delivery_max'] != null
          ? DateTime.parse(json['estimated_delivery_max'] as String)
          : json['estimatedDeliveryMax'] != null
              ? DateTime.parse(json['estimatedDeliveryMax'] as String)
              : null,
      actualDeliveryTime: json['actual_delivery_time'] != null
          ? DateTime.parse(json['actual_delivery_time'] as String)
          : json['actualDeliveryTime'] != null
              ? DateTime.parse(json['actualDeliveryTime'] as String)
              : null,
      customerNote: json['customer_note'] ??
          json['customerNote'] ??
          json['note'] as String?,
      internalNote: json['internal_note'] ?? json['internalNote'] as String?,
      couponCode: json['coupon_code'] ?? json['couponCode'] as String?,
      walletUsed: json['wallet_used'] != null
          ? Money.fromJson(json['wallet_used'] as Map<String, dynamic>)
          : json['walletUsed'] != null
              ? Money((json['walletUsed'] as num).toDouble())
              : const Money.zero(),
      pointsRedeemed:
          json['points_redeemed'] ?? json['pointsRedeemed'] as int? ?? 0,
      pointsEarned: json['points_earned'] ?? json['pointsEarned'] as int? ?? 0,
      cashbackEarned: json['cashback_earned'] != null
          ? Money.fromJson(json['cashback_earned'] as Map<String, dynamic>)
          : json['cashbackEarned'] != null
              ? Money((json['cashbackEarned'] as num).toDouble())
              : const Money.zero(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : json['confirmedAt'] != null
              ? DateTime.parse(json['confirmedAt'] as String)
              : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : json['completedAt'] != null
              ? DateTime.parse(json['completedAt'] as String)
              : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : json['cancelledAt'] != null
              ? DateTime.parse(json['cancelledAt'] as String)
              : null,
      cancellationReason:
          json['cancellation_reason'] ?? json['cancellationReason'] as String?,
      trackingNumber:
          json['tracking_number'] ?? json['trackingNumber'] as String?,
      trackingUrl: json['tracking_url'] ?? json['trackingUrl'] as String?,
      driver: json['driver'] != null
          ? DeliveryDriver.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      source: json['source'] as String?,
      platform: json['platform'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'order_number': orderNumber,
        'user_id': userId,
        'status': status.name,
        'payment_status': paymentStatus.name,
        'payment_method': paymentMethod.name,
        'items': items.map((e) => e.toJson()).toList(),
        'summary': summary.toJson(),
        'shipping_address': shippingAddress?.toJson(),
        'billing_address': billingAddress?.toJson(),
        'shipping_method': shippingMethod?.toJson(),
        'delivery_time_slot': deliveryTimeSlot?.toJson(),
        'estimated_delivery_min': estimatedDeliveryMin?.toIso8601String(),
        'estimated_delivery_max': estimatedDeliveryMax?.toIso8601String(),
        'actual_delivery_time': actualDeliveryTime?.toIso8601String(),
        'customer_note': customerNote,
        'internal_note': internalNote,
        'coupon_code': couponCode,
        'wallet_used': walletUsed.toJson(),
        'points_redeemed': pointsRedeemed,
        'points_earned': pointsEarned,
        'cashback_earned': cashbackEarned.toJson(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'confirmed_at': confirmedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'cancelled_at': cancelledAt?.toIso8601String(),
        'cancellation_reason': cancellationReason,
        'tracking_number': trackingNumber,
        'tracking_url': trackingUrl,
        'driver': driver?.toJson(),
        'source': source,
        'platform': platform,
        'metadata': metadata,
      };

  /// Returns true if order can be cancelled.
  bool get canCancel => status.canBeCancelled;

  /// Returns true if order can be modified.
  bool get canModify => status.canBeModified;

  /// Returns true if order is in progress.
  bool get isInProgress => status.isActive;

  /// Returns true if order is completed.
  bool get isCompleted => status.isFulfilled;

  /// Returns formatted estimated delivery time.
  String get estimatedDeliveryFormatted {
    if (estimatedDeliveryMin == null && estimatedDeliveryMax == null) {
      return '';
    }

    String format(DateTime dt) {
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}$period';
    }

    if (estimatedDeliveryMin != null && estimatedDeliveryMax != null) {
      return '${format(estimatedDeliveryMin!)} - ${format(estimatedDeliveryMax!)}';
    } else if (estimatedDeliveryMin != null) {
      return 'From ${format(estimatedDeliveryMin!)}';
    } else {
      return 'By ${format(estimatedDeliveryMax!)}';
    }
  }

  /// Creates a copy with updated values.
  Order copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    List<OrderItem>? items,
    OrderSummary? summary,
    ShippingAddress? shippingAddress,
    ShippingAddress? billingAddress,
    ShippingMethod? shippingMethod,
    DeliveryTimeSlot? deliveryTimeSlot,
    DateTime? estimatedDeliveryMin,
    DateTime? estimatedDeliveryMax,
    DateTime? actualDeliveryTime,
    String? customerNote,
    String? internalNote,
    String? couponCode,
    Money? walletUsed,
    int? pointsRedeemed,
    int? pointsEarned,
    Money? cashbackEarned,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? trackingNumber,
    String? trackingUrl,
    DeliveryDriver? driver,
    String? source,
    String? platform,
    Map<String, dynamic>? metadata,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      summary: summary ?? this.summary,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      deliveryTimeSlot: deliveryTimeSlot ?? this.deliveryTimeSlot,
      estimatedDeliveryMin: estimatedDeliveryMin ?? this.estimatedDeliveryMin,
      estimatedDeliveryMax: estimatedDeliveryMax ?? this.estimatedDeliveryMax,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      customerNote: customerNote ?? this.customerNote,
      internalNote: internalNote ?? this.internalNote,
      couponCode: couponCode ?? this.couponCode,
      walletUsed: walletUsed ?? this.walletUsed,
      pointsRedeemed: pointsRedeemed ?? this.pointsRedeemed,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      cashbackEarned: cashbackEarned ?? this.cashbackEarned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      trackingUrl: trackingUrl ?? this.trackingUrl,
      driver: driver ?? this.driver,
      source: source ?? this.source,
      platform: platform ?? this.platform,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        userId,
        status,
        paymentStatus,
        paymentMethod,
        items,
        summary,
        shippingAddress,
        billingAddress,
        shippingMethod,
        deliveryTimeSlot,
        estimatedDeliveryMin,
        estimatedDeliveryMax,
        actualDeliveryTime,
        customerNote,
        internalNote,
        couponCode,
        walletUsed,
        pointsRedeemed,
        pointsEarned,
        cashbackEarned,
        createdAt,
        updatedAt,
        confirmedAt,
        completedAt,
        cancelledAt,
        cancellationReason,
        trackingNumber,
        trackingUrl,
        driver,
        source,
        platform,
        metadata,
      ];
}

/// Represents delivery driver information.
class DeliveryDriver extends Equatable {
  /// Driver ID.
  final String id;

  /// Driver name.
  final String name;

  /// Driver phone number.
  final String? phone;

  /// Driver photo URL.
  final String? photoUrl;

  /// Vehicle type.
  final String? vehicleType;

  /// Vehicle number.
  final String? vehicleNumber;

  /// Current latitude.
  final double? latitude;

  /// Current longitude.
  final double? longitude;

  /// Rating.
  final double? rating;

  /// Creates a [DeliveryDriver].
  const DeliveryDriver({
    required this.id,
    required this.name,
    this.phone,
    this.photoUrl,
    this.vehicleType,
    this.vehicleNumber,
    this.latitude,
    this.longitude,
    this.rating,
  });

  /// Creates from JSON.
  factory DeliveryDriver.fromJson(Map<String, dynamic> json) {
    return DeliveryDriver(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      photoUrl:
          json['photo_url'] ?? json['photoUrl'] ?? json['photo'] as String?,
      vehicleType: json['vehicle_type'] ?? json['vehicleType'] as String?,
      vehicleNumber: json['vehicle_number'] ?? json['vehicleNumber'] as String?,
      latitude: (json['latitude'] ?? json['lat'] as num?)?.toDouble(),
      longitude: (json['longitude'] ?? json['lng'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'photo_url': photoUrl,
        'vehicle_type': vehicleType,
        'vehicle_number': vehicleNumber,
        'latitude': latitude,
        'longitude': longitude,
        'rating': rating,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        photoUrl,
        vehicleType,
        vehicleNumber,
        latitude,
        longitude,
        rating,
      ];
}
