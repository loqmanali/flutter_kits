# Money Examples - Detailed Plan

This document provides detailed examples for the Money class in Commerce Kit.

## Overview

The `Money` class provides type-safe currency operations with support for multiple currencies, arithmetic operations, comparisons, and formatting.

---

## Example 1: Basic Creation

```dart
static void basicCreation() {
  print('\n▶ Example 1: Creating Money Instances');
  print('─' * 60);

  // Create money with default currency
  final price1 = Money(12.99);
  print('Price 1: $price1'); // Money(12.99)

  // Create money with specific currency
  final price2 = Money(29.99, currency: 'EUR', symbol: '€');
  print('Price 2: $price2'); // Money(29.99, EUR)

  // Create money from integer (cents)
  final price3 = Money.fromCents(1299, currency: 'USD', symbol: '$');
  print('Price 3: $price3'); // Money(12.99)

  // Zero money
  final zero = Money.zero;
  print('Zero: $zero'); // Money(0.00)
}
```

**Output:**

```
Price 1: Money(12.99)
Price 2: Money(29.99, EUR)
Price 3: Money(12.99)
Zero: Money(0.00)
```

---

## Example 2: Arithmetic Operations

```dart
static void arithmeticOperations() {
  print('\n▶ Example 2: Arithmetic Operations');
  print('─' * 60);

  final price = Money(29.99);
  final discount = Money(5.00);

  // Addition
  final sum = price + discount;
  print('Addition: $price + $discount = $sum'); // Money(34.99)

  // Subtraction
  final difference = price - discount;
  print('Subtraction: $price - $discount = $difference'); // Money(24.99)

  // Multiplication
  final doubled = price * 2;
  print('Multiplication: $price * 2 = $doubled'); // Money(59.98)

  // Division
  final split = price / 3;
  print('Division: $price / 3 = $split'); // Money(10.00)

  // Modulo
  final remainder = Money(10.50) % Money(3.00);
  print('Modulo: Money(10.50) % Money(3.00) = $remainder'); // Money(1.50)
}
```

**Output:**

```
Addition: Money(29.99) + Money(5.00) = Money(34.99)
Subtraction: Money(29.99) - Money(5.00) = Money(24.99)
Multiplication: Money(29.99) * 2 = Money(59.98)
Division: Money(29.99) / 3 = Money(10.00)
Modulo: Money(10.50) % Money(3.00) = Money(1.50)
```

---

## Example 3: Comparison Operations

```dart
static void comparisonOperations() {
  print('\n▶ Example 3: Comparison Operations');
  print('─' * 60);

  final price1 = Money(29.99);
  final price2 = Money(19.99);
  final price3 = Money(29.99);

  // Greater than
  print('$price1 > $price2: ${price1 > price2}'); // true
  print('$price2 > $price1: ${price2 > price1}'); // false

  // Less than
  print('$price1 < $price2: ${price1 < price2}'); // false
  print('$price2 < $price1: ${price2 < price1}'); // true

  // Greater than or equal
  print('$price1 >= $price3: ${price1 >= price3}'); // true
  print('$price2 >= $price1: ${price2 >= price1}'); // false

  // Less than or equal
  print('$price1 <= $price3: ${price1 <= price3}'); // true
  print('$price1 <= $price2: ${price1 <= price2}'); // false

  // Equality
  print('$price1 == $price3: ${price1 == price3}'); // true
  print('$price1 == $price2: ${price1 == price2}'); // false

  // Is zero
  print('$price1.isZero: ${price1.isZero}'); // false
  print('${Money.zero}.isZero: ${Money.zero.isZero}'); // true

  // Is negative
  print('$price1.isNegative: ${price1.isNegative}'); // false
  print('${Money(-5.00)}.isNegative: ${Money(-5.00).isNegative}'); // true

  // Is positive
  print('$price1.isPositive: ${price1.isPositive}'); // true
}
```

**Output:**

```
Money(29.99) > Money(19.99): true
Money(19.99) > Money(29.99): false
Money(29.99) < Money(19.99): false
Money(19.99) < Money(29.99): true
Money(29.99) >= Money(29.99): true
Money(19.99) >= Money(29.99): false
Money(29.99) <= Money(29.99): true
Money(29.99) <= Money(19.99): false
Money(29.99) == Money(29.99): true
Money(29.99) == Money(19.99): false
Money(29.99).isZero: false
Money(0.00).isZero: true
Money(29.99).isNegative: false
Money(-5.00).isNegative: true
Money(29.99).isPositive: true
```

---

## Example 4: Formatting

```dart
static void formatting() {
  print('\n▶ Example 4: Money Formatting');
  print('─' * 60);

  final price = Money(1299.99);

  // Standard formatted
  print('Formatted: ${price.formatted}'); // "$1,299.99"

  // Compact formatted
  print('Formatted Compact: ${price.formattedCompact}'); // "$1,300"

  // With specific currency
  final euros = Money(1299.99, currency: 'EUR', symbol: '€');
  print('EUR Formatted: ${euros.formatted}'); // "€1,299.99"

  // Different decimal places
  final price2 = Money(12.5);
  print('With 2 decimals: ${price2.formatted}'); // "$12.50"

  // Large number
  final large = Money(1234567.89);
  print('Large number: ${large.formatted}'); // "$1,234,567.89"
}
```

**Output:**

```
Formatted: $1,299.99
Formatted Compact: $1,300
EUR Formatted: €1,299.99
With 2 decimals: $12.50
Large number: $1,234,567.89
```

---

## Example 5: Currency Configuration

```dart
static void currencyConfiguration() {
  print('\n▶ Example 5: Currency Configuration');
  print('─' * 60);

  // USD
  final usd = Money(99.99, currency: 'USD', symbol: '\$');
  print('USD: ${usd.formatted}'); // "$99.99"

  // EUR
  final eur = Money(99.99, currency: 'EUR', symbol: '€');
  print('EUR: ${eur.formatted}'); // "€99.99"

  // GBP
  final gbp = Money(99.99, currency: 'GBP', symbol: '£');
  print('GBP: ${gbp.formatted}'); // "£99.99"

  // JPY (no decimals)
  final jpy = Money(1000, currency: 'JPY', symbol: '¥', decimalPlaces: 0);
  print('JPY: ${jpy.formatted}'); // "¥1,000"

  // EGP (Egyptian Pound)
  final egp = Money(99.99, currency: 'EGP', symbol: 'E£');
  print('EGP: ${egp.formatted}'); // "E£99.99"
}
```

**Output:**

```
USD: $99.99
EUR: €99.99
GBP: £99.99
JPY: ¥1,000
EGP: E£99.99
```

---

## Example 6: Zero and Checks

```dart
static void zeroAndChecks() {
  print('\n▶ Example 6: Zero and Checks');
  print('─' * 60);

  // Zero money
  final zero = Money.zero;
  print('Zero: $zero');
  print('Is Zero: ${zero.isZero}'); // true

  // Positive money
  final positive = Money(10.00);
  print('Positive: $positive');
  print('Is Positive: ${positive.isPositive}'); // true
  print('Is Zero: ${positive.isZero}'); // false

  // Negative money
  final negative = Money(-10.00);
  print('Negative: $negative');
  print('Is Negative: ${negative.isNegative}'); // true

  // Check if money is zero using comparison
  print('$positive == Money.zero: ${positive == Money.zero}'); // false
  print('$zero == Money.zero: ${zero == Money.zero}'); // true
}
```

**Output:**

```
Zero: Money(0.00)
Is Zero: true
Positive: Money(10.00)
Is Positive: true
Is Zero: false
Negative: Money(-10.00)
Is Negative: true
Money(10.00) == Money.zero: false
Money(0.00) == Money.zero: true
```

---

## Example 7: Edge Cases

```dart
static void edgeCases() {
  print('\n▶ Example 7: Edge Cases');
  print('─' * 60);

  // Very small number
  final tiny = Money(0.01);
  print('Tiny: ${tiny.formatted}'); // "$0.01"

  // Very large number
  final huge = Money(999999999.99);
  print('Huge: ${huge.formatted}'); // "$999,999,999.99"

  // Division resulting in many decimals
  final result = Money(10) / 3;
  print('10 / 3: ${result.formatted}'); // "$3.33" (rounded)

  // Multiplication by zero
  final zeroProduct = Money(100.00) * 0;
  print('100 * 0: ${zeroProduct.formatted}'); // "$0.00"

  // Adding money with different currencies (should handle or throw)
  final usd = Money(10.00, currency: 'USD', symbol: '\$');
  final eur = Money(10.00, currency: 'EUR', symbol: '€');
  // Note: Depending on implementation, this may throw or convert
  print('USD: ${usd.formatted}');
  print('EUR: ${eur.formatted}');

  // From cents
  final fromCents = Money.fromCents(1299, currency: 'USD', symbol: '\$');
  print('From 1299 cents: ${fromCents.formatted}'); // "$12.99"

  // To cents
  final price = Money(12.99);
  print('To cents: ${price.toCents()}'); // 1299
}
```

**Output:**

```
Tiny: $0.01
Huge: $999,999,999.99
10 / 3: $3.33
100 * 0: $0.00
USD: $10.00
EUR: €10.00
From 1299 cents: $12.99
To cents: 1299
```

---

## Example 8: Practical Use Case - Burger Pricing

```dart
static void burgerPricing() {
  print('\n▶ Example 8: Practical Use Case - Burger Pricing');
  print('─' * 60);

  // Burger prices
  final classicBurger = Money(12.99);
  final cheeseBurger = Money(14.99);
  final baconBurger = Money(16.99);

  print('Classic Burger: ${classicBurger.formatted}');
  print('Cheese Burger: ${cheeseBurger.formatted}');
  print('Bacon Burger: ${baconBurger.formatted}');

  // Calculate total for order
  final orderTotal = classicBurger + cheeseBurger + baconBurger;
  print('\nOrder Total: ${orderTotal.formatted}');

  // Apply discount
  final discount = Money(5.00);
  final discountedTotal = orderTotal - discount;
  print('Discount: ${discount.formatted}');
  print('Discounted Total: ${discountedTotal.formatted}');

  // Add tax (8%)
  final taxRate = 0.08;
  final tax = orderTotal * taxRate;
  final totalWithTax = orderTotal + tax;
  print('\nTax (8%): ${tax.formatted}');
  print('Total with Tax: ${totalWithTax.formatted}');

  // Split payment among friends
  final friends = 3;
  final perPerson = totalWithTax / friends;
  print('\nSplit among $friends friends: ${perPerson.formatted} each');
}
```

**Output:**

```
Classic Burger: $12.99
Cheese Burger: $14.99
Bacon Burger: $16.99

Order Total: $44.97
Discount: $5.00
Discounted Total: $39.97

Tax (8%): $3.60
Total with Tax: $48.57

Split among 3 friends: $16.19 each
```

---

## Complete Example File Structure

```dart
/// # Money Examples
///
/// This file contains examples demonstrating how to use the Money class
/// in the Commerce Kit package.
library;

import 'package:commerce_kit/commerce_kit.dart';

class MoneyExamples {
  /// Run all money examples
  static void runAll() {
    print('════════════════════════════════════════════════════════════════');
    print('MONEY EXAMPLES');
    print('════════════════════════════════════════════════════════════════\n');

    basicCreation();
    arithmeticOperations();
    comparisonOperations();
    formatting();
    currencyConfiguration();
    zeroAndChecks();
    edgeCases();
    burgerPricing();

    print('\n════════════════════════════════════════════════════════════════\n');
  }

  static void basicCreation() {
    // ... implementation
  }

  static void arithmeticOperations() {
    // ... implementation
  }

  static void comparisonOperations() {
    // ... implementation
  }

  static void formatting() {
    // ... implementation
  }

  static void currencyConfiguration() {
    // ... implementation
  }

  static void zeroAndChecks() {
    // ... implementation
  }

  static void edgeCases() {
    // ... implementation
  }

  static void burgerPricing() {
    // ... implementation
  }
}
```

---

## Key Points

1. **Type Safety**: Money prevents mixing different currencies accidentally
2. **Precision**: Uses cents internally to avoid floating-point errors
3. **Formatting**: Automatic formatting with currency symbols and separators
4. **Operations**: Full arithmetic support (+, -, \*, /, %)
5. **Comparisons**: All comparison operators available (>, <, >=, <=, ==)
6. **Zero Check**: Convenient `isZero` property for empty values
7. **Currency Support**: Works with any currency symbol and decimal places

---

## Testing

To test these examples:

```dart
void main() {
  MoneyExamples.runAll();
}
```

Expected output should match the examples above.
