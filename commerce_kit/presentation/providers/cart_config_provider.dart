import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/cart_config.dart';
import '../../core/models/money.dart';

/// Provider for cart configuration.
///
/// Override this provider to customize cart behavior.
///
/// ## Usage
///
/// ```dart
/// // In your app
/// ProviderScope(
///   overrides: [
///     cartConfigProvider.overrideWithValue(
///       CartConfig(
///         maxQuantityPerItem: 10,
///         freeShippingThreshold: Money(500),
///       ),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
final cartConfigProvider = Provider<CartConfig>((ref) {
  return const CartConfig();
});

/// Provider for free shipping threshold.
final freeShippingThresholdProvider = Provider<Money?>((ref) {
  return ref.watch(cartConfigProvider).freeShippingThreshold;
});

/// Provider for minimum order amount.
final minimumOrderAmountProvider = Provider<Money?>((ref) {
  return ref.watch(cartConfigProvider).minimumOrderAmount;
});

/// Provider for tax rate.
final taxRateProvider = Provider<double?>((ref) {
  return ref.watch(cartConfigProvider).taxRate;
});

/// Provider for max quantity per item.
final maxQuantityPerItemProvider = Provider<int>((ref) {
  return ref.watch(cartConfigProvider).maxQuantityPerItem;
});
