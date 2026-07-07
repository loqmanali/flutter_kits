# Product Examples - Detailed Plan

This document provides detailed examples for the Product model in Commerce Kit.

## Overview

The `Product` class supports multiple product types: simple, variable, configurable, and bundle. Each type serves different use cases in an e-commerce application.

---

## Example 1: Simple Product

```dart
static void simpleProduct() {
  print('\n▶ Example 1: Simple Product');
  print('─' * 60);

  final burger = Product(
    id: 'burger-001',
    name: 'Classic Burger',
    description: 'Juicy beef patty with fresh lettuce, tomato, and special sauce',
    price: Money(12.99),
    type: ProductType.simple,
    sku: 'BUR-001',
    stockStatus: StockStatus.inStock,
    stockQuantity: 50,
    images: [
      ProductImage(
        url: 'https://example.com/burger.jpg',
        isPrimary: true,
        alt: 'Classic Burger',
      ),
    ],
    categories: ['burgers'],
    tags: ['beef', 'classic', 'popular'],
  );

  print('Product ID: ${burger.id}');
  print('Name: ${burger.name}');
  print('Price: ${burger.price.formatted}');
  print('Type: ${burger.type}');
  print('SKU: ${burger.sku}');
  print('Stock Status: ${burger.stockStatus}');
  print('Stock Quantity: ${burger.stockQuantity}');
  print('Is In Stock: ${burger.isInStock}');
  print('Categories: ${burger.categories}');
  print('Tags: ${burger.tags}');
}
```

**Output:**

```
Product ID: burger-001
Name: Classic Burger
Price: $12.99
Type: ProductType.simple
SKU: BUR-001
Stock Status: StockStatus.inStock
Stock Quantity: 50
Is In Stock: true
Categories: [burgers]
Tags: [beef, classic, popular]
```

---

## Example 2: Variable Product (with Variants)

```dart
static void variableProduct() {
  print('\n▶ Example 2: Variable Product with Variants');
  print('─' * 60);

  final tshirt = Product(
    id: 'tshirt-001',
    name: 'Burger Republic T-Shirt',
    description: 'Official Burger Republic cotton t-shirt',
    price: Money(24.99),
    type: ProductType.variable,
    sku: 'TS-BR-001',
    stockStatus: StockStatus.inStock,
    variants: [
      ProductVariant(
        id: 'var-s-black',
        sku: 'TS-S-BLK',
        price: Money(24.99),
        selectedOptions: {'size': 'S', 'color': 'Black'},
        stockQuantity: 50,
        stockStatus: StockStatus.inStock,
      ),
      ProductVariant(
        id: 'var-m-black',
        sku: 'TS-M-BLK',
        price: Money(24.99),
        selectedOptions: {'size': 'M', 'color': 'Black'},
        stockQuantity: 30,
        stockStatus: StockStatus.inStock,
      ),
      ProductVariant(
        id: 'var-l-black',
        sku: 'TS-L-BLK',
        price: Money(26.99),
        selectedOptions: {'size': 'L', 'color': 'Black'},
        stockQuantity: 20,
        stockStatus: StockStatus.inStock,
      ),
      ProductVariant(
        id: 'var-m-red',
        sku: 'TS-M-RED',
        price: Money(24.99),
        selectedOptions: {'size': 'M', 'color': 'Red'},
        stockQuantity: 25,
        stockStatus: StockStatus.inStock,
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
          ProductOptionValue(id: 'Red', label: 'Red', colorCode: '#FF0000'),
          ProductOptionValue(id: 'Navy', label: 'Navy', colorCode: '#000080'),
        ],
      ),
    ],
    images: [
      ProductImage(url: 'https://example.com/tshirt-black.jpg', isPrimary: true),
      ProductImage(url: 'https://example.com/tshirt-red.jpg'),
    ],
  );

  print('Product: ${tshirt.name}');
  print('Base Price: ${tshirt.price.formatted}');
  print('Variants: ${tshirt.variants.length}');
  print('Options: ${tshirt.options.length}');

  print('\nVariants:');
  for (final variant in tshirt.variants) {
    print('  - ${variant.sku}: ${variant.price.formatted} (${variant.optionsSummary})');
  }
}
```

**Output:**

```
Product: Burger Republic T-Shirt
Base Price: $24.99
Variants: 4
Options: 2

Variants:
  - TS-S-BLK: $24.99 (S / Black)
  - TS-M-BLK: $24.99 (M / Black)
  - TS-L-BLK: $26.99 (L / Black)
  - TS-M-RED: $24.99 (M / Red)
```

---

## Example 3: Configurable Product (with Options)

```dart
static void configurableProduct() {
  print('\n▶ Example 3: Configurable Product with Options');
  print('─' * 60);

  final pizza = Product(
    id: 'pizza-001',
    name: 'Margherita Pizza',
    description: 'Classic Italian pizza with fresh mozzarella and basil',
    price: Money(14.99),
    type: ProductType.configurable,
    sku: 'PIZ-MAR-001',
    stockStatus: StockStatus.inStock,
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
        id: 'crust',
        name: 'Crust Type',
        type: VariantType.custom,
        isRequired: true,
        values: [
          ProductOptionValue(id: 'thin', label: 'Thin Crust'),
          ProductOptionValue(id: 'thick', label: 'Thick Crust', priceModifier: Money(1.00)),
          ProductOptionValue(id: 'stuffed', label: 'Stuffed Crust', priceModifier: Money(2.50)),
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
          ProductOptionValue(id: 'onions', label: 'Onions', priceModifier: Money(0.75)),
        ],
      ),
    ],
    images: [
      ProductImage(url: 'https://example.com/pizza.jpg', isPrimary: true),
    ],
  );

  print('Product: ${pizza.name}');
  print('Base Price: ${pizza.price.formatted}');
  print('Options: ${pizza.options.length}');

  print('\nOptions:');
  for (final option in pizza.options) {
    print('  ${option.name} (${option.type}): ${option.isRequired ? 'Required' : 'Optional'}');
    for (final value in option.values) {
      final modifier = value.priceModifier.value > 0
          ? ' +${value.priceModifier.formatted}'
          : '';
      print('    - ${value.label}$modifier');
    }
  }
}
```

**Output:**

```
Product: Margherita Pizza
Base Price: $14.99
Options: 3

Options:
  Size (VariantType.size): Required
    - Small (10")
    - Medium (12") +$3.00
    - Large (14") +$6.00
  Crust Type (VariantType.custom): Required
    - Thin Crust
    - Thick Crust +$1.00
    - Stuffed Crust +$2.50
  Extra Toppings (VariantType.custom): Optional
    - Extra Cheese +$1.50
    - Pepperoni +$2.00
    - Mushrooms +$1.00
    - Olives +$1.00
    - Onions +$0.75
```

---

## Example 4: Bundle Product

```dart
static void bundleProduct() {
  print('\n▶ Example 4: Bundle Product');
  print('─' * 60);

  final mealDeal = Product(
    id: 'bundle-001',
    name: 'Family Meal Deal',
    description: 'Perfect for families - 4 burgers, 4 fries, 4 drinks',
    price: Money(49.99),
    compareAtPrice: Money(64.99),
    type: ProductType.bundle,
    sku: 'BND-FAM-001',
    stockStatus: StockStatus.inStock,
    bundleItems: [
      'burger-001',  // Classic Burger x4
      'fries-001',   // Fries x4
      'drink-001',   // Drink x4
    ],
    images: [
      ProductImage(url: 'https://example.com/bundle.jpg', isPrimary: true),
    ],
    tags: ['bundle', 'family', 'deal'],
  );

  print('Product: ${mealDeal.name}');
  print('Price: ${mealDeal.price.formatted}');
  print('Original Price: ${mealDeal.compareAtPrice?.formatted}');
  print('Savings: ${(mealDeal.compareAtPrice! - mealDeal.price).formatted}');
  print('Bundle Items: ${mealDeal.bundleItems.length}');
  print('Is On Sale: ${mealDeal.isOnSale}');
}
```

**Output:**

```
Product: Family Meal Deal
Price: $49.99
Original Price: $64.99
Savings: $15.00
Bundle Items: 3
Is On Sale: true
```

---

## Example 5: Product with Multiple Images

```dart
static void productWithImages() {
  print('\n▶ Example 5: Product with Multiple Images');
  print('─' * 60);

  final burger = Product(
    id: 'burger-002',
    name: 'Double Cheeseburger',
    description: 'Two beef patties with double cheese',
    price: Money(15.99),
    type: ProductType.simple,
    stockStatus: StockStatus.inStock,
    images: [
      ProductImage(
        url: 'https://example.com/burger-front.jpg',
        isPrimary: true,
        alt: 'Double Cheeseburger Front View',
        position: 0,
      ),
      ProductImage(
        url: 'https://example.com/burger-side.jpg',
        isPrimary: false,
        alt: 'Double Cheeseburger Side View',
        position: 1,
      ),
      ProductImage(
        url: 'https://example.com/burger-top.jpg',
        isPrimary: false,
        alt: 'Double Cheeseburger Top View',
        position: 2,
      ),
      ProductImage(
        url: 'https://example.com/burger-ingredients.jpg',
        isPrimary: false,
        alt: 'Double Cheeseburger Ingredients',
        position: 3,
      ),
    ],
  );

  print('Product: ${burger.name}');
  print('Images: ${burger.images.length}');

  print('\nImages:');
  for (final image in burger.images) {
    final primary = image.isPrimary ? ' (Primary)' : '';
    print('  - ${image.alt}$primary');
    print('    URL: ${image.url}');
    print('    Position: ${image.position}');
  }

  print('\nPrimary Image: ${burger.primaryImage?.url}');
}
```

**Output:**

```
Product: Double Cheeseburger
Images: 4

Images:
  - Double Cheeseburger Front View (Primary)
    URL: https://example.com/burger-front.jpg
    Position: 0
  - Double Cheeseburger Side View
    URL: https://example.com/burger-side.jpg
    Position: 1
  - Double Cheeseburger Top View
    URL: https://example.com/burger-top.jpg
    Position: 2
  - Double Cheeseburger Ingredients
    URL: https://example.com/burger-ingredients.jpg
    Position: 3

Primary Image: https://example.com/burger-front.jpg
```

---

## Example 6: Product with Attributes

```dart
static void productWithAttributes() {
  print('\n▶ Example 6: Product with Attributes');
  print('─' * 60);

  final burger = Product(
    id: 'burger-003',
    name: 'Spicy Chicken Burger',
    description: 'Crispy chicken with spicy sauce',
    price: Money(13.99),
    type: ProductType.simple,
    stockStatus: StockStatus.inStock,
    attributes: [
      ProductAttribute(
        id: 'calories',
        name: 'Calories',
        value: '650',
        visible: true,
      ),
      ProductAttribute(
        id: 'protein',
        name: 'Protein',
        value: '35g',
        visible: true,
      ),
      ProductAttribute(
        id: 'allergens',
        name: 'Allergens',
        value: 'Gluten, Dairy, Eggs',
        visible: true,
      ),
      ProductAttribute(
        id: 'cooking-time',
        name: 'Cooking Time',
        value: '12 minutes',
        visible: false,
      ),
    ],
  );

  print('Product: ${burger.name}');
  print('Attributes: ${burger.attributes.length}');

  print('\nVisible Attributes:');
  for (final attr in burger.visibleAttributes) {
    print('  ${attr.name}: ${attr.value}');
  }

  print('\nAll Attributes:');
  for (final attr in burger.attributes) {
    final visible = attr.visible ? ' (Visible)' : ' (Hidden)';
    print('  ${attr.name}: ${attr.value}$visible');
  }
}
```

**Output:**

```
Product: Spicy Chicken Burger
Attributes: 4

Visible Attributes:
  Calories: 650
  Protein: 35g
  Allergens: Gluten, Dairy, Eggs

All Attributes:
  Calories: 650 (Visible)
  Protein: 35g (Visible)
  Allergens: Gluten, Dairy, Eggs (Visible)
  Cooking Time: 12 minutes (Hidden)
```

---

## Example 7: Product with Tags and Metadata

```dart
static void productWithTags() {
  print('\n▶ Example 7: Product with Tags and Metadata');
  print('─' * 60);

  final burger = Product(
    id: 'burger-004',
    name: 'Veggie Burger',
    description: 'Delicious plant-based burger',
    price: Money(14.99),
    type: ProductType.simple,
    stockStatus: StockStatus.inStock,
    tags: ['vegetarian', 'vegan', 'healthy', 'plant-based'],
    metadata: {
      'is_vegan': true,
      'is_vegetarian': true,
      'is_gluten_free': false,
      'spiciness': 'mild',
      'preparation_time': 10,
      'chef_recommendation': true,
    },
  );

  print('Product: ${burger.name}');
  print('Tags: ${burger.tags}');

  print('\nMetadata:');
  burger.metadata.forEach((key, value) {
    print('  $key: $value');
  });

  print('\nIs Vegan: ${burger.metadata['is_vegan']}');
  print('Is Vegetarian: ${burger.metadata['is_vegetarian']}');
  print('Is Chef Recommendation: ${burger.metadata['chef_recommendation']}');
}
```

**Output:**

```
Product: Veggie Burger
Tags: [vegetarian, vegan, healthy, plant-based]

Metadata:
  is_vegan: true
  is_vegetarian: true
  is_gluten_free: false
  spiciness: mild
  preparation_time: 10
  chef_recommendation: true

Is Vegan: true
Is Vegetarian: true
Is Chef Recommendation: true
```

---

## Example 8: Product Extensions

```dart
static void productExtensions() {
  print('\n▶ Example 8: Product Extensions');
  print('─' * 60);

  final burger = Product(
    id: 'burger-005',
    name: 'Gourmet Burger',
    description: 'Premium beef with truffle sauce',
    price: Money(18.99),
    compareAtPrice: Money(22.99),
    type: ProductType.simple,
    stockStatus: StockStatus.inStock,
    stockQuantity: 15,
    images: [
      ProductImage(url: 'https://example.com/burger.jpg', isPrimary: true),
    ],
    tags: ['premium', 'gourmet', 'truffle'],
  );

  print('Product: ${burger.name}');

  // Stock status checks
  print('\nStock Status:');
  print('  Is In Stock: ${burger.isInStock}');
  print('  Is Out of Stock: ${burger.isOutOfStock}');
  print('  Is Low Stock: ${burger.isLowStock}');
  print('  Stock Quantity: ${burger.stockQuantity}');

  // Price checks
  print('\nPrice:');
  print('  Price: ${burger.price.formatted}');
  print('  Compare At Price: ${burger.compareAtPrice?.formatted}');
  print('  Is On Sale: ${burger.isOnSale}');
  print('  Discount Amount: ${burger.discountAmount?.formatted}');
  print('  Discount Percentage: ${burger.discountPercentage?.toStringAsFixed(0)}%');

  // Image checks
  print('\nImages:');
  print('  Has Images: ${burger.hasImages}');
  print('  Image Count: ${burger.images.length}');
  print('  Primary Image: ${burger.primaryImage?.url}');

  // Tag checks
  print('\nTags:');
  print('  Has Tags: ${burger.hasTags}');
  print('  Tags: ${burger.tags}');
  print('  Has Tag "premium": ${burger.hasTag("premium")}');
  print('  Has Tag "spicy": ${burger.hasTag("spicy")}');

  // Type checks
  print('\nType:');
  print('  Product Type: ${burger.type}');
  print('  Is Simple: ${burger.isSimple}');
  print('  Is Variable: ${burger.isVariable}');
  print('  Is Configurable: ${burger.isConfigurable}');
  print('  Is Bundle: ${burger.isBundle}');
}
```

**Output:**

```
Product: Gourmet Burger

Stock Status:
  Is In Stock: true
  Is Out of Stock: false
  Is Low Stock: false
  Stock Quantity: 15

Price:
  Price: $18.99
  Compare At Price: $22.99
  Is On Sale: true
  Discount Amount: $4.00
  Discount Percentage: 17%

Images:
  Has Images: true
  Image Count: 1
  Primary Image: https://example.com/burger.jpg

Tags:
  Has Tags: true
  Tags: [premium, gourmet, truffle]
  Has Tag "premium": true
  Has Tag "spicy": false

Type:
  Product Type: ProductType.simple
  Is Simple: true
  Is Variable: false
  Is Configurable: false
  Is Bundle: false
```

---

## Example 9: Digital Product

```dart
static void digitalProduct() {
  print('\n▶ Example 9: Digital Product');
  print('─' * 60);

  final giftCard = Product(
    id: 'giftcard-001',
    name: 'Burger Republic Gift Card',
    description: 'Digital gift card for Burger Republic',
    price: Money(25.00),
    type: ProductType.digital,
    sku: 'GC-25-001',
    stockStatus: StockStatus.inStock,
    metadata: {
      'is_digital': true,
      'delivery_method': 'email',
      'validity_days': 365,
    },
    images: [
      ProductImage(url: 'https://example.com/giftcard.jpg', isPrimary: true),
    ],
  );

  print('Product: ${giftCard.name}');
  print('Type: ${giftCard.type}');
  print('Price: ${giftCard.price.formatted}');
  print('Is Digital: ${giftCard.isDigital}');
  print('Delivery Method: ${giftCard.metadata['delivery_method']}');
  print('Validity: ${giftCard.metadata['validity_days']} days');
}
```

**Output:**

```
Product: Burger Republic Gift Card
Type: ProductType.digital
Price: $25.00
Is Digital: true
Delivery Method: email
Validity: 365 days
```

---

## Example 10: Service Product

```dart
static void serviceProduct() {
  print('\n▶ Example 10: Service Product');
  print('─' * 60);

  final catering = Product(
    id: 'service-001',
    name: 'Catering Service',
    description: 'Full catering service for events',
    price: Money(199.99),
    type: ProductType.service,
    sku: 'SRV-CAT-001',
    stockStatus: StockStatus.inStock,
    metadata: {
      'service_type': 'catering',
      'min_guests': 10,
      'max_guests': 100,
      'advance_booking_days': 3,
    },
  );

  print('Product: ${catering.name}');
  print('Type: ${catering.type}');
  print('Price: ${catering.price.formatted}');
  print('Is Service: ${catering.isService}');
  print('Min Guests: ${catering.metadata['min_guests']}');
  print('Max Guests: ${catering.metadata['max_guests']}');
  print('Advance Booking: ${catering.metadata['advance_booking_days']} days');
}
```

**Output:**

```
Product: Catering Service
Type: ProductType.service
Price: $199.99
Is Service: true
Min Guests: 10
Max Guests: 100
Advance Booking: 3 days
```

---

## Complete Example File Structure

```dart
/// # Product Examples
///
/// This file contains examples demonstrating how to use Product model
/// in the Commerce Kit package.
library;

import 'package:commerce_kit/commerce_kit.dart';

class ProductExamples {
  /// Run all product examples
  static void runAll() {
    print('════════════════════════════════════════════════════════════════');
    print('PRODUCT EXAMPLES');
    print('════════════════════════════════════════════════════════════════\n');

    simpleProduct();
    variableProduct();
    configurableProduct();
    bundleProduct();
    productWithImages();
    productWithAttributes();
    productWithTags();
    productExtensions();
    digitalProduct();
    serviceProduct();

    print('\n════════════════════════════════════════════════════════════════\n');
  }

  static void simpleProduct() {
    // ... implementation
  }

  static void variableProduct() {
    // ... implementation
  }

  // ... more examples
}
```

---

## Key Points

1. **Product Types**: Simple, Variable, Configurable, Bundle, Digital, Service
2. **Variants**: For products with different size/color combinations
3. **Options**: For configurable products with add-ons
4. **Images**: Support for multiple images with primary designation
5. **Attributes**: Custom product properties (calories, allergens, etc.)
6. **Tags**: For categorization and filtering
7. **Metadata**: Flexible key-value pairs for custom data
8. **Stock Management**: Stock status and quantity tracking
9. **Pricing**: Regular price, compare-at price for sales
10. **Extensions**: Helper methods for common checks (isInStock, isOnSale, etc.)
