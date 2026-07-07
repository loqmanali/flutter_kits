import 'package:equatable/equatable.dart';

import '../enums/checkout_status.dart';
import '../enums/payment_method.dart';
import 'cart_item.dart';
import 'money.dart';
import 'order_summary.dart';
import 'shipping_address.dart';
import 'shipping_method.dart';

/// Represents an active checkout session.
///
/// A checkout session holds the state of an ongoing checkout process,
/// including selected options, applied discounts, and calculated totals.
class CheckoutSession extends Equatable {
  /// Unique session identifier.
  final String id;

  /// Cart ID associated with this checkout.
  final String? cartId;

  /// User ID if authenticated.
  final String? userId;

  /// Current checkout status.
  final CheckoutStatus status;

  /// Items in checkout.
  final List<CartItem> items;

  /// Selected shipping address.
  final ShippingAddress? shippingAddress;

  /// Selected billing address (if different).
  final ShippingAddress? billingAddress;

  /// Whether billing address is same as shipping.
  final bool billingAddressSameAsShipping;

  /// Available shipping methods.
  final List<ShippingMethod> availableShippingMethods;

  /// Selected shipping method.
  final ShippingMethod? selectedShippingMethod;

  /// Selected delivery time slot.
  final DeliveryTimeSlot? selectedTimeSlot;

  /// Available payment methods.
  final List<PaymentMethod> availablePaymentMethods;

  /// Selected payment method.
  final PaymentMethod? selectedPaymentMethod;

  /// Applied coupon code.
  final String? couponCode;

  /// Coupon validation message.
  final String? couponMessage;

  /// Whether coupon is valid.
  final bool? isCouponValid;

  /// Whether to use wallet balance.
  final bool useWallet;

  /// Available wallet balance.
  final Money availableWalletBalance;

  /// Wallet amount to be used.
  final Money walletAmountToUse;

  /// Whether to redeem points.
  final bool redeemPoints;

  /// Available points balance.
  final int availablePoints;

  /// Available points value in money.
  final Money availablePointsValue;

  /// Points to redeem.
  final int pointsToRedeem;

  /// Points value to be redeemed.
  final Money pointsValueToRedeem;

  /// Tip amount.
  final Money tip;

  /// Tip percentage (if using percentage).
  final double? tipPercentage;

  /// Customer note/instructions.
  final String? customerNote;

  /// Gift message.
  final String? giftMessage;

  /// Whether this is a gift order.
  final bool isGift;

  /// Order summary with calculated totals.
  final OrderSummary summary;

  /// Estimated delivery date/time (minimum).
  final DateTime? estimatedDeliveryMin;

  /// Estimated delivery date/time (maximum).
  final DateTime? estimatedDeliveryMax;

  /// Points that will be earned.
  final int pointsToEarn;

  /// Cashback that will be earned.
  final Money cashbackToEarn;

  /// Session expiration time.
  final DateTime? expiresAt;

  /// Session creation time.
  final DateTime createdAt;

  /// Last update time.
  final DateTime updatedAt;

  /// Validation errors.
  final List<String> validationErrors;

  /// Whether checkout is ready to place order.
  bool get isReadyToOrder =>
      validationErrors.isEmpty &&
      items.isNotEmpty &&
      shippingAddress != null &&
      selectedShippingMethod != null &&
      selectedPaymentMethod != null;

  /// Whether session has expired.
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Creates a [CheckoutSession].
  const CheckoutSession({
    required this.id,
    this.cartId,
    this.userId,
    this.status = CheckoutStatus.pending,
    this.items = const [],
    this.shippingAddress,
    this.billingAddress,
    this.billingAddressSameAsShipping = true,
    this.availableShippingMethods = const [],
    this.selectedShippingMethod,
    this.selectedTimeSlot,
    this.availablePaymentMethods = const [],
    this.selectedPaymentMethod,
    this.couponCode,
    this.couponMessage,
    this.isCouponValid,
    this.useWallet = false,
    this.availableWalletBalance = const Money.zero(),
    this.walletAmountToUse = const Money.zero(),
    this.redeemPoints = false,
    this.availablePoints = 0,
    this.availablePointsValue = const Money.zero(),
    this.pointsToRedeem = 0,
    this.pointsValueToRedeem = const Money.zero(),
    this.tip = const Money.zero(),
    this.tipPercentage,
    this.customerNote,
    this.giftMessage,
    this.isGift = false,
    this.summary = const OrderSummary.empty(),
    this.estimatedDeliveryMin,
    this.estimatedDeliveryMax,
    this.pointsToEarn = 0,
    this.cashbackToEarn = const Money.zero(),
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.validationErrors = const [],
  });

  /// Creates an empty checkout session.
  factory CheckoutSession.empty() {
    final now = DateTime.now();
    return CheckoutSession(
      id: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a [CheckoutSession] from JSON.
  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      id: json['id'] as String,
      cartId: json['cart_id'] ?? json['cartId'] as String?,
      userId: json['user_id'] ?? json['userId'] as String?,
      status: CheckoutStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => CheckoutStatus.pending,
      ),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      billingAddressSameAsShipping: json['billing_address_same_as_shipping'] ??
          json['billingAddressSameAsShipping'] as bool? ??
          true,
      availableShippingMethods: (json['available_shipping_methods']
                  as List<dynamic>?)
              ?.map((e) => ShippingMethod.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      selectedShippingMethod: json['selected_shipping_method'] != null
          ? ShippingMethod.fromJson(
              json['selected_shipping_method'] as Map<String, dynamic>,
            )
          : json['selectedShippingMethod'] != null
              ? ShippingMethod.fromJson(
                  json['selectedShippingMethod'] as Map<String, dynamic>,
                )
              : null,
      selectedTimeSlot: json['selected_time_slot'] != null
          ? DeliveryTimeSlot.fromJson(
              json['selected_time_slot'] as Map<String, dynamic>,
            )
          : json['selectedTimeSlot'] != null
              ? DeliveryTimeSlot.fromJson(
                  json['selectedTimeSlot'] as Map<String, dynamic>,
                )
              : null,
      availablePaymentMethods:
          (json['available_payment_methods'] as List<dynamic>?)
                  ?.map(
                    (e) => PaymentMethod.values.firstWhere(
                      (pm) => pm.name == e,
                      orElse: () => PaymentMethod.card,
                    ),
                  )
                  .toList() ??
              [],
      selectedPaymentMethod: json['selected_payment_method'] != null ||
              json['selectedPaymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) =>
                  e.name ==
                  (json['selected_payment_method'] ??
                      json['selectedPaymentMethod']),
              orElse: () => PaymentMethod.card,
            )
          : null,
      couponCode: json['coupon_code'] ?? json['couponCode'] as String?,
      couponMessage: json['coupon_message'] ?? json['couponMessage'] as String?,
      isCouponValid: json['is_coupon_valid'] ?? json['isCouponValid'] as bool?,
      useWallet: json['use_wallet'] ?? json['useWallet'] as bool? ?? false,
      availableWalletBalance: json['available_wallet_balance'] != null
          ? Money.fromJson(
              json['available_wallet_balance'] as Map<String, dynamic>,
            )
          : json['availableWalletBalance'] != null
              ? Money((json['availableWalletBalance'] as num).toDouble())
              : const Money.zero(),
      walletAmountToUse: json['wallet_amount_to_use'] != null
          ? Money.fromJson(json['wallet_amount_to_use'] as Map<String, dynamic>)
          : json['walletAmountToUse'] != null
              ? Money((json['walletAmountToUse'] as num).toDouble())
              : const Money.zero(),
      redeemPoints:
          json['redeem_points'] ?? json['redeemPoints'] as bool? ?? false,
      availablePoints:
          json['available_points'] ?? json['availablePoints'] as int? ?? 0,
      availablePointsValue: json['available_points_value'] != null
          ? Money.fromJson(
              json['available_points_value'] as Map<String, dynamic>,
            )
          : json['availablePointsValue'] != null
              ? Money((json['availablePointsValue'] as num).toDouble())
              : const Money.zero(),
      pointsToRedeem:
          json['points_to_redeem'] ?? json['pointsToRedeem'] as int? ?? 0,
      pointsValueToRedeem: json['points_value_to_redeem'] != null
          ? Money.fromJson(
              json['points_value_to_redeem'] as Map<String, dynamic>,
            )
          : json['pointsValueToRedeem'] != null
              ? Money((json['pointsValueToRedeem'] as num).toDouble())
              : const Money.zero(),
      tip: json['tip'] != null
          ? Money.fromJson(json['tip'] as Map<String, dynamic>)
          : const Money.zero(),
      tipPercentage:
          (json['tip_percentage'] ?? json['tipPercentage'] as num?)?.toDouble(),
      customerNote: json['customer_note'] ?? json['customerNote'] as String?,
      giftMessage: json['gift_message'] ?? json['giftMessage'] as String?,
      isGift: json['is_gift'] ?? json['isGift'] as bool? ?? false,
      summary: json['summary'] != null
          ? OrderSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : const OrderSummary.empty(),
      estimatedDeliveryMin: json['estimated_delivery_min'] != null
          ? DateTime.parse(json['estimated_delivery_min'] as String)
          : null,
      estimatedDeliveryMax: json['estimated_delivery_max'] != null
          ? DateTime.parse(json['estimated_delivery_max'] as String)
          : null,
      pointsToEarn: json['points_to_earn'] ?? json['pointsToEarn'] as int? ?? 0,
      cashbackToEarn: json['cashback_to_earn'] != null
          ? Money.fromJson(json['cashback_to_earn'] as Map<String, dynamic>)
          : json['cashbackToEarn'] != null
              ? Money((json['cashbackToEarn'] as num).toDouble())
              : const Money.zero(),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      validationErrors: (json['validation_errors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'cart_id': cartId,
        'user_id': userId,
        'status': status.name,
        'items': items.map((e) => e.toJson()).toList(),
        'shipping_address': shippingAddress?.toJson(),
        'billing_address': billingAddress?.toJson(),
        'billing_address_same_as_shipping': billingAddressSameAsShipping,
        'available_shipping_methods':
            availableShippingMethods.map((e) => e.toJson()).toList(),
        'selected_shipping_method': selectedShippingMethod?.toJson(),
        'selected_time_slot': selectedTimeSlot?.toJson(),
        'available_payment_methods':
            availablePaymentMethods.map((e) => e.name).toList(),
        'selected_payment_method': selectedPaymentMethod?.name,
        'coupon_code': couponCode,
        'coupon_message': couponMessage,
        'is_coupon_valid': isCouponValid,
        'use_wallet': useWallet,
        'available_wallet_balance': availableWalletBalance.toJson(),
        'wallet_amount_to_use': walletAmountToUse.toJson(),
        'redeem_points': redeemPoints,
        'available_points': availablePoints,
        'available_points_value': availablePointsValue.toJson(),
        'points_to_redeem': pointsToRedeem,
        'points_value_to_redeem': pointsValueToRedeem.toJson(),
        'tip': tip.toJson(),
        'tip_percentage': tipPercentage,
        'customer_note': customerNote,
        'gift_message': giftMessage,
        'is_gift': isGift,
        'summary': summary.toJson(),
        'estimated_delivery_min': estimatedDeliveryMin?.toIso8601String(),
        'estimated_delivery_max': estimatedDeliveryMax?.toIso8601String(),
        'points_to_earn': pointsToEarn,
        'cashback_to_earn': cashbackToEarn.toJson(),
        'expires_at': expiresAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'validation_errors': validationErrors,
      };

  /// Creates a copy with updated values.
  CheckoutSession copyWith({
    String? id,
    String? cartId,
    String? userId,
    CheckoutStatus? status,
    List<CartItem>? items,
    ShippingAddress? shippingAddress,
    ShippingAddress? billingAddress,
    bool? billingAddressSameAsShipping,
    List<ShippingMethod>? availableShippingMethods,
    ShippingMethod? selectedShippingMethod,
    DeliveryTimeSlot? selectedTimeSlot,
    List<PaymentMethod>? availablePaymentMethods,
    PaymentMethod? selectedPaymentMethod,
    String? couponCode,
    String? couponMessage,
    bool? isCouponValid,
    bool? useWallet,
    Money? availableWalletBalance,
    Money? walletAmountToUse,
    bool? redeemPoints,
    int? availablePoints,
    Money? availablePointsValue,
    int? pointsToRedeem,
    Money? pointsValueToRedeem,
    Money? tip,
    double? tipPercentage,
    String? customerNote,
    String? giftMessage,
    bool? isGift,
    OrderSummary? summary,
    DateTime? estimatedDeliveryMin,
    DateTime? estimatedDeliveryMax,
    int? pointsToEarn,
    Money? cashbackToEarn,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? validationErrors,
  }) {
    return CheckoutSession(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      billingAddressSameAsShipping:
          billingAddressSameAsShipping ?? this.billingAddressSameAsShipping,
      availableShippingMethods:
          availableShippingMethods ?? this.availableShippingMethods,
      selectedShippingMethod:
          selectedShippingMethod ?? this.selectedShippingMethod,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      availablePaymentMethods:
          availablePaymentMethods ?? this.availablePaymentMethods,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      couponCode: couponCode ?? this.couponCode,
      couponMessage: couponMessage ?? this.couponMessage,
      isCouponValid: isCouponValid ?? this.isCouponValid,
      useWallet: useWallet ?? this.useWallet,
      availableWalletBalance:
          availableWalletBalance ?? this.availableWalletBalance,
      walletAmountToUse: walletAmountToUse ?? this.walletAmountToUse,
      redeemPoints: redeemPoints ?? this.redeemPoints,
      availablePoints: availablePoints ?? this.availablePoints,
      availablePointsValue: availablePointsValue ?? this.availablePointsValue,
      pointsToRedeem: pointsToRedeem ?? this.pointsToRedeem,
      pointsValueToRedeem: pointsValueToRedeem ?? this.pointsValueToRedeem,
      tip: tip ?? this.tip,
      tipPercentage: tipPercentage ?? this.tipPercentage,
      customerNote: customerNote ?? this.customerNote,
      giftMessage: giftMessage ?? this.giftMessage,
      isGift: isGift ?? this.isGift,
      summary: summary ?? this.summary,
      estimatedDeliveryMin: estimatedDeliveryMin ?? this.estimatedDeliveryMin,
      estimatedDeliveryMax: estimatedDeliveryMax ?? this.estimatedDeliveryMax,
      pointsToEarn: pointsToEarn ?? this.pointsToEarn,
      cashbackToEarn: cashbackToEarn ?? this.cashbackToEarn,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cartId,
        userId,
        status,
        items,
        shippingAddress,
        billingAddress,
        billingAddressSameAsShipping,
        availableShippingMethods,
        selectedShippingMethod,
        selectedTimeSlot,
        availablePaymentMethods,
        selectedPaymentMethod,
        couponCode,
        couponMessage,
        isCouponValid,
        useWallet,
        availableWalletBalance,
        walletAmountToUse,
        redeemPoints,
        availablePoints,
        availablePointsValue,
        pointsToRedeem,
        pointsValueToRedeem,
        tip,
        tipPercentage,
        customerNote,
        giftMessage,
        isGift,
        summary,
        estimatedDeliveryMin,
        estimatedDeliveryMax,
        pointsToEarn,
        cashbackToEarn,
        expiresAt,
        createdAt,
        updatedAt,
        validationErrors,
      ];
}
