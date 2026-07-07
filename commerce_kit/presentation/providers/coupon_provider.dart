import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/coupon.dart';
import '../../core/models/money.dart';

/// Coupon state.
class CouponState {
  /// Available coupons for the user.
  final List<Coupon> availableCoupons;

  /// Applied coupon.
  final Coupon? appliedCoupon;

  /// Validation result.
  final CouponValidation? validation;

  /// Input coupon code.
  final String inputCode;

  /// Loading state.
  final bool isLoading;

  /// Validating state.
  final bool isValidating;

  /// Error message.
  final String? error;

  const CouponState({
    this.availableCoupons = const [],
    this.appliedCoupon,
    this.validation,
    this.inputCode = '',
    this.isLoading = false,
    this.isValidating = false,
    this.error,
  });

  const CouponState.initial()
      : availableCoupons = const [],
        appliedCoupon = null,
        validation = null,
        inputCode = '',
        isLoading = false,
        isValidating = false,
        error = null;

  CouponState copyWith({
    List<Coupon>? availableCoupons,
    Coupon? appliedCoupon,
    CouponValidation? validation,
    String? inputCode,
    bool? isLoading,
    bool? isValidating,
    String? error,
    bool clearAppliedCoupon = false,
    bool clearValidation = false,
  }) {
    return CouponState(
      availableCoupons: availableCoupons ?? this.availableCoupons,
      appliedCoupon: clearAppliedCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      validation: clearValidation ? null : (validation ?? this.validation),
      inputCode: inputCode ?? this.inputCode,
      isLoading: isLoading ?? this.isLoading,
      isValidating: isValidating ?? this.isValidating,
      error: error,
    );
  }

  // Convenience getters
  bool get hasCouponApplied => appliedCoupon != null;
  bool get isValidCoupon => validation?.isValid ?? false;
  Money get discountAmount => validation?.discountAmount ?? const Money.zero();
}

/// Coupon notifier.
class CouponNotifier extends Notifier<CouponState> {
  @override
  CouponState build() {
    return const CouponState.initial();
  }

  /// Sets available coupons.
  void setAvailableCoupons(List<Coupon> coupons) {
    state = state.copyWith(availableCoupons: coupons);
  }

  /// Adds a coupon to available list.
  void addAvailableCoupon(Coupon coupon) {
    state = state.copyWith(
      availableCoupons: [...state.availableCoupons, coupon],
    );
  }

  /// Updates input code.
  void setInputCode(String code) {
    state = state.copyWith(
      inputCode: code,
      clearValidation: true,
    );
  }

  /// Validates a coupon code.
  Future<CouponValidation> validateCoupon(
    String code, {
    required Money orderAmount,
    int? itemCount,
    List<String>? productIds,
    List<String>? categoryIds,
    String? userId,
  }) async {
    state = state.copyWith(isValidating: true, clearValidation: true);

    try {
      // Find coupon in available coupons
      final coupon = state.availableCoupons.firstWhere(
        (c) => c.code.toUpperCase() == code.toUpperCase(),
        orElse: () => throw Exception('Coupon not found'),
      );

      // Validate coupon
      if (!coupon.isActive) {
        final validation = CouponValidation.invalid(
          message: 'This coupon is not active',
          code: CouponErrorCode.inactive,
        );
        state = state.copyWith(isValidating: false, validation: validation);
        return validation;
      }

      if (coupon.isExpired) {
        final validation = CouponValidation.invalid(
          message: 'This coupon has expired',
          code: CouponErrorCode.expired,
        );
        state = state.copyWith(isValidating: false, validation: validation);
        return validation;
      }

      if (coupon.isNotStarted) {
        final validation = CouponValidation.invalid(
          message: 'This coupon is not yet valid',
          code: CouponErrorCode.notStarted,
        );
        state = state.copyWith(isValidating: false, validation: validation);
        return validation;
      }

      if (coupon.isUsageLimitReached) {
        final validation = CouponValidation.invalid(
          message: 'This coupon has reached its usage limit',
          code: CouponErrorCode.usageLimitReached,
        );
        state = state.copyWith(isValidating: false, validation: validation);
        return validation;
      }

      if (coupon.minimumOrderAmount != null &&
          orderAmount < coupon.minimumOrderAmount!) {
        final validation = CouponValidation.invalid(
          message:
              'Minimum order of ${coupon.minimumOrderAmount!.formatted} required',
          code: CouponErrorCode.minimumNotMet,
        );
        state = state.copyWith(isValidating: false, validation: validation);
        return validation;
      }

      if (coupon.minimumItems != null &&
          itemCount != null &&
          itemCount < coupon.minimumItems!) {
        final validation = CouponValidation.invalid(
          message: 'Minimum of ${coupon.minimumItems} items required',
          code: CouponErrorCode.minimumItemsNotMet,
        );
        state = state.copyWith(isValidating: false, validation: validation);
        return validation;
      }

      // Check user restrictions
      if (coupon.applicableUserIds.isNotEmpty &&
          userId != null &&
          !coupon.applicableUserIds.contains(userId)) {
        final validation = CouponValidation.invalid(
          message: 'This coupon is not available for your account',
          code: CouponErrorCode.notApplicable,
        );
        state = state.copyWith(isValidating: false, validation: validation);
        return validation;
      }

      // Calculate discount
      final discountAmount = coupon.calculateDiscount(orderAmount);

      final validation = CouponValidation.valid(
        coupon: coupon,
        discountAmount: discountAmount,
      );

      state = state.copyWith(isValidating: false, validation: validation);
      return validation;
    } catch (e) {
      final validation = CouponValidation.invalid(
        message: 'Invalid coupon code',
        code: CouponErrorCode.notFound,
      );
      state = state.copyWith(isValidating: false, validation: validation);
      return validation;
    }
  }

  /// Applies a validated coupon.
  void applyCoupon(Coupon coupon) {
    state = state.copyWith(appliedCoupon: coupon);
  }

  /// Applies coupon from validation.
  void applyValidatedCoupon() {
    if (state.validation?.isValid == true && state.validation?.coupon != null) {
      state = state.copyWith(appliedCoupon: state.validation!.coupon);
    }
  }

  /// Removes applied coupon.
  void removeCoupon() {
    state = state.copyWith(
      clearAppliedCoupon: true,
      clearValidation: true,
      inputCode: '',
    );
  }

  /// Validates and applies coupon in one step.
  Future<bool> validateAndApply(
    String code, {
    required Money orderAmount,
    int? itemCount,
    List<String>? productIds,
    List<String>? categoryIds,
    String? userId,
  }) async {
    final validation = await validateCoupon(
      code,
      orderAmount: orderAmount,
      itemCount: itemCount,
      productIds: productIds,
      categoryIds: categoryIds,
      userId: userId,
    );

    if (validation.isValid && validation.coupon != null) {
      applyCoupon(validation.coupon!);
      return true;
    }
    return false;
  }

  /// Sets loading state.
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Sets error.
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Clears error.
  void clearError() {
    state = state.copyWith();
  }

  /// Clears all state.
  void clear() {
    state = const CouponState.initial();
  }
}

/// Main coupon provider.
final couponProvider =
    NotifierProvider<CouponNotifier, CouponState>(CouponNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Selector Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for available coupons.
final availableCouponsProvider = Provider<List<Coupon>>((ref) {
  return ref.watch(couponProvider.select((s) => s.availableCoupons));
});

/// Provider for valid available coupons only.
final validCouponsProvider = Provider<List<Coupon>>((ref) {
  final coupons = ref.watch(availableCouponsProvider);
  return coupons.where((c) => c.isValid).toList();
});

/// Provider for applied coupon.
final appliedCouponProvider = Provider<Coupon?>((ref) {
  return ref.watch(couponProvider.select((s) => s.appliedCoupon));
});

/// Provider for coupon validation.
final couponValidationProvider = Provider<CouponValidation?>((ref) {
  return ref.watch(couponProvider.select((s) => s.validation));
});

/// Provider for coupon input code.
final couponInputCodeProvider = Provider<String>((ref) {
  return ref.watch(couponProvider.select((s) => s.inputCode));
});

/// Provider for coupon discount amount.
final couponDiscountAmountProvider = Provider<Money>((ref) {
  return ref.watch(couponProvider.select((s) => s.discountAmount));
});

/// Provider for coupon loading state.
final couponLoadingProvider = Provider<bool>((ref) {
  return ref.watch(couponProvider.select((s) => s.isLoading));
});

/// Provider for coupon validating state.
final couponValidatingProvider = Provider<bool>((ref) {
  return ref.watch(couponProvider.select((s) => s.isValidating));
});

/// Provider for coupon error.
final couponErrorProvider = Provider<String?>((ref) {
  return ref.watch(couponProvider.select((s) => s.error));
});

/// Provider for coupon applied state.
final hasCouponAppliedProvider = Provider<bool>((ref) {
  return ref.watch(couponProvider.select((s) => s.hasCouponApplied));
});

/// Provider for coupon validation message.
final couponMessageProvider = Provider<String?>((ref) {
  final validation = ref.watch(couponValidationProvider);
  if (validation == null) return null;
  if (validation.isValid) {
    return validation.coupon?.formattedDiscount;
  }
  return validation.errorMessage;
});

/// Family provider to check if a coupon code is available.
final isCouponAvailableProvider = Provider.family<bool, String>((ref, code) {
  final coupons = ref.watch(validCouponsProvider);
  return coupons.any((c) => c.code.toUpperCase() == code.toUpperCase());
});

/// Family provider for coupon by code.
final couponByCodeProvider = Provider.family<Coupon?, String>((ref, code) {
  final coupons = ref.watch(availableCouponsProvider);
  try {
    return coupons.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
    );
  } catch (_) {
    return null;
  }
});
