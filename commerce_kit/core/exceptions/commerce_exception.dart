/// Base exception class for all commerce-related errors.
///
/// All specific exceptions in the commerce kit extend this class,
/// making it easy to catch all commerce-related errors.
///
/// ## Usage
///
/// ```dart
/// try {
///   await cartRepository.addItem(item);
/// } on CommerceException catch (e) {
///   print('Commerce error: ${e.message}');
/// }
/// ```
abstract class CommerceException implements Exception {
  /// The error message.
  final String message;

  /// The error code (for API errors or categorization).
  final String? code;

  /// The original exception that caused this error.
  final Object? cause;

  /// Additional details about the error.
  final Map<String, dynamic>? details;

  /// Creates a [CommerceException].
  const CommerceException({
    required this.message,
    this.code,
    this.cause,
    this.details,
  });

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (code != null) buffer.write(' (code: $code)');
    return buffer.toString();
  }
}

/// Exception thrown when a cart operation fails.
class CartException extends CommerceException {
  /// Creates a [CartException].
  const CartException({
    required super.message,
    super.code,
    super.cause,
    super.details,
  });

  /// Creates a [CartException] for item not found.
  factory CartException.itemNotFound(String itemId) {
    return CartException(
      message: 'Cart item not found: $itemId',
      code: 'ITEM_NOT_FOUND',
    );
  }

  /// Creates a [CartException] for invalid quantity.
  factory CartException.invalidQuantity(int quantity) {
    return CartException(
      message: 'Invalid quantity: $quantity',
      code: 'INVALID_QUANTITY',
    );
  }

  /// Creates a [CartException] for max quantity exceeded.
  factory CartException.maxQuantityExceeded(int max) {
    return CartException(
      message: 'Maximum quantity of $max exceeded',
      code: 'MAX_QUANTITY_EXCEEDED',
    );
  }

  /// Creates a [CartException] for empty cart.
  factory CartException.emptyCart() {
    return const CartException(
      message: 'Cart is empty',
      code: 'EMPTY_CART',
    );
  }

  /// Creates a [CartException] for persistence failure.
  factory CartException.persistenceFailed(Object cause) {
    return CartException(
      message: 'Failed to save cart',
      code: 'PERSISTENCE_FAILED',
      cause: cause,
    );
  }
}

/// Exception thrown when a product operation fails.
class ProductException extends CommerceException {
  /// Creates a [ProductException].
  const ProductException({
    required super.message,
    super.code,
    super.cause,
    super.details,
  });

  /// Creates a [ProductException] for product not found.
  factory ProductException.notFound(String productId) {
    return ProductException(
      message: 'Product not found: $productId',
      code: 'PRODUCT_NOT_FOUND',
    );
  }

  /// Creates a [ProductException] for out of stock.
  factory ProductException.outOfStock(String productId) {
    return ProductException(
      message: 'Product is out of stock',
      code: 'OUT_OF_STOCK',
      details: {'product_id': productId},
    );
  }

  /// Creates a [ProductException] for invalid variant.
  factory ProductException.invalidVariant(String productId, String variantId) {
    return ProductException(
      message: 'Invalid variant: $variantId',
      code: 'INVALID_VARIANT',
      details: {'product_id': productId, 'variant_id': variantId},
    );
  }

  /// Creates a [ProductException] for invalid options.
  factory ProductException.invalidOptions(Map<String, String> errors) {
    return ProductException(
      message: 'Invalid product options',
      code: 'INVALID_OPTIONS',
      details: {'errors': errors},
    );
  }
}

/// Exception thrown when a discount operation fails.
class DiscountException extends CommerceException {
  /// Creates a [DiscountException].
  const DiscountException({
    required super.message,
    super.code,
    super.cause,
    super.details,
  });

  /// Creates a [DiscountException] for invalid code.
  factory DiscountException.invalidCode(String code) {
    return DiscountException(
      message: 'Invalid discount code: $code',
      code: 'INVALID_CODE',
    );
  }

  /// Creates a [DiscountException] for expired discount.
  factory DiscountException.expired(String code) {
    return DiscountException(
      message: 'Discount has expired',
      code: 'DISCOUNT_EXPIRED',
      details: {'code': code},
    );
  }

  /// Creates a [DiscountException] for minimum not met.
  factory DiscountException.minimumNotMet(double minimum, double current) {
    return DiscountException(
      message: 'Minimum order amount of $minimum not met',
      code: 'MINIMUM_NOT_MET',
      details: {'minimum': minimum, 'current': current},
    );
  }

  /// Creates a [DiscountException] for not applicable.
  factory DiscountException.notApplicable(String reason) {
    return DiscountException(
      message: reason,
      code: 'NOT_APPLICABLE',
    );
  }

  /// Creates a [DiscountException] for already applied.
  factory DiscountException.alreadyApplied(String code) {
    return DiscountException(
      message: 'Discount is already applied',
      code: 'ALREADY_APPLIED',
      details: {'code': code},
    );
  }

  /// Creates a [DiscountException] for usage limit reached.
  factory DiscountException.usageLimitReached(String code) {
    return DiscountException(
      message: 'Discount usage limit has been reached',
      code: 'USAGE_LIMIT_REACHED',
      details: {'code': code},
    );
  }
}

/// Exception thrown when validation fails.
class ValidationException extends CommerceException {
  /// The validation errors by field.
  final Map<String, List<String>> errors;

  /// Creates a [ValidationException].
  const ValidationException({
    required super.message,
    this.errors = const {},
    super.code = 'VALIDATION_ERROR',
    super.cause,
    super.details,
  });

  /// Creates a [ValidationException] for a single field.
  factory ValidationException.field(String field, String error) {
    return ValidationException(
      message: error,
      errors: {
        field: [error],
      },
    );
  }

  /// Creates a [ValidationException] for multiple errors.
  factory ValidationException.multiple(Map<String, List<String>> errors) {
    return ValidationException(
      message: 'Validation failed',
      errors: errors,
    );
  }

  /// Returns `true` if there are any errors.
  bool get hasErrors => errors.isNotEmpty;

  /// Returns all error messages as a flat list.
  List<String> get allMessages {
    return errors.values.expand((e) => e).toList();
  }

  /// Returns the first error message.
  String? get firstMessage {
    final messages = allMessages;
    return messages.isNotEmpty ? messages.first : null;
  }
}

/// Exception thrown when an API/network operation fails.
class ApiException extends CommerceException {
  /// The HTTP status code (if applicable).
  final int? statusCode;

  /// Creates an [ApiException].
  const ApiException({
    required super.message,
    this.statusCode,
    super.code,
    super.cause,
    super.details,
  });

  /// Creates an [ApiException] for network error.
  factory ApiException.networkError(Object cause) {
    return ApiException(
      message: 'Network error occurred',
      code: 'NETWORK_ERROR',
      cause: cause,
    );
  }

  /// Creates an [ApiException] for timeout.
  factory ApiException.timeout() {
    return const ApiException(
      message: 'Request timed out',
      code: 'TIMEOUT',
    );
  }

  /// Creates an [ApiException] for unauthorized.
  factory ApiException.unauthorized() {
    return const ApiException(
      message: 'Unauthorized',
      code: 'UNAUTHORIZED',
      statusCode: 401,
    );
  }

  /// Creates an [ApiException] for forbidden.
  factory ApiException.forbidden() {
    return const ApiException(
      message: 'Access forbidden',
      code: 'FORBIDDEN',
      statusCode: 403,
    );
  }

  /// Creates an [ApiException] for server error.
  factory ApiException.serverError([String? message]) {
    return ApiException(
      message: message ?? 'Server error occurred',
      code: 'SERVER_ERROR',
      statusCode: 500,
    );
  }

  /// Creates an [ApiException] from status code.
  factory ApiException.fromStatusCode(int statusCode, [String? message]) {
    return ApiException(
      message: message ?? 'Request failed with status $statusCode',
      code: 'HTTP_$statusCode',
      statusCode: statusCode,
    );
  }
}

/// Exception thrown for data mapping/parsing errors.
class MappingException extends CommerceException {
  /// The field that failed to map.
  final String? field;

  /// Creates a [MappingException].
  const MappingException({
    required super.message,
    this.field,
    super.code = 'MAPPING_ERROR',
    super.cause,
    super.details,
  });

  /// Creates a [MappingException] for missing field.
  factory MappingException.missingField(String field) {
    return MappingException(
      message: 'Missing required field: $field',
      field: field,
      code: 'MISSING_FIELD',
    );
  }

  /// Creates a [MappingException] for invalid type.
  factory MappingException.invalidType(String field, String expected, String actual) {
    return MappingException(
      message: 'Invalid type for $field: expected $expected, got $actual',
      field: field,
      code: 'INVALID_TYPE',
      details: {'expected': expected, 'actual': actual},
    );
  }

  /// Creates a [MappingException] for invalid format.
  factory MappingException.invalidFormat(String field, String format) {
    return MappingException(
      message: 'Invalid format for $field: expected $format',
      field: field,
      code: 'INVALID_FORMAT',
    );
  }
}

/// Exception thrown when an order operation fails.
class OrderException extends CommerceException {
  /// Creates an [OrderException].
  const OrderException({
    required super.message,
    super.code,
    super.cause,
    super.details,
  });

  /// Creates an [OrderException] for order not found.
  factory OrderException.notFound(String orderId) {
    return OrderException(
      message: 'Order not found: $orderId',
      code: 'ORDER_NOT_FOUND',
    );
  }

  /// Creates an [OrderException] for cannot cancel.
  factory OrderException.cannotCancel(String orderId, String reason) {
    return OrderException(
      message: 'Cannot cancel order: $reason',
      code: 'CANNOT_CANCEL',
      details: {'order_id': orderId},
    );
  }

  /// Creates an [OrderException] for cannot modify.
  factory OrderException.cannotModify(String orderId) {
    return OrderException(
      message: 'Order cannot be modified in current status',
      code: 'CANNOT_MODIFY',
      details: {'order_id': orderId},
    );
  }

  /// Creates an [OrderException] for payment failed.
  factory OrderException.paymentFailed(String reason) {
    return OrderException(
      message: 'Payment failed: $reason',
      code: 'PAYMENT_FAILED',
    );
  }

  /// Creates an [OrderException] for order creation failed.
  factory OrderException.creationFailed(Object cause) {
    return OrderException(
      message: 'Failed to create order',
      code: 'CREATION_FAILED',
      cause: cause,
    );
  }
}

/// Exception thrown when a checkout operation fails.
class CheckoutException extends CommerceException {
  /// Creates a [CheckoutException].
  const CheckoutException({
    required super.message,
    super.code,
    super.cause,
    super.details,
  });

  /// Creates a [CheckoutException] for invalid address.
  factory CheckoutException.invalidAddress(String reason) {
    return CheckoutException(
      message: 'Invalid address: $reason',
      code: 'INVALID_ADDRESS',
    );
  }

  /// Creates a [CheckoutException] for no delivery available.
  factory CheckoutException.noDeliveryAvailable() {
    return const CheckoutException(
      message: 'No delivery options available for this address',
      code: 'NO_DELIVERY_AVAILABLE',
    );
  }

  /// Creates a [CheckoutException] for minimum order not met.
  factory CheckoutException.minimumOrderNotMet(double minimum, double current) {
    return CheckoutException(
      message: 'Minimum order amount of $minimum not met',
      code: 'MINIMUM_ORDER_NOT_MET',
      details: {'minimum': minimum, 'current': current},
    );
  }

  /// Creates a [CheckoutException] for session expired.
  factory CheckoutException.sessionExpired() {
    return const CheckoutException(
      message: 'Checkout session has expired',
      code: 'SESSION_EXPIRED',
    );
  }

  /// Creates a [CheckoutException] for items unavailable.
  factory CheckoutException.itemsUnavailable(List<String> productIds) {
    return CheckoutException(
      message: 'Some items are no longer available',
      code: 'ITEMS_UNAVAILABLE',
      details: {'product_ids': productIds},
    );
  }
}

/// Exception thrown when a wallet operation fails.
class WalletException extends CommerceException {
  /// Creates a [WalletException].
  const WalletException({
    required super.message,
    super.code,
    super.cause,
    super.details,
  });

  /// Creates a [WalletException] for insufficient balance.
  factory WalletException.insufficientBalance(double required, double available) {
    return WalletException(
      message: 'Insufficient wallet balance',
      code: 'INSUFFICIENT_BALANCE',
      details: {'required': required, 'available': available},
    );
  }

  /// Creates a [WalletException] for wallet not found.
  factory WalletException.notFound() {
    return const WalletException(
      message: 'Wallet not found',
      code: 'WALLET_NOT_FOUND',
    );
  }

  /// Creates a [WalletException] for transaction failed.
  factory WalletException.transactionFailed(Object cause) {
    return WalletException(
      message: 'Wallet transaction failed',
      code: 'TRANSACTION_FAILED',
      cause: cause,
    );
  }
}

/// Exception thrown when a loyalty/points operation fails.
class LoyaltyException extends CommerceException {
  /// Creates a [LoyaltyException].
  const LoyaltyException({
    required super.message,
    super.code,
    super.cause,
    super.details,
  });

  /// Creates a [LoyaltyException] for insufficient points.
  factory LoyaltyException.insufficientPoints(int required, int available) {
    return LoyaltyException(
      message: 'Insufficient points',
      code: 'INSUFFICIENT_POINTS',
      details: {'required': required, 'available': available},
    );
  }

  /// Creates a [LoyaltyException] for account not found.
  factory LoyaltyException.accountNotFound() {
    return const LoyaltyException(
      message: 'Loyalty account not found',
      code: 'ACCOUNT_NOT_FOUND',
    );
  }

  /// Creates a [LoyaltyException] for points expired.
  factory LoyaltyException.pointsExpired(int expiredPoints) {
    return LoyaltyException(
      message: '$expiredPoints points have expired',
      code: 'POINTS_EXPIRED',
      details: {'expired_points': expiredPoints},
    );
  }
}

/// Exception thrown when a review operation fails.
class ReviewException extends CommerceException {
  /// Creates a [ReviewException].
  const ReviewException({
    required super.message,
    super.code,
    super.cause,
    super.details,
  });

  /// Creates a [ReviewException] for already reviewed.
  factory ReviewException.alreadyReviewed(String productId) {
    return ReviewException(
      message: 'You have already reviewed this product',
      code: 'ALREADY_REVIEWED',
      details: {'product_id': productId},
    );
  }

  /// Creates a [ReviewException] for purchase required.
  factory ReviewException.purchaseRequired() {
    return const ReviewException(
      message: 'You must purchase this product before reviewing',
      code: 'PURCHASE_REQUIRED',
    );
  }

  /// Creates a [ReviewException] for review not found.
  factory ReviewException.notFound(String reviewId) {
    return ReviewException(
      message: 'Review not found',
      code: 'REVIEW_NOT_FOUND',
      details: {'review_id': reviewId},
    );
  }

  /// Creates a [ReviewException] for cannot edit.
  factory ReviewException.cannotEdit(String reason) {
    return ReviewException(
      message: 'Cannot edit review: $reason',
      code: 'CANNOT_EDIT',
    );
  }
}

/// Exception thrown when a wishlist operation fails.
class WishlistException extends CommerceException {
  /// Creates a [WishlistException].
  const WishlistException({
    required super.message,
    super.code,
    super.cause,
    super.details,
  });

  /// Creates a [WishlistException] for item not found.
  factory WishlistException.itemNotFound(String productId) {
    return WishlistException(
      message: 'Item not found in wishlist',
      code: 'ITEM_NOT_FOUND',
      details: {'product_id': productId},
    );
  }

  /// Creates a [WishlistException] for wishlist limit reached.
  factory WishlistException.limitReached(int limit) {
    return WishlistException(
      message: 'Wishlist limit of $limit items reached',
      code: 'LIMIT_REACHED',
      details: {'limit': limit},
    );
  }

  /// Creates a [WishlistException] for already in wishlist.
  factory WishlistException.alreadyExists(String productId) {
    return WishlistException(
      message: 'Item is already in wishlist',
      code: 'ALREADY_EXISTS',
      details: {'product_id': productId},
    );
  }
}
