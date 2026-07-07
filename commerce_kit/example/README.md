# Commerce Kit Examples

This directory contains comprehensive examples demonstrating all features of the Commerce Kit package.

## 📁 Example Files

| File                                   | Description                        |
| -------------------------------------- | ---------------------------------- |
| [`EXAMPLES_PLAN.md`](EXAMPLES_PLAN.md) | Complete plan for all examples     |
| `money_examples.dart`                  | Money class operations             |
| `product_examples.dart`                | Product model examples (all types) |
| `product_variant_examples.dart`        | Product variant examples           |
| `product_option_examples.dart`         | Product option examples            |
| `category_examples.dart`               | Category examples (hierarchical)   |
| `cart_examples.dart`                   | Cart and cart item examples        |
| `discount_examples.dart`               | Discount examples (all types)      |
| `adapter_examples.dart`                | API adapter examples               |
| `provider_examples.dart`               | Riverpod provider examples         |
| `widget_examples.dart`                 | Widget examples                    |
| `configuration_examples.dart`          | Configuration examples             |
| `integration_examples.dart`            | Complete integration examples      |

## 🚀 Quick Start

### Running All Examples

```dart
import 'package:commerce_kit/example/commerce_kit_examples.dart';

void main() {
  runAllExamples();
}
```

### Running Specific Examples

```dart
// Money examples
import 'package:commerce_kit/example/money_examples.dart';

void main() {
  MoneyExamples.runAll();
}

// Product examples
import 'package:commerce_kit/example/product_examples.dart';

void main() {
  ProductExamples.runAll();
}

// etc.
```

## 📚 Topics Covered

### 1. Money Class

- Creating Money instances
- Arithmetic operations (add, subtract, multiply, divide)
- Comparison operations
- Formatting (formatted, formattedCompact)
- Currency configuration
- Zero and checks
- Edge cases

### 2. Products

- Simple products
- Variable products (with variants)
- Configurable products (with options)
- Bundle products
- Product properties (images, attributes, tags, metadata)
- Product extensions and helpers

### 3. Product Variants

- Creating variants
- Variant with selected options
- Variant pricing (compare at price)
- Variant stock management
- Variant images
- Variant properties

### 4. Product Options

- Single-select required options
- Multi-select optional options
- Color options with color codes
- Size options with price modifiers
- Custom options with max selections
- Option validation

### 5. Categories

- Simple categories
- Categories with images (network, asset, icon, banner)
- Featured categories with badges
- Sale categories with expiration
- Brand categories with logos
- Hierarchical categories (nested)
- Category navigation
- Category extensions

### 6. Cart

- Creating empty cart
- Adding items
- Updating quantities
- Removing items
- Clearing cart
- Applying discounts
- Cart calculations
- Finding items

### 7. Discounts

- Percentage discount
- Fixed amount discount
- Free shipping discount
- Buy one get one (BOGO) discount
- Bulk discount
- Tiered discount
- Discount with expiration
- Discount validation

### 8. API Adapters

- Map-based adapter
- JSON adapter with custom field mapping
- WooCommerce adapter
- Shopify adapter
- Magento adapter
- PrestaShop adapter
- OpenCart adapter
- Custom adapter implementation

### 9. State Management

- Cart providers
- Category providers
- Family providers
- Cart operations with providers
- Category operations with providers
- Using CartMixin

### 10. Widgets

#### Cart Widgets

- CartBadgeWidget
- CartIconButton
- QuantitySelectorWidget
- CartItemWidget
- CartSummaryWidget
- AddToCartButton
- PriceDisplayWidget

#### Product Option Widgets

- VariantSelectorWidget
- RadioOptionSelector
- OptionSelectorWidget
- ColorSwatchSelector

#### Category Widgets

- CategoryCard
- CategoryChip
- CategoryList
- CategoryGrid
- CategoryTreeView
- CategoryBreadcrumbWidget
- CategoryDropdown
- CategoryListView

### 11. Configuration

- CartConfig
- CommerceConfig
- Initializing configuration
- Price formatting
- Tax calculation

### 12. Integration

- Complete product detail page
- Complete cart page
- Custom API integration
- Category management page
- Checkout flow
- Discount application flow

## 🏗️ Architecture

Each example file follows a consistent structure:

```dart
class [FeatureName]Examples {
  /// Run all examples for this feature
  static void runAll() {
    example1();
    example2();
    example3();
    // ... more examples
  }

  static void example1() {
    print('\n▶ Example 1: [Description]');
    print('─' * 60);

    // Example code here
    final result = /* code */;

    print('Result: $result');
  }

  // ... more examples
}
```

## 🎯 Burger Republic Theme

Since this package is being used in the Burger Republic app, many examples use a burger restaurant theme:

- Burgers, pizzas, drinks as products
- Food categories (Burgers, Pizza, Drinks, etc.)
- Restaurant-specific discounts and promotions

## 📝 Example Output Format

When running examples, you'll see output like:

```
════════════════════════════════════════════════════════════════
MONEY EXAMPLES
════════════════════════════════════════════════════════════════

▶ Example 1: Creating Money
────────────────────────────────────────────────────────────────
Result: Money(12.99)

▶ Example 2: Arithmetic Operations
────────────────────────────────────────────────────────────────
Result: Money(24.99)

════════════════════════════════════════════════════════════════
```

## 🔧 Testing Examples

You can test individual examples in a Flutter app or in a Dart script:

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
          // ... more examples
        ],
      ),
    );
  }
}
```

### In a Dart Script

```dart
// examples_runner.dart
import 'package:commerce_kit/example/commerce_kit_examples.dart';

void main() {
  runAllExamples();
}
```

Run with:

```bash
dart run examples_runner.dart
```

## 📖 Additional Resources

- [Commerce Kit README](../README.md) - Main documentation
- [Commerce Kit API Reference](../README.md#api-reference) - API documentation

## 💡 Tips

1. **Start with Money Examples** - Learn the basics first
2. **Follow the Order** - Examples are organized from simple to complex
3. **Run and Experiment** - Modify examples to see different results
4. **Use in Your App** - Copy patterns from examples to your code
5. **Check Integration Examples** - See how everything works together

## 🤝 Contributing

If you find issues with examples or want to add new examples, please:

1. Check the [EXAMPLES_PLAN.md](EXAMPLES_PLAN.md) for the planned structure
2. Follow the example template
3. Ensure examples are self-contained and runnable
4. Add comments explaining each step
5. Test your examples before submitting

---

**Happy Coding! 🍔**
