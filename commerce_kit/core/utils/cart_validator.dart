import '../exceptions/commerce_exception.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/money.dart';
import '../models/product.dart';

/// Utility class for validating cart operations.
///
/// Provides methods to validate cart items, quantities, and overall cart state
/// before performing operations.
///
/// ## Usage
///
/// ```dart
/// // Validate before adding to cart
/// final errors = CartValidator.validateAddToCart(
///   product: product,
///   quantity: 2,
///   selectedOptions: {'size': 'large'},
/// );
///
/// if (errors.isNotEmpty) {
///   // Handle validation errors
/// }
///
/// // Validate entire cart
/// final cartErrors = CartValidator.validateCart(cart);
/// ```
class CartValidator {
  CartValidator._();

  /// Default maximum quantity per item.
  static const int defaultMaxQuantity = 99;

  /// Default minimum quantity per item.
  static const int defaultMinQuantity = 1;

  // ─────────────────────────────────────────────────────────────────────────
  // Item Validation
  // ─────────────────────────────────────────────────────────────────────────

  /// Validates adding a product to the cart.
  ///
  /// Returns a list of validation errors. Empty list means validation passed.
  static List<String> validateAddToCart({
    required Product product,
    int quantity = 1,
    Map<String, String>? selectedOptions,
    int? maxQuantity,
  }) {
    final errors = <String>[];

    // Check if product can be purchased
    if (!product.canPurchase) {
      errors.add('${product.name} is not available for purchase');
    }

    // Validate quantity
    final quantityErrors = validateQuantity(
      quantity,
      maxQuantity: maxQuantity ?? defaultMaxQuantity,
    );
    errors.addAll(quantityErrors);

    // Validate required options
    if (product.hasRequiredOptions) {
      final optionErrors = validateRequiredOptions(
        product: product,
        selectedOptions: selectedOptions ?? {},
      );
      errors.addAll(optionErrors);
    }

    // Validate stock availability
    if (product.stockQuantity != null && quantity > product.stockQuantity!) {
      errors.add('Only ${product.stockQuantity} items available');
    }

    return errors;
  }

  /// Validates a quantity value.
  static List<String> validateQuantity(
    int quantity, {
    int minQuantity = defaultMinQuantity,
    int maxQuantity = defaultMaxQuantity,
  }) {
    final errors = <String>[];

    if (quantity < minQuantity) {
      errors.add('Quantity must be at least $minQuantity');
    }

    if (quantity > maxQuantity) {
      errors.add('Quantity cannot exceed $maxQuantity');
    }

    return errors;
  }

  /// Validates required options are selected.
  static List<String> validateRequiredOptions({
    required Product product,
    required Map<String, String> selectedOptions,
  }) {
    final errors = <String>[];

    for (final option in product.options.where((o) => o.isRequired)) {
      if (!selectedOptions.containsKey(option.id)) {
        errors.add('Please select a ${option.name}');
      } else {
        final selectedValue = selectedOptions[option.id];
        final validationError = option.validateSelection(
          selectedValue != null ? [selectedValue] : [],
        );
        if (validationError != null) {
          errors.add(validationError);
        }
      }
    }

    return errors;
  }

  /// Validates a cart item.
  static List<String> validateCartItem(
    CartItem item, {
    int? maxQuantity,
    int? stockQuantity,
  }) {
    final errors = <String>[];

    // Validate quantity
    errors.addAll(
      validateQuantity(
        item.quantity,
        maxQuantity: maxQuantity ?? defaultMaxQuantity,
      ),
    );

    // Validate against stock
    if (stockQuantity != null && item.quantity > stockQuantity) {
      errors.add('Only $stockQuantity items available for ${item.name}');
    }

    return errors;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cart Validation
  // ─────────────────────────────────────────────────────────────────────────

  /// Validates the entire cart.
  ///
  /// Returns a map of item IDs to their validation errors.
  static Map<String, List<String>> validateCart(
    Cart cart, {
    int? maxQuantityPerItem,
    int? maxUniqueItems,
    int? maxTotalItems,
    Money? maxCartTotal,
    Money? minCartTotal,
  }) {
    final errors = <String, List<String>>{};

    // Validate each item
    for (final item in cart.items) {
      final itemErrors = validateCartItem(
        item,
        maxQuantity: maxQuantityPerItem ?? defaultMaxQuantity,
      );
      if (itemErrors.isNotEmpty) {
        errors[item.id] = itemErrors;
      }
    }

    // Validate unique items count
    if (maxUniqueItems != null && cart.uniqueItemCount > maxUniqueItems) {
      errors['_cart'] = [
        ...(errors['_cart'] ?? []),
        'Cart cannot have more than $maxUniqueItems different items',
      ];
    }

    // Validate total items count
    if (maxTotalItems != null && cart.itemCount > maxTotalItems) {
      errors['_cart'] = [
        ...(errors['_cart'] ?? []),
        'Cart cannot have more than $maxTotalItems total items',
      ];
    }

    // Validate cart total
    if (maxCartTotal != null && cart.totalPrice > maxCartTotal) {
      errors['_cart'] = [
        ...(errors['_cart'] ?? []),
        'Cart total cannot exceed ${maxCartTotal.formatted}',
      ];
    }

    if (minCartTotal != null && cart.totalPrice < minCartTotal) {
      errors['_cart'] = [
        ...(errors['_cart'] ?? []),
        'Minimum order amount is ${minCartTotal.formatted}',
      ];
    }

    return errors;
  }

  /// Validates if cart is ready for checkout.
  static CartValidationResult validateForCheckout(
    Cart cart, {
    Money? minimumOrderAmount,
    bool requireItems = true,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check if cart has items
    if (requireItems && cart.isEmpty) {
      errors.add('Cart is empty');
    }

    // Check minimum order amount
    if (minimumOrderAmount != null && cart.totalPrice < minimumOrderAmount) {
      final remaining = minimumOrderAmount - cart.totalPrice;
      errors.add(
        'Minimum order amount is ${minimumOrderAmount.formatted}. '
        'Add ${remaining.formatted} more to proceed.',
      );
    }

    // Check for items with issues
    for (final item in cart.items) {
      if (item.quantity <= 0) {
        errors.add('${item.name} has invalid quantity');
      }
    }

    return CartValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Throwing Validators
  // ─────────────────────────────────────────────────────────────────────────

  /// Validates and throws if invalid.
  static void assertValidQuantity(
    int quantity, {
    int minQuantity = defaultMinQuantity,
    int maxQuantity = defaultMaxQuantity,
  }) {
    if (quantity < minQuantity) {
      throw CartException.invalidQuantity(quantity);
    }
    if (quantity > maxQuantity) {
      throw CartException.maxQuantityExceeded(maxQuantity);
    }
  }

  /// Validates cart is not empty and throws if it is.
  static void assertNotEmpty(Cart cart) {
    if (cart.isEmpty) {
      throw CartException.emptyCart();
    }
  }

  /// Validates item exists in cart and throws if not.
  static void assertItemExists(Cart cart, String itemId) {
    if (cart.getItem(itemId) == null) {
      throw CartException.itemNotFound(itemId);
    }
  }

  /// Validates product can be purchased and throws if not.
  static void assertCanPurchase(Product product) {
    if (!product.canPurchase) {
      throw ProductException.outOfStock(product.id);
    }
  }

  /// Validates required options are selected and throws if not.
  static void assertRequiredOptionsSelected({
    required Product product,
    required Map<String, String> selectedOptions,
  }) {
    final errors = validateRequiredOptions(
      product: product,
      selectedOptions: selectedOptions,
    );
    if (errors.isNotEmpty) {
      throw ProductException.invalidOptions(
        {for (final e in errors) 'option': e},
      );
    }
  }
}

/// Result of cart validation for checkout.
class CartValidationResult {
  /// Whether the cart is valid for checkout.
  final bool isValid;

  /// List of validation errors.
  final List<String> errors;

  /// List of warnings (non-blocking).
  final List<String> warnings;

  /// Creates a [CartValidationResult].
  const CartValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  /// Returns `true` if there are any errors.
  bool get hasErrors => errors.isNotEmpty;

  /// Returns `true` if there are any warnings.
  bool get hasWarnings => warnings.isNotEmpty;

  /// Returns the first error message.
  String? get firstError => errors.isNotEmpty ? errors.first : null;

  /// Returns all messages (errors + warnings).
  List<String> get allMessages => [...errors, ...warnings];
}
