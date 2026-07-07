/// # Commerce Kit
///
/// A comprehensive, standalone e-commerce module for Flutter applications.
///
/// This module provides a complete solution for managing products and shopping carts
/// in any e-commerce application, regardless of the backend API structure.
///
/// ## Features
///
/// - **Product Management**: Full support for products with variants, options, and pricing
/// - **Cart Management**: Complete cart operations with persistence support
/// - **API Adapters**: Flexible adapters to map any API response to internal models
/// - **State Management**: Ready-to-use Riverpod providers
/// - **Reusable Widgets**: Pre-built cart and product widgets
///
/// ## Quick Start
///
/// ```dart
/// import 'package:commerce_kit/commerce_kit.dart';
///
/// // 1. Create an adapter for your API response
/// class MyApiAdapter extends ProductAdapter<MyApiResponse> {
///   @override
///   Product fromResponse(MyApiResponse response) {
///     return Product(
///       id: response.id,
///       name: response.name,
///       // ... map other fields
///     );
///   }
/// }
///
/// // 2. Initialize the cart
/// final cartConfig = CartConfig(
///   persistenceEnabled: true,
///   maxQuantityPerItem: 10,
/// );
///
/// // 3. Use the cart provider
/// final cart = ref.watch(cartProvider);
/// ```
///
/// ## Architecture
///
/// The module follows Clean Architecture principles:
///
/// ```
/// commerce_kit/
/// ├── core/           # Shared models, enums, exceptions
/// ├── data/           # Adapters, repositories implementations
/// ├── domain/         # Business logic, entities, use cases
/// ├── presentation/   # Providers, widgets, UI components
/// └── config/         # Configuration classes
/// ```
library;

// ═══════════════════════════════════════════════════════════════════════════
// CONFIG - Configuration Classes
// ═══════════════════════════════════════════════════════════════════════════

export 'config/cart_config.dart';
export 'config/commerce_config.dart';
export 'core/enums/cart_operation.dart';
export 'core/enums/category_type.dart';
export 'core/enums/checkout_status.dart';
export 'core/enums/coupon_type.dart';
export 'core/enums/discount_type.dart';
export 'core/enums/loyalty_tier.dart';
export 'core/enums/order_status.dart';
export 'core/enums/payment_method.dart';
export 'core/enums/payment_status.dart';
export 'core/enums/points_transaction_type.dart';
// ═══════════════════════════════════════════════════════════════════════════
// CORE - Models, Enums, Exceptions, Extensions, Utils
// ═══════════════════════════════════════════════════════════════════════════

// Enums
export 'core/enums/product_type.dart';
export 'core/enums/shipping_type.dart';
export 'core/enums/sort_option.dart';
export 'core/enums/stock_status.dart';
export 'core/enums/variant_type.dart';
export 'core/enums/wallet_transaction_type.dart';
// Exceptions
export 'core/exceptions/commerce_exception.dart';
// Extensions
export 'core/extensions/cart_extensions.dart';
export 'core/extensions/category_extensions.dart';
export 'core/extensions/product_extensions.dart';
// Analytics
export 'core/models/analytics_event.dart';
// Models
export 'core/models/cart.dart';
export 'core/models/cart_item.dart';
export 'core/models/category.dart';
export 'core/models/category_image.dart';
export 'core/models/checkout_session.dart';
export 'core/models/coupon.dart';
export 'core/models/discount.dart';
export 'core/models/loyalty_account.dart';
export 'core/models/money.dart';
export 'core/models/order.dart';
export 'core/models/order_item.dart';
export 'core/models/order_summary.dart';
export 'core/models/price_breakdown.dart';
export 'core/models/product.dart';
export 'core/models/product_attribute.dart';
export 'core/models/product_filter.dart';
export 'core/models/product_image.dart';
export 'core/models/product_option.dart';
export 'core/models/product_option_value.dart';
export 'core/models/product_variant.dart';
export 'core/models/review.dart';
export 'core/models/search_result.dart';
export 'core/models/shipping_address.dart';
export 'core/models/shipping_method.dart';
export 'core/models/wallet.dart';
export 'core/models/wishlist.dart';
// Utils
export 'core/utils/cart_validator.dart';
export 'core/utils/error_handler.dart';
export 'core/utils/price_calculator.dart';
export 'core/utils/product_sorter.dart';
export 'core/utils/validators.dart';
// ═══════════════════════════════════════════════════════════════════════════
// DATA - Adapters, Repositories, Datasources, Mappers
// ═══════════════════════════════════════════════════════════════════════════

// Adapters (API Response Mapping)
export 'data/adapters/cart_adapter.dart';
export 'data/adapters/category_adapter.dart';
export 'data/adapters/json_product_adapter.dart';
export 'data/adapters/order_adapter.dart';
export 'data/adapters/product_adapter.dart';
export 'data/adapters/review_adapter.dart';
export 'data/adapters/search_adapter.dart';
export 'data/adapters/wishlist_adapter.dart';
// Datasources
export 'data/datasources/cart_local_datasource.dart';
export 'data/mappers/cart_mapper.dart';
// Mappers
export 'data/mappers/product_mapper.dart';
// Repositories
export 'data/repositories/cart_repository_impl.dart';
// ═══════════════════════════════════════════════════════════════════════════
// DOMAIN - Entities, Repositories, Use Cases
// ═══════════════════════════════════════════════════════════════════════════

// Repositories (Interfaces)
export 'domain/repositories/cart_repository.dart';
export 'domain/repositories/order_repository.dart';
export 'domain/repositories/review_repository.dart';
export 'domain/repositories/search_repository.dart';
export 'domain/repositories/wishlist_repository.dart';
// Use Cases - Cart
export 'domain/usecases/add_to_cart_usecase.dart';
export 'domain/usecases/apply_discount_usecase.dart';
export 'domain/usecases/clear_cart_usecase.dart';
// Use Cases - Order
export 'domain/usecases/order_usecases.dart';
export 'domain/usecases/remove_from_cart_usecase.dart';
// Use Cases - Review
export 'domain/usecases/review_usecases.dart';
// Use Cases - Search
export 'domain/usecases/search_usecases.dart';
export 'domain/usecases/update_cart_item_usecase.dart';
// Use Cases - Wishlist
export 'domain/usecases/wishlist_usecases.dart';
// ═══════════════════════════════════════════════════════════════════════════
// PRESENTATION - Providers, Widgets, Mixins
// ═══════════════════════════════════════════════════════════════════════════

// Mixins
export 'presentation/mixins/cart_mixin.dart';
// Providers
export 'presentation/providers/analytics_provider.dart';
export 'presentation/providers/cart_config_provider.dart';
export 'presentation/providers/cart_provider.dart';
export 'presentation/providers/category_provider.dart';
export 'presentation/providers/checkout_provider.dart';
export 'presentation/providers/coupon_provider.dart';
export 'presentation/providers/loyalty_provider.dart';
export 'presentation/providers/order_provider.dart';
export 'presentation/providers/review_provider.dart';
export 'presentation/providers/search_provider.dart';
export 'presentation/providers/wallet_provider.dart';
export 'presentation/providers/wishlist_provider.dart';
// Widgets
export 'presentation/widgets/add_to_cart_button.dart';
export 'presentation/widgets/cart_badge_widget.dart';
export 'presentation/widgets/cart_item_widget.dart';
export 'presentation/widgets/cart_summary_widget.dart';
export 'presentation/widgets/category_widgets.dart';
export 'presentation/widgets/checkout_widgets.dart';
export 'presentation/widgets/coupon_widgets.dart';
export 'presentation/widgets/loyalty_widgets.dart';
export 'presentation/widgets/option_selector_widget.dart';
export 'presentation/widgets/order_widgets.dart';
export 'presentation/widgets/price_display_widget.dart';
export 'presentation/widgets/quantity_selector_widget.dart';
export 'presentation/widgets/review_widgets.dart';
export 'presentation/widgets/search_widgets.dart';
export 'presentation/widgets/variant_selector_widget.dart';
export 'presentation/widgets/wallet_widgets.dart';
export 'presentation/widgets/wishlist_widgets.dart';
