import '../../core/models/cart.dart';
import '../../core/models/discount.dart';
import '../repositories/cart_repository.dart';

/// Use case for applying discounts to the cart.
class ApplyDiscountUseCase {
  final CartRepository _repository;

  ApplyDiscountUseCase(this._repository);

  /// Applies a discount to the cart.
  Future<Cart> call(Discount discount) async {
    return _repository.applyDiscount(discount);
  }

  /// Applies a coupon code.
  Future<Cart> applyCoupon(String code) async {
    return _repository.applyCoupon(code);
  }

  /// Removes a discount.
  Future<Cart> removeDiscount(String discountId) async {
    return _repository.removeDiscount(discountId);
  }

  /// Removes the coupon code.
  Future<Cart> removeCoupon() async {
    return _repository.removeCoupon();
  }
}
