# Commerce Kit

A complete, standalone, and reusable commerce module for Flutter applications. This module provides a robust foundation for cart and product management with support for variants, options, discounts, and flexible API integration.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
  - [Money](#money)
  - [Products](#products)
  - [Product Variants](#product-variants)
  - [Product Options](#product-options)
  - [Categories](#categories)
  - [Cart](#cart)
  - [Discounts](#discounts)
- [Checkout System](#checkout-system)
  - [Checkout Flow](#checkout-flow)
  - [Order Summary](#order-summary)
  - [Payment Methods](#payment-methods)
  - [Shipping](#shipping)
- [Order Management](#order-management)
  - [Order Status](#order-status)
  - [Order Tracking](#order-tracking)
- [Loyalty & Points System](#loyalty--points-system)
  - [Loyalty Tiers](#loyalty-tiers)
  - [Points Transactions](#points-transactions)
  - [Redeeming Points](#redeeming-points)
- [Coupon System](#coupon-system)
  - [Coupon Types](#coupon-types)
  - [Coupon Validation](#coupon-validation)
  - [Applying Coupons](#applying-coupons)
- [Wallet System](#wallet-system)
  - [Wallet Balance](#wallet-balance)
  - [Wallet Transactions](#wallet-transactions)
  - [Using Wallet at Checkout](#using-wallet-at-checkout)
- [Review System](#review-system)
  - [Reviews & Ratings](#reviews--ratings)
  - [Rating Statistics](#rating-statistics)
  - [Review Filtering](#review-filtering)
- [Wishlist System](#wishlist-system)
  - [Wishlist Management](#wishlist-management)
  - [Wishlist Notifications](#wishlist-notifications)
- [Search & Filtering](#search--filtering)
  - [Product Search](#product-search)
  - [Product Filters](#product-filters)
  - [Search Suggestions](#search-suggestions)
- [Analytics System](#analytics-system)
  - [Event Tracking](#event-tracking)
  - [Analytics Provider](#analytics-provider)
- [API Integration](#api-integration)
  - [Using Built-in Adapters](#using-built-in-adapters)
  - [Creating Custom Adapters](#creating-custom-adapters)
  - [Pre-built Platform Adapters](#pre-built-platform-adapters)
- [State Management](#state-management)
  - [Providers](#providers)
  - [Using CartMixin](#using-cartmixin)
- [Category Management](#category-management)
- [Widgets](#widgets)
- [Configuration](#configuration)
- [Examples](#examples)
- [API Reference](#api-reference)

---

## Features

- **Complete Product Management**: Support for simple, variable, configurable, and bundle products
- **Full Variant Support**: Size, color, material, and custom variants with price modifiers
- **Flexible Options System**: Single-select and multi-select options with validation
- **Comprehensive Category System**: Hierarchical categories with unlimited depth, types, images, and scheduling
- **Comprehensive Cart Operations**: Add, remove, update, clear with undo support
- **Discount System**: Percentage, fixed amount, free shipping, buy-one-get-one, and more
- **Complete Checkout Flow**: Multi-step checkout with shipping, payment, and order review
- **Order Management**: Complete order tracking with status updates, history, and order provider
- **Loyalty & Points System**: Tier-based loyalty program with points earning and redemption
- **Coupon System**: Flexible coupons with validation, limits, and multiple discount types
- **Wallet System**: Digital wallet with balance management, transactions, and checkout integration
- **Review & Rating System**: Product reviews with ratings, images, verified purchases, and statistics
- **Wishlist System**: Multiple wishlists with notifications for price drops and back-in-stock
- **Search & Filtering**: Advanced product search with filters, sorting, and suggestions
- **Analytics System**: Event tracking for e-commerce analytics integration
- **Price Calculations**: Automatic subtotal, tax, shipping, and total calculations
- **Local Persistence**: SharedPreferences-based cart and wishlist storage
- **Flexible API Integration**: Adapter pattern for any backend response format
- **Pre-built Platform Support**: WooCommerce, Shopify, Magento, PrestaShop adapters included
- **Riverpod State Management**: Efficient, reactive state with selector providers
- **Ready-to-use Widgets**: 60+ widgets for cart, checkout, reviews, wishlist, search, and more
- **Full Validation**: Stock checks, quantity limits, option requirements, input validation
- **Type-safe Money Handling**: Currency-aware arithmetic operations
- **Error Handling**: Comprehensive error handling with custom exceptions

---

## Architecture

```
commerce_kit/
├── core/                          # Core business logic
│   ├── enums/                     # Type definitions
│   │   ├── product_type.dart      # Simple, Variable, Configurable, Bundle
│   │   ├── variant_type.dart      # Size, Color, Material, Style, Custom
│   │   ├── discount_type.dart     # Percentage, Fixed, FreeShipping, BOGO
│   │   ├── cart_operation.dart    # Add, Remove, Update, Clear
│   │   ├── stock_status.dart      # InStock, OutOfStock, LowStock, etc.
│   │   ├── category_type.dart     # Standard, Featured, Sale, Brand, etc.
│   │   ├── checkout_status.dart   # Checkout flow states
│   │   ├── payment_method.dart    # Cash, Card, Wallet, Apple/Google Pay
│   │   ├── payment_status.dart    # Pending, Completed, Failed, Refunded
│   │   ├── order_status.dart      # Pending, Confirmed, Preparing, Delivered
│   │   ├── loyalty_tier.dart      # Bronze, Silver, Gold, Platinum, Diamond
│   │   ├── coupon_type.dart       # Percentage, Fixed, FreeShipping, BOGO
│   │   ├── wallet_transaction_type.dart  # Credit, Debit, Cashback, Refund
│   │   ├── points_transaction_type.dart  # Earned, Redeemed, Expired, Bonus
│   │   ├── shipping_type.dart     # Standard, Express, SameDay, Pickup
│   │   └── sort_option.dart       # Product sorting options
│   ├── models/                    # Data models
│   │   ├── money.dart             # Currency-safe money operations
│   │   ├── product.dart           # Complete product model
│   │   ├── product_variant.dart   # Variant with options
│   │   ├── product_option.dart    # Option groups (size, color)
│   │   ├── product_option_value.dart  # Individual option values
│   │   ├── product_image.dart     # Product images
│   │   ├── product_attribute.dart # Product attributes
│   │   ├── product_filter.dart    # Product filtering and search
│   │   ├── cart_item.dart         # Cart item with selections
│   │   ├── cart.dart              # Complete cart model
│   │   ├── discount.dart          # Discount definitions
│   │   ├── price_breakdown.dart   # Price calculation breakdown
│   │   ├── category.dart          # Category with hierarchy support
│   │   ├── category_image.dart    # Category images
│   │   ├── checkout_session.dart  # Checkout session state
│   │   ├── order.dart             # Complete order model
│   │   ├── order_item.dart        # Order line items
│   │   ├── order_summary.dart     # Order totals breakdown
│   │   ├── shipping_address.dart  # Shipping/billing addresses
│   │   ├── shipping_method.dart   # Shipping options and time slots
│   │   ├── loyalty_account.dart   # Loyalty account and points
│   │   ├── coupon.dart            # Coupons and validation
│   │   ├── wallet.dart            # Wallet and transactions
│   │   ├── review.dart            # Product reviews and ratings
│   │   ├── wishlist.dart          # Wishlist and items
│   │   ├── search_result.dart     # Search results and pagination
│   │   └── analytics_event.dart   # Analytics events
│   ├── exceptions/                # Custom exceptions
│   │   └── commerce_exception.dart # Base and specialized exceptions
│   ├── extensions/                # Utility extensions
│   │   ├── product_extensions.dart
│   │   ├── cart_extensions.dart
│   │   └── category_extensions.dart
│   └── utils/                     # Helpers
│       ├── price_calculator.dart  # Complex price calculations
│       ├── cart_validator.dart    # Cart validation logic
│       ├── product_sorter.dart    # Product sorting utilities
│       ├── validators.dart        # Input validation utilities
│       └── error_handler.dart     # Error handling utilities
├── data/                          # Data layer
│   ├── adapters/                  # API response adapters
│   │   ├── product_adapter.dart   # Product mapping interface
│   │   ├── cart_adapter.dart      # Cart mapping interface
│   │   ├── json_product_adapter.dart  # Configurable JSON adapter
│   │   └── category_adapter.dart  # Category mapping with platform presets
│   ├── mappers/                   # Data mappers
│   │   ├── product_mapper.dart    # Product transformations
│   │   └── cart_mapper.dart       # Cart serialization
│   ├── datasources/               # Local/remote data sources
│   │   └── cart_local_datasource.dart # SharedPreferences storage
│   └── repositories/              # Repository implementations
│       └── cart_repository_impl.dart
├── domain/                        # Domain layer
│   ├── repositories/              # Repository interfaces
│   │   └── cart_repository.dart
│   └── usecases/                  # Business use cases
│       ├── add_to_cart_usecase.dart
│       ├── remove_from_cart_usecase.dart
│       ├── update_cart_item_usecase.dart
│       ├── clear_cart_usecase.dart
│       └── apply_discount_usecase.dart
├── presentation/                  # UI layer
│   ├── providers/                 # Riverpod providers
│   │   ├── cart_provider.dart     # Cart state management
│   │   ├── cart_config_provider.dart # Cart configuration
│   │   ├── category_provider.dart # Category state management
│   │   ├── checkout_provider.dart # Checkout flow management
│   │   ├── order_provider.dart    # Order management
│   │   ├── loyalty_provider.dart  # Loyalty/points management
│   │   ├── coupon_provider.dart   # Coupon validation and application
│   │   ├── wallet_provider.dart   # Wallet balance management
│   │   ├── review_provider.dart   # Reviews and ratings
│   │   ├── wishlist_provider.dart # Wishlist management
│   │   ├── search_provider.dart   # Search and filtering
│   │   └── analytics_provider.dart # Analytics events
│   ├── widgets/                   # Reusable widgets (60+)
│   │   ├── cart widgets           # Cart badge, item, summary, add-to-cart
│   │   ├── checkout_widgets.dart  # Order summary, payment selector, etc.
│   │   ├── loyalty_widgets.dart   # Points display, tier badges, etc.
│   │   ├── coupon_widgets.dart    # Coupon input, applied coupons, etc.
│   │   ├── wallet_widgets.dart    # Wallet balance, toggle, transactions
│   │   ├── review_widgets.dart    # Review cards, rating bars, forms
│   │   ├── wishlist_widgets.dart  # Wishlist button, items, grid
│   │   ├── search_widgets.dart    # Search bar, suggestions, filters
│   │   ├── order_widgets.dart     # Order cards, status, tracking
│   │   └── category_widgets.dart  # Category cards, grids, trees
│   └── mixins/                    # Widget mixins
│       └── cart_mixin.dart        # Cart functionality for widgets
├── example/                       # Example implementations
└── config/                        # Configuration
```

---

## Installation

1. Copy the `commerce_kit` folder to your project's `lib/packages/` directory.

2. Add required dependencies to `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  equatable: ^2.0.5
  shared_preferences: ^2.2.0
  uuid: ^4.2.1
```

3. Import the library:

```dart
import 'package:your_app/packages/commerce_kit/commerce_kit.dart';
```

---

## Quick Start

### 1. Initialize Configuration

```dart
void main() {
  // Configure the commerce module
  CommerceConfig.initialize(
    currency: 'USD',
    currencySymbol: '\$',
    locale: 'en_US',
    taxRate: 0.08,  // 8% tax
    cartConfig: const CartConfig(
      maxQuantityPerItem: 10,
      maxCartItems: 50,
      freeShippingThreshold: 100.0,
    ),
  );

  runApp(
    ProviderScope(child: MyApp()),
  );
}
```

### 2. Create Products

```dart
// Simple product
final burger = Product(
  id: 'burger-001',
  name: 'Classic Burger',
  description: 'Juicy beef patty with fresh vegetables',
  price: Money(12.99),
  type: ProductType.simple,
  stockStatus: StockStatus.inStock,
  images: [
    ProductImage(url: 'https://example.com/burger.jpg', isPrimary: true),
  ],
);

// Product with variants
final tshirt = Product(
  id: 'tshirt-001',
  name: 'Cotton T-Shirt',
  price: Money(24.99),
  type: ProductType.variable,
  variants: [
    ProductVariant(
      id: 'var-s-black',
      sku: 'TS-S-BLK',
      price: Money(24.99),
      selectedOptions: {'size': 'S', 'color': 'Black'},
      stockQuantity: 50,
    ),
    ProductVariant(
      id: 'var-m-black',
      sku: 'TS-M-BLK',
      price: Money(24.99),
      selectedOptions: {'size': 'M', 'color': 'Black'},
      stockQuantity: 30,
    ),
    ProductVariant(
      id: 'var-l-black',
      sku: 'TS-L-BLK',
      price: Money(26.99),  // Large costs more
      selectedOptions: {'size': 'L', 'color': 'Black'},
      stockQuantity: 20,
    ),
  ],
  options: [
    ProductOption(
      id: 'size',
      name: 'Size',
      type: VariantType.size,
      isRequired: true,
      values: [
        ProductOptionValue(id: 'S', label: 'Small'),
        ProductOptionValue(id: 'M', label: 'Medium'),
        ProductOptionValue(id: 'L', label: 'Large', priceModifier: Money(2.00)),
      ],
    ),
    ProductOption(
      id: 'color',
      name: 'Color',
      type: VariantType.color,
      isRequired: true,
      values: [
        ProductOptionValue(id: 'Black', label: 'Black', colorCode: '#000000'),
        ProductOptionValue(id: 'White', label: 'White', colorCode: '#FFFFFF'),
        ProductOptionValue(id: 'Navy', label: 'Navy', colorCode: '#000080'),
      ],
    ),
  ],
);

// Product with extras/add-ons
final pizza = Product(
  id: 'pizza-001',
  name: 'Margherita Pizza',
  price: Money(14.99),
  type: ProductType.configurable,
  options: [
    ProductOption(
      id: 'size',
      name: 'Size',
      type: VariantType.size,
      isRequired: true,
      values: [
        ProductOptionValue(id: 'small', label: 'Small (10")'),
        ProductOptionValue(id: 'medium', label: 'Medium (12")', priceModifier: Money(3.00)),
        ProductOptionValue(id: 'large', label: 'Large (14")', priceModifier: Money(6.00)),
      ],
    ),
    ProductOption(
      id: 'extras',
      name: 'Extra Toppings',
      type: VariantType.custom,
      isRequired: false,
      maxSelections: 5,
      values: [
        ProductOptionValue(id: 'cheese', label: 'Extra Cheese', priceModifier: Money(1.50)),
        ProductOptionValue(id: 'pepperoni', label: 'Pepperoni', priceModifier: Money(2.00)),
        ProductOptionValue(id: 'mushrooms', label: 'Mushrooms', priceModifier: Money(1.00)),
        ProductOptionValue(id: 'olives', label: 'Olives', priceModifier: Money(1.00)),
      ],
    ),
  ],
);
```

### 3. Add to Cart

```dart
class ProductPage extends ConsumerWidget {
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Product info...

        AddToCartButton(
          product: product,
          selectedOptions: {
            'size': SelectedOption(
              optionId: 'size',
              optionName: 'Size',
              valueId: 'M',
              valueLabel: 'Medium',
            ),
          },
          onAddToCart: (product, quantity, options) {
            ref.read(commerceCartProvider.notifier).addProduct(
              product,
              quantity: quantity,
              selectedOptions: options,
            );
          },
        ),
      ],
    );
  }
}
```

### 4. Display Cart

```dart
class CartPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartItemsProvider);
    final cartTotal = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        actions: [
          CartIconButton(
            itemCount: ref.watch(cartItemCountProvider),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return CartItemWidget(
            item: item,
            onQuantityChanged: (quantity) {
              ref.read(commerceCartProvider.notifier)
                  .updateQuantity(item.id, quantity);
            },
            onRemove: () {
              ref.read(commerceCartProvider.notifier)
                  .removeItem(item.id);
            },
          );
        },
      ),
      bottomNavigationBar: CartSummaryWidget(
        subtotal: cartTotal,
        shipping: Money(5.99),
        onCheckout: () => Navigator.pushNamed(context, '/checkout'),
      ),
    );
  }
}
```

---

## Core Concepts

### Money

The `Money` class provides type-safe currency operations:

```dart
final price = Money(29.99);
final discount = Money(5.00);

// Arithmetic operations
final salePrice = price - discount;  // Money(24.99)
final doubled = price * 2;           // Money(59.98)
final split = price / 3;             // Money(10.00)

// Comparison
if (price > discount) { /* ... */ }
if (price >= Money(25)) { /* ... */ }

// Formatting
print(price.formatted);        // "$29.99"
print(price.formattedCompact); // "$30"

// Currency configuration
final euros = Money(29.99, currency: 'EUR', symbol: '€');
print(euros.formatted);  // "€29.99"

// Zero and checks
final zero = Money.zero;
print(price.isZero);     // false
print(zero.isZero);      // true
```

### Products

Products support multiple types for different use cases:

```dart
// ProductType.simple - No variants or options
final simpleProduct = Product(
  id: 'prod-1',
  name: 'Coffee Mug',
  price: Money(15.99),
  type: ProductType.simple,
);

// ProductType.variable - Has variants (size/color combinations)
final variableProduct = Product(
  id: 'prod-2',
  name: 'Running Shoes',
  price: Money(89.99),
  type: ProductType.variable,
  variants: [/* ... */],
  options: [/* ... */],
);

// ProductType.configurable - Has configurable options
final configurableProduct = Product(
  id: 'prod-3',
  name: 'Custom Laptop',
  price: Money(999.99),
  type: ProductType.configurable,
  options: [/* RAM, Storage, etc. */],
);

// ProductType.bundle - Collection of products
final bundleProduct = Product(
  id: 'prod-4',
  name: 'Gaming Bundle',
  price: Money(199.99),
  type: ProductType.bundle,
  bundleItems: [/* List of product IDs */],
);
```

**Product Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier |
| `name` | `String` | Display name |
| `description` | `String?` | Product description |
| `price` | `Money` | Base price |
| `compareAtPrice` | `Money?` | Original price (for sales) |
| `type` | `ProductType` | Product type |
| `stockStatus` | `StockStatus` | Availability status |
| `stockQuantity` | `int?` | Available quantity |
| `sku` | `String?` | Stock keeping unit |
| `variants` | `List<ProductVariant>` | Product variants |
| `options` | `List<ProductOption>` | Configurable options |
| `images` | `List<ProductImage>` | Product images |
| `attributes` | `List<ProductAttribute>` | Additional attributes |
| `categories` | `List<String>` | Category IDs |
| `tags` | `List<String>` | Product tags |
| `metadata` | `Map<String, dynamic>` | Custom metadata |

### Product Variants

Variants represent specific combinations of options:

```dart
final variant = ProductVariant(
  id: 'var-001',
  sku: 'SHOE-42-BLK',
  price: Money(89.99),
  compareAtPrice: Money(109.99),  // Was on sale
  selectedOptions: {
    'size': '42',
    'color': 'Black',
  },
  stockQuantity: 25,
  stockStatus: StockStatus.inStock,
  images: [
    ProductImage(url: 'https://example.com/shoe-black.jpg'),
  ],
);

// Check variant properties
print(variant.isInStock);     // true
print(variant.isOnSale);      // true
print(variant.optionsSummary); // "42 / Black"
```

### Product Options

Options define customization choices:

```dart
// Single-select required option
final sizeOption = ProductOption(
  id: 'size',
  name: 'Size',
  type: VariantType.size,
  isRequired: true,
  values: [
    ProductOptionValue(id: 'S', label: 'Small'),
    ProductOptionValue(id: 'M', label: 'Medium'),
    ProductOptionValue(id: 'L', label: 'Large', priceModifier: Money(2.00)),
  ],
);

// Multi-select optional option with limit
final toppingsOption = ProductOption(
  id: 'toppings',
  name: 'Extra Toppings',
  type: VariantType.custom,
  isRequired: false,
  maxSelections: 3,  // Limit selections
  values: [
    ProductOptionValue(id: 'cheese', label: 'Extra Cheese', priceModifier: Money(1.50)),
    ProductOptionValue(id: 'bacon', label: 'Bacon', priceModifier: Money(2.00)),
    ProductOptionValue(id: 'onions', label: 'Grilled Onions', priceModifier: Money(0.75)),
  ],
);

// Color option with color codes
final colorOption = ProductOption(
  id: 'color',
  name: 'Color',
  type: VariantType.color,
  isRequired: true,
  values: [
    ProductOptionValue(id: 'red', label: 'Red', colorCode: '#FF0000'),
    ProductOptionValue(id: 'blue', label: 'Blue', colorCode: '#0000FF'),
    ProductOptionValue(
      id: 'gold',
      label: 'Gold',
      colorCode: '#FFD700',
      priceModifier: Money(10.00),  // Premium color
    ),
  ],
);

// Accessing option properties
print(sizeOption.availableValues);  // Only values with isAvailable: true
print(sizeOption.hasExtraCosts);    // true (Large has price modifier)
print(colorOption.getValue('red')); // ProductOptionValue for red
```

### Categories

Categories organize products into a hierarchical structure with support for multiple types, images, scheduling, and SEO.

#### Category Types

```dart
// CategoryType enum values:
// - standard: Regular product category
// - featured: Prominently displayed category
// - sale: Promotional/discount category
// - newArrivals: Recently added products
// - bestSellers: Top-selling products
// - seasonal: Season-specific category
// - collection: Curated collection
// - brand: Brand/manufacturer category
// - virtual: Filter-based (not real category)
// - menu: Navigation-only (no products)
// - hidden: Internal use only
// - archive: Discontinued products
```

#### Creating Categories

```dart
// Simple category
final burgers = Category(
  id: 'cat-1',
  name: 'Burgers',
  slug: 'burgers',
  description: 'Delicious handcrafted burgers',
  productCount: 15,
);

// Category with image
final pizzas = Category(
  id: 'cat-2',
  name: 'Pizzas',
  slug: 'pizzas',
  image: CategoryImage.network(url: 'https://example.com/pizza.jpg'),
  thumbnail: CategoryImage.thumbnail(url: 'https://example.com/pizza-thumb.jpg'),
  banner: CategoryImage.banner(url: 'https://example.com/pizza-banner.jpg'),
  productCount: 20,
);

// Featured category with badge
final featured = Category.featured(
  id: 'cat-featured',
  name: 'Featured Items',
  slug: 'featured',
  description: 'Our most popular items',
  badge: 'Hot',
);

// Sale category with expiration
final sale = Category.sale(
  id: 'cat-sale',
  name: 'Summer Sale',
  slug: 'summer-sale',
  activeUntil: DateTime(2024, 8, 31),
);

// Brand category
final brand = Category.brand(
  id: 'brand-nike',
  name: 'Nike',
  slug: 'nike',
  logo: CategoryImage.network(url: 'https://example.com/nike-logo.png'),
);
```

#### Hierarchical Categories

```dart
// Create nested categories
final food = Category(
  id: 'cat-food',
  name: 'Food',
  slug: 'food',
  level: 0,
  children: [
    Category(
      id: 'cat-burgers',
      name: 'Burgers',
      slug: 'burgers',
      parentId: 'cat-food',
      level: 1,
      path: ['cat-food'],
      children: [
        Category(
          id: 'cat-beef',
          name: 'Beef Burgers',
          slug: 'beef-burgers',
          parentId: 'cat-burgers',
          level: 2,
          path: ['cat-food', 'cat-burgers'],
        ),
        Category(
          id: 'cat-chicken',
          name: 'Chicken Burgers',
          slug: 'chicken-burgers',
          parentId: 'cat-burgers',
          level: 2,
          path: ['cat-food', 'cat-burgers'],
        ),
      ],
    ),
    Category(
      id: 'cat-pizza',
      name: 'Pizza',
      slug: 'pizza',
      parentId: 'cat-food',
      level: 1,
      path: ['cat-food'],
    ),
  ],
);

// Navigate hierarchy
print(food.hasChildren);           // true
print(food.childCount);            // 2
print(food.findChild('cat-beef')); // Category for Beef Burgers
print(food.allDescendants.length); // 4 (all nested categories)
print(food.maxDepth);              // 2
```

#### Category Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier |
| `name` | `String` | Display name |
| `slug` | `String?` | URL-friendly slug |
| `type` | `CategoryType` | Category type |
| `description` | `String?` | Full description |
| `parentId` | `String?` | Parent category ID |
| `children` | `List<Category>` | Subcategories |
| `level` | `int` | Depth in hierarchy (0 = root) |
| `path` | `List<String>` | Ancestor IDs |
| `image` | `CategoryImage?` | Primary image |
| `thumbnail` | `CategoryImage?` | Thumbnail image |
| `icon` | `CategoryImage?` | Icon |
| `banner` | `CategoryImage?` | Banner/hero image |
| `productCount` | `int` | Products in category |
| `sortOrder` | `int` | Display order |
| `isActive` | `bool` | Active status |
| `isVisible` | `bool` | Visibility status |
| `isFeatured` | `bool` | Featured flag |
| `includeInMenu` | `bool` | Show in navigation |
| `activeFrom` | `DateTime?` | Start date |
| `activeUntil` | `DateTime?` | End date |
| `badge` | `String?` | Badge text |
| `metadata` | `Map?` | Custom data |

#### Category Images

```dart
// Network image
final image = CategoryImage.network(
  url: 'https://example.com/category.jpg',
  alt: 'Category image',
);

// Asset image
final asset = CategoryImage.asset(
  path: 'assets/images/category.png',
);

// Icon
final icon = CategoryImage.icon(
  name: 'restaurant',
  color: '#FF5722',
);

// Banner with dimensions
final banner = CategoryImage.banner(
  url: 'https://example.com/banner.jpg',
  width: 1200,
  height: 400,
);

// Placeholder
final placeholder = CategoryImage.placeholder(
  backgroundColor: '#E0E0E0',
  iconName: 'category',
);
```

#### Category Extensions

```dart
// List extensions
final categories = [/* list of categories */];

// Filter categories
final roots = categories.roots;           // Root categories only
final visible = categories.visible;       // Visible categories
final featured = categories.featured;     // Featured categories
final forMenu = categories.forMenu;       // Menu categories

// Sort categories
final sorted = categories.sorted;         // By sort order
final byName = categories.sortedByName;   // Alphabetically

// Search
final results = categories.search('pizza');

// Build tree from flat list
final tree = categories.buildTree();

// Find by ID or slug
final cat = categories.findById('cat-1');
final catBySlug = categories.findBySlug('burgers');

// Build navigation
final menuItems = categories.buildMenu(maxDepth: 3);
final breadcrumbs = categories.buildBreadcrumb('cat-beef');
```

### Cart

The `Cart` model manages all cart operations:

```dart
// Create empty cart
var cart = Cart.empty();

// Add item
cart = cart.addItem(CartItem(
  id: 'item-1',
  productId: 'prod-1',
  name: 'Classic Burger',
  price: Money(12.99),
  quantity: 2,
));

// Update quantity
cart = cart.updateQuantity('item-1', 3);

// Remove item
cart = cart.removeItem('item-1');

// Apply discount
cart = cart.applyDiscount(Discount(
  id: 'SAVE10',
  code: 'SAVE10',
  type: DiscountType.percentage,
  value: 10.0,  // 10% off
));

// Cart calculations
print(cart.subtotal);      // Sum of item prices
print(cart.itemCount);     // Total items
print(cart.uniqueItemCount); // Unique products
print(cart.isEmpty);       // Check if empty

// Find items
final item = cart.getItem('item-1');
final productItem = cart.getItemByProductId('prod-1');
final quantity = cart.getProductQuantity('prod-1');
```

### Discounts

Multiple discount types are supported:

```dart
// Percentage discount
final percentOff = Discount(
  id: 'percent-10',
  code: 'SAVE10',
  type: DiscountType.percentage,
  value: 10.0,  // 10% off
  minimumOrderAmount: Money(50.00),  // Minimum order required
);

// Fixed amount discount
final fixedOff = Discount(
  id: 'fixed-5',
  code: 'FIVE_OFF',
  type: DiscountType.fixedAmount,
  value: 5.0,  // $5 off
);

// Free shipping
final freeShip = Discount(
  id: 'free-ship',
  code: 'FREESHIP',
  type: DiscountType.freeShipping,
  value: 0,
);

// Buy one get one
final bogo = Discount(
  id: 'bogo',
  code: 'BOGO',
  type: DiscountType.buyOneGetOne,
  value: 0,
  applicableProductIds: ['prod-1', 'prod-2'],  // Only for specific products
);

// Discount with expiration
final limitedOffer = Discount(
  id: 'limited',
  code: 'FLASH50',
  type: DiscountType.percentage,
  value: 50.0,
  validFrom: DateTime(2024, 1, 1),
  validUntil: DateTime(2024, 1, 7),
  maxUsageCount: 100,
);

// Check validity
print(limitedOffer.isValid);           // Based on dates and usage
print(limitedOffer.isExpired);         // Past validUntil
print(limitedOffer.hasReachedUsageLimit); // Usage count exceeded
```

---

## Checkout System

The checkout system provides a complete multi-step checkout flow with order management.

### Checkout Flow

```dart
// CheckoutStatus enum values:
// - pending: Initial state, cart ready
// - shippingInfo: Collecting shipping address
// - paymentMethod: Selecting payment method
// - review: Reviewing order before placement
// - processing: Order being processed
// - completed: Order placed successfully
// - cancelled: Order cancelled
// - failed: Order failed
// - expired: Checkout session expired
```

### Using the Checkout Provider

```dart
// Watch checkout state
final checkoutState = ref.watch(checkoutProvider);
final session = checkoutState.session;
final summary = ref.watch(orderSummaryProvider);

// Checkout operations
final notifier = ref.read(checkoutProvider.notifier);

// Start checkout
await notifier.startCheckout();

// Set shipping address
notifier.setShippingAddress(ShippingAddress(
  id: 'addr-1',
  fullName: 'John Doe',
  phoneNumber: '+1234567890',
  addressLine1: '123 Main St',
  city: 'New York',
  state: 'NY',
  postalCode: '10001',
  country: 'US',
  type: AddressType.home,
  isDefault: true,
));

// Select shipping method
notifier.setShippingMethod(ShippingMethod(
  id: 'standard',
  name: 'Standard Delivery',
  description: '3-5 business days',
  price: Money(5.99),
  type: ShippingType.standard,
  estimatedMinDays: 3,
  estimatedMaxDays: 5,
));

// Select payment method
notifier.setPaymentMethod(PaymentMethod.card);

// Apply coupon
await notifier.applyCoupon('SAVE20');

// Use wallet balance
notifier.setWalletAmount(Money(10.00));

// Redeem points
notifier.setPointsToRedeem(500);

// Add tip
notifier.setTipAmount(Money(5.00));

// Place order
final order = await notifier.placeOrder();
```

### Order Summary

The `OrderSummary` model provides complete price breakdown:

```dart
final summary = OrderSummary(
  subtotal: Money(100.00),
  discount: Money(20.00),
  couponDiscount: Money(10.00),
  pointsDiscount: Money(5.00),
  walletDiscount: Money(15.00),
  shipping: Money(5.99),
  tax: Money(4.50),
  tip: Money(3.00),
  total: Money(63.49),
  itemCount: 5,
  savings: Money(50.00),
  earnedPoints: 63,
);

// Display summary lines
for (final line in summary.displayLines) {
  print('${line.label}: ${line.amount.formatted}');
  // Subtotal: $100.00
  // Discount: -$20.00
  // Coupon (SAVE20): -$10.00
  // Points Redeemed: -$5.00
  // Wallet: -$15.00
  // Shipping: $5.99
  // Tax: $4.50
  // Tip: $3.00
  // Total: $63.49
}
```

### Order Model

```dart
final order = Order(
  id: 'order-12345',
  orderNumber: 'ORD-2024-12345',
  status: OrderStatus.confirmed,
  paymentStatus: PaymentStatus.completed,
  items: orderItems,
  summary: orderSummary,
  shippingAddress: address,
  shippingMethod: shippingMethod,
  paymentMethod: PaymentMethod.card,
  createdAt: DateTime.now(),
  estimatedDelivery: DateTime.now().add(Duration(days: 3)),
);

// Order status tracking
print(order.status.label);           // "Confirmed"
print(order.status.isActive);        // true
print(order.status.canBeCancelled);  // true
print(order.canBeModified);          // true
```

### Payment Methods

```dart
// PaymentMethod enum values:
// - cashOnDelivery: Pay when delivered
// - card: Credit/debit card
// - applePay: Apple Pay
// - googlePay: Google Pay
// - paypal: PayPal
// - wallet: In-app wallet
// - bankTransfer: Bank transfer
// - crypto: Cryptocurrency

// Check payment method properties
print(PaymentMethod.card.label);        // "Card"
print(PaymentMethod.card.icon);         // Icons.credit_card
print(PaymentMethod.card.requiresOnlinePayment);  // true
print(PaymentMethod.wallet.isDigitalWallet);      // true
```

### Shipping

```dart
// Shipping types
// - standard: Regular delivery
// - express: Fast delivery
// - sameDay: Same day delivery
// - nextDay: Next day delivery
// - pickup: Store pickup
// - curbside: Curbside pickup
// - locker: Pickup locker
// - scheduled: Scheduled delivery

final shipping = ShippingMethod(
  id: 'express',
  name: 'Express Delivery',
  description: 'Get it tomorrow',
  price: Money(12.99),
  type: ShippingType.express,
  estimatedMinDays: 1,
  estimatedMaxDays: 2,
  availableTimeSlots: [
    DeliveryTimeSlot(
      id: 'morning',
      label: 'Morning (9AM - 12PM)',
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 12, minute: 0),
      extraCharge: Money.zero,
    ),
    DeliveryTimeSlot(
      id: 'evening',
      label: 'Evening (6PM - 9PM)',
      startTime: TimeOfDay(hour: 18, minute: 0),
      endTime: TimeOfDay(hour: 21, minute: 0),
      extraCharge: Money(2.00),
    ),
  ],
);

// Shipping address
final address = ShippingAddress(
  id: 'addr-1',
  fullName: 'John Doe',
  phoneNumber: '+1234567890',
  addressLine1: '123 Main Street',
  addressLine2: 'Apt 4B',
  city: 'New York',
  state: 'NY',
  postalCode: '10001',
  country: 'US',
  type: AddressType.home,
  isDefault: true,
  deliveryInstructions: 'Leave at door',
);

print(address.formattedAddress);
// John Doe
// 123 Main Street, Apt 4B
// New York, NY 10001
// US
```

---

## Loyalty & Points System

The loyalty system provides tier-based rewards with points earning and redemption.

### Loyalty Tiers

```dart
// LoyaltyTier enum values (with default thresholds):
// - none: No tier (0 points)
// - bronze: Entry level (100 points)
// - silver: 500 points
// - gold: 1,000 points
// - platinum: 5,000 points
// - diamond: 10,000 points
// - vip: 25,000+ points

// Tier properties
print(LoyaltyTier.gold.label);           // "Gold"
print(LoyaltyTier.gold.threshold);       // 1000
print(LoyaltyTier.gold.multiplier);      // 1.5 (50% bonus points)
print(LoyaltyTier.gold.discountPercent); // 10.0 (10% tier discount)
print(LoyaltyTier.gold.color);           // Colors.amber
print(LoyaltyTier.gold.icon);            // Icons.workspace_premium

// Get tier from points
final tier = LoyaltyTierExtension.fromPoints(1500); // LoyaltyTier.gold
```

### Loyalty Account

```dart
final account = LoyaltyAccount(
  id: 'loyalty-123',
  memberId: 'MEM-2024-001',
  currentPoints: 1250,
  lifetimePoints: 5000,
  tier: LoyaltyTier.gold,
  tierExpiresAt: DateTime(2025, 12, 31),
  pointsExpiringAt: DateTime(2024, 6, 30),
  expiringPoints: 200,
  memberSince: DateTime(2023, 1, 15),
  transactions: [...],
);

// Account properties
print(account.pointsValue);           // Money(12.50) at $0.01/point
print(account.pointsToNextTier);      // Points needed for platinum
print(account.nextTier);              // LoyaltyTier.platinum
print(account.hasExpiringPoints);     // true
print(account.daysUntilExpiration);   // Days until points expire
```

### Using the Loyalty Provider

```dart
// Watch loyalty state
final loyaltyState = ref.watch(loyaltyProvider);
final account = loyaltyState.account;
final points = ref.watch(pointsBalanceProvider);
final tier = ref.watch(currentTierProvider);

// Loyalty operations
final notifier = ref.read(loyaltyProvider.notifier);

// Load account
await notifier.loadAccount('user-123');

// Add earned points
notifier.addPoints(
  points: 150,
  type: PointsTransactionType.earned,
  description: 'Order #12345',
  orderId: 'order-12345',
);

// Redeem points
notifier.redeemPoints(
  points: 500,
  description: 'Checkout redemption',
);

// Add bonus points
notifier.addBonusPoints(
  points: 100,
  description: 'Birthday bonus',
);
```

### Points Transactions

```dart
// PointsTransactionType enum values:
// - earned: Points earned from purchase
// - redeemed: Points used for discount
// - expired: Points that expired
// - bonus: Promotional bonus points
// - adjustment: Manual adjustment
// - referral: Referral reward
// - signup: Sign-up bonus
// - review: Review reward
// - birthday: Birthday bonus
// - tier: Tier upgrade bonus
// - cancelled: Cancelled order reversal
// - refunded: Refund reversal

final transaction = PointsTransaction(
  id: 'txn-1',
  type: PointsTransactionType.earned,
  points: 150,
  balance: 1400,
  description: 'Order #12345',
  orderId: 'order-12345',
  createdAt: DateTime.now(),
);

print(transaction.type.isCredit);  // true (adds points)
print(transaction.type.label);     // "Earned"
print(transaction.formattedPoints); // "+150"
```

### Redeeming Points

```dart
// Calculate points value
final pointsValue = Money.fromPoints(500); // 500 points = $5.00

// Check if enough points
if (account.currentPoints >= 500) {
  // Redeem at checkout
  ref.read(checkoutProvider.notifier).setPointsToRedeem(500);
}

// Validate redemption
final canRedeem = account.currentPoints >= minRedemption;
final maxRedeem = min(account.currentPoints, orderTotal.toPoints());
```

---

## Coupon System

The coupon system supports multiple discount types with comprehensive validation.

### Coupon Types

```dart
// CouponType enum values:
// - percentage: Percentage off (e.g., 20% off)
// - fixedAmount: Fixed amount off (e.g., $10 off)
// - freeShipping: Free shipping
// - freeItem: Free item with purchase
// - buyXGetY: Buy X get Y free
// - firstOrder: First order discount
// - referral: Referral discount
// - loyalty: Loyalty member exclusive
// - seasonal: Seasonal promotion
// - flash: Limited time flash sale
```

### Creating Coupons

```dart
// Percentage coupon
final percentCoupon = Coupon(
  id: 'coupon-1',
  code: 'SAVE20',
  type: CouponType.percentage,
  discountValue: 20.0,
  description: '20% off your order',
  minimumOrderAmount: Money(50.00),
  maximumDiscount: Money(30.00),
  validFrom: DateTime(2024, 1, 1),
  validUntil: DateTime(2024, 12, 31),
  usageLimit: 1000,
  usageCount: 150,
  perUserLimit: 1,
);

// Fixed amount coupon
final fixedCoupon = Coupon(
  id: 'coupon-2',
  code: 'FLAT10',
  type: CouponType.fixedAmount,
  discountValue: 10.0,
  description: '\$10 off orders over \$30',
  minimumOrderAmount: Money(30.00),
);

// Free shipping coupon
final freeship = Coupon(
  id: 'coupon-3',
  code: 'FREESHIP',
  type: CouponType.freeShipping,
  discountValue: 0,
  description: 'Free shipping on all orders',
);

// Coupon properties
print(percentCoupon.formattedDiscount);  // "20% off"
print(fixedCoupon.formattedDiscount);    // "$10.00 off"
print(freeship.formattedDiscount);       // "Free Shipping"
print(percentCoupon.isValid);            // true
print(percentCoupon.isExpired);          // false
print(percentCoupon.usageRemaining);     // 850
```

### Coupon Validation

```dart
final validation = CouponValidation(
  isValid: true,
  coupon: coupon,
  discountAmount: Money(20.00),
  message: 'Coupon applied successfully',
);

// Invalid validation
final invalidValidation = CouponValidation(
  isValid: false,
  errorCode: CouponErrorCode.minimumNotMet,
  message: 'Minimum order amount is \$50.00',
);

// Error codes
// - CouponErrorCode.invalid: Invalid coupon code
// - CouponErrorCode.expired: Coupon has expired
// - CouponErrorCode.notYetValid: Coupon not yet active
// - CouponErrorCode.usageLimitReached: Global limit reached
// - CouponErrorCode.userLimitReached: Per-user limit reached
// - CouponErrorCode.minimumNotMet: Order below minimum
// - CouponErrorCode.productNotEligible: Products not eligible
// - CouponErrorCode.alreadyApplied: Coupon already applied
```

### Using the Coupon Provider

```dart
// Watch coupon state
final couponState = ref.watch(couponProvider);
final appliedCoupon = ref.watch(appliedCouponProvider);
final discount = ref.watch(couponDiscountAmountProvider);
final message = ref.watch(couponMessageProvider);

// Coupon operations
final notifier = ref.read(couponProvider.notifier);

// Validate and apply coupon
await notifier.validateAndApply(
  'SAVE20',
  orderAmount: Money(75.00),
);

// Remove coupon
notifier.removeCoupon();

// Load available coupons
await notifier.loadAvailableCoupons();

// Get valid coupons
final validCoupons = ref.watch(validCouponsProvider);
```

---

## Wallet System

The wallet system provides digital wallet functionality with balance management.

### Wallet Balance

```dart
final wallet = Wallet(
  id: 'wallet-123',
  balance: Money(150.00),
  currency: 'USD',
  isActive: true,
  breakdown: WalletBalanceBreakdown(
    mainBalance: Money(100.00),
    promotionalBalance: Money(30.00),
    cashbackBalance: Money(20.00),
    pendingBalance: Money(10.00),
  ),
  transactions: [...],
);

// Balance properties
print(wallet.availableBalance);        // Money(150.00)
print(wallet.hasBalance);              // true
print(wallet.breakdown.mainBalance);   // Money(100.00)
```

### Wallet Transactions

```dart
// WalletTransactionType enum values:
// - credit: Money added
// - debit: Money spent
// - refund: Refund received
// - cashback: Cashback reward
// - promotion: Promotional credit
// - adjustment: Manual adjustment
// - expired: Expired promotional balance
// - transfer: Transferred funds
// - bonus: Bonus credit
// - reward: Reward earned

final transaction = WalletTransaction(
  id: 'wtxn-1',
  type: WalletTransactionType.cashback,
  amount: Money(5.00),
  balance: Money(155.00),
  description: '5% cashback on order #12345',
  orderId: 'order-12345',
  createdAt: DateTime.now(),
  expiresAt: DateTime.now().add(Duration(days: 90)),
);

print(transaction.type.isCredit);      // true
print(transaction.type.label);         // "Cashback"
print(transaction.formattedAmount);    // "+$5.00"
print(transaction.hasExpiration);      // true
```

### Using the Wallet Provider

```dart
// Watch wallet state
final walletState = ref.watch(walletProvider);
final balance = ref.watch(walletTotalBalanceProvider);
final breakdown = ref.watch(walletBalanceBreakdownProvider);
final transactions = ref.watch(walletTransactionsProvider);

// Wallet operations
final notifier = ref.read(walletProvider.notifier);

// Load wallet
await notifier.loadWallet('user-123');

// Add funds
notifier.addFunds(
  amount: Money(50.00),
  description: 'Top up',
);

// Deduct for purchase
notifier.deductFunds(
  amount: Money(25.00),
  orderId: 'order-12345',
  description: 'Order payment',
);

// Add cashback
notifier.addCashback(
  amount: Money(5.00),
  orderId: 'order-12345',
  description: '5% cashback',
);

// Refund
notifier.refund(
  amount: Money(10.00),
  orderId: 'order-12345',
  description: 'Order refund',
);
```

### Using Wallet at Checkout

```dart
// In checkout, toggle wallet usage
ref.read(checkoutProvider.notifier).setUseWallet(true);

// Or set specific amount
ref.read(checkoutProvider.notifier).setWalletAmount(Money(25.00));

// The order summary will show wallet discount
final summary = ref.watch(orderSummaryProvider);
print(summary.walletDiscount);  // Money(25.00)
print(summary.total);           // Reduced by wallet amount
```

---

## Review System

The review system provides comprehensive product reviews with ratings, images, and statistics.

### Reviews & Ratings

```dart
// Create a review
final review = Review(
  id: 'review-1',
  productId: 'prod-123',
  userId: 'user-456',
  userName: 'John Doe',
  rating: 4.5,
  title: 'Great product!',
  content: 'Really enjoyed using this product. Highly recommend!',
  images: ['https://example.com/review-image.jpg'],
  isVerifiedPurchase: true,
  status: ReviewStatus.approved,
  createdAt: DateTime.now(),
  helpfulCount: 15,
);

// Review properties
print(review.hasImages);           // true
print(review.hasResponse);         // false
print(review.helpfulnessPercentage); // 100.0
```

### Rating Statistics

```dart
// Aggregated rating stats
final stats = RatingStats(
  productId: 'prod-123',
  averageRating: 4.3,
  totalReviews: 150,
  distribution: {1: 5, 2: 10, 3: 20, 4: 45, 5: 70},
  reviewsWithImages: 25,
  verifiedPurchaseReviews: 120,
);

// Calculate from reviews
final calculatedStats = RatingStats.fromReviews('prod-123', reviewsList);

// Stats properties
print(stats.hasReviews);                    // true
print(stats.percentageForRating(5));        // 46.67
print(stats.distributionPercentage);        // {1: 3.33, 2: 6.67, ...}
```

### Using the Review Provider

```dart
// Watch review state for a product
final reviewsState = ref.watch(reviewsProvider('prod-123'));
final stats = ref.watch(ratingStatsProvider('prod-123'));
final avgRating = ref.watch(averageRatingProvider('prod-123'));
final reviewCount = ref.watch(reviewCountProvider('prod-123'));

// Review operations
final notifier = ref.read(reviewsNotifierProvider.notifier);

// Configure callbacks
notifier.setLoadReviewsCallback((productId, {page, filter}) async {
  return await api.getReviews(productId, page: page);
});

// Load reviews
await notifier.loadReviews('prod-123');

// Filter and sort
notifier.setFilter('prod-123', ReviewFilter(
  rating: 5,              // Only 5-star reviews
  verifiedOnly: true,     // Only verified purchases
  withImagesOnly: true,   // Only with images
  sortBy: ReviewSortOption.mostHelpful,
));

// Submit a new review
await notifier.submitReview(newReview);

// Vote on a review
await notifier.vote('prod-123', 'review-1', true); // Helpful
```

### Review Widgets

```dart
// Rating summary widget
RatingSummaryWidget(
  stats: ratingStats,
  onRatingTap: (rating) => filterByRating(rating),
)

// Review card
ReviewCard(
  review: review,
  onHelpful: () => voteHelpful(review.id),
  onReport: () => reportReview(review.id),
)

// Review form
ReviewFormWidget(
  productId: 'prod-123',
  onSubmit: (review) => submitReview(review),
)
```

---

## Wishlist System

The wishlist system supports multiple wishlists with notifications for price drops and back-in-stock alerts.

### Wishlist Management

```dart
// Create a wishlist
final wishlist = Wishlist(
  id: 'wishlist-1',
  userId: 'user-123',
  name: 'My Favorites',
  items: [],
  isPublic: false,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Add product
final updated = wishlist.addProduct(product, note: 'Birthday gift idea');

// Check if contains product
print(wishlist.containsProduct('prod-123')); // true

// Wishlist item with notifications
final item = WishlistItem(
  id: 'item-1',
  productId: 'prod-123',
  product: product,
  note: 'Gift for mom',
  priority: 1,
  addedAt: DateTime.now(),
  notification: WishlistNotification(
    onPriceDrop: true,
    priceDropThreshold: 10, // 10% drop
    onBackInStock: true,
    onSale: true,
  ),
);
```

### Using the Wishlist Provider

```dart
// Watch wishlist state
final wishlistState = ref.watch(wishlistProvider);
final items = ref.watch(wishlistItemsProvider);
final count = ref.watch(wishlistItemCountProvider);
final isInWishlist = ref.watch(isInWishlistProvider('prod-123'));

// Wishlist operations
final notifier = ref.read(wishlistProvider.notifier);

// Add/remove/toggle product
await notifier.addProduct(product);
await notifier.removeProduct('prod-123');
await notifier.toggleProduct(product); // Adds if not exists, removes if exists

// Update item
await notifier.updateItemNote('prod-123', 'New note');
await notifier.updateItemPriority('prod-123', 1);
await notifier.markAsPurchased('prod-123');

// Notification settings
await notifier.setItemNotification('prod-123', WishlistNotification.all);
```

### Wishlist Widgets

```dart
// Wishlist toggle button
WishlistToggleButton(
  productId: product.id,
  product: product,
  size: 24,
  activeColor: Colors.red,
)

// Connected version (auto-watches provider)
ConnectedWishlistButton(
  product: product,
)

// Wishlist item card
WishlistItemCard(
  item: wishlistItem,
  onRemove: () => removeFromWishlist(item.productId),
  onAddToCart: () => addToCart(item.product),
)
```

---

## Search & Filtering

Comprehensive search functionality with filters, sorting, and suggestions.

### Product Search

```dart
// Using the search provider
final searchState = ref.watch(searchProvider);
final results = ref.watch(searchResultsProvider);
final isLoading = ref.watch(searchLoadingProvider);
final suggestions = ref.watch(searchSuggestionsProvider);

// Search operations
final notifier = ref.read(searchProvider.notifier);

// Configure search callback
notifier.setSearchCallback((query, filter, {page, pageSize}) async {
  return await api.searchProducts(query, filter, page: page);
});

// Set query and search
notifier.setQuery('burger');
await notifier.search();

// Load more results (pagination)
await notifier.loadMore();

// Get suggestions
await notifier.getSuggestions('burg');
```

### Product Filters

```dart
// Create a filter
final filter = ProductFilter(
  query: 'burger',
  categoryIds: ['cat-food', 'cat-burgers'],
  minPrice: Money(5.00),
  maxPrice: Money(20.00),
  stockStatuses: [StockStatus.inStock],
  onSaleOnly: true,
  inStockOnly: true,
  minRating: 4.0,
  brandIds: ['brand-1'],
  tags: ['popular', 'new'],
  sortBy: SortOption.priceLowToHigh,
);

// Factory constructors
final searchFilter = ProductFilter.search('query');
final categoryFilter = ProductFilter.byCategory('cat-id');
final saleFilter = ProductFilter.onSale();
final priceFilter = ProductFilter.priceRange(Money(10), Money(50));

// Filter modifications
final updated = filter
    .addCategory('new-cat')
    .addTag('featured')
    .copyWith(onSaleOnly: true);

// Convert to API params
final params = filter.toQueryParams();
// {'q': 'burger', 'category': 'cat-food,cat-burgers', 'min_price': 5.0, ...}

// Check filter state
print(filter.hasActiveFilters);  // true
print(filter.activeFilterCount); // 8
```

### Search Suggestions

```dart
// Suggestion types
final suggestion = SearchSuggestion(
  text: 'Cheese Burger',
  type: SuggestionType.product,
  imageUrl: 'https://...',
  count: 15, // 15 matching products
);

// Types: query, product, category, brand, recent, popular

// Provider operations
notifier.setSuggestionsCallback((query) async {
  return await api.getSuggestions(query);
});

// Filter operations
notifier.filterByCategory('cat-id');
notifier.setPriceRange(Money(10), Money(50));
notifier.toggleOnSale(true);
notifier.toggleInStock(true);
notifier.sortResultsLocally(SortOption.priceHighToLow);
```

### Search Result

```dart
// Paginated search result
final result = SearchResult<Product>(
  items: products,
  page: 1,
  pageSize: 20,
  totalItems: 150,
  totalPages: 8,
  hasNextPage: true,
  hasPreviousPage: false,
  filter: filter,
  availableFilters: availableFilters,
  suggestions: suggestions,
  searchTimeMs: 45,
);

// Result properties
print(result.rangeText);     // "1-20 of 150"
print(result.isFirstPage);   // true
print(result.isLastPage);    // false
```

### Search Widgets

```dart
// Search bar with suggestions
SearchBarWidget(
  onSearch: (query) => performSearch(query),
  onSuggestionTap: (suggestion) => handleSuggestion(suggestion),
  showSuggestions: true,
  recentSearches: recentSearches,
)

// Filter chips
FilterChipsWidget(
  filter: currentFilter,
  onFilterChanged: (filter) => updateFilter(filter),
  availableFilters: availableFilters,
)

// Sort dropdown
SortDropdownWidget(
  currentSort: SortOption.relevance,
  onSortChanged: (sort) => updateSort(sort),
)
```

---

## Analytics System

Track e-commerce events for analytics platforms.

### Event Tracking

```dart
// Analytics events
final viewEvent = AnalyticsEvent.viewProduct(product);
final addToCartEvent = AnalyticsEvent.addToCart(product, quantity: 2);
final removeFromCartEvent = AnalyticsEvent.removeFromCart(product);
final purchaseEvent = AnalyticsEvent.purchase(order);
final searchEvent = AnalyticsEvent.search('burger');
final viewCategoryEvent = AnalyticsEvent.viewCategory(category);
```

### Analytics Provider

```dart
// Configure analytics callback
final notifier = ref.read(analyticsProvider.notifier);
notifier.setTrackCallback((event) async {
  // Send to your analytics platform
  await firebase.logEvent(event.name, event.parameters);
  await mixpanel.track(event.name, event.parameters);
});

// Track events
notifier.trackProductView(product);
notifier.trackAddToCart(product, quantity: 2);
notifier.trackPurchase(order);
notifier.trackSearch('burger', resultsCount: 15);
```

---

## API Integration

The adapter pattern allows integration with any backend API.

### Using Built-in Adapters

```dart
// Map-based adapter for custom responses
final adapter = MapProductAdapter();

// Parse API response
final apiResponse = {
  'id': 'prod-123',
  'name': 'Widget',
  'price': 29.99,
  'stock_status': 'in_stock',
  // ...
};

final product = adapter.fromMap(apiResponse);
```

### Creating Custom Adapters

Implement the `ProductAdapter` interface:

```dart
class MyApiProductAdapter implements ProductAdapter<MyApiProduct> {
  @override
  Product fromExternal(MyApiProduct external) {
    return Product(
      id: external.productId,
      name: external.title,
      description: external.details,
      price: Money(external.priceInCents / 100),
      compareAtPrice: external.originalPrice != null
          ? Money(external.originalPrice! / 100)
          : null,
      type: _mapProductType(external.type),
      stockStatus: _mapStockStatus(external.availability),
      stockQuantity: external.inventory,
      variants: external.variations.map(_mapVariant).toList(),
      options: external.options.map(_mapOption).toList(),
      images: external.media.map(_mapImage).toList(),
    );
  }

  @override
  MyApiProduct toExternal(Product product) {
    // Convert back to API format if needed
    return MyApiProduct(
      productId: product.id,
      title: product.name,
      // ...
    );
  }

  ProductType _mapProductType(String type) {
    switch (type) {
      case 'SIMPLE': return ProductType.simple;
      case 'VARIABLE': return ProductType.variable;
      case 'CONFIGURABLE': return ProductType.configurable;
      case 'BUNDLE': return ProductType.bundle;
      default: return ProductType.simple;
    }
  }

  // ... other mapping methods
}
```

### Pre-built Platform Adapters

#### WooCommerce

```dart
final adapter = JsonProductAdapter.wooCommerce();

// Parse WooCommerce product response
final wooProduct = await api.get('/wp-json/wc/v3/products/123');
final product = adapter.fromJson(wooProduct);
```

#### Shopify

```dart
final adapter = JsonProductAdapter.shopify();

// Parse Shopify product response
final shopifyProduct = await api.get('/admin/api/2024-01/products/123.json');
final product = adapter.fromJson(shopifyProduct['product']);
```

#### Custom JSON Mapping

```dart
final adapter = JsonProductAdapter(
  idField: 'product_id',
  nameField: 'title',
  descriptionField: 'body_html',
  priceField: 'base_price',
  compareAtPriceField: 'original_price',
  typeField: 'product_type',
  skuField: 'sku_code',
  stockStatusField: 'availability',
  stockQuantityField: 'inventory_count',
  imagesField: 'media',
  variantsField: 'variations',
  optionsField: 'customization_options',

  // Custom type mapping
  typeMapping: {
    'standard': ProductType.simple,
    'with_variants': ProductType.variable,
    'customizable': ProductType.configurable,
    'package': ProductType.bundle,
  },

  // Custom stock status mapping
  stockStatusMapping: {
    'available': StockStatus.inStock,
    'limited': StockStatus.lowStock,
    'unavailable': StockStatus.outOfStock,
    'coming_soon': StockStatus.onBackorder,
  },

  // Custom price parser (e.g., for cents)
  priceParser: (value) => (value as int) / 100,
);
```

---

## State Management

### Providers

The module provides Riverpod providers for reactive state:

```dart
// Main cart provider
final cartState = ref.watch(commerceCartProvider);
print(cartState.cart);        // Current cart
print(cartState.isLoading);   // Loading state
print(cartState.error);       // Error message

// Selector providers (optimized rebuilds)
final items = ref.watch(cartItemsProvider);       // List<CartItem>
final total = ref.watch(cartTotalProvider);       // Money
final count = ref.watch(cartItemCountProvider);   // int
final isEmpty = ref.watch(cartIsEmptyProvider);   // bool

// Cart operations
final notifier = ref.read(commerceCartProvider.notifier);

// Add product
notifier.addProduct(
  product,
  quantity: 2,
  selectedOptions: {
    'size': SelectedOption(
      optionId: 'size',
      optionName: 'Size',
      valueId: 'M',
      valueLabel: 'Medium',
      priceModifier: Money.zero,
    ),
  },
  note: 'No onions please',
);

// Quick add (without full product)
notifier.quickAddItem(
  name: 'Custom Item',
  price: 9.99,
  quantity: 1,
);

// Update quantity
notifier.updateQuantity(itemId, 3);
notifier.incrementQuantity(itemId);
notifier.decrementQuantity(itemId);

// Remove
notifier.removeItem(itemId);

// Clear
notifier.clearCart();

// Discounts
notifier.applyDiscount(discount);
notifier.removeDiscount();

// Persistence
await notifier.loadCart();  // Load from storage
await notifier.saveCart();  // Save to storage
```

### Using CartMixin

Add cart functionality to any widget:

```dart
class ProductCard extends ConsumerWidget with CartMixin {
  final Product product;

  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantityInCart = getProductQuantityInCart(ref, product.id);

    return Card(
      child: Column(
        children: [
          Text(product.name),
          Text(product.price.formatted),

          if (quantityInCart > 0)
            Text('In cart: $quantityInCart'),

          ElevatedButton(
            onPressed: () => addProductToCart(
              ref,
              context,
              product,
              quantity: 1,
              showSnackbar: true,
            ),
            child: Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}
```

**CartMixin Methods:**

| Method | Description |
|--------|-------------|
| `getCartItemCount(ref)` | Total items in cart |
| `getCartTotal(ref)` | Cart total as Money |
| `getCartItems(ref)` | List of cart items |
| `isCartEmpty(ref)` | Check if cart is empty |
| `getCartItemByProductId(ref, id)` | Find item by product ID |
| `getProductQuantityInCart(ref, id)` | Product quantity in cart |
| `addProductToCart(ref, context, product, ...)` | Add product with snackbar |
| `quickAddToCart(ref, context, ...)` | Quick add by name/price |
| `removeFromCart(ref, id, ...)` | Remove item |
| `updateCartQuantity(ref, id, qty)` | Update quantity |
| `incrementCartItem(ref, id)` | Increment by 1 |
| `decrementCartItem(ref, id)` | Decrement by 1 |
| `clearCart(ref, ...)` | Clear with confirmation |

---

## Category Management

### Category Providers

The module provides Riverpod providers for category state management:

```dart
// Main categories provider
final state = ref.watch(categoriesProvider);
print(state.categories);      // All categories (flat)
print(state.categoryTree);    // Categories as tree
print(state.selectedCategory); // Currently selected
print(state.isLoading);       // Loading state
print(state.error);           // Error message

// Selector providers
final all = ref.watch(allCategoriesProvider);           // All categories
final tree = ref.watch(categoryTreeProvider);           // Tree structure
final roots = ref.watch(rootCategoriesProvider);        // Root categories
final visible = ref.watch(visibleCategoriesProvider);   // Visible only
final featured = ref.watch(featuredCategoriesProvider); // Featured only
final menu = ref.watch(menuCategoriesProvider);         // For navigation
final selected = ref.watch(selectedCategoryProvider);   // Selected category
final count = ref.watch(categoriesCountProvider);       // Total count

// Family providers
final cat = ref.watch(categoryByIdProvider('cat-1'));
final catBySlug = ref.watch(categoryBySlugProvider('burgers'));
final children = ref.watch(categoryChildrenProvider('cat-food'));
final ofType = ref.watch(categoriesByTypeProvider(CategoryType.featured));
final atLevel = ref.watch(categoriesAtLevelProvider(1));
final breadcrumb = ref.watch(categoryBreadcrumbProvider('cat-beef'));
final searchResults = ref.watch(categorySearchProvider('pizza'));

// Category operations
final notifier = ref.read(categoriesProvider.notifier);

// Set categories from API
notifier.setCategories(categoriesFromApi);

// Set tree directly
notifier.setCategoryTree(treeFromApi);

// CRUD operations
notifier.addCategory(newCategory);
notifier.updateCategory(updatedCategory);
notifier.removeCategory('cat-1');

// Selection
notifier.selectCategory('cat-1');
notifier.selectCategoryBySlug('burgers');
notifier.clearSelection();

// State management
notifier.setLoading(true);
notifier.setError('Failed to load');
notifier.clearError();
notifier.clear();
```

### Category Adapters

```dart
// Default adapter
final adapter = MapCategoryAdapter();
final category = adapter.fromExternal(jsonData);

// Configurable JSON adapter
final customAdapter = JsonCategoryAdapter(
  idField: 'category_id',
  nameField: 'title',
  slugField: 'url_key',
  descriptionField: 'content',
  parentIdField: 'parent',
  childrenField: 'subcategories',
  imageField: 'cover_image',
  productCountField: 'items_count',
);

// Platform-specific adapters
final wooAdapter = JsonCategoryAdapter.wooCommerce();
final shopifyAdapter = JsonCategoryAdapter.shopify();
final magentoAdapter = JsonCategoryAdapter.magento();
final prestaAdapter = JsonCategoryAdapter.prestaShop();
final openCartAdapter = JsonCategoryAdapter.openCart();

// Nested category adapter (for APIs with nested children)
final nestedAdapter = NestedCategoryAdapter(
  childrenField: 'subcategories',
  maxDepth: 5,
);

// Flat category adapter (builds tree from flat list)
final flatAdapter = FlatCategoryAdapter(
  parentIdField: 'parent_id',
);
final tree = flatAdapter.fromFlatList(flatCategoriesFromApi);
```

---

## Widgets

### Cart Widgets

### CartBadgeWidget

Displays item count on any widget:

```dart
CartBadgeWidget(
  count: 5,
  badgeColor: Colors.red,
  textColor: Colors.white,
  maxCount: 99,  // Shows "99+" if exceeded
  showZero: false,
  child: Icon(Icons.shopping_cart),
)
```

### CartIconButton

Pre-built cart icon with badge:

```dart
CartIconButton(
  itemCount: ref.watch(cartItemCountProvider),
  onPressed: () => Navigator.pushNamed(context, '/cart'),
  iconColor: Colors.black,
  badgeColor: Colors.red,
  iconSize: 24,
)
```

### QuantitySelectorWidget

Quantity input with increment/decrement:

```dart
QuantitySelectorWidget(
  quantity: 2,
  minQuantity: 1,
  maxQuantity: 10,
  onChanged: (qty) => updateQuantity(qty),
  size: QuantitySelectorSize.medium,
  showBorder: true,
)
```

### CartItemWidget

Display a cart item with actions:

```dart
CartItemWidget(
  item: cartItem,
  onQuantityChanged: (qty) => updateQuantity(item.id, qty),
  onRemove: () => removeItem(item.id),
  showImage: true,
  showOptions: true,
  showNote: true,
)
```

### CartSummaryWidget

Order summary with totals:

```dart
CartSummaryWidget(
  subtotal: Money(99.99),
  discount: Money(10.00),
  shipping: Money(5.99),
  tax: Money(7.60),
  onCheckout: () => processCheckout(),
  checkoutLabel: 'Proceed to Checkout',
)
```

### AddToCartButton

Configurable add-to-cart button:

```dart
AddToCartButton(
  product: product,
  selectedVariant: selectedVariant,
  selectedOptions: selectedOptions,
  quantity: 1,
  onAddToCart: (product, qty, options) {
    // Handle add to cart
  },
  showPrice: true,
  showQuantity: true,
)
```

### PriceDisplayWidget

Price with optional sale price:

```dart
PriceDisplayWidget(
  price: Money(79.99),
  compareAtPrice: Money(99.99),  // Shows strikethrough
  showDiscountBadge: true,       // Shows "-20%"
  axis: Axis.horizontal,
)
```

### VariantSelectorWidget

Button-style variant selection:

```dart
VariantSelectorWidget(
  option: sizeOption,
  selectedValueId: 'M',
  onSelected: (value) => selectSize(value),
  showPrices: true,
  wrap: true,
)
```

### RadioOptionSelector

Radio-button style selection:

```dart
RadioOptionSelector(
  option: deliveryOption,
  selectedValueId: 'standard',
  onSelected: (value) => selectDelivery(value),
  showPrices: true,
)
```

### OptionSelectorWidget

Checkbox-style multi-selection:

```dart
OptionSelectorWidget(
  option: toppingsOption,
  selectedValueIds: {'cheese', 'bacon'},
  onSelectionChanged: (ids) => updateToppings(ids),
  showPrices: true,
)
```

### ColorSwatchSelector

Color swatch selection:

```dart
ColorSwatchSelector(
  option: colorOption,
  selectedValueId: 'red',
  onSelected: (value) => selectColor(value),
  swatchSize: 40,
)
```

### Checkout Widgets

#### OrderSummaryWidget

Displays complete order summary with all line items:

```dart
OrderSummaryWidget(
  summary: orderSummary,
  showSavings: true,
  showEarnedPoints: true,
  compactMode: false,
  onCouponTap: () => _showCouponSheet(),
  onWalletTap: () => _toggleWallet(),
)

// Connected version (auto-watches provider)
ConnectedOrderSummaryWidget(
  showSavings: true,
  showEarnedPoints: true,
)
```

#### PaymentMethodSelector

Select payment method:

```dart
PaymentMethodSelector(
  methods: [
    PaymentMethod.card,
    PaymentMethod.applePay,
    PaymentMethod.cashOnDelivery,
    PaymentMethod.wallet,
  ],
  selectedMethod: PaymentMethod.card,
  onMethodSelected: (method) => selectPayment(method),
  walletBalance: Money(50.00),
  showIcons: true,
)

// Connected version
ConnectedPaymentMethodSelector(
  methods: availableMethods,
)
```

#### ShippingMethodSelector

Select shipping method:

```dart
ShippingMethodSelector(
  methods: shippingMethods,
  selectedMethod: selectedShipping,
  onMethodSelected: (method) => selectShipping(method),
  showEstimates: true,
  showPrices: true,
)
```

#### PlaceOrderButton

Checkout action button:

```dart
PlaceOrderButton(
  total: Money(63.49),
  onPressed: () => placeOrder(),
  isLoading: isProcessing,
  enabled: canPlaceOrder,
  label: 'Place Order',
)

// Connected version
ConnectedPlaceOrderButton(
  onOrderPlaced: (order) => navigateToConfirmation(order),
)
```

#### TipSelector

Add tip to order:

```dart
TipSelector(
  orderTotal: Money(50.00),
  selectedTip: Money(5.00),
  onTipSelected: (tip) => setTip(tip),
  presetPercentages: [10, 15, 20, 25],
  allowCustom: true,
)
```

#### EarnedRewardsWidget

Show points to be earned:

```dart
EarnedRewardsWidget(
  earnedPoints: 63,
  pointsValue: Money(0.63),
  tier: LoyaltyTier.gold,
  multiplier: 1.5,
)
```

### Loyalty Widgets

#### PointsBalanceWidget

Display points balance:

```dart
PointsBalanceWidget(
  points: 1250,
  tier: LoyaltyTier.gold,
  showValue: true,
  pointValue: 0.01,
)

// Connected version
ConnectedPointsBalanceWidget(
  showValue: true,
)
```

#### LoyaltyTierWidget

Display tier badge:

```dart
LoyaltyTierWidget(
  tier: LoyaltyTier.gold,
  showProgress: true,
  pointsToNextTier: 3750,
  totalForNextTier: 5000,
)
```

#### PointsRedeemWidget

Points redemption slider:

```dart
PointsRedeemWidget(
  availablePoints: 1250,
  maxRedeemable: 1000,
  pointsToRedeem: 500,
  pointValue: 0.01,
  onPointsChanged: (points) => setRedemption(points),
)

// Connected version
ConnectedPointsRedeemWidget(
  maxRedeemable: orderTotal.toPoints(),
)
```

#### ExpiringPointsWidget

Warning for expiring points:

```dart
ExpiringPointsWidget(
  expiringPoints: 200,
  expiresAt: DateTime(2024, 6, 30),
  onUsePoints: () => redeemPoints(),
)
```

#### LoyaltyBannerWidget

Promotional loyalty banner:

```dart
LoyaltyBannerWidget(
  tier: LoyaltyTier.gold,
  earnedPoints: 63,
  multiplier: 1.5,
  message: 'Earn 1.5x points as Gold member!',
  onTap: () => showLoyaltyDetails(),
)
```

#### PointsTransactionList

Transaction history:

```dart
PointsTransactionList(
  transactions: transactions,
  maxItems: 10,
  onShowAll: () => navigateToHistory(),
  emptyWidget: Text('No transactions yet'),
)

// Connected version
ConnectedPointsTransactionList(
  maxItems: 10,
  onShowAll: () => navigateToHistory(),
)
```

### Coupon Widgets

#### CouponInputWidget

Enter and apply coupons:

```dart
CouponInputWidget(
  currentCode: 'SAVE20',
  isApplied: true,
  isValidating: false,
  message: 'Coupon applied! You save \$20',
  isValid: true,
  onApply: (code) => applyCoupon(code),
  onRemove: () => removeCoupon(),
  hintText: 'Enter coupon code',
)

// Connected version
ConnectedCouponInputWidget(
  orderAmount: Money(100.00),
)
```

#### AppliedCouponWidget

Display applied coupon:

```dart
AppliedCouponWidget(
  coupon: appliedCoupon,
  discountAmount: Money(20.00),
  onRemove: () => removeCoupon(),
)

// Connected version
ConnectedAppliedCouponWidget()
```

#### AvailableCouponsWidget

Show available coupons:

```dart
AvailableCouponsWidget(
  coupons: availableCoupons,
  appliedCoupon: currentCoupon,
  onSelect: (coupon) => applyCoupon(coupon.code),
  title: 'Available Coupons',
)

// Connected version
ConnectedAvailableCouponsWidget(
  orderAmount: Money(100.00),
  title: 'Your Coupons',
)
```

### Wallet Widgets

#### WalletBalanceWidget

Display wallet balance:

```dart
WalletBalanceWidget(
  balance: Money(150.00),
  breakdown: walletBreakdown,
  showBreakdown: true,
  icon: Icon(Icons.account_balance_wallet),
)

// Connected version
ConnectedWalletBalanceWidget(
  showBreakdown: true,
)
```

#### WalletToggleWidget

Toggle wallet usage at checkout:

```dart
WalletToggleWidget(
  availableBalance: Money(150.00),
  isEnabled: true,
  amountUsed: Money(50.00),
  onToggle: (enabled) => toggleWallet(enabled),
)

// Connected version
ConnectedWalletToggleWidget(
  onToggle: (enabled) => toggleWallet(enabled),
)
```

#### WalletCheckoutWidget

Compact wallet display for checkout:

```dart
WalletCheckoutWidget(
  availableBalance: Money(150.00),
  isUsing: true,
  amountUsed: Money(50.00),
  expiringBalance: Money(30.00),
  expiresAt: DateTime(2024, 6, 30),
  onToggle: (enabled) => toggleWallet(enabled),
)
```

#### WalletTransactionList

Transaction history:

```dart
WalletTransactionList(
  transactions: transactions,
  maxItems: 10,
  onShowAll: () => navigateToHistory(),
)

// Connected version
ConnectedWalletTransactionList(
  maxItems: 10,
  onShowAll: () => navigateToHistory(),
)
```

### Category Widgets

#### CategoryCard

Displays a category with image and info:

```dart
CategoryCard(
  category: category,
  onTap: () => navigateToCategory(category),
  showProductCount: true,
  showDescription: false,
  showBadge: true,
  elevation: 2,
  borderRadius: 12,
  imageHeight: 120,
)
```

#### CategoryChip

Compact category chip:

```dart
CategoryChip(
  category: category,
  onTap: () => selectCategory(category),
  isSelected: selectedId == category.id,
  showIcon: true,
  showCount: true,
)
```

#### CategoryList

Horizontal scrollable category list:

```dart
CategoryList(
  categories: categories,
  onCategoryTap: (cat) => navigateTo(cat),
  selectedId: selectedCategoryId,
  height: 120,
  padding: EdgeInsets.symmetric(horizontal: 16),
  spacing: 12,
)
```

#### CategoryGrid

Grid layout for categories:

```dart
CategoryGrid(
  categories: categories,
  onCategoryTap: (cat) => navigateTo(cat),
  crossAxisCount: 2,
  childAspectRatio: 1.0,
  spacing: 16,
  padding: EdgeInsets.all(16),
)
```

#### CategoryTreeView

Expandable tree view:

```dart
CategoryTreeView(
  categories: rootCategories,
  onCategoryTap: (cat) => selectCategory(cat),
  selectedId: selectedCategoryId,
  initiallyExpanded: {'cat-food', 'cat-burgers'},
)
```

#### CategoryBreadcrumbWidget

Breadcrumb navigation:

```dart
CategoryBreadcrumbWidget(
  items: [
    CategoryBreadcrumbItem(id: 'food', name: 'Food'),
    CategoryBreadcrumbItem(id: 'burgers', name: 'Burgers'),
    CategoryBreadcrumbItem(id: 'beef', name: 'Beef', isActive: true),
  ],
  onItemTap: (id) => navigateToCategory(id),
  separator: Icon(Icons.chevron_right, size: 16),
)

// Or from category extensions
CategoryBreadcrumbWidget.fromCategory(
  allCategories: allCategories,
  categoryId: 'cat-beef',
  onItemTap: (id) => navigateToCategory(id),
)
```

#### CategoryDropdown

Dropdown selector:

```dart
CategoryDropdown(
  categories: categories,
  selectedId: selectedCategoryId,
  onChanged: (id) => selectCategory(id),
  hint: 'Select category',
  showProductCount: true,
  includeAll: true,
  allLabel: 'All Categories',
)
```

#### CategoryListView (with Riverpod)

Auto-connected to providers:

```dart
CategoryListView(
  onCategoryTap: (cat) => navigateTo(cat),
  menuOnly: false,    // Show only menu categories
  featuredOnly: true, // Show only featured categories
)
```

---

## Configuration

### CartConfig

```dart
const config = CartConfig(
  maxQuantityPerItem: 10,        // Max qty per line item
  maxCartItems: 50,              // Max unique items
  allowNegativeStock: false,     // Prevent overselling
  persistCart: true,             // Enable local storage
  storageKey: 'commerce_cart',   // Storage key name
  freeShippingThreshold: 100.0,  // Free shipping minimum
);
```

### CommerceConfig

```dart
CommerceConfig.initialize(
  currency: 'USD',
  currencySymbol: '\$',
  currencyPosition: CurrencyPosition.before,
  locale: 'en_US',
  decimalSeparator: '.',
  thousandsSeparator: ',',
  decimalPlaces: 2,
  taxRate: 0.08,           // 8% tax
  taxInclusive: false,      // Tax added at checkout
  defaultShippingCost: 5.99,
  cartConfig: const CartConfig(),
);

// Access config anywhere
final config = CommerceConfig.instance;
print(config.formatPrice(29.99));  // "$29.99"
print(config.calculateTax(Money(100)));  // Money(8.00)
```

---

## Examples

### Complete Product Detail Page

```dart
class ProductDetailPage extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailPage({required this.product});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> with CartMixin {
  int quantity = 1;
  ProductVariant? selectedVariant;
  Map<String, SelectedOption> selectedOptions = {};

  @override
  void initState() {
    super.initState();
    // Auto-select first variant if available
    if (widget.product.variants.isNotEmpty) {
      selectedVariant = widget.product.variants.first;
    }
  }

  Money get currentPrice {
    // Base price
    var price = selectedVariant?.price ?? widget.product.price;

    // Add option modifiers
    for (final option in selectedOptions.values) {
      price = price + option.priceModifier;
    }

    return price;
  }

  bool get canAddToCart {
    // Check required options
    for (final option in widget.product.options) {
      if (option.isRequired && !selectedOptions.containsKey(option.id)) {
        return false;
      }
    }

    // Check stock
    if (selectedVariant != null) {
      return selectedVariant!.isInStock;
    }

    return widget.product.isInStock;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Product images
          SliverAppBar(
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and price
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  PriceDisplayWidget(
                    price: currentPrice,
                    compareAtPrice: widget.product.compareAtPrice,
                  ),

                  const SizedBox(height: 24),

                  // Options
                  ...widget.product.options.map((option) {
                    if (option.type == VariantType.color) {
                      return ColorSwatchSelector(
                        option: option,
                        selectedValueId: selectedOptions[option.id]?.valueId,
                        onSelected: (value) => _selectOption(option, value),
                      );
                    }

                    if (option.maxSelections != null && option.maxSelections! > 1) {
                      return OptionSelectorWidget(
                        option: option,
                        selectedValueIds: _getSelectedValueIds(option.id),
                        onSelectionChanged: (ids) => _selectMultiple(option, ids),
                      );
                    }

                    return VariantSelectorWidget(
                      option: option,
                      selectedValueId: selectedOptions[option.id]?.valueId,
                      onSelected: (value) => _selectOption(option, value),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Quantity
                  Row(
                    children: [
                      Text('Quantity:', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(width: 16),
                      QuantitySelectorWidget(
                        quantity: quantity,
                        minQuantity: 1,
                        maxQuantity: selectedVariant?.stockQuantity ?? 99,
                        onChanged: (qty) => setState(() => quantity = qty),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  if (widget.product.description != null) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(widget.product.description!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AddToCartButton(
            product: widget.product,
            selectedVariant: selectedVariant,
            selectedOptions: selectedOptions,
            quantity: quantity,
            enabled: canAddToCart,
            onAddToCart: (product, qty, options) {
              addProductToCart(
                ref,
                context,
                product,
                quantity: qty,
                selectedOptions: options,
              );
            },
          ),
        ),
      ),
    );
  }

  void _selectOption(ProductOption option, ProductOptionValue value) {
    setState(() {
      selectedOptions[option.id] = SelectedOption(
        optionId: option.id,
        optionName: option.name,
        valueId: value.id,
        valueLabel: value.label,
        priceModifier: value.priceModifier,
      );

      // Update variant if applicable
      _updateSelectedVariant();
    });
  }

  Set<String> _getSelectedValueIds(String optionId) {
    final option = selectedOptions[optionId];
    if (option == null) return {};
    return {option.valueId};
  }

  void _selectMultiple(ProductOption option, Set<String> valueIds) {
    // For multi-select, we'd need a different approach
    // This is simplified for single selections stored in map
  }

  void _updateSelectedVariant() {
    // Find variant matching selected options
    for (final variant in widget.product.variants) {
      bool matches = true;
      for (final entry in selectedOptions.entries) {
        if (variant.selectedOptions[entry.key] != entry.value.valueId) {
          matches = false;
          break;
        }
      }
      if (matches) {
        selectedVariant = variant;
        return;
      }
    }
  }

  Widget _buildImageGallery() {
    final images = selectedVariant?.images.isNotEmpty == true
        ? selectedVariant!.images
        : widget.product.images;

    if (images.isEmpty) {
      return Container(color: Colors.grey[200]);
    }

    return PageView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Image.network(
          images[index].url,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
```

### Cart Page with Full Features

```dart
class CartPage extends ConsumerWidget with CartMixin {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(commerceCartProvider);
    final items = ref.watch(cartItemsProvider);
    final isEmpty = ref.watch(cartIsEmptyProvider);

    if (cartState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Your cart is empty'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (${getCartItemCount(ref)} items)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => clearCart(ref, context: context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Error message
          if (cartState.error != null)
            MaterialBanner(
              content: Text(cartState.error!),
              backgroundColor: Colors.red[100],
              actions: [
                TextButton(
                  onPressed: () => ref.read(commerceCartProvider.notifier).clearError(),
                  child: const Text('Dismiss'),
                ),
              ],
            ),

          // Cart items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = items[index];
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => removeFromCart(ref, item.id),
                  child: CartItemWidget(
                    item: item,
                    onQuantityChanged: (qty) {
                      updateCartQuantity(ref, item.id, qty);
                    },
                    onRemove: () => removeFromCart(ref, item.id),
                  ),
                );
              },
            ),
          ),

          // Summary
          CartSummaryWidget(
            subtotal: getCartTotal(ref),
            discount: cartState.cart.appliedDiscount != null
                ? _calculateDiscount(cartState.cart)
                : null,
            shipping: Money(5.99),
            onCheckout: () => _proceedToCheckout(context),
          ),
        ],
      ),
    );
  }

  Money _calculateDiscount(Cart cart) {
    final discount = cart.appliedDiscount!;
    switch (discount.type) {
      case DiscountType.percentage:
        return cart.subtotal * (discount.value / 100);
      case DiscountType.fixedAmount:
        return Money(discount.value);
      default:
        return Money.zero;
    }
  }

  void _proceedToCheckout(BuildContext context) {
    Navigator.pushNamed(context, '/checkout');
  }
}
```

### Integrating with Custom API

```dart
// 1. Create your API service
class ProductApiService {
  final Dio _dio;
  final ProductAdapter<Map<String, dynamic>> _adapter;

  ProductApiService(this._dio)
      : _adapter = JsonProductAdapter(
          idField: 'product_id',
          nameField: 'title',
          priceField: 'price_cents',
          priceParser: (value) => (value as int) / 100,
        );

  Future<List<Product>> getProducts() async {
    final response = await _dio.get('/api/products');
    final List<dynamic> data = response.data['products'];

    return data.map((json) => _adapter.fromMap(json)).toList();
  }

  Future<Product> getProduct(String id) async {
    final response = await _dio.get('/api/products/$id');
    return _adapter.fromMap(response.data['product']);
  }
}

// 2. Create provider
final productApiProvider = Provider<ProductApiService>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  return ProductApiService(dio);
});

final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productApiProvider).getProducts();
});

// 3. Use in UI
class ProductListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
      data: (products) => ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text(product.price.formatted),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(product: product),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

## API Reference

### Models

| Class | Description |
|-------|-------------|
| `Money` | Currency-safe value object |
| `Product` | Complete product representation |
| `ProductVariant` | Product variant with options |
| `ProductOption` | Option group (size, color) |
| `ProductOptionValue` | Individual option value |
| `ProductImage` | Product image |
| `ProductAttribute` | Product attribute |
| `Category` | Category with hierarchy support |
| `CategoryImage` | Category image (icon, banner, etc.) |
| `CartItem` | Item in cart |
| `Cart` | Shopping cart |
| `Discount` | Discount definition |
| `PriceBreakdown` | Price calculation breakdown |
| `SelectedOption` | Selected option in cart item |
| `CheckoutSession` | Checkout flow state |
| `Order` | Complete order |
| `OrderItem` | Order line item |
| `OrderSummary` | Order totals breakdown |
| `ShippingAddress` | Shipping/billing address |
| `ShippingMethod` | Shipping option with time slots |
| `DeliveryTimeSlot` | Delivery time window |
| `LoyaltyAccount` | Loyalty program account |
| `PointsTransaction` | Points transaction history |
| `TierBenefits` | Loyalty tier benefits |
| `Coupon` | Coupon definition |
| `CouponValidation` | Coupon validation result |
| `Wallet` | Digital wallet |
| `WalletTransaction` | Wallet transaction |
| `WalletBalanceBreakdown` | Balance breakdown |
| `Review` | Product review with rating and content |
| `ReviewResponse` | Merchant response to review |
| `RatingStats` | Aggregated rating statistics |
| `ReviewFilter` | Review filtering options |
| `Wishlist` | Wishlist container |
| `WishlistItem` | Item in wishlist with metadata |
| `WishlistNotification` | Notification preferences for wishlist items |
| `SearchResult<T>` | Paginated search results |
| `SearchSuggestion` | Search autocomplete suggestion |
| `ProductFilter` | Product filtering criteria |
| `AvailableFilters` | Available filter options from API |
| `FilterOption` | Individual filter option |
| `FilterPriceRange` | Price range filter bounds |
| `AnalyticsEvent` | Analytics event for tracking |

### Enums

| Enum | Values |
|------|--------|
| `ProductType` | simple, variable, configurable, bundle, grouped, digital, subscription, service |
| `VariantType` | size, color, material, style, custom |
| `DiscountType` | percentage, fixedAmount, freeShipping, buyOneGetOne, bulkDiscount, tieredDiscount |
| `CartOperation` | add, remove, update, clear |
| `StockStatus` | inStock, outOfStock, lowStock, onBackorder, preOrder, discontinued |
| `CategoryType` | standard, featured, sale, newArrivals, bestSellers, seasonal, collection, brand, virtual, menu, hidden, archive |
| `CategoryImageType` | image, thumbnail, icon, banner, background, asset, placeholder |
| `CategoryDisplayMode` | grid, list, carousel, masonry, compact, featured |
| `ProductSortOption` | nameAsc, nameDesc, priceAsc, priceDesc, newest, oldest, popularity, rating, featured, random |
| `CheckoutStatus` | pending, shippingInfo, paymentMethod, review, processing, completed, cancelled, failed, expired |
| `PaymentMethod` | cashOnDelivery, card, applePay, googlePay, paypal, wallet, bankTransfer, crypto |
| `PaymentStatus` | pending, authorized, processing, completed, failed, cancelled, refunded, partiallyRefunded |
| `OrderStatus` | pending, confirmed, preparing, ready, dispatched, outForDelivery, delivered, cancelled, refunded, failed |
| `ShippingType` | standard, express, sameDay, nextDay, pickup, curbside, locker, scheduled |
| `LoyaltyTier` | none, bronze, silver, gold, platinum, diamond, vip |
| `CouponType` | percentage, fixedAmount, freeShipping, freeItem, buyXGetY, firstOrder, referral, loyalty, seasonal, flash |
| `WalletTransactionType` | credit, debit, refund, cashback, promotion, adjustment, expired, transfer, bonus, reward |
| `PointsTransactionType` | earned, redeemed, expired, bonus, adjustment, referral, signup, review, birthday, tier, cancelled, refunded |
| `ReviewStatus` | pending, approved, rejected, flagged |
| `ReviewSortOption` | newest, oldest, highestRating, lowestRating, mostHelpful, verified |
| `SuggestionType` | query, product, category, brand, recent, trending, correction |
| `SortOption` | relevance, newest, priceAsc, priceDesc, nameAsc, nameDesc, rating, popularity, bestSelling |

### Cart Providers

| Provider | Type | Description |
|----------|------|-------------|
| `commerceCartProvider` | `NotifierProvider<CartNotifier, CartState>` | Main cart state |
| `cartItemsProvider` | `Provider<List<CartItem>>` | Cart items list |
| `cartTotalProvider` | `Provider<Money>` | Cart total |
| `cartItemCountProvider` | `Provider<int>` | Total item count |
| `cartIsEmptyProvider` | `Provider<bool>` | Empty check |
| `cartConfigProvider` | `Provider<CartConfig>` | Cart configuration |

### Category Providers

| Provider | Type | Description |
|----------|------|-------------|
| `categoriesProvider` | `NotifierProvider<CategoriesNotifier, CategoriesState>` | Main categories state |
| `allCategoriesProvider` | `Provider<List<Category>>` | All categories flat |
| `categoryTreeProvider` | `Provider<List<Category>>` | Category tree |
| `rootCategoriesProvider` | `Provider<List<Category>>` | Root categories only |
| `visibleCategoriesProvider` | `Provider<List<Category>>` | Visible categories |
| `featuredCategoriesProvider` | `Provider<List<Category>>` | Featured categories |
| `menuCategoriesProvider` | `Provider<List<Category>>` | Menu categories |
| `selectedCategoryProvider` | `Provider<Category?>` | Selected category |
| `categoriesCountProvider` | `Provider<int>` | Categories count |
| `categoryByIdProvider` | `Provider.family<Category?, String>` | Find by ID |
| `categoryBySlugProvider` | `Provider.family<Category?, String>` | Find by slug |
| `categoryChildrenProvider` | `Provider.family<List<Category>, String>` | Children of category |
| `categoriesByTypeProvider` | `Provider.family<List<Category>, CategoryType>` | By type |
| `categoriesAtLevelProvider` | `Provider.family<List<Category>, int>` | At level |
| `categoryBreadcrumbProvider` | `Provider.family<List<CategoryBreadcrumb>, String>` | Breadcrumb |
| `categorySearchProvider` | `Provider.family<List<Category>, String>` | Search |

### Checkout Providers

| Provider | Type | Description |
|----------|------|-------------|
| `checkoutProvider` | `NotifierProvider<CheckoutNotifier, CheckoutState>` | Main checkout state |
| `checkoutSessionProvider` | `Provider<CheckoutSession?>` | Current session |
| `checkoutStatusProvider` | `Provider<CheckoutStatus>` | Current status |
| `orderSummaryProvider` | `Provider<OrderSummary?>` | Order summary |
| `selectedPaymentMethodProvider` | `Provider<PaymentMethod?>` | Selected payment |
| `selectedShippingMethodProvider` | `Provider<ShippingMethod?>` | Selected shipping |
| `shippingAddressProvider` | `Provider<ShippingAddress?>` | Shipping address |
| `canProceedToPaymentProvider` | `Provider<bool>` | Can proceed check |
| `canPlaceOrderProvider` | `Provider<bool>` | Can place order check |
| `checkoutTotalProvider` | `Provider<Money>` | Total amount |
| `checkoutSavingsProvider` | `Provider<Money>` | Total savings |
| `earnedPointsProvider` | `Provider<int>` | Points to earn |

### Loyalty Providers

| Provider | Type | Description |
|----------|------|-------------|
| `loyaltyProvider` | `NotifierProvider<LoyaltyNotifier, LoyaltyState>` | Main loyalty state |
| `loyaltyAccountProvider` | `Provider<LoyaltyAccount?>` | Loyalty account |
| `pointsBalanceProvider` | `Provider<int>` | Current points |
| `currentTierProvider` | `Provider<LoyaltyTier>` | Current tier |
| `pointsValueProvider` | `Provider<Money>` | Points monetary value |
| `pointsToNextTierProvider` | `Provider<int>` | Points to next tier |
| `tierProgressProvider` | `Provider<double>` | Tier progress (0-1) |
| `expiringPointsProvider` | `Provider<int>` | Expiring points |
| `pointsTransactionsProvider` | `Provider<List<PointsTransaction>>` | Transaction history |

### Coupon Providers

| Provider | Type | Description |
|----------|------|-------------|
| `couponProvider` | `NotifierProvider<CouponNotifier, CouponState>` | Main coupon state |
| `appliedCouponProvider` | `Provider<Coupon?>` | Applied coupon |
| `couponDiscountAmountProvider` | `Provider<Money>` | Discount amount |
| `couponMessageProvider` | `Provider<String?>` | Validation message |
| `couponValidationProvider` | `Provider<CouponValidation?>` | Validation result |
| `availableCouponsProvider` | `Provider<List<Coupon>>` | Available coupons |
| `validCouponsProvider` | `Provider<List<Coupon>>` | Valid coupons only |
| `hasCouponAppliedProvider` | `Provider<bool>` | Has coupon applied |

### Wallet Providers

| Provider | Type | Description |
|----------|------|-------------|
| `walletProvider` | `NotifierProvider<WalletNotifier, WalletState>` | Main wallet state |
| `walletBalanceProvider` | `Provider<Wallet?>` | Wallet data |
| `walletTotalBalanceProvider` | `Provider<Money>` | Total balance |
| `walletBalanceBreakdownProvider` | `Provider<WalletBalanceBreakdown?>` | Balance breakdown |
| `walletTransactionsProvider` | `Provider<List<WalletTransaction>>` | Transaction history |
| `hasWalletBalanceProvider` | `Provider<bool>` | Has balance check |
| `walletAvailableForCheckoutProvider` | `Provider<Money>` | Available for checkout |

### Review Providers

| Provider | Type | Description |
|----------|------|-------------|
| `reviewsNotifierProvider` | `NotifierProvider.family<ReviewsNotifier, ReviewsState, String>` | Reviews state per product |
| `productReviewsProvider` | `Provider.family<List<Review>, String>` | Reviews list for product |
| `productRatingStatsProvider` | `Provider.family<RatingStats?, String>` | Rating statistics |
| `reviewsLoadingProvider` | `Provider.family<bool, String>` | Loading state |
| `reviewsErrorProvider` | `Provider.family<String?, String>` | Error message |
| `hasMoreReviewsProvider` | `Provider.family<bool, String>` | Has more pages |
| `userReviewProvider` | `Provider.family<Review?, String>` | Current user's review |
| `verifiedReviewsProvider` | `Provider.family<List<Review>, String>` | Verified purchases only |
| `reviewsWithImagesProvider` | `Provider.family<List<Review>, String>` | Reviews with images |

### Wishlist Providers

| Provider | Type | Description |
|----------|------|-------------|
| `wishlistProvider` | `NotifierProvider<WishlistNotifier, WishlistState>` | Main wishlist state |
| `wishlistItemsProvider` | `Provider<List<WishlistItem>>` | Wishlist items |
| `wishlistCountProvider` | `Provider<int>` | Items count |
| `isInWishlistProvider` | `Provider.family<bool, String>` | Check if product in wishlist |
| `wishlistTotalValueProvider` | `Provider<Money>` | Total value of items |
| `wishlistOnSaleItemsProvider` | `Provider<List<WishlistItem>>` | Items currently on sale |
| `wishlistLowStockItemsProvider` | `Provider<List<WishlistItem>>` | Items with low stock |

### Search Providers

| Provider | Type | Description |
|----------|------|-------------|
| `searchProvider` | `NotifierProvider<SearchNotifier, SearchState>` | Main search state |
| `searchResultsProvider` | `Provider<List<Product>>` | Search results |
| `searchQueryProvider` | `Provider<String>` | Current query |
| `searchSuggestionsProvider` | `Provider<List<SearchSuggestion>>` | Autocomplete suggestions |
| `searchFiltersProvider` | `Provider<ProductFilter>` | Active filters |
| `availableFiltersProvider` | `Provider<AvailableFilters?>` | Available filter options |
| `searchTotalResultsProvider` | `Provider<int>` | Total results count |
| `searchHasMoreProvider` | `Provider<bool>` | Has more pages |
| `recentSearchesProvider` | `Provider<List<String>>` | Recent search queries |

### Analytics Provider

| Provider | Type | Description |
|----------|------|-------------|
| `analyticsProvider` | `Provider<AnalyticsProvider>` | Analytics tracking provider |

### Order Providers

| Provider | Type | Description |
|----------|------|-------------|
| `orderProvider` | `NotifierProvider<OrderProvider, OrderState>` | Main order state |
| `currentOrderProvider` | `Provider<Order?>` | Current/active order |
| `orderHistoryProvider` | `Provider<List<Order>>` | Order history |
| `orderByIdProvider` | `Provider.family<Order?, String>` | Find order by ID |

### Exceptions

| Exception | Description |
|-----------|-------------|
| `CommerceException` | Base exception |
| `CartException` | Cart operation errors |
| `ProductException` | Product-related errors |
| `ValidationException` | Validation failures |
| `AdapterException` | API mapping errors |

---

## License

MIT License - Feel free to use in any project.

---

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.
