/// # Money Examples
///
/// This file contains examples demonstrating how to use Money class
/// in the Commerce Kit package.
// ignore_for_file: avoid_print

library;

import '../commerce_kit.dart';

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

    print(
      '\n════════════════════════════════════════════════════════════════\n',
    );
  }

  static void basicCreation() {
    print('\n▶ Example 1: Creating Money Instances');
    print('─' * 60);

    // Create money with default currency (EGP)
    const price1 = Money(12.99);
    print('Price 1: $price1');

    // Create money with specific currency
    const price2 = Money(29.99, currency: 'USD');
    print('Price 2: $price2');

    // Create money from integer (cents)
    final price3 = Money.fromCents(1299, currency: 'USD');
    print('Price 3 (from cents): $price3');

    // Zero money
    const zero = Money.zero();
    print('Zero: $zero');
  }

  static void arithmeticOperations() {
    print('\n▶ Example 2: Arithmetic Operations');
    print('─' * 60);

    const price = Money(29.99, currency: 'USD');
    const discount = Money(5.00, currency: 'USD');

    // Addition
    final sum = price + discount;
    print('Addition: $price + $discount = $sum');

    // Subtraction
    final difference = price - discount;
    print('Subtraction: $price - $discount = $difference');

    // Multiplication
    final doubled = price * 2;
    print('Multiplication: $price * 2 = $doubled');

    // Division
    final split = price / 3;
    print('Division: $price / 3 = $split');

    // Negation
    final negated = -price;
    print('Negation: -$price = $negated');

    // Absolute value
    const negative = Money(-10.00, currency: 'USD');
    print('Absolute: $negative.abs() = $negative.abs()');

    // Percentage calculation
    final percentage = price.percentage(20);
    print('Percentage (20% of $price): $percentage');

    // With percentage off
    final discounted = price.withPercentageOff(20);
    print('With 20% off: $price.withPercentageOff(20) = $discounted');

    // Rounding
    final rounded = price.roundTo(1);
    print('Rounded to 1 decimal: $price.roundTo(1) = $rounded');
  }

  static void comparisonOperations() {
    print('\n▶ Example 3: Comparison Operations');
    print('─' * 60);

    const price1 = Money(29.99, currency: 'USD');
    const price2 = Money(19.99, currency: 'USD');
    const price3 = Money(29.99, currency: 'USD');

    // Greater than
    print('$price1 > $price2: ${price1 > price2}');
    print('$price2 > $price1: ${price2 > price1}');

    // Less than
    print('$price1 < $price2: ${price1 < price2}');
    print('$price2 < $price1: ${price2 < price1}');

    // Greater than or equal
    print('$price1 >= $price3: ${price1 >= price3}');
    print('$price2 >= $price1: ${price2 >= price1}');

    // Less than or equal
    print('$price1 <= $price3: ${price1 <= price3}');
    print('$price1 <= $price2: ${price1 <= price2}');

    // Equality
    print('$price1 == $price3: ${price1 == price3}');
    print('$price1 == $price2: ${price1 == price2}');

    // Is zero
    print('$price1.isZero: ${price1.isZero}');
    print('${const Money.zero().isZero}: ${const Money.zero().isZero}');

    // Is negative
    print('$price1.isNegative: ${price1.isNegative}');
    print(
      '${const Money(-5.00, currency: 'USD').isNegative}: ${const Money(-5.00, currency: 'USD').isNegative}',
    );

    // Is positive
    print('$price1.isPositive: ${price1.isPositive}');
  }

  static void formatting() {
    print('\n▶ Example 4: Money Formatting');
    print('─' * 60);

    const price = Money(1299.99, currency: 'USD');

    // Standard formatted
    print('Formatted: ${price.formatted}');

    // Formatted with symbol
    print('Formatted with symbol: ${price.formattedWithSymbol}');

    // Compact formatted
    print('Compact: ${price.compact}');

    // Formatted amount only
    print('Formatted amount: ${price.formattedAmount}');

    // With specific currency
    const euros = Money(1299.99, currency: 'EUR');
    print('EUR Formatted: ${euros.formatted}');
    print('EUR Formatted with symbol: ${euros.formattedWithSymbol}');

    // Different decimal places
    const price2 = Money(12.5, currency: 'USD');
    print('With 2 decimals: ${price2.formatted}');

    // Large number
    const large = Money(1234567.89, currency: 'USD');
    print('Large number: ${large.formatted}');
    print('Large number compact: ${large.compact}');

    // Very large number
    const huge = Money(1500000, currency: 'USD');
    print('Huge number: ${huge.formatted}');
    print('Huge number compact: ${huge.compact}');
  }

  static void currencyConfiguration() {
    print('\n▶ Example 5: Currency Configuration');
    print('─' * 60);

    // USD
    const usd = Money(99.99, currency: 'USD');
    print('USD: ${usd.formatted}');
    print('USD with symbol: ${usd.formattedWithSymbol}');

    // EUR
    const eur = Money(99.99, currency: 'EUR');
    print('EUR: ${eur.formatted}');
    print('EUR with symbol: ${eur.formattedWithSymbol}');

    // GBP
    const gbp = Money(99.99, currency: 'GBP');
    print('GBP: ${gbp.formatted}');
    print('GBP with symbol: ${gbp.formattedWithSymbol}');

    // JPY (no decimals)
    const jpy = Money(1000, currency: 'JPY');
    print('JPY: ${jpy.formatted}');
    print('JPY with symbol: ${jpy.formattedWithSymbol}');

    // EGP (Egyptian Pound)
    const egp = Money(99.99);
    print('EGP: ${egp.formatted}');
    print('EGP with symbol: ${egp.formattedWithSymbol}');

    // SAR (Saudi Riyal)
    const sar = Money(99.99, currency: 'SAR');
    print('SAR: ${sar.formatted}');
    print('SAR with symbol: ${sar.formattedWithSymbol}');
  }

  static void zeroAndChecks() {
    print('\n▶ Example 6: Zero and Checks');
    print('─' * 60);

    // Zero money
    const zero = Money.zero();
    print('Zero: $zero');
    print('Is Zero: ${zero.isZero}');

    // Positive money
    const positive = Money(10.00, currency: 'USD');
    print('Positive: $positive');
    print('Is Positive: ${positive.isPositive}');
    print('Is Zero: ${positive.isZero}');

    // Negative money
    const negative = Money(-10.00, currency: 'USD');
    print('Negative: $negative');
    print('Is Negative: ${negative.isNegative}');

    // Check if money is zero using comparison
    print('$positive == Money.zero(): ${positive == const Money.zero()}');
    print('$zero == Money.zero(): ${zero == const Money.zero()}');

    // Absolute value of negative
    print('Absolute of negative: ${negative.abs}');
  }

  static void edgeCases() {
    print('\n▶ Example 7: Edge Cases');
    print('─' * 60);

    // Very small number
    const tiny = Money(0.01, currency: 'USD');
    print('Tiny: ${tiny.formatted}');

    // Very large number
    const huge = Money(999999999.99, currency: 'USD');
    print('Huge: ${huge.formatted}');
    print('Huge compact: ${huge.compact}');

    // Division resulting in many decimals
    final result = const Money(10, currency: 'USD') / 3;
    print('10 / 3: ${result.formatted} (rounded)');

    // Multiplication by zero
    final zeroProduct = const Money(100.00, currency: 'USD') * 0;
    print('100 * 0: ${zeroProduct.formatted}');

    // From cents
    final fromCents = Money.fromCents(1299, currency: 'USD');
    print('From 1299 cents: ${fromCents.formatted}');

    // To cents
    const price = Money(12.99, currency: 'USD');
    print('To cents: ${price.cents}');

    // Copy with new values
    final copied = price.copyWith(amount: 20.00);
    print('Copy with new amount: ${copied.formatted}');

    final copied2 = price.copyWith(currency: 'EUR');
    print('Copy with new currency: ${copied2.formatted}');
  }

  static void burgerPricing() {
    print('\n▶ Example 8: Practical Use Case - Burger Pricing');
    print('─' * 60);

    // Burger prices
    const classicBurger = Money(12.99);
    const cheeseBurger = Money(14.99);
    const baconBurger = Money(16.99);

    print('Classic Burger: ${classicBurger.formatted}');
    print('Cheese Burger: ${cheeseBurger.formatted}');
    print('Bacon Burger: ${baconBurger.formatted}');

    // Calculate total for order
    final orderTotal = classicBurger + cheeseBurger + baconBurger;
    print('\nOrder Total: ${orderTotal.formatted}');

    // Apply discount
    final discountedTotal = orderTotal.withPercentageOff(10);
    print('Discount (10%): ${discountedTotal.formatted}');
    print('Savings: ${(orderTotal - discountedTotal).formatted}');

    // Add tax (14% - Egyptian VAT)
    final tax = orderTotal.percentage(14);
    final totalWithTax = orderTotal + tax;
    print('\nTax (14%): ${tax.formatted}');
    print('Total with Tax: ${totalWithTax.formatted}');

    // Split payment among friends
    const friends = 3;
    final perPerson = totalWithTax / friends;
    print('\nSplit among $friends friends: ${perPerson.formatted} each');
    print('Per person (rounded): ${perPerson.roundTo(2).formatted}');
  }
}
