# Changelog

All notable changes to Commerce Kit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.0] - 2025-02-01

### Added

#### Review System
- `Review` model with complete review data (rating, content, images, verified purchase)
- `ReviewResponse` model for merchant responses to reviews
- `RatingStats` model with aggregated rating statistics and distribution
- `ReviewFilter` model for filtering reviews
- `ReviewStatus` enum (pending, approved, rejected, flagged)
- `ReviewSortOption` enum (mostRecent, highestRating, mostHelpful, etc.)
- `ReviewsNotifier` provider with family support for per-product state
- Selector providers: `productReviewsProvider`, `productRatingStatsProvider`, `verifiedReviewsProvider`, `reviewsWithImagesProvider`
- `ReviewWidgets` for displaying reviews and rating summaries

#### Wishlist System
- `Wishlist` model with multiple wishlists support
- `WishlistItem` model with product reference and notification settings
- `WishlistNotification` model for price drop and back-in-stock alerts
- `WishlistNotifier` provider with add/remove/toggle operations
- Selector providers: `wishlistItemsProvider`, `wishlistCountProvider`, `isInWishlistProvider`, `wishlistOnSaleItemsProvider`
- `WishlistWidgets` for wishlist display and management

#### Search & Filtering
- `SearchResult<T>` generic model for paginated results
- `SearchSuggestion` model for autocomplete
- `ProductFilter` model with comprehensive filtering options
- `AvailableFilters` model for dynamic filter options from API
- `FilterOption` and `FilterPriceRange` models
- `SuggestionType` enum (query, product, category, brand, recent, popular)
- `SortOption` enum (relevance, newest, priceAsc, priceDesc, rating, popularity)
- `SearchNotifier` provider with search, filter, and pagination
- Selector providers: `searchResultsProvider`, `searchQueryProvider`, `availableFiltersProvider`, `recentSearchesProvider`
- `SearchWidgets` for search bar and filter UI

#### Analytics System
- `AnalyticsEvent` model for tracking commerce events
- `AnalyticsProvider` with support for multiple backends
- Event tracking: product viewed, add to cart, remove from cart, begin checkout, purchase, search, wishlist actions, review submissions
- Firebase Analytics integration support
- Mixpanel integration support
- Custom API endpoint support

#### Order Management
- `OrderProvider` for order history and management
- Order tracking, cancellation, and refund request support
- Reorder functionality
- Selector providers: `currentOrderProvider`, `orderHistoryProvider`, `orderByIdProvider`
- `OrderWidgets` for order display and tracking

### Changed

- Updated `commerce_kit.dart` to export all new modules
- Enhanced documentation in README.md with new feature sections
- Updated API_INTEGRATION_GUIDE.md with adapters for new features
- Updated ARCHITECTURE.md with new module diagrams

### Documentation

- Added comprehensive Review System documentation with usage examples
- Added Wishlist System documentation with notification setup
- Added Search & Filtering documentation with filter configuration
- Added Analytics Integration guide with multiple provider setup
- Updated API Reference with all new models, enums, and providers

---

## [1.3.0] - 2025-01-15

### Added

- Complete checkout flow implementation
- `CheckoutSession` model with step-by-step state management
- `CheckoutNotifier` provider with order placement
- Shipping method selection with time slots
- Payment method support (card, cash, wallet, Apple Pay, Google Pay)
- Order summary with price breakdown
- Points redemption during checkout
- Wallet balance usage during checkout
- Tip amount support

---

## [1.2.0] - 2025-01-01

### Added

- Loyalty program support
- `LoyaltyAccount` model with tier system
- `PointsTransaction` for transaction history
- `LoyaltyTier` enum (bronze, silver, gold, platinum, diamond, vip)
- Points earning and redemption
- Tier progress tracking

- Coupon system
- `Coupon` model with validation
- `CouponValidation` result model
- Multiple coupon types (percentage, fixed, free shipping, buy X get Y)
- Usage limits and expiration

- Digital wallet
- `Wallet` model with balance tracking
- `WalletTransaction` for transaction history
- Cashback support
- Refund handling

---

## [1.1.0] - 2024-12-15

### Added

- Category management system
- `Category` model with hierarchy support
- `CategoryImage` for various image types
- `CategoriesNotifier` provider with tree operations
- Breadcrumb generation
- Category filtering and search

---

## [1.0.0] - 2024-12-01

### Added

- Initial release of Commerce Kit
- Core models: `Product`, `ProductVariant`, `ProductOption`, `Money`
- Cart management with persistence
- `CartNotifier` provider with full CRUD operations
- Product adapters for API integration
- `JsonProductAdapter` for flexible JSON mapping
- Pre-built widgets: AddToCartButton, CartBadge, CartItem, CartSummary
- Price calculator with discount support
- Cart validator for stock and quantity checks
- Clean Architecture structure
- Comprehensive documentation
