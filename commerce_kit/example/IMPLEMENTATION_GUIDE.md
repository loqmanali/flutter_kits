# Commerce Kit Examples - Implementation Guide

This document provides a complete guide for implementing all Commerce Kit examples.

## 📋 Implementation Status

| Example File                    | Status     | Notes                                                                 |
| ------------------------------- | ---------- | --------------------------------------------------------------------- |
| `money_examples.dart`           | ⏳ Pending | Detailed plan available in [MONEY_EXAMPLES.md](MONEY_EXAMPLES.md)     |
| `product_examples.dart`         | ⏳ Pending | Detailed plan available in [PRODUCT_EXAMPLES.md](PRODUCT_EXAMPLES.md) |
| `product_variant_examples.dart` | ⏳ Pending | Plan available in [EXAMPLES_PLAN.md](EXAMPLES_PLAN.md)                |
| `product_option_examples.dart`  | ⏳ Pending | Plan available in [EXAMPLES_PLAN.md](EXAMPLES_PLAN.md)                |
| `category_examples.dart`        | ⏳ Pending | Plan available in [EXAMPLES_PLAN.md](EXAMPLES_PLAN.md)                |
| `cart_examples.dart`            | ⏳ Pending | Plan available in [EXAMPLES_PLAN.md](EXAMPLES_PLAN.md)                |
| `discount_examples.dart`        | ⏳ Pending | Plan available in [EXAMPLES_PLAN.md](EXAMPLES_PLAN.md)                |
| `adapter_examples.dart`         | ⏳ Pending | Plan available in [EXAMPLES_PLAN.md](EXAMPLES_PLAN.md)                |
| `provider_examples.dart`        | ⏳ Pending | Plan available in [EXAMPLES_PLAN.md](EXAMPLES_PLAN.md)                |
| `widget_examples.dart`          | ⏳ Pending | Plan available in [EXAMPLES_PLAN.md](EXAMPLES_PLAN.md)                |
| `configuration_examples.dart`   | ⏳ Pending | Plan available in [EXAMPLES_PLAN.md](EXAMPLES_PLAN.md)                |
| `integration_examples.dart`     | ⏳ Pending | Plan available in [EXAMPLES_PLAN.md](EXAMPLES_PLAN.md)                |

---

## 🏗️ Implementation Template

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

## 📝 Implementation Checklist

### Money Examples (`money_examples.dart`)

- [ ] basicCreation() - Creating Money instances
- [ ] arithmeticOperations() - Add, subtract, multiply, divide
- [ ] comparisonOperations() - Greater than, less than, equality
- [ ] formatting() - Formatted, formattedCompact
- [ ] currencyConfiguration() - USD, EUR, GBP, JPY, EGP
- [ ] zeroAndChecks() - Is zero, is positive, is negative
- [ ] edgeCases() - Tiny, huge, division, from/to cents
- [ ] burgerPricing() - Practical use case

### Product Examples (`product_examples.dart`)

- [ ] simpleProduct() - Basic simple product
- [ ] variableProduct() - Product with variants
- [ ] configurableProduct() - Product with options
- [ ] bundleProduct() - Bundle of products
- [ ] productWithImages() - Multiple images
- [ ] productWithAttributes() - Custom attributes
- [ ] productWithTags() - Tags and metadata
- [ ] productExtensions() - Helper methods
- [ ] digitalProduct() - Digital gift card
- [ ] serviceProduct() - Catering service

### Product Variant Examples (`product_variant_examples.dart`)

- [ ] basicVariant() - Creating a variant
- [ ] variantWithSelectedOptions() - Size/color combinations
- [ ] variantWithSalePrice() - Compare at price
- [ ] variantWithStock() - Stock management
- [ ] variantWithImages() - Variant-specific images
- [ ] variantProperties() - isInStock, isOnSale, optionsSummary
- [ ] variantMatching() - Finding matching variants

### Product Option Examples (`product_option_examples.dart`)

- [ ] singleSelectOption() - Required single select
- [ ] multiSelectOption() - Optional multi-select with limit
- [ ] colorOption() - Color options with color codes
- [ ] sizeOption() - Size options with price modifiers
- [ ] customOption() - Custom options
- [ ] optionWithPriceModifiers() - Price modifiers
- [ ] optionProperties() - availableValues, hasExtraCosts, getValue
- [ ] optionValidation() - Required, max selections

### Category Examples (`category_examples.dart`)

- [ ] simpleCategory() - Basic category
- [ ] categoryWithImages() - Network, asset, icon, banner
- [ ] featuredCategory() - Featured with badge
- [ ] saleCategory() - Sale with expiration
- [ ] brandCategory() - Brand with logo
- [ ] hierarchicalCategories() - Nested categories
- [ ] categoryNavigation() - findChild, allDescendants, maxDepth
- [ ] categoryExtensions() - roots, visible, featured, sorted, search
- [ ] categoryImages() - All image types
- [ ] categoryTypes() - All category types

### Cart Examples (`cart_examples.dart`)

- [ ] emptyCart() - Creating empty cart
- [ ] addItemToCart() - Adding items
- [ ] updateQuantity() - Updating quantities
- [ ] removeItem() - Removing items
- [ ] clearCart() - Clearing cart
- [ ] applyDiscount() - Applying discounts
- [ ] cartCalculations() - Subtotal, itemCount, isEmpty
- [ ] findItems() - getItem, getItemByProductId, getProductQuantity
- [ ] cartOperations() - All operations
- [ ] cartWithMultipleItems() - Multiple items
- [ ] cartWithDiscounts() - Multiple discounts

### Discount Examples (`discount_examples.dart`)

- [ ] percentageDiscount() - Percentage off
- [ ] fixedAmountDiscount() - Fixed amount off
- [ ] freeShippingDiscount() - Free shipping
- [ ] bogoDiscount() - Buy one get one
- [ ] bulkDiscount() - Bulk discount
- [ ] tieredDiscount() - Tiered discount
- [ ] discountWithExpiration() - Date-based expiration
- [ ] discountWithMinimumOrder() - Minimum order requirement
- [ ] discountForSpecificProducts() - Product-specific
- [ ] discountProperties() - isValid, isExpired, hasReachedUsageLimit
- [ ] discountValidation() - All validation checks

### Adapter Examples (`adapter_examples.dart`)

- [ ] mapAdapter() - Map-based adapter
- [ ] jsonAdapterWithCustomFields() - Custom field mapping
- [ ] woocommerceAdapter() - WooCommerce
- [ ] shopifyAdapter() - Shopify
- [ ] magentoAdapter() - Magento
- [ ] prestaShopAdapter() - PrestaShop
- [ ] openCartAdapter() - OpenCart
- [ ] customAdapter() - Custom implementation
- [ ] nestedCategoryAdapter() - Nested categories
- [ ] flatCategoryAdapter() - Flat to tree

### Provider Examples (`provider_examples.dart`)

- [ ] cartProviders() - Main cart provider
- [ ] cartSelectorProviders() - Items, total, count, isEmpty
- [ ] cartOperations() - Add, update, remove, clear, discount
- [ ] categoryProviders() - Main category provider
- [ ] categoryFamilyProviders() - By ID, slug, type, level
- [ ] categoryOperations() - Set, add, update, remove, select
- [ ] cartMixinUsage() - Using CartMixin in widgets

### Widget Examples (`widget_examples.dart`)

#### Cart Widgets:

- [ ] cartBadgeWidget() - Badge on any widget
- [ ] cartIconButton() - Pre-built cart icon
- [ ] quantitySelectorWidget() - Quantity input
- [ ] cartItemWidget() - Cart item display
- [ ] cartSummaryWidget() - Order summary
- [ ] addToCartButton() - Add to cart button
- [ ] priceDisplayWidget() - Price with sale price

#### Product Option Widgets:

- [ ] variantSelectorWidget() - Button-style selection
- [ ] radioOptionSelector() - Radio-button style
- [ ] optionSelectorWidget() - Checkbox-style
- [ ] colorSwatchSelector() - Color swatches

#### Category Widgets:

- [ ] categoryCard() - Category card with image
- [ ] categoryChip() - Compact category chip
- [ ] categoryList() - Horizontal scrollable list
- [ ] categoryGrid() - Grid layout
- [ ] categoryTreeView() - Expandable tree
- [ ] categoryBreadcrumbWidget() - Breadcrumb navigation
- [ ] categoryDropdown() - Dropdown selector
- [ ] categoryListView() - Auto-connected to providers

### Configuration Examples (`configuration_examples.dart`)

- [ ] cartConfig() - Cart configuration options
- [ ] commerceConfig() - Commerce configuration
- [ ] initializeConfiguration() - Initializing in main()
- [ ] accessConfigAnywhere() - Accessing config
- [ ] priceFormatting() - Format prices with config
- [ ] taxCalculation() - Calculate tax with config

### Integration Examples (`integration_examples.dart`)

- [ ] productDetailPage() - Complete product detail page
- [ ] cartPage() - Complete cart page
- [ ] customApiIntegration() - Custom API service
- [ ] categoryManagementPage() - Category management
- [ ] checkoutFlow() - Checkout flow
- [ ] discountApplicationFlow() - Discount application

---

## 🚀 Running Examples

### Individual Example File

```dart
import 'package:commerce_kit/example/money_examples.dart';

void main() {
  MoneyExamples.runAll();
}
```

### All Examples

```dart
import 'package:commerce_kit/example/commerce_kit_examples.dart';

void main() {
  runAllExamples();
}
```

### In a Flutter App

```dart
import 'package:flutter/material.dart';
import 'package:commerce_kit/example/money_examples.dart';

class ExamplesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Commerce Kit Examples')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Money Examples'),
            onTap: () => MoneyExamples.runAll(),
          ),
          ListTile(
            title: Text('Product Examples'),
            onTap: () => ProductExamples.runAll(),
          ),
          // ... more examples
        ],
      ),
    );
  }
}
```

---

## 🎯 Implementation Tips

1. **Follow the Template**: Use the provided template for consistency
2. **Use Print Statements**: Show results clearly with print()
3. **Add Comments**: Explain each step with comments
4. **Test Each Example**: Ensure examples run without errors
5. **Use Realistic Data**: Use burger restaurant theme where appropriate
6. **Show Output**: Include expected output in comments
7. **Handle Edge Cases**: Show how to handle errors and edge cases

---

## 📊 Progress Tracking

Use this checklist to track implementation progress:

```
Total Examples: 12 files
Completed: 0
Remaining: 12
Progress: 0%
```

---

## 🤝 Next Steps

1. **Review the Plans**: Read through all example plans
2. **Choose Implementation Order**: Decide which to implement first
3. **Implement One at a Time**: Complete each file before moving to the next
4. **Test Thoroughly**: Run each example to verify it works
5. **Document Any Issues**: Note any problems encountered

---

## 📚 Related Documentation

- [Commerce Kit README](../README.md) - Main documentation
- [EXAMPLES_PLAN.md](EXAMPLES_PLAN.md) - Complete example plan
- [MONEY_EXAMPLES.md](MONEY_EXAMPLES.md) - Money examples detail
- [PRODUCT_EXAMPLES.md](PRODUCT_EXAMPLES.md) - Product examples detail
- [README.md](README.md) - Examples directory documentation

---

**Ready to implement? Switch to Code mode to start creating the example files!**
