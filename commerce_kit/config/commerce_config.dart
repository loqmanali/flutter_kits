import 'cart_config.dart';

/// Global configuration for the commerce kit.
///
/// ## Usage
///
/// ```dart
/// // Initialize once at app startup
/// CommerceConfig.initialize(
///   cartConfig: CartConfig(
///     maxQuantityPerItem: 10,
///     freeShippingThreshold: Money(500),
///   ),
///   currency: 'EGP',
///   locale: 'ar_EG',
/// );
///
/// // Access anywhere
/// final config = CommerceConfig.instance;
/// ```
class CommerceConfig {
  static CommerceConfig? _instance;

  /// The cart configuration.
  final CartConfig cartConfig;

  /// Default currency code.
  final String currency;

  /// Locale for formatting.
  final String locale;

  /// Whether to enable debug logging.
  final bool debugMode;

  /// API base URL (if using remote cart).
  final String? apiBaseUrl;

  /// API timeout in milliseconds.
  final int apiTimeout;

  CommerceConfig._({
    required this.cartConfig,
    required this.currency,
    required this.locale,
    required this.debugMode,
    this.apiBaseUrl,
    required this.apiTimeout,
  });

  /// Gets the singleton instance.
  static CommerceConfig get instance {
    if (_instance == null) {
      throw StateError(
        'CommerceConfig not initialized. Call CommerceConfig.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Checks if the config has been initialized.
  static bool get isInitialized => _instance != null;

  /// Initializes the commerce configuration.
  static void initialize({
    CartConfig cartConfig = const CartConfig(),
    String currency = 'EGP',
    String locale = 'en_US',
    bool debugMode = false,
    String? apiBaseUrl,
    int apiTimeout = 30000,
  }) {
    _instance = CommerceConfig._(
      cartConfig: cartConfig,
      currency: currency,
      locale: locale,
      debugMode: debugMode,
      apiBaseUrl: apiBaseUrl,
      apiTimeout: apiTimeout,
    );
  }

  /// Resets the configuration (for testing).
  static void reset() {
    _instance = null;
  }

  /// Gets the cart config, or defaults if not initialized.
  static CartConfig get cart {
    return _instance?.cartConfig ?? const CartConfig();
  }
}
