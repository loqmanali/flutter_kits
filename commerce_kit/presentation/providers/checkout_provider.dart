import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/checkout_status.dart';
import '../../core/enums/order_status.dart';
import '../../core/enums/payment_method.dart';
import '../../core/enums/payment_status.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/checkout_session.dart';
import '../../core/models/coupon.dart';
import '../../core/models/money.dart';
import '../../core/models/order.dart';
import '../../core/models/order_item.dart';
import '../../core/models/order_summary.dart';
import '../../core/models/shipping_address.dart';
import '../../core/models/shipping_method.dart';
import 'cart_provider.dart';

/// Checkout state.
class CheckoutState {
  /// Current checkout session.
  final CheckoutSession session;

  /// Loading state.
  final bool isLoading;

  /// Processing order.
  final bool isProcessing;

  /// Error message.
  final String? error;

  /// Created order (after successful checkout).
  final Order? createdOrder;

  const CheckoutState({
    required this.session,
    this.isLoading = false,
    this.isProcessing = false,
    this.error,
    this.createdOrder,
  });

  CheckoutState.initial()
      : session = CheckoutSession.empty(),
        isLoading = false,
        isProcessing = false,
        error = null,
        createdOrder = null;

  CheckoutState copyWith({
    CheckoutSession? session,
    bool? isLoading,
    bool? isProcessing,
    String? error,
    Order? createdOrder,
  }) {
    return CheckoutState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      createdOrder: createdOrder ?? this.createdOrder,
    );
  }

  // Convenience getters
  CheckoutStatus get status => session.status;
  bool get isReadyToOrder => session.isReadyToOrder;
  ShippingAddress? get shippingAddress => session.shippingAddress;
  ShippingMethod? get shippingMethod => session.selectedShippingMethod;
  PaymentMethod? get paymentMethod => session.selectedPaymentMethod;
  OrderSummary get summary => session.summary;
  bool get hasError => error != null;
}

/// Checkout notifier.
class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    return CheckoutState.initial();
  }

  /// Initializes checkout with cart items.
  void initializeCheckout({
    required List<CartItem> items,
    String? userId,
    List<ShippingMethod>? availableShippingMethods,
    List<PaymentMethod>? availablePaymentMethods,
    Money? availableWalletBalance,
    int? availablePoints,
    Money? availablePointsValue,
  }) {
    final now = DateTime.now();
    final session = CheckoutSession(
      id: 'checkout_${now.millisecondsSinceEpoch}',
      userId: userId,
      status: CheckoutStatus.shippingInfo,
      items: items,
      availableShippingMethods: availableShippingMethods ?? [],
      availablePaymentMethods: availablePaymentMethods ??
          [
            PaymentMethod.card,
            PaymentMethod.applePay,
            PaymentMethod.cashOnDelivery,
          ],
      availableWalletBalance: availableWalletBalance ?? const Money.zero(),
      availablePoints: availablePoints ?? 0,
      availablePointsValue: availablePointsValue ?? const Money.zero(),
      createdAt: now,
      updatedAt: now,
    );

    state = state.copyWith(
      session: session,
    );

    _recalculateSummary();
  }

  /// Initializes checkout from cart provider.
  void initializeFromCart() {
    final cartState = ref.read(commerceCartProvider);
    initializeCheckout(items: cartState.items);
  }

  /// Sets shipping address.
  void setShippingAddress(ShippingAddress address) {
    state = state.copyWith(
      session: state.session.copyWith(
        shippingAddress: address,
        status: CheckoutStatus.paymentMethod,
        updatedAt: DateTime.now(),
      ),
    );
    _validateCheckout();
    _recalculateSummary();
  }

  /// Sets billing address.
  void setBillingAddress(ShippingAddress address) {
    state = state.copyWith(
      session: state.session.copyWith(
        billingAddress: address,
        billingAddressSameAsShipping: false,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Sets billing address same as shipping.
  void setBillingAddressSameAsShipping(bool same) {
    state = state.copyWith(
      session: state.session.copyWith(
        billingAddressSameAsShipping: same,
        billingAddress: same ? null : state.session.billingAddress,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Sets shipping method.
  void setShippingMethod(ShippingMethod method) {
    state = state.copyWith(
      session: state.session.copyWith(
        selectedShippingMethod: method,
        estimatedDeliveryMin: method.estimatedDateMin,
        estimatedDeliveryMax: method.estimatedDateMax,
        updatedAt: DateTime.now(),
      ),
    );
    _validateCheckout();
    _recalculateSummary();
  }

  /// Sets delivery time slot.
  void setDeliveryTimeSlot(DeliveryTimeSlot slot) {
    state = state.copyWith(
      session: state.session.copyWith(
        selectedTimeSlot: slot,
        updatedAt: DateTime.now(),
      ),
    );
    _recalculateSummary();
  }

  /// Sets payment method.
  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(
      session: state.session.copyWith(
        selectedPaymentMethod: method,
        status: CheckoutStatus.review,
        updatedAt: DateTime.now(),
      ),
    );
    _validateCheckout();
  }

  /// Toggles wallet usage.
  void setUseWallet(bool use) {
    final walletAmount =
        use ? state.session.availableWalletBalance : const Money.zero();
    state = state.copyWith(
      session: state.session.copyWith(
        useWallet: use,
        walletAmountToUse: walletAmount,
        updatedAt: DateTime.now(),
      ),
    );
    _recalculateSummary();
  }

  /// Sets wallet amount to use.
  void setWalletAmount(Money amount) {
    final maxAmount = state.session.availableWalletBalance;
    final actualAmount = amount > maxAmount ? maxAmount : amount;
    state = state.copyWith(
      session: state.session.copyWith(
        useWallet: actualAmount.isPositive,
        walletAmountToUse: actualAmount,
        updatedAt: DateTime.now(),
      ),
    );
    _recalculateSummary();
  }

  /// Toggles points redemption.
  void setRedeemPoints(bool redeem) {
    final pointsToRedeem = redeem ? state.session.availablePoints : 0;
    final pointsValue =
        redeem ? state.session.availablePointsValue : const Money.zero();
    state = state.copyWith(
      session: state.session.copyWith(
        redeemPoints: redeem,
        pointsToRedeem: pointsToRedeem,
        pointsValueToRedeem: pointsValue,
        updatedAt: DateTime.now(),
      ),
    );
    _recalculateSummary();
  }

  /// Sets points to redeem.
  void setPointsToRedeem(int points) {
    final maxPoints = state.session.availablePoints;
    final actualPoints = points > maxPoints ? maxPoints : points;
    // Calculate value based on conversion rate
    const pointsPerUnit = 100.0; // Default, should come from config
    final value = Money(actualPoints / pointsPerUnit);
    state = state.copyWith(
      session: state.session.copyWith(
        redeemPoints: actualPoints > 0,
        pointsToRedeem: actualPoints,
        pointsValueToRedeem: value,
        updatedAt: DateTime.now(),
      ),
    );
    _recalculateSummary();
  }

  /// Applies coupon code.
  Future<void> applyCoupon(String code) async {
    state = state.copyWith(isLoading: true);

    // This would typically call an API to validate the coupon
    // For now, we just store the code
    state = state.copyWith(
      isLoading: false,
      session: state.session.copyWith(
        couponCode: code,
        updatedAt: DateTime.now(),
      ),
    );
    _recalculateSummary();
  }

  /// Validates and applies coupon.
  void applyCouponValidation(CouponValidation validation) {
    state = state.copyWith(
      session: state.session.copyWith(
        couponCode: validation.isValid ? validation.coupon?.code : null,
        couponMessage: validation.isValid
            ? validation.coupon?.formattedDiscount
            : validation.errorMessage,
        isCouponValid: validation.isValid,
        updatedAt: DateTime.now(),
      ),
    );
    _recalculateSummary();
  }

  /// Removes coupon.
  void removeCoupon() {
    state = state.copyWith(
      session: state.session.copyWith(
        updatedAt: DateTime.now(),
      ),
    );
    _recalculateSummary();
  }

  /// Sets tip amount.
  void setTip(Money amount) {
    state = state.copyWith(
      session: state.session.copyWith(
        tip: amount,
        updatedAt: DateTime.now(),
      ),
    );
    _recalculateSummary();
  }

  /// Sets tip percentage.
  void setTipPercentage(double percentage) {
    final subtotal = _calculateSubtotal();
    final tipAmount = subtotal * (percentage / 100);
    state = state.copyWith(
      session: state.session.copyWith(
        tip: tipAmount,
        tipPercentage: percentage,
        updatedAt: DateTime.now(),
      ),
    );
    _recalculateSummary();
  }

  /// Sets customer note.
  void setCustomerNote(String? note) {
    state = state.copyWith(
      session: state.session.copyWith(
        customerNote: note,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Sets gift options.
  void setGiftOptions({bool? isGift, String? message}) {
    state = state.copyWith(
      session: state.session.copyWith(
        isGift: isGift ?? state.session.isGift,
        giftMessage: message ?? state.session.giftMessage,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Places the order.
  Future<Order?> placeOrder() async {
    if (!state.session.isReadyToOrder) {
      state = state.copyWith(error: 'Please complete all required fields');
      return null;
    }

    state = state.copyWith(
      isProcessing: true,
      session: state.session.copyWith(
        status: CheckoutStatus.processing,
      ),
    );

    try {
      // This would typically call an API to create the order
      // For now, we create a mock order
      final now = DateTime.now();
      final order = Order(
        id: 'order_${now.millisecondsSinceEpoch}',
        orderNumber: '#${now.millisecondsSinceEpoch.toString().substring(5)}',
        userId: state.session.userId,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        paymentMethod: state.session.selectedPaymentMethod!,
        items: state.session.items
            .map(
              (item) => OrderItem(
                id: item.id,
                productId: item.productId,
                name: item.name,
                unitPrice: item.price,
                quantity: item.quantity,
                selectedOptions: item.selectedOptions.map(
                  (key, value) => MapEntry(
                    key,
                    SelectedOrderOption(
                      optionId: value.optionId,
                      optionName: value.optionName,
                      valueId: value.valueId,
                      valueLabel: value.valueName,
                      priceModifier: value.priceModifier,
                    ),
                  ),
                ),
                note: item.note,
              ),
            )
            .toList(),
        summary: state.session.summary,
        shippingAddress: state.session.shippingAddress,
        billingAddress: state.session.billingAddressSameAsShipping
            ? state.session.shippingAddress
            : state.session.billingAddress,
        shippingMethod: state.session.selectedShippingMethod,
        deliveryTimeSlot: state.session.selectedTimeSlot,
        estimatedDeliveryMin: state.session.estimatedDeliveryMin,
        estimatedDeliveryMax: state.session.estimatedDeliveryMax,
        customerNote: state.session.customerNote,
        couponCode: state.session.couponCode,
        walletUsed: state.session.walletAmountToUse,
        pointsRedeemed: state.session.pointsToRedeem,
        pointsEarned: state.session.pointsToEarn,
        cashbackEarned: state.session.cashbackToEarn,
        createdAt: now,
        updatedAt: now,
      );

      state = state.copyWith(
        isProcessing: false,
        createdOrder: order,
        session: state.session.copyWith(
          status: CheckoutStatus.completed,
        ),
      );

      // Clear cart after successful order
      ref.read(commerceCartProvider.notifier).clearCart();

      return order;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to place order: $e',
        session: state.session.copyWith(
          status: CheckoutStatus.failed,
        ),
      );
      return null;
    }
  }

  /// Clears error.
  void clearError() {
    state = state.copyWith();
  }

  /// Resets checkout.
  void reset() {
    state = CheckoutState.initial();
  }

  // Private helpers

  void _validateCheckout() {
    final errors = <String>[];

    if (state.session.items.isEmpty) {
      errors.add('Cart is empty');
    }
    if (state.session.shippingAddress == null) {
      errors.add('Shipping address is required');
    }
    if (state.session.selectedShippingMethod == null) {
      errors.add('Shipping method is required');
    }
    if (state.session.selectedPaymentMethod == null) {
      errors.add('Payment method is required');
    }

    state = state.copyWith(
      session: state.session.copyWith(
        validationErrors: errors,
      ),
    );
  }

  Money _calculateSubtotal() {
    return state.session.items.fold(
      const Money.zero(),
      (sum, item) => sum + item.totalPrice,
    );
  }

  void _recalculateSummary() {
    final items = state.session.items;
    final subtotal = _calculateSubtotal();
    final shippingCost =
        state.session.selectedShippingMethod?.cost ?? const Money.zero();
    final timeSlotCost =
        state.session.selectedTimeSlot?.additionalCost ?? const Money.zero();
    final tip = state.session.tip;
    final walletUsed = state.session.walletAmountToUse;
    final pointsValue = state.session.pointsValueToRedeem;

    // Calculate discounts
    var orderDiscount = const Money.zero();
    if (state.session.isCouponValid == true &&
        state.session.couponCode != null) {
      // Coupon discount would be calculated based on coupon type
      // For now, assume 10% placeholder
      orderDiscount = subtotal * 0.1;
    }

    // Calculate tax (8% example)
    const taxRate = 0.08;
    final taxableAmount = subtotal - orderDiscount;
    final tax = taxableAmount * taxRate;

    // Service fee (example)
    final serviceFee = Money(subtotal.amount * 0.01); // 1%

    // Points earned (10 points per EGP spent)
    final pointsEarned = (subtotal.amount * 10).round();

    final summary = OrderSummary(
      subtotal: subtotal,
      orderDiscount: orderDiscount,
      shippingCost: shippingCost + timeSlotCost,
      serviceFee: serviceFee,
      tip: tip,
      tax: tax,
      taxPercentage: taxRate * 100,
      walletUsed: walletUsed,
      pointsValueRedeemed: pointsValue,
      pointsRedeemed: state.session.pointsToRedeem,
      itemCount: items.fold(0, (sum, item) => sum + item.quantity),
      uniqueItemCount: items.length,
      pointsEarned: pointsEarned,
      couponCode: state.session.couponCode,
    );

    state = state.copyWith(
      session: state.session.copyWith(
        summary: summary,
        pointsToEarn: pointsEarned,
      ),
    );
  }
}

/// Main checkout provider.
final checkoutProvider =
    NotifierProvider<CheckoutNotifier, CheckoutState>(CheckoutNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Selector Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for checkout session.
final checkoutSessionProvider = Provider<CheckoutSession>((ref) {
  return ref.watch(checkoutProvider.select((s) => s.session));
});

/// Provider for checkout status.
final checkoutStatusProvider = Provider<CheckoutStatus>((ref) {
  return ref.watch(checkoutProvider.select((s) => s.status));
});

/// Provider for shipping address.
final checkoutShippingAddressProvider = Provider<ShippingAddress?>((ref) {
  return ref.watch(checkoutProvider.select((s) => s.shippingAddress));
});

/// Provider for shipping method.
final checkoutShippingMethodProvider = Provider<ShippingMethod?>((ref) {
  return ref.watch(checkoutProvider.select((s) => s.shippingMethod));
});

/// Provider for payment method.
final checkoutPaymentMethodProvider = Provider<PaymentMethod?>((ref) {
  return ref.watch(checkoutProvider.select((s) => s.paymentMethod));
});

/// Provider for order summary.
final orderSummaryProvider = Provider<OrderSummary>((ref) {
  return ref.watch(checkoutProvider.select((s) => s.summary));
});

/// Provider for order summary line items.
final orderSummaryLineItemsProvider = Provider<List<SummaryLineItem>>((ref) {
  return ref.watch(orderSummaryProvider).toLineItems();
});

/// Provider for checkout ready state.
final checkoutReadyProvider = Provider<bool>((ref) {
  return ref.watch(checkoutProvider.select((s) => s.isReadyToOrder));
});

/// Provider for checkout loading state.
final checkoutLoadingProvider = Provider<bool>((ref) {
  return ref.watch(checkoutProvider.select((s) => s.isLoading));
});

/// Provider for checkout processing state.
final checkoutProcessingProvider = Provider<bool>((ref) {
  return ref.watch(checkoutProvider.select((s) => s.isProcessing));
});

/// Provider for checkout error.
final checkoutErrorProvider = Provider<String?>((ref) {
  return ref.watch(checkoutProvider.select((s) => s.error));
});

/// Provider for created order.
final createdOrderProvider = Provider<Order?>((ref) {
  return ref.watch(checkoutProvider.select((s) => s.createdOrder));
});

/// Provider for available shipping methods.
final availableShippingMethodsProvider = Provider<List<ShippingMethod>>((ref) {
  return ref.watch(
    checkoutProvider.select((s) => s.session.availableShippingMethods),
  );
});

/// Provider for available payment methods.
final availablePaymentMethodsProvider = Provider<List<PaymentMethod>>((ref) {
  return ref.watch(
    checkoutProvider.select((s) => s.session.availablePaymentMethods),
  );
});

/// Provider for wallet availability.
final checkoutWalletProvider =
    Provider<({Money balance, bool isUsing, Money amountUsed})>((ref) {
  final session = ref.watch(checkoutSessionProvider);
  return (
    balance: session.availableWalletBalance,
    isUsing: session.useWallet,
    amountUsed: session.walletAmountToUse,
  );
});

/// Provider for points availability.
final checkoutPointsProvider = Provider<
    ({
      int balance,
      Money value,
      bool isRedeeming,
      int redeeming,
      Money redeemingValue
    })>((ref) {
  final session = ref.watch(checkoutSessionProvider);
  return (
    balance: session.availablePoints,
    value: session.availablePointsValue,
    isRedeeming: session.redeemPoints,
    redeeming: session.pointsToRedeem,
    redeemingValue: session.pointsValueToRedeem,
  );
});

/// Provider for coupon state.
final checkoutCouponProvider =
    Provider<({String? code, String? message, bool? isValid})>((ref) {
  final session = ref.watch(checkoutSessionProvider);
  return (
    code: session.couponCode,
    message: session.couponMessage,
    isValid: session.isCouponValid,
  );
});

/// Provider for tip.
final checkoutTipProvider =
    Provider<({Money amount, double? percentage})>((ref) {
  final session = ref.watch(checkoutSessionProvider);
  return (
    amount: session.tip,
    percentage: session.tipPercentage,
  );
});

/// Provider for points to earn.
final pointsToEarnProvider = Provider<int>((ref) {
  return ref.watch(checkoutProvider.select((s) => s.session.pointsToEarn));
});

/// Provider for cashback to earn.
final cashbackToEarnProvider = Provider<Money>((ref) {
  return ref.watch(checkoutProvider.select((s) => s.session.cashbackToEarn));
});
