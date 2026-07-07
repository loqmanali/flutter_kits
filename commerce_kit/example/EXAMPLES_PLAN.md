# Commerce Kit - Complete Examples Plan

This document outlines the comprehensive examples to be created for the Commerce Kit package.

## Overview

The examples will demonstrate all features of the Commerce Kit package including:

- Money class operations
- Product models (all types)
- Product variants
- Product options
- Categories (hierarchical)
- Cart operations
- Discounts (all types)
- API adapters
- State management with Riverpod
- Widgets
- Configuration
- Complete integration examples

---

## Example Files Structure

```
lib/packages/commerce_kit/example/
├── EXAMPLES_PLAN.md              # This file
├── money_examples.dart           # Money class examples
├── product_examples.dart         # Product model examples
├── product_variant_examples.dart # Product variant examples
├── product_option_examples.dart  # Product option examples
├── category_examples.dart        # Category examples
├── cart_examples.dart            # Cart and cart item examples
├── discount_examples.dart        # Discount examples
├── adapter_examples.dart         # API adapter examples
├── provider_examples.dart        # Riverpod provider examples
├── widget_examples.dart          # Widget examples
├── configuration_examples.dart   # Configuration examples
├── integration_examples.dart    # Complete integration examples
└── README.md                     # Examples documentation
```

---

## 1. Money Examples (`money_examples.dart`)

### Topics to Cover:

- Creating Money instances
- Arithmetic operations (add, subtract, multiply, divide)
- Comparison operations
- Formatting (formatted, formattedCompact)
- Currency configuration
- Zero and checks
- Edge cases

### Example Functions:

```dart
class MoneyExamples {
  static void runAll() {
    basicCreation();
    arithmeticOperations();
    comparisonOperations();
    formatting();
    currencyConfiguration();
    zeroAndChecks();
    edgeCases();
  }

  static void basicCreation() { ... }
  static void arithmeticOperations() { ... }
  static void comparisonOperations() { ... }
  static void formatting() { ... }
  static void currencyConfiguration() { ... }
  static void zeroAndChecks() { ... }
  static void edgeCases() { ... }
}
```

---

## 2. Product Examples (`product_examples.dart`)

### Topics to Cover:

- Simple products
- Variable products (with variants)
- Configurable products (with options)
- Bundle products
- Product properties (images, attributes, tags, metadata)
- Product extensions and helpers

### Example Functions:

```dart
class ProductExamples {
  static void runAll() {
    simpleProduct();
    variableProduct();
    configurableProduct();
    bundleProduct();
    productWithImages();
    productWithAttributes();
    productWithTags();
    productWithMetadata();
    productExtensions();
  }

  static void simpleProduct() { ... }
  static void variableProduct() { ... }
  static void configurableProduct() { ... }
  static void bundleProduct() { ... }
  static void productWithImages() { ... }
  static void productWithAttributes() { ... }
  static void productWithTags() { ... }
  static void productWithMetadata() { ... }
  static void productExtensions() { ... }
}
```

---

## 3. Product Variant Examples (`product_variant_examples.dart`)

### Topics to Cover:

- Creating variants
- Variant with selected options
- Variant pricing (compare at price)
- Variant stock management
- Variant images
- Variant properties (isInStock, isOnSale, optionsSummary)

### Example Functions:

```dart
class ProductVariantExamples {
  static void runAll() {
    basicVariant();
    variantWithSelectedOptions();
    variantWithSalePrice();
    variantWithStock();
    variantWithImages();
    variantProperties();
    variantMatching();
  }

  static void basicVariant() { ... }
  static void variantWithSelectedOptions() { ... }
  static void variantWithSalePrice() { ... }
  static void variantWithStock() { ... }
  static void variantWithImages() { ... }
  static void variantProperties() { ... }
  static void variantMatching() { ... }
}
```

---

## 4. Product Option Examples (`product_option_examples.dart`)

### Topics to Cover:

- Single-select required options
- Multi-select optional options
- Color options with color codes
- Size options with price modifiers
- Custom options with max selections
- Option properties (availableValues, hasExtraCosts, getValue)

### Example Functions:

```dart
class ProductOptionExamples {
  static void runAll() {
    singleSelectOption();
    multiSelectOption();
    colorOption();
    sizeOption();
    customOption();
    optionWithPriceModifiers();
    optionProperties();
    optionValidation();
  }

  static void singleSelectOption() { ... }
  static void multiSelectOption() { ... }
  static void colorOption() { ... }
  static void sizeOption() { ... }
  static void customOption() { ... }
  static void optionWithPriceModifiers() { ... }
  static void optionProperties() { ... }
  static void optionValidation() { ... }
}
```

---

## 5. Category Examples (`category_examples.dart`)

### Topics to Cover:

- Simple categories
- Categories with images (network, asset, icon, banner)
- Featured categories with badges
- Sale categories with expiration
- Brand categories with logos
- Hierarchical categories (nested)
- Category navigation (findChild, allDescendants, maxDepth)
- Category extensions (roots, visible, featured, forMenu, sorted, search)
- Category images (network, asset, icon, banner, placeholder)

### Example Functions:

```dart
class CategoryExamples {
  static void runAll() {
    simpleCategory();
    categoryWithImages();
    featuredCategory();
    saleCategory();
    brandCategory();
    hierarchicalCategories();
    categoryNavigation();
    categoryExtensions();
    categoryImages();
    categoryTypes();
  }

  static void simpleCategory() { ... }
  static void categoryWithImages() { ... }
  static void featuredCategory() { ... }
  static void saleCategory() { ... }
  static void brandCategory() { ... }
  static void hierarchicalCategories() { ... }
  static void categoryNavigation() { ... }
  static void categoryExtensions() { ... }
  static void categoryImages() { ... }
  static void categoryTypes() { ... }
}
```

---

## 6. Cart Examples (`cart_examples.dart`)

### Topics to Cover:

- Creating empty cart
- Adding items
- Updating quantities
- Removing items
- Clearing cart
- Applying discounts
- Cart calculations (subtotal, itemCount, uniqueItemCount, isEmpty)
- Finding items (getItem, getItemByProductId, getProductQuantity)
- Cart operations (addItem, updateQuantity, removeItem, clear, applyDiscount)

### Example Functions:

```dart
class CartExamples {
  static void runAll() {
    emptyCart();
    addItemToCart();
    updateQuantity();
    removeItem();
    clearCart();
    applyDiscount();
    cartCalculations();
    findItems();
    cartOperations();
    cartWithMultipleItems();
    cartWithDiscounts();
  }

  static void emptyCart() { ... }
  static void addItemToCart() { ... }
  static void updateQuantity() { ... }
  static void removeItem() { ... }
  static void clearCart() { ... }
  static void applyDiscount() { ... }
  static void cartCalculations() { ... }
  static void findItems() { ... }
  static void cartOperations() { ... }
  static void cartWithMultipleItems() { ... }
  static void cartWithDiscounts() { ... }
}
```

---

## 7. Discount Examples (`discount_examples.dart`)

### Topics to Cover:

- Percentage discount
- Fixed amount discount
- Free shipping discount
- Buy one get one (BOGO) discount
- Bulk discount
- Tiered discount
- Discount with expiration
- Discount with minimum order amount
- Discount for specific products
- Discount properties (isValid, isExpired, hasReachedUsageLimit)

### Example Functions:

```dart
class DiscountExamples {
  static void runAll() {
    percentageDiscount();
    fixedAmountDiscount();
    freeShippingDiscount();
    bogoDiscount();
    bulkDiscount();
    tieredDiscount();
    discountWithExpiration();
    discountWithMinimumOrder();
    discountForSpecificProducts();
    discountProperties();
    discountValidation();
  }

  static void percentageDiscount() { ... }
  static void fixedAmountDiscount() { ... }
  static void freeShippingDiscount() { ... }
  static void bogoDiscount() { ... }
  static void bulkDiscount() { ... }
  static void tieredDiscount() { ... }
  static void discountWithExpiration() { ... }
  static void discountWithMinimumOrder() { ... }
  static void discountForSpecificProducts() { ... }
  static void discountProperties() { ... }
  static void discountValidation() { ... }
}
```

---

## 8. Adapter Examples (`adapter_examples.dart`)

### Topics to Cover:

- Map-based adapter
- JSON adapter with custom field mapping
- WooCommerce adapter
- Shopify adapter
- Magento adapter
- PrestaShop adapter
- OpenCart adapter
- Custom adapter implementation
- Nested category adapter
- Flat category adapter

### Example Functions:

```dart
class AdapterExamples {
  static void runAll() {
    mapAdapter();
    jsonAdapterWithCustomFields();
    woocommerceAdapter();
    shopifyAdapter();
    magentoAdapter();
    prestaShopAdapter();
    openCartAdapter();
    customAdapter();
    nestedCategoryAdapter();
    flatCategoryAdapter();
  }

  static void mapAdapter() { ... }
  static void jsonAdapterWithCustomFields() { ... }
  static void woocommerceAdapter() { ... }
  static void shopifyAdapter() { ... }
  static void magentoAdapter() { ... }
  static void prestaShopAdapter() { ... }
  static void openCartAdapter() { ... }
  static void customAdapter() { ... }
  static void nestedCategoryAdapter() { ... }
  static void flatCategoryAdapter() { ... }
}
```

---

## 9. Provider Examples (`provider_examples.dart`)

### Topics to Cover:

- Cart providers (commerceCartProvider, cartItemsProvider, cartTotalProvider, cartItemCountProvider, cartIsEmptyProvider)
- Category providers (categoriesProvider, allCategoriesProvider, categoryTreeProvider, rootCategoriesProvider, etc.)
- Family providers (categoryByIdProvider, categoryBySlugProvider, categoryChildrenProvider, etc.)
- Cart operations with providers (addProduct, updateQuantity, removeItem, clearCart, applyDiscount)
- Category operations with providers (setCategories, selectCategory, addCategory, updateCategory, removeCategory)
- Using CartMixin

### Example Functions:

```dart
class ProviderExamples {
  static void runAll() {
    cartProviders();
    cartSelectorProviders();
    cartOperations();
    categoryProviders();
    categoryFamilyProviders();
    categoryOperations();
    cartMixinUsage();
  }

  static void cartProviders() { ... }
  static void cartSelectorProviders() { ... }
  static void cartOperations() { ... }
  static void categoryProviders() { ... }
  static void categoryFamilyProviders() { ... }
  static void categoryOperations() { ... }
  static void cartMixinUsage() { ... }
}
```

---

## 10. Widget Examples (`widget_examples.dart`)

### Topics to Cover:

#### Cart Widgets:

- CartBadgeWidget
- CartIconButton
- QuantitySelectorWidget
- CartItemWidget
- CartSummaryWidget
- AddToCartButton
- PriceDisplayWidget

#### Product Option Widgets:

- VariantSelectorWidget
- RadioOptionSelector
- OptionSelectorWidget
- ColorSwatchSelector

#### Category Widgets:

- CategoryCard
- CategoryChip
- CategoryList
- CategoryGrid
- CategoryTreeView
- CategoryBreadcrumbWidget
- CategoryDropdown
- CategoryListView

### Example Functions:

```dart
class WidgetExamples {
  static void runAll() {
    cartBadgeWidget();
    cartIconButton();
    quantitySelectorWidget();
    cartItemWidget();
    cartSummaryWidget();
    addToCartButton();
    priceDisplayWidget();
    variantSelectorWidget();
    radioOptionSelector();
    optionSelectorWidget();
    colorSwatchSelector();
    categoryCard();
    categoryChip();
    categoryList();
    categoryGrid();
    categoryTreeView();
    categoryBreadcrumbWidget();
    categoryDropdown();
    categoryListView();
  }

  static void cartBadgeWidget() { ... }
  static void cartIconButton() { ... }
  static void quantitySelectorWidget() { ... }
  static void cartItemWidget() { ... }
  static void cartSummaryWidget() { ... }
  static void addToCartButton() { ... }
  static void priceDisplayWidget() { ... }
  static void variantSelectorWidget() { ... }
  static void radioOptionSelector() { ... }
  static void optionSelectorWidget() { ... }
  static void colorSwatchSelector() { ... }
  static void categoryCard() { ... }
  static void categoryChip() { ... }
  static void categoryList() { ... }
  static void categoryGrid() { ... }
  static void categoryTreeView() { ... }
  static void categoryBreadcrumbWidget() { ... }
  static void categoryDropdown() { ... }
  static void categoryListView() { ... }
}
```

---

## 11. Configuration Examples (`configuration_examples.dart`)

### Topics to Cover:

- CartConfig (maxQuantityPerItem, maxCartItems, allowNegativeStock, persistCart, storageKey, freeShippingThreshold)
- CommerceConfig (currency, currencySymbol, currencyPosition, locale, decimalSeparator, thousandsSeparator, decimalPlaces, taxRate, taxInclusive, defaultShippingCost, cartConfig)
- Initializing configuration
- Accessing config anywhere
- Price formatting with config
- Tax calculation with config

### Example Functions:

```dart
class ConfigurationExamples {
  static void runAll() {
    cartConfig();
    commerceConfig();
    initializeConfiguration();
    accessConfigAnywhere();
    priceFormatting();
    taxCalculation();
  }

  static void cartConfig() { ... }
  static void commerceConfig() { ... }
  static void initializeConfiguration() { ... }
  static void accessConfigAnywhere() { ... }
  static void priceFormatting() { ... }
  static void taxCalculation() { ... }
}
```

---

## 12. Integration Examples (`integration_examples.dart`)

### Topics to Cover:

- Complete product detail page with variants, options, and add to cart
- Complete cart page with all features
- Integrating with custom API service
- Category management page
- Checkout flow integration
- Discount application flow

### Example Functions:

```dart
class IntegrationExamples {
  static void runAll() {
    productDetailPage();
    cartPage();
    customApiIntegration();
    categoryManagementPage();
    checkoutFlow();
    discountApplicationFlow();
  }

  static void productDetailPage() { ... }
  static void cartPage() { ... }
  static void customApiIntegration() { ... }
  static void categoryManagementPage() { ... }
  static void checkoutFlow() { ... }
  static void discountApplicationFlow() { ... }
}
```

---

## Example Code Template

Each example file should follow this template:

```dart
/// # [Feature Name] Examples
///
/// This file contains examples demonstrating how to use [Feature Name]
/// in the Commerce Kit package.
library;

import 'package:commerce_kit/commerce_kit.dart';

class [FeatureName]Examples {
  /// Run all examples for this feature
  static void runAll() {
    print('════════════════════════════════════════════════════════════════');
    print('[FEATURE NAME] EXAMPLES');
    print('════════════════════════════════════════════════════════════════\n');

    example1();
    example2();
    example3();
    // ... more examples

    print('\n════════════════════════════════════════════════════════════════\n');
  }

  static void example1() {
    print('\n▶ Example 1: [Description]');
    print('─' * 60);

    // Example code here
    final result = /* code */;

    print('Result: $result');
  }

  static void example2() {
    print('\n▶ Example 2: [Description]');
    print('─' * 60);

    // Example code here
    final result = /* code */;

    print('Result: $result');
  }

  // ... more examples
}
```

---

## Running Examples

To run all examples:

```dart
import 'package:commerce_kit/example/commerce_kit_examples.dart';

void main() {
  runAllExamples();
}
```

To run specific examples:

```dart
import 'package:commerce_kit/example/money_examples.dart';

void main() {
  MoneyExamples.runAll();
}
```

---

## Notes

- All examples should be self-contained and runnable
- Use print statements to show results
- Include comments explaining each step
- Cover edge cases and error handling where applicable
- Examples should be realistic and practical
- Use the burger restaurant theme where appropriate (since this is for Burger Republic)
