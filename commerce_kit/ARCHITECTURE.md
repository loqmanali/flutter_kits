# Commerce Kit Architecture

A comprehensive guide to the architecture, data flow, and structure of the Commerce Kit module.

## Table of Contents

- [Overview](#overview)
- [Architecture Diagram](#architecture-diagram)
- [Layer Structure](#layer-structure)
- [Data Flow](#data-flow)
- [Module Dependencies](#module-dependencies)
- [State Management Flow](#state-management-flow)
- [Feature Modules](#feature-modules)
  - [Cart Module](#cart-module)
  - [Checkout Module](#checkout-module)
  - [Loyalty Module](#loyalty-module)
  - [Coupon Module](#coupon-module)
  - [Wallet Module](#wallet-module)
  - [Review Module](#review-module)
  - [Wishlist Module](#wishlist-module)
  - [Search Module](#search-module)
  - [Analytics Module](#analytics-module)
  - [Order Module](#order-module)
- [File Structure](#file-structure)
- [Design Patterns](#design-patterns)
- [Sequence Diagrams](#sequence-diagrams)

---

## Overview

Commerce Kit follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Widgets   │  │  Providers  │  │   Mixins    │  │   Screens   │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────────────────────┤
│                           DOMAIN LAYER                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                      │
│  │  Use Cases  │  │ Repositories│  │  Entities   │                      │
│  │  (abstract) │  │ (interface) │  │  (models)   │                      │
│  └─────────────┘  └─────────────┘  └─────────────┘                      │
├─────────────────────────────────────────────────────────────────────────┤
│                            DATA LAYER                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │  Adapters   │  │   Mappers   │  │Repositories │  │ Datasources │    │
│  │ (API→Model) │  │ (transform) │  │   (impl)    │  │(local/remote)│    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────────────────────┤
│                            CORE LAYER                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Models    │  │    Enums    │  │ Extensions  │  │   Utils     │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────────────────────┤
│                           CONFIG LAYER                                   │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    CommerceConfig / CartConfig                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Architecture Diagram

### High-Level Architecture

```
                                    ┌──────────────────┐
                                    │     Flutter      │
                                    │       App        │
                                    └────────┬─────────┘
                                             │
                                             ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                              COMMERCE KIT                                   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         PRESENTATION                                 │   │
│  │                                                                      │   │
│  │   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐     │   │
│  │   │  Cart    │    │ Checkout │    │ Loyalty  │    │  Wallet  │     │   │
│  │   │ Provider │    │ Provider │    │ Provider │    │ Provider │     │   │
│  │   └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘     │   │
│  │        │               │               │               │            │   │
│  │   ┌────▼─────┐    ┌────▼─────┐    ┌────▼─────┐    ┌────▼─────┐     │   │
│  │   │  Cart    │    │ Checkout │    │ Loyalty  │    │  Wallet  │     │   │
│  │   │ Widgets  │    │ Widgets  │    │ Widgets  │    │ Widgets  │     │   │
│  │   └──────────┘    └──────────┘    └──────────┘    └──────────┘     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                     │                                       │
│                                     ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                            DOMAIN                                    │   │
│  │                                                                      │   │
│  │   ┌─────────────────┐         ┌─────────────────────────────────┐   │   │
│  │   │    Use Cases    │         │      Repository Interfaces      │   │   │
│  │   │                 │         │                                  │   │   │
│  │   │ • AddToCart     │         │  • CartRepository               │   │   │
│  │   │ • RemoveFromCart│   ───►  │  • OrderRepository              │   │   │
│  │   │ • UpdateItem    │         │  • PaymentRepository            │   │   │
│  │   │ • ApplyDiscount │         │                                  │   │   │
│  │   │ • ClearCart     │         │                                  │   │   │
│  │   └─────────────────┘         └─────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                     │                                       │
│                                     ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                             DATA                                     │   │
│  │                                                                      │   │
│  │   ┌─────────────┐    ┌─────────────┐    ┌─────────────────────┐     │   │
│  │   │  Adapters   │    │   Mappers   │    │  Repository Impl    │     │   │
│  │   │             │    │             │    │                     │     │   │
│  │   │ • Product   │    │ • Product   │    │  • CartRepoImpl     │     │   │
│  │   │ • Category  │    │ • Cart      │    │                     │     │   │
│  │   │ • Cart      │    │             │    │                     │     │   │
│  │   └──────┬──────┘    └──────┬──────┘    └──────────┬──────────┘     │   │
│  │          │                  │                      │                 │   │
│  │          └────────────┬─────┴──────────────────────┘                 │   │
│  │                       ▼                                              │   │
│  │              ┌─────────────────┐                                     │   │
│  │              │   Datasources   │                                     │   │
│  │              │                 │                                     │   │
│  │              │  • Local (SP)   │                                     │   │
│  │              │  • Remote (API) │                                     │   │
│  │              └─────────────────┘                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                     │                                       │
│                                     ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                             CORE                                     │   │
│  │                                                                      │   │
│  │   ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐       │   │
│  │   │  Models   │  │   Enums   │  │Extensions │  │   Utils   │       │   │
│  │   │           │  │           │  │           │  │           │       │   │
│  │   │ • Money   │  │ • Product │  │ • Product │  │ • Price   │       │   │
│  │   │ • Product │  │   Type    │  │   Ext     │  │Calculator │       │   │
│  │   │ • Cart    │  │ • Stock   │  │ • Cart    │  │ • Cart    │       │   │
│  │   │ • Order   │  │   Status  │  │   Ext     │  │ Validator │       │   │
│  │   │ • Coupon  │  │ • Payment │  │ • Category│  │           │       │   │
│  │   │ • Wallet  │  │   Method  │  │   Ext     │  │           │       │   │
│  │   │ • Loyalty │  │ • Order   │  │           │  │           │       │   │
│  │   │   Account │  │   Status  │  │           │  │           │       │   │
│  │   └───────────┘  └───────────┘  └───────────┘  └───────────┘       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
                         ┌──────────────────────┐
                         │    External APIs     │
                         │  (REST/GraphQL/etc)  │
                         └──────────────────────┘
```

---

## Layer Structure

### 1. Config Layer

Centralized configuration for the entire module.

```
config/
├── commerce_config.dart      # Global settings (currency, tax, locale)
└── cart_config.dart          # Cart-specific settings (limits, persistence)
```

**CommerceConfig** (Singleton):
```
┌─────────────────────────────────────────────────────────┐
│                    CommerceConfig                        │
├─────────────────────────────────────────────────────────┤
│  • currency: String         (USD, EUR, SAR, etc.)       │
│  • currencySymbol: String   ($, €, ر.س, etc.)           │
│  • locale: String           (en_US, ar_SA, etc.)        │
│  • taxRate: double          (0.0 - 1.0)                 │
│  • taxInclusive: bool       (prices include tax?)       │
│  • decimalPlaces: int       (2 for most currencies)     │
│  • cartConfig: CartConfig   (nested cart settings)      │
├─────────────────────────────────────────────────────────┤
│  Methods:                                                │
│  • initialize()             (setup once at app start)   │
│  • formatPrice(amount)      (format with currency)      │
│  • calculateTax(amount)     (apply tax rate)            │
└─────────────────────────────────────────────────────────┘
```

### 2. Core Layer

The foundation - models, enums, extensions, utilities.

```
core/
├── enums/                    # Type definitions
│   ├── product_type.dart     # simple, variable, bundle, etc.
│   ├── stock_status.dart     # inStock, outOfStock, lowStock, etc.
│   ├── variant_type.dart     # size, color, material, etc.
│   ├── discount_type.dart    # percentage, fixed, freeShipping, etc.
│   ├── cart_operation.dart   # add, remove, update, clear, etc.
│   ├── checkout_status.dart  # pending, shipping, payment, review, etc.
│   ├── payment_method.dart   # card, cash, wallet, applePay, etc.
│   ├── payment_status.dart   # pending, completed, failed, etc.
│   ├── order_status.dart     # pending, confirmed, delivered, etc.
│   ├── loyalty_tier.dart     # bronze, silver, gold, platinum, etc.
│   ├── coupon_type.dart      # percentage, fixed, freeShipping, etc.
│   ├── wallet_transaction.dart # credit, debit, cashback, etc.
│   ├── points_transaction.dart # earned, redeemed, bonus, etc.
│   ├── shipping_type.dart    # standard, express, pickup, etc.
│   ├── category_type.dart    # standard, featured, sale, etc.
│   ├── review_status.dart    # pending, approved, rejected, flagged
│   ├── review_sort_option.dart # newest, oldest, highestRating, etc.
│   ├── suggestion_type.dart  # query, product, category, brand, etc.
│   └── sort_option.dart      # relevance, newest, priceAsc, etc.
│
├── models/                   # Data structures
│   ├── money.dart            # Currency-safe value object
│   ├── product.dart          # Complete product model
│   ├── product_variant.dart  # Variant with options
│   ├── product_option.dart   # Customization options
│   ├── cart.dart             # Shopping cart
│   ├── cart_item.dart        # Item in cart
│   ├── order.dart            # Complete order
│   ├── order_item.dart       # Item in order
│   ├── order_summary.dart    # Price breakdown
│   ├── checkout_session.dart # Checkout state
│   ├── coupon.dart           # Discount coupon
│   ├── loyalty_account.dart  # Points/tier info
│   ├── wallet.dart           # Digital wallet
│   ├── shipping_address.dart # Address model
│   ├── shipping_method.dart  # Delivery options
│   ├── category.dart         # Product category
│   ├── review.dart           # Product review
│   ├── rating_stats.dart     # Rating statistics
│   ├── wishlist.dart         # Wishlist container
│   ├── wishlist_item.dart    # Wishlist item
│   ├── search_result.dart    # Search results
│   ├── search_suggestion.dart # Autocomplete suggestions
│   ├── product_filter.dart   # Filter criteria
│   ├── available_filters.dart # Available filter options
│   └── analytics_event.dart  # Analytics event
│
├── extensions/               # Extension methods
│   ├── product_extensions.dart
│   ├── cart_extensions.dart
│   └── category_extensions.dart
│
├── utils/                    # Utilities
│   ├── price_calculator.dart # Complex price calculations
│   └── cart_validator.dart   # Validation logic
│
└── exceptions/               # Error types
    └── commerce_exception.dart
```

### 3. Data Layer

API integration, persistence, and data transformation.

```
data/
├── adapters/                 # API → Model conversion
│   ├── product_adapter.dart  # Abstract adapter interface
│   ├── json_product_adapter.dart  # Configurable JSON adapter
│   ├── category_adapter.dart # Category conversion
│   └── cart_adapter.dart     # Cart serialization
│
├── mappers/                  # Model ↔ Map transformation
│   ├── product_mapper.dart
│   └── cart_mapper.dart
│
├── datasources/              # Data sources
│   └── cart_local_datasource.dart  # SharedPreferences
│
└── repositories/             # Repository implementations
    └── cart_repository_impl.dart
```

**Adapter Pattern Flow:**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   External API  │    │     Adapter     │    │  Commerce Kit   │
│    Response     │───►│   (Your Code)   │───►│     Model       │
│                 │    │                 │    │                 │
│  {              │    │  fromExternal() │    │  Product(       │
│    "id": "123", │    │  ─────────────► │    │    id: "123",   │
│    "title": "X",│    │                 │    │    name: "X",   │
│    "cost": 999  │    │  toExternal()   │    │    price: 9.99  │
│  }              │◄───│  ◄───────────── │◄───│  )              │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 4. Domain Layer

Business logic and use cases (currently cart-focused).

```
domain/
├── repositories/             # Abstract interfaces
│   └── cart_repository.dart
│
└── usecases/                 # Business operations
    ├── add_to_cart_usecase.dart
    ├── remove_from_cart_usecase.dart
    ├── update_cart_item_usecase.dart
    ├── clear_cart_usecase.dart
    └── apply_discount_usecase.dart
```

**Use Case Pattern:**

```
┌─────────────────────────────────────────────────────────────┐
│                      AddToCartUseCase                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Input:                                                      │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  • product: Product                                  │    │
│  │  • quantity: int                                     │    │
│  │  • selectedOptions: Map<String, SelectedOption>?     │    │
│  │  • selectedVariant: ProductVariant?                  │    │
│  │  • note: String?                                     │    │
│  └─────────────────────────────────────────────────────┘    │
│                           │                                  │
│                           ▼                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                   Validation                         │    │
│  │  • Check stock availability                          │    │
│  │  • Validate required options                         │    │
│  │  • Check quantity limits                             │    │
│  │  • Verify variant exists                             │    │
│  └─────────────────────────────────────────────────────┘    │
│                           │                                  │
│                           ▼                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                    Execution                         │    │
│  │  • Create CartItem                                   │    │
│  │  • Add to Cart via Repository                        │    │
│  │  • Return updated Cart                               │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 5. Presentation Layer

State management and UI components.

```
presentation/
├── providers/                # Riverpod state management
│   ├── cart_provider.dart
│   ├── cart_config_provider.dart
│   ├── checkout_provider.dart
│   ├── coupon_provider.dart
│   ├── loyalty_provider.dart
│   ├── wallet_provider.dart
│   ├── category_provider.dart
│   ├── review_provider.dart      # Reviews state per product
│   ├── wishlist_provider.dart    # Wishlist management
│   ├── search_provider.dart      # Search & filter state
│   ├── analytics_provider.dart   # Analytics tracking
│   └── order_provider.dart       # Order management
│
├── widgets/                  # Reusable UI components
│   ├── cart_widgets/
│   │   ├── add_to_cart_button.dart
│   │   ├── cart_badge_widget.dart
│   │   ├── cart_item_widget.dart
│   │   └── cart_summary_widget.dart
│   ├── product_widgets/
│   │   ├── price_display_widget.dart
│   │   ├── quantity_selector_widget.dart
│   │   ├── variant_selector_widget.dart
│   │   └── option_selector_widget.dart
│   ├── checkout_widgets.dart
│   ├── loyalty_widgets.dart
│   ├── coupon_widgets.dart
│   ├── wallet_widgets.dart
│   └── category_widgets.dart
│
└── mixins/                   # Widget utilities
    └── cart_mixin.dart
```

---

## Data Flow

### Cart Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            CART FLOW                                     │
└─────────────────────────────────────────────────────────────────────────┘

User Action                Widget              Provider              Repository
    │                        │                    │                      │
    │  Tap "Add to Cart"     │                    │                      │
    │───────────────────────►│                    │                      │
    │                        │                    │                      │
    │                        │  addProduct()      │                      │
    │                        │───────────────────►│                      │
    │                        │                    │                      │
    │                        │                    │  Validate            │
    │                        │                    │──────────┐           │
    │                        │                    │          │           │
    │                        │                    │◄─────────┘           │
    │                        │                    │                      │
    │                        │                    │  addItem()           │
    │                        │                    │─────────────────────►│
    │                        │                    │                      │
    │                        │                    │                      │  Save to
    │                        │                    │                      │  Local Storage
    │                        │                    │                      │──────────┐
    │                        │                    │                      │          │
    │                        │                    │                      │◄─────────┘
    │                        │                    │                      │
    │                        │                    │  Updated Cart        │
    │                        │                    │◄─────────────────────│
    │                        │                    │                      │
    │                        │  State Update      │                      │
    │                        │◄───────────────────│                      │
    │                        │                    │                      │
    │  UI Rebuilds           │                    │                      │
    │◄───────────────────────│                    │                      │
    │                        │                    │                      │
```

### Checkout Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          CHECKOUT FLOW                                   │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│   Cart   │───►│ Shipping │───►│ Payment  │───►│  Review  │───►│  Order   │
│  Ready   │    │   Info   │    │  Method  │    │          │    │ Complete │
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
     │               │               │               │               │
     │               │               │               │               │
     ▼               ▼               ▼               ▼               ▼
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ Checkout │    │  Address │    │ Payment  │    │ Summary  │    │  Order   │
│ Session  │    │   Form   │    │ Selector │    │  Widget  │    │ Created  │
│ Created  │    │          │    │          │    │          │    │          │
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘

State Transitions:
─────────────────
CheckoutStatus.pending
        │
        ▼ startCheckout()
CheckoutStatus.shippingInfo
        │
        ▼ setShippingAddress()
CheckoutStatus.paymentMethod
        │
        ▼ setPaymentMethod()
CheckoutStatus.review
        │
        ▼ placeOrder()
CheckoutStatus.processing
        │
        ├──────────────────────────┐
        ▼                          ▼
CheckoutStatus.completed    CheckoutStatus.failed
```

### Provider State Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      PROVIDER STATE FLOW                                 │
└─────────────────────────────────────────────────────────────────────────┘

                    ┌─────────────────────────────────┐
                    │         CartNotifier            │
                    │                                 │
                    │  State: CartState               │
                    │  ├── cart: Cart                 │
                    │  ├── isLoading: bool            │
                    │  ├── error: String?             │
                    │  └── lastOperation: CartOp?     │
                    │                                 │
                    │  Methods:                       │
                    │  ├── addProduct()               │
                    │  ├── removeItem()               │
                    │  ├── updateQuantity()           │
                    │  ├── applyDiscount()            │
                    │  └── clearCart()                │
                    └───────────────┬─────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
          ┌─────────▼─────────┐         ┌──────────▼──────────┐
          │ Selector Providers│         │ Computed Providers  │
          │                   │         │                     │
          │ cartItemsProvider │         │ cartTotalProvider   │
          │ cartIsEmptyProv   │         │ cartItemCountProv   │
          │ cartErrorProvider │         │ canCheckoutProvider │
          └─────────┬─────────┘         └──────────┬──────────┘
                    │                               │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                         ┌──────────────────┐
                         │     Widgets      │
                         │   (Consumers)    │
                         │                  │
                         │ • CartPage       │
                         │ • CartBadge      │
                         │ • CartSummary    │
                         └──────────────────┘
```

---

## Module Dependencies

### Internal Dependencies

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     MODULE DEPENDENCY GRAPH                              │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────┐
│ presentation │
│              │
│  providers   │────────────────────────────────┐
│  widgets     │                                │
│  mixins      │                                │
└──────┬───────┘                                │
       │                                        │
       │ depends on                             │
       ▼                                        │
┌──────────────┐                                │
│    domain    │                                │
│              │                                │
│  use cases   │──────────────────────┐         │
│  repositories│                      │         │
│  (interface) │                      │         │
└──────┬───────┘                      │         │
       │                              │         │
       │ depends on                   │         │
       ▼                              ▼         │
┌──────────────┐              ┌──────────────┐  │
│     data     │              │     core     │◄─┘
│              │──────────────│              │
│  adapters    │              │  models      │
│  mappers     │              │  enums       │
│  datasources │              │  extensions  │
│  repositories│              │  utils       │
│  (impl)      │              │  exceptions  │
└──────────────┘              └──────────────┘
                                     ▲
                                     │
                              ┌──────┴───────┐
                              │    config    │
                              │              │
                              │ CommerceConf │
                              │ CartConfig   │
                              └──────────────┘
```

### External Dependencies

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     EXTERNAL DEPENDENCIES                                │
└─────────────────────────────────────────────────────────────────────────┘

commerce_kit
     │
     ├──► flutter (SDK)
     │
     ├──► flutter_riverpod (^2.4.0)
     │         │
     │         └──► State management
     │
     ├──► equatable (^2.0.5)
     │         │
     │         └──► Value equality for models
     │
     ├──► shared_preferences (^2.2.0)
     │         │
     │         └──► Local persistence
     │
     └──► uuid (^4.2.1)
               │
               └──► ID generation
```

---

## State Management Flow

### Riverpod Provider Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    RIVERPOD PROVIDER HIERARCHY                           │
└─────────────────────────────────────────────────────────────────────────┘

                    ┌───────────────────────────┐
                    │      cartConfigProvider   │ (Config)
                    └─────────────┬─────────────┘
                                  │
                                  ▼
                    ┌───────────────────────────┐
                    │    commerceCartProvider   │ (NotifierProvider)
                    │                           │
                    │    CartNotifier           │
                    │    └── CartState          │
                    └─────────────┬─────────────┘
                                  │
        ┌─────────────────────────┼─────────────────────────┐
        │                         │                         │
        ▼                         ▼                         ▼
┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│cartItemsProv  │       │cartTotalProv  │       │cartCountProv  │
│               │       │               │       │               │
│ List<CartItem>│       │    Money      │       │     int       │
└───────────────┘       └───────────────┘       └───────────────┘

        ▼                         ▼                         ▼
┌───────────────────────────────────────────────────────────────┐
│                          WIDGETS                               │
│                                                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │ CartPage    │  │ CartBadge   │  │ CartSummary │            │
│  │             │  │             │  │             │            │
│  │ watches:    │  │ watches:    │  │ watches:    │            │
│  │ cartItems   │  │ cartCount   │  │ cartTotal   │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
└───────────────────────────────────────────────────────────────┘
```

### Provider Types Used

```
Provider Types:
──────────────

1. NotifierProvider<T, State>
   └── Main state holders (CartNotifier, CheckoutNotifier, etc.)

2. Provider<T>
   └── Computed/derived values (cartTotal, cartItemCount, etc.)

3. Provider.family<T, Arg>
   └── Parameterized providers (categoryById, productById, etc.)

4. FutureProvider<T>
   └── Async operations (fetchProducts, validateCoupon, etc.)

5. StreamProvider<T>
   └── Real-time updates (cartStream, orderUpdates, etc.)
```

---

## Feature Modules

### Cart Module

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           CART MODULE                                    │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Cart     │     │  CartItem   │     │SelectedOpt │     │  CartState  │
│   Model     │────►│   Model     │────►│   Model     │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └──────┬──────┘
                                                                   │
┌─────────────┐     ┌─────────────┐     ┌─────────────┐            │
│ CartConfig  │     │CartValidator│     │PriceCalc    │            │
│             │     │             │     │             │            │
└─────────────┘     └─────────────┘     └─────────────┘            │
                                                                   │
┌─────────────┐     ┌─────────────┐     ┌─────────────┐            │
│CartProvider │◄────│ CartRepo    │◄────│CartDataSrc  │            │
│ (Notifier)  │     │  (Impl)     │     │  (Local)    │            │
└──────┬──────┘     └─────────────┘     └─────────────┘            │
       │                                                           │
       └───────────────────────────────────────────────────────────┘

┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│AddToCartBtn │     │CartItemWgt  │     │CartSummary  │     │ CartBadge   │
│   Widget    │     │   Widget    │     │   Widget    │     │   Widget    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### Checkout Module

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         CHECKOUT MODULE                                  │
└─────────────────────────────────────────────────────────────────────────┘

Models:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Checkout   │     │    Order    │     │ OrderItem   │     │OrderSummary │
│  Session    │     │   Model     │     │   Model     │     │   Model     │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Shipping   │     │  Shipping   │     │  Delivery   │
│  Address    │     │  Method     │     │  TimeSlot   │
└─────────────┘     └─────────────┘     └─────────────┘

Enums:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Checkout   │     │  Payment    │     │  Payment    │     │   Order     │
│   Status    │     │   Method    │     │   Status    │     │   Status    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘

Provider:
┌─────────────────────────────────────────────────────────────────────────┐
│                        CheckoutNotifier                                  │
│                                                                          │
│  State: CheckoutState                                                    │
│  ├── session: CheckoutSession?                                          │
│  ├── isLoading: bool                                                     │
│  ├── error: String?                                                      │
│  └── currentOrder: Order?                                                │
│                                                                          │
│  Methods:                                                                │
│  ├── startCheckout()                                                     │
│  ├── setShippingAddress(address)                                         │
│  ├── setShippingMethod(method)                                           │
│  ├── setPaymentMethod(method)                                            │
│  ├── applyCoupon(code)                                                   │
│  ├── setWalletAmount(amount)                                             │
│  ├── setPointsToRedeem(points)                                           │
│  ├── setTipAmount(amount)                                                │
│  └── placeOrder()                                                        │
└─────────────────────────────────────────────────────────────────────────┘

Widgets:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Order      │     │  Payment    │     │  Shipping   │     │   Place     │
│  Summary    │     │  Selector   │     │  Selector   │     │  OrderBtn   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### Loyalty Module

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          LOYALTY MODULE                                  │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Loyalty    │     │   Points    │     │    Tier     │
│  Account    │     │ Transaction │     │  Benefits   │
└─────────────┘     └─────────────┘     └─────────────┘

┌─────────────┐     ┌─────────────┐
│ LoyaltyTier │     │ PointsTxn   │
│   (Enum)    │     │ Type (Enum) │
└─────────────┘     └─────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                        LoyaltyNotifier                                   │
│                                                                          │
│  State: LoyaltyState                                                     │
│  ├── account: LoyaltyAccount?                                            │
│  ├── isLoading: bool                                                     │
│  └── error: String?                                                      │
│                                                                          │
│  Methods:                                                                │
│  ├── loadAccount(userId)                                                 │
│  ├── addPoints(points, type, description)                                │
│  ├── redeemPoints(points, description)                                   │
│  └── refreshAccount()                                                    │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Points     │     │  Loyalty    │     │  Points     │     │  Loyalty    │
│  Balance    │     │   Tier      │     │  Redeem     │     │   Banner    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### Coupon Module

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          COUPON MODULE                                   │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Coupon    │     │   Coupon    │     │   Coupon    │
│   Model     │     │ Validation  │     │ Type (Enum) │
└─────────────┘     └─────────────┘     └─────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         CouponNotifier                                   │
│                                                                          │
│  State: CouponState                                                      │
│  ├── appliedCoupon: Coupon?                                              │
│  ├── validation: CouponValidation?                                       │
│  ├── availableCoupons: List<Coupon>                                      │
│  ├── isValidating: bool                                                  │
│  └── inputCode: String?                                                  │
│                                                                          │
│  Methods:                                                                │
│  ├── validateAndApply(code, orderAmount)                                 │
│  ├── removeCoupon()                                                      │
│  └── loadAvailableCoupons()                                              │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Coupon     │     │  Applied    │     │ Available   │
│   Input     │     │  Coupon     │     │  Coupons    │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Wallet Module

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          WALLET MODULE                                   │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Wallet    │     │   Wallet    │     │   Balance   │
│   Model     │     │ Transaction │     │  Breakdown  │
└─────────────┘     └─────────────┘     └─────────────┘

┌─────────────┐
│ WalletTxn   │
│ Type (Enum) │
└─────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         WalletNotifier                                   │
│                                                                          │
│  State: WalletState                                                      │
│  ├── wallet: Wallet?                                                     │
│  ├── isLoading: bool                                                     │
│  └── error: String?                                                      │
│                                                                          │
│  Methods:                                                                │
│  ├── loadWallet(userId)                                                  │
│  ├── addFunds(amount, description)                                       │
│  ├── deductFunds(amount, orderId, description)                           │
│  ├── addCashback(amount, orderId, description)                           │
│  └── refund(amount, orderId, description)                                │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Wallet     │     │  Wallet     │     │  Wallet     │     │ Transaction │
│  Balance    │     │  Toggle     │     │  Checkout   │     │    List     │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### Review Module

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          REVIEW MODULE                                   │
└─────────────────────────────────────────────────────────────────────────┘

Models:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Review    │     │  Review     │     │  Rating     │     │   Review    │
│   Model     │     │  Response   │     │   Stats     │     │   Filter    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘

Enums:
┌─────────────┐     ┌─────────────┐
│   Review    │     │   Review    │
│   Status    │     │ SortOption  │
└─────────────┘     └─────────────┘

Provider:
┌─────────────────────────────────────────────────────────────────────────┐
│                        ReviewsNotifier                                   │
│                                                                          │
│  State: ReviewsState (per product via .family)                          │
│  ├── reviews: List<Review>                                               │
│  ├── ratingStats: RatingStats?                                          │
│  ├── isLoading: bool                                                     │
│  ├── hasMore: bool                                                       │
│  ├── currentFilter: ReviewFilter?                                       │
│  └── error: String?                                                      │
│                                                                          │
│  Methods:                                                                │
│  ├── loadReviews(productId)                                              │
│  ├── loadMore()                                                          │
│  ├── setFilter(filter)                                                   │
│  ├── setSortOption(sort)                                                 │
│  ├── submitReview(rating, content, images)                               │
│  ├── voteHelpful(reviewId)                                               │
│  └── reportReview(reviewId, reason)                                      │
└─────────────────────────────────────────────────────────────────────────┘

Selector Providers:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  product    │     │  product    │     │  verified   │     │  reviews    │
│  Reviews    │     │ RatingStats │     │  Reviews    │     │ WithImages  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### Wishlist Module

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         WISHLIST MODULE                                  │
└─────────────────────────────────────────────────────────────────────────┘

Models:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Wishlist   │     │  Wishlist   │     │  Wishlist   │
│   Model     │     │    Item     │     │Notification │
└─────────────┘     └─────────────┘     └─────────────┘

Provider:
┌─────────────────────────────────────────────────────────────────────────┐
│                        WishlistNotifier                                  │
│                                                                          │
│  State: WishlistState                                                    │
│  ├── wishlist: Wishlist?                                                 │
│  ├── items: List<WishlistItem>                                          │
│  ├── isLoading: bool                                                     │
│  └── error: String?                                                      │
│                                                                          │
│  Methods:                                                                │
│  ├── loadWishlist()                                                      │
│  ├── addProduct(product, notification?)                                  │
│  ├── removeProduct(productId)                                            │
│  ├── toggleProduct(product)                                              │
│  ├── isInWishlist(productId)                                             │
│  ├── updateNotification(itemId, notification)                            │
│  └── clearWishlist()                                                     │
└─────────────────────────────────────────────────────────────────────────┘

Selector Providers:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  wishlist   │     │  wishlist   │     │ isInWishlist│     │  onSale     │
│   Items     │     │   Count     │     │  Provider   │     │   Items     │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### Search Module

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          SEARCH MODULE                                   │
└─────────────────────────────────────────────────────────────────────────┘

Models:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Search     │     │   Search    │     │  Product    │     │  Available  │
│  Result<T>  │     │ Suggestion  │     │   Filter    │     │   Filters   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘

┌─────────────┐     ┌─────────────┐
│   Filter    │     │ FilterPrice │
│   Option    │     │    Range    │
└─────────────┘     └─────────────┘

Enums:
┌─────────────┐     ┌─────────────┐
│ Suggestion  │     │    Sort     │
│    Type     │     │   Option    │
└─────────────┘     └─────────────┘

Provider:
┌─────────────────────────────────────────────────────────────────────────┐
│                         SearchNotifier                                   │
│                                                                          │
│  State: SearchState                                                      │
│  ├── results: List<Product>                                              │
│  ├── suggestions: List<SearchSuggestion>                                │
│  ├── query: String                                                       │
│  ├── filter: ProductFilter?                                              │
│  ├── availableFilters: AvailableFilters?                                │
│  ├── totalResults: int                                                   │
│  ├── hasMore: bool                                                       │
│  ├── isLoading: bool                                                     │
│  ├── recentSearches: List<String>                                       │
│  └── error: String?                                                      │
│                                                                          │
│  Methods:                                                                │
│  ├── search(query)                                                       │
│  ├── applyFilter(filter)                                                 │
│  ├── clearFilters()                                                      │
│  ├── loadMore()                                                          │
│  ├── getSuggestions(query)                                               │
│  ├── addToRecentSearches(query)                                          │
│  ├── clearRecentSearches()                                               │
│  └── reset()                                                             │
└─────────────────────────────────────────────────────────────────────────┘

Selector Providers:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   search    │     │   search    │     │  available  │     │   recent    │
│   Results   │     │   Query     │     │   Filters   │     │  Searches   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### Analytics Module

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        ANALYTICS MODULE                                  │
└─────────────────────────────────────────────────────────────────────────┘

Models:
┌─────────────┐
│  Analytics  │
│   Event     │
└─────────────┘

Provider:
┌─────────────────────────────────────────────────────────────────────────┐
│                       AnalyticsProvider                                  │
│                                                                          │
│  Tracks commerce events:                                                 │
│  ├── trackProductViewed(product)                                         │
│  ├── trackAddToCart(product, quantity)                                   │
│  ├── trackRemoveFromCart(productId)                                      │
│  ├── trackBeginCheckout(cart)                                            │
│  ├── trackPurchase(order)                                                │
│  ├── trackSearch(query, resultsCount)                                    │
│  ├── trackFilterApplied(filter)                                          │
│  ├── trackWishlistAdd(product)                                           │
│  ├── trackWishlistRemove(productId)                                      │
│  └── trackReviewSubmitted(productId, rating)                             │
│                                                                          │
│  Supports multiple analytics backends:                                   │
│  ├── Firebase Analytics                                                  │
│  ├── Mixpanel                                                            │
│  ├── Amplitude                                                           │
│  └── Custom API endpoints                                                │
└─────────────────────────────────────────────────────────────────────────┘
```

### Order Module

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          ORDER MODULE                                    │
└─────────────────────────────────────────────────────────────────────────┘

Models:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Order    │     │  OrderItem  │     │OrderSummary │
│   Model     │     │   Model     │     │   Model     │
└─────────────┘     └─────────────┘     └─────────────┘

Provider:
┌─────────────────────────────────────────────────────────────────────────┐
│                         OrderProvider                                    │
│                                                                          │
│  State: OrderState                                                       │
│  ├── currentOrder: Order?                                                │
│  ├── orderHistory: List<Order>                                          │
│  ├── isLoading: bool                                                     │
│  └── error: String?                                                      │
│                                                                          │
│  Methods:                                                                │
│  ├── loadOrderHistory()                                                  │
│  ├── loadOrder(orderId)                                                  │
│  ├── trackOrder(orderId)                                                 │
│  ├── cancelOrder(orderId, reason)                                        │
│  ├── requestRefund(orderId, items, reason)                               │
│  └── reorder(orderId)                                                    │
└─────────────────────────────────────────────────────────────────────────┘

Selector Providers:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   current   │     │   order     │     │  orderById  │
│   Order     │     │  History    │     │  Provider   │
└─────────────┘     └─────────────┘     └─────────────┘
```

---

## File Structure

```
commerce_kit/
│
├── commerce_kit.dart              # Main export file
├── README.md                      # Documentation
├── API_INTEGRATION_GUIDE.md       # API integration guide
├── ARCHITECTURE.md                # This file
│
├── config/
│   ├── cart_config.dart           # Cart configuration
│   └── commerce_config.dart       # Global configuration
│
├── core/
│   ├── enums/
│   │   ├── cart_operation.dart
│   │   ├── category_type.dart
│   │   ├── checkout_status.dart
│   │   ├── coupon_type.dart
│   │   ├── discount_type.dart
│   │   ├── loyalty_tier.dart
│   │   ├── order_status.dart
│   │   ├── payment_method.dart
│   │   ├── payment_status.dart
│   │   ├── points_transaction_type.dart
│   │   ├── product_type.dart
│   │   ├── review_status.dart
│   │   ├── review_sort_option.dart
│   │   ├── shipping_type.dart
│   │   ├── sort_option.dart
│   │   ├── stock_status.dart
│   │   ├── suggestion_type.dart
│   │   ├── variant_type.dart
│   │   └── wallet_transaction_type.dart
│   │
│   ├── exceptions/
│   │   └── commerce_exception.dart
│   │
│   ├── extensions/
│   │   ├── cart_extensions.dart
│   │   ├── category_extensions.dart
│   │   └── product_extensions.dart
│   │
│   ├── models/
│   │   ├── analytics_event.dart
│   │   ├── available_filters.dart
│   │   ├── cart.dart
│   │   ├── cart_item.dart
│   │   ├── category.dart
│   │   ├── category_image.dart
│   │   ├── checkout_session.dart
│   │   ├── coupon.dart
│   │   ├── discount.dart
│   │   ├── filter_option.dart
│   │   ├── filter_price_range.dart
│   │   ├── loyalty_account.dart
│   │   ├── money.dart
│   │   ├── order.dart
│   │   ├── order_item.dart
│   │   ├── order_summary.dart
│   │   ├── price_breakdown.dart
│   │   ├── product.dart
│   │   ├── product_attribute.dart
│   │   ├── product_filter.dart
│   │   ├── product_image.dart
│   │   ├── product_option.dart
│   │   ├── product_option_value.dart
│   │   ├── product_variant.dart
│   │   ├── rating_stats.dart
│   │   ├── review.dart
│   │   ├── review_filter.dart
│   │   ├── review_response.dart
│   │   ├── search_result.dart
│   │   ├── search_suggestion.dart
│   │   ├── shipping_address.dart
│   │   ├── shipping_method.dart
│   │   ├── wallet.dart
│   │   ├── wishlist.dart
│   │   ├── wishlist_item.dart
│   │   └── wishlist_notification.dart
│   │
│   └── utils/
│       ├── cart_validator.dart
│       └── price_calculator.dart
│
├── data/
│   ├── adapters/
│   │   ├── cart_adapter.dart
│   │   ├── category_adapter.dart
│   │   ├── json_product_adapter.dart
│   │   └── product_adapter.dart
│   │
│   ├── datasources/
│   │   └── cart_local_datasource.dart
│   │
│   ├── mappers/
│   │   ├── cart_mapper.dart
│   │   └── product_mapper.dart
│   │
│   └── repositories/
│       └── cart_repository_impl.dart
│
├── domain/
│   ├── repositories/
│   │   └── cart_repository.dart
│   │
│   └── usecases/
│       ├── add_to_cart_usecase.dart
│       ├── apply_discount_usecase.dart
│       ├── clear_cart_usecase.dart
│       ├── remove_from_cart_usecase.dart
│       └── update_cart_item_usecase.dart
│
├── presentation/
│   ├── mixins/
│   │   └── cart_mixin.dart
│   │
│   ├── providers/
│   │   ├── analytics_provider.dart
│   │   ├── cart_config_provider.dart
│   │   ├── cart_provider.dart
│   │   ├── category_provider.dart
│   │   ├── checkout_provider.dart
│   │   ├── coupon_provider.dart
│   │   ├── loyalty_provider.dart
│   │   ├── order_provider.dart
│   │   ├── review_provider.dart
│   │   ├── search_provider.dart
│   │   ├── wallet_provider.dart
│   │   └── wishlist_provider.dart
│   │
│   └── widgets/
│       ├── add_to_cart_button.dart
│       ├── cart_badge_widget.dart
│       ├── cart_item_widget.dart
│       ├── cart_summary_widget.dart
│       ├── category_widgets.dart
│       ├── checkout_widgets.dart
│       ├── coupon_widgets.dart
│       ├── loyalty_widgets.dart
│       ├── option_selector_widget.dart
│       ├── order_widgets.dart
│       ├── price_display_widget.dart
│       ├── quantity_selector_widget.dart
│       ├── review_widgets.dart
│       ├── search_widgets.dart
│       ├── variant_selector_widget.dart
│       ├── wallet_widgets.dart
│       └── wishlist_widgets.dart
│
└── example/
    └── ... (example implementations)
```

---

## Design Patterns

### 1. Adapter Pattern

Converts external API data to internal models.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ADAPTER PATTERN                                  │
└─────────────────────────────────────────────────────────────────────────┘

                    ┌─────────────────────┐
                    │  ProductAdapter<T>  │ (Abstract)
                    │                     │
                    │  + fromExternal(T)  │
                    │  + toExternal(P)    │
                    └──────────┬──────────┘
                               │
           ┌───────────────────┼───────────────────┐
           │                   │                   │
           ▼                   ▼                   ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│ JsonProductAdapter│ │WooCommerceAdapter│ │ ShopifyAdapter   │
│                  │ │                  │ │                  │
│ Configurable     │ │ Pre-configured   │ │ Pre-configured   │
│ field mappings   │ │ for WooCommerce  │ │ for Shopify      │
└──────────────────┘ └──────────────────┘ └──────────────────┘
```

### 2. Repository Pattern

Abstracts data access from business logic.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        REPOSITORY PATTERN                                │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐         ┌──────────────────┐
│  CartRepository  │         │CartRepositoryImpl│
│   (Interface)    │◄────────│ (Implementation) │
│                  │         │                  │
│  + getCart()     │         │ Uses:            │
│  + addItem()     │         │ - Datasource     │
│  + removeItem()  │         │ - Mapper         │
│  + updateItem()  │         │                  │
│  + clear()       │         │                  │
└──────────────────┘         └────────┬─────────┘
                                      │
                             ┌────────▼─────────┐
                             │CartLocalDatasource│
                             │                  │
                             │ SharedPreferences│
                             └──────────────────┘
```

### 3. Singleton Pattern

Used for global configuration.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SINGLETON PATTERN                                │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    CommerceConfig                        │
│                                                          │
│  static CommerceConfig? _instance;                       │
│                                                          │
│  static CommerceConfig get instance {                    │
│    if (_instance == null) {                              │
│      throw StateError('Not initialized');                │
│    }                                                     │
│    return _instance!;                                    │
│  }                                                       │
│                                                          │
│  static void initialize({...}) {                         │
│    _instance = CommerceConfig._(...);                    │
│  }                                                       │
│                                                          │
│  CommerceConfig._({...}); // Private constructor         │
└─────────────────────────────────────────────────────────┘
```

### 4. Value Object Pattern

Money class as immutable value object.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       VALUE OBJECT PATTERN                               │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                        Money                             │
│                                                          │
│  Immutable:                                              │
│  - final double amount                                   │
│  - final String currency                                 │
│                                                          │
│  Operations return new instances:                        │
│  - Money operator +(Money other)                         │
│  - Money operator -(Money other)                         │
│  - Money operator *(num factor)                          │
│  - Money operator /(num divisor)                         │
│                                                          │
│  Value equality (via Equatable):                         │
│  - Money(10.00) == Money(10.00) // true                  │
└─────────────────────────────────────────────────────────┘
```

### 5. State Pattern (via Enums)

Enums with behavior methods.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          STATE PATTERN                                   │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                     CheckoutStatus                       │
│                                                          │
│  enum CheckoutStatus {                                   │
│    pending,                                              │
│    shippingInfo,                                         │
│    paymentMethod,                                        │
│    review,                                               │
│    processing,                                           │
│    completed,                                            │
│    failed,                                               │
│    cancelled,                                            │
│  }                                                       │
│                                                          │
│  extension CheckoutStatusExtension {                     │
│    int get stepNumber { ... }                            │
│    bool get canGoBack { ... }                            │
│    bool get isTerminal { ... }                           │
│    CheckoutStatus? get nextStatus { ... }                │
│    CheckoutStatus? get previousStatus { ... }            │
│  }                                                       │
└─────────────────────────────────────────────────────────┘
```

---

## Sequence Diagrams

### Add to Cart Sequence

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      ADD TO CART SEQUENCE                                │
└─────────────────────────────────────────────────────────────────────────┘

User         UI Widget      CartProvider    CartValidator    Repository
 │               │               │               │               │
 │  Tap Add      │               │               │               │
 │──────────────►│               │               │               │
 │               │               │               │               │
 │               │ addProduct()  │               │               │
 │               │──────────────►│               │               │
 │               │               │               │               │
 │               │               │ validateAdd() │               │
 │               │               │──────────────►│               │
 │               │               │               │               │
 │               │               │   ok/error    │               │
 │               │               │◄──────────────│               │
 │               │               │               │               │
 │               │               │ [if valid]    │               │
 │               │               │ addItem()     │               │
 │               │               │───────────────────────────────►
 │               │               │               │               │
 │               │               │               │   save to     │
 │               │               │               │   storage     │
 │               │               │               │               │
 │               │               │  updated cart │               │
 │               │               │◄───────────────────────────────
 │               │               │               │               │
 │               │ state update  │               │               │
 │               │◄──────────────│               │               │
 │               │               │               │               │
 │  UI rebuild   │               │               │               │
 │◄──────────────│               │               │               │
 │               │               │               │               │
```

### Checkout Sequence

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        CHECKOUT SEQUENCE                                 │
└─────────────────────────────────────────────────────────────────────────┘

User          CheckoutUI     CheckoutProv     CouponProv      WalletProv
 │                │               │               │               │
 │  Start         │               │               │               │
 │───────────────►│               │               │               │
 │                │               │               │               │
 │                │ startCheckout()│              │               │
 │                │──────────────►│               │               │
 │                │               │               │               │
 │                │   session     │               │               │
 │                │◄──────────────│               │               │
 │                │               │               │               │
 │  Enter address │               │               │               │
 │───────────────►│               │               │               │
 │                │setShippingAddr│               │               │
 │                │──────────────►│               │               │
 │                │               │               │               │
 │  Apply coupon  │               │               │               │
 │───────────────►│               │               │               │
 │                │               │ validateCoupon│               │
 │                │               │──────────────►│               │
 │                │               │               │               │
 │                │               │   validation  │               │
 │                │               │◄──────────────│               │
 │                │               │               │               │
 │  Use wallet    │               │               │               │
 │───────────────►│               │               │               │
 │                │               │  getBalance   │               │
 │                │               │───────────────────────────────►
 │                │               │               │               │
 │                │               │   balance     │               │
 │                │               │◄───────────────────────────────
 │                │               │               │               │
 │  Place order   │               │               │               │
 │───────────────►│               │               │               │
 │                │ placeOrder()  │               │               │
 │                │──────────────►│               │               │
 │                │               │               │               │
 │                │               │── create order ──────────────►│
 │                │               │── deduct wallet ──────────────►
 │                │               │── deduct coupon ─────────────►│
 │                │               │               │               │
 │                │   Order       │               │               │
 │                │◄──────────────│               │               │
 │                │               │               │               │
 │  Confirmation  │               │               │               │
 │◄───────────────│               │               │               │
 │                │               │               │               │
```

### Product Options Selection

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    PRODUCT OPTIONS SELECTION                             │
└─────────────────────────────────────────────────────────────────────────┘

User         OptionWidget    VariantWidget    PriceWidget    AddButton
 │               │               │               │               │
 │  Select size  │               │               │               │
 │──────────────►│               │               │               │
 │               │               │               │               │
 │               │ onSelected    │               │               │
 │               │──────────────►│               │               │
 │               │               │               │               │
 │               │               │ find matching │               │
 │               │               │    variant    │               │
 │               │               │───────┐       │               │
 │               │               │       │       │               │
 │               │               │◄──────┘       │               │
 │               │               │               │               │
 │               │               │ update price  │               │
 │               │               │──────────────►│               │
 │               │               │               │               │
 │               │               │ check stock   │               │
 │               │               │───────────────────────────────►
 │               │               │               │               │
 │  Select color │               │               │               │
 │──────────────►│               │               │               │
 │               │               │               │               │
 │               │ onSelected    │               │               │
 │               │──────────────►│               │               │
 │               │               │               │               │
 │               │               │ find variant  │               │
 │               │               │───────┐       │               │
 │               │               │       │       │               │
 │               │               │◄──────┘       │               │
 │               │               │               │               │
 │               │               │ update price  │               │
 │               │               │──────────────►│               │
 │               │               │               │               │
 │               │               │ enable button │               │
 │               │               │───────────────────────────────►
 │               │               │               │               │
 │  Add to cart  │               │               │               │
 │───────────────────────────────────────────────────────────────►
 │               │               │               │               │
```

---

## Summary

Commerce Kit is built with:

1. **Clean Architecture** - Clear layer separation
2. **Immutable Models** - All models use Equatable
3. **Riverpod State** - Efficient reactive state management
4. **Adapter Pattern** - Flexible API integration
5. **Repository Pattern** - Abstracted data access
6. **Rich Enums** - Enums with behavior via extensions
7. **Type Safety** - Strong typing throughout

The architecture supports:

- Easy testing (mockable layers)
- API flexibility (adapters)
- State predictability (immutable)
- Code organization (feature modules)
- Scalability (clean separation)
