import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a monetary value with currency support.
///
/// The [Money] class provides a type-safe way to handle monetary values
/// with proper formatting, calculations, and currency support.
///
/// ## Features
///
/// - Immutable value object using Equatable
/// - Currency support with ISO 4217 codes
/// - Proper decimal handling
/// - Arithmetic operations
/// - Formatting utilities
///
/// ## Usage
///
/// ```dart
/// // Create money values
/// final price = Money(99.99, currency: 'EGP');
/// final tax = Money(10);
///
/// // Arithmetic operations
/// final total = price + tax;
/// final discounted = price * 0.8; // 20% off
///
/// // Formatting
/// print(price.formatted); // "99.99 EGP"
/// print(price.formattedWithSymbol); // "99.99 EGP" (English default)
/// print(price.formattedWithSymbolForLocale(Locale('ar'))); // "99.99 ج.م" (Arabic)
/// ```
///
/// ## JSON Serialization
///
/// ```dart
/// final json = money.toJson();
/// // {'amount': 99.99, 'currency': 'EGP'}
///
/// final money = Money.fromJson(json);
/// ```
class Money extends Equatable {
  /// The monetary amount.
  final double amount;

  /// The currency code (ISO 4217).
  final String currency;

  /// Creates a [Money] instance.
  ///
  /// [amount] - The monetary value (defaults to 0).
  /// [currency] - The currency code (defaults to 'EGP').
  const Money(
    this.amount, {
    this.currency = 'EGP',
  });

  /// Creates a zero money value.
  const Money.zero({String currency = 'EGP'}) : this(0, currency: currency);

  /// Creates a [Money] instance from cents/smallest unit.
  ///
  /// Useful when working with payment APIs that use integer amounts.
  ///
  /// ```dart
  /// final price = Money.fromCents(9999); // 99.99
  /// ```
  factory Money.fromCents(int cents, {String currency = 'EGP'}) {
    final decimals = _getCurrencyDecimals(currency);
    return Money(cents / _pow10(decimals), currency: currency);
  }

  /// Creates a [Money] instance from JSON.
  ///
  /// Supports multiple JSON formats:
  /// - `{'amount': 99.99, 'currency': 'EGP'}`
  /// - `{'value': 99.99, 'currency_code': 'EGP'}`
  /// - `{'price': 99.99}`
  factory Money.fromJson(Map<String, dynamic> json) {
    final amount =
        (json['amount'] ?? json['value'] ?? json['price'] ?? json['total'] ?? 0)
            .toDouble();

    final currency = json['currency'] ??
        json['currency_code'] ??
        json['currencyCode'] ??
        'EGP';

    return Money(amount, currency: currency);
  }

  /// Converts this [Money] to JSON.
  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
      };

  /// Returns the amount in cents/smallest unit.
  int get cents {
    final decimals = _getCurrencyDecimals(currency);
    return (amount * _pow10(decimals)).round();
  }

  /// Returns `true` if the amount is zero.
  bool get isZero => amount == 0;

  /// Returns `true` if the amount is positive.
  bool get isPositive => amount > 0;

  /// Returns `true` if the amount is negative.
  bool get isNegative => amount < 0;

  /// Returns the absolute value.
  Money get abs => Money(amount.abs(), currency: currency);

  /// Returns the formatted amount without currency.
  String get formattedAmount {
    final decimals = _getCurrencyDecimals(currency);
    return amount.toStringAsFixed(decimals);
  }

  /// Returns the formatted amount with currency code.
  String get formatted => '$formattedAmount $currency';

  /// Returns the formatted amount with currency symbol.
  String get formattedWithSymbol {
    final symbol = _getCurrencySymbol(currency);
    return '$formattedAmount $symbol';
  }

  /// Returns the formatted amount with currency symbol based on locale.
  String formattedWithSymbolForLocale(Locale locale) {
    final symbol = _getCurrencySymbol(currency, locale: locale);
    return '$formattedAmount $symbol';
  }

  /// Returns a compact formatted string for display.
  ///
  /// ```dart
  /// Money(1500).compact // "1.5K"
  /// Money(1500000).compact // "1.5M"
  /// ```
  String get compact {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $currency';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $currency';
    }
    return formatted;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Arithmetic Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Adds two money values.
  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(amount + other.amount, currency: currency);
  }

  /// Subtracts two money values.
  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(amount - other.amount, currency: currency);
  }

  /// Multiplies by a factor.
  Money operator *(num factor) {
    return Money(amount * factor, currency: currency);
  }

  /// Divides by a factor.
  Money operator /(num factor) {
    return Money(amount / factor, currency: currency);
  }

  /// Compares two money values.
  bool operator <(Money other) {
    _assertSameCurrency(other);
    return amount < other.amount;
  }

  /// Compares two money values.
  bool operator <=(Money other) {
    _assertSameCurrency(other);
    return amount <= other.amount;
  }

  /// Compares two money values.
  bool operator >(Money other) {
    _assertSameCurrency(other);
    return amount > other.amount;
  }

  /// Compares two money values.
  bool operator >=(Money other) {
    _assertSameCurrency(other);
    return amount >= other.amount;
  }

  /// Returns the negation of this value.
  Money operator -() => Money(-amount, currency: currency);

  // ─────────────────────────────────────────────────────────────────────────
  // Utility Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns a new [Money] with the percentage applied.
  ///
  /// ```dart
  /// final price = Money(100);
  /// final discount = price.percentage(20); // Money(20)
  /// ```
  Money percentage(double percent) {
    return Money(amount * percent / 100, currency: currency);
  }

  /// Returns this value with a percentage discount applied.
  ///
  /// ```dart
  /// final price = Money(100);
  /// final discounted = price.withPercentageOff(20); // Money(80)
  /// ```
  Money withPercentageOff(double percent) {
    return Money(amount * (1 - percent / 100), currency: currency);
  }

  /// Returns a new [Money] rounded to the nearest value.
  ///
  /// ```dart
  /// final price = Money(99.99);
  /// final rounded = price.roundTo(1); // Money(100)
  /// ```
  Money roundTo(int decimals) {
    final factor = _pow10(decimals);
    return Money((amount * factor).round() / factor, currency: currency);
  }

  /// Copies this [Money] with optional new values.
  Money copyWith({
    double? amount,
    String? currency,
  }) {
    return Money(
      amount ?? this.amount,
      currency: currency ?? this.currency,
    );
  }

  void _assertSameCurrency(Money other) {
    assert(
      currency == other.currency,
      'Cannot perform operation on different currencies: $currency vs ${other.currency}',
    );
  }

  static int _getCurrencyDecimals(String currency) {
    const noDecimals = ['JPY', 'KRW', 'VND'];
    const threeDecimals = ['BHD', 'KWD', 'OMR'];

    if (noDecimals.contains(currency)) return 0;
    if (threeDecimals.contains(currency)) return 3;
    return 2;
  }

  static String _getCurrencySymbol(String currency, {Locale? locale}) {
    // If locale is provided and is Arabic, return Arabic symbols
    if (locale != null && locale.languageCode == 'ar') {
      const arabicSymbols = {
        'EGP': 'ج.م',
        'USD': '\$',
        'EUR': '€',
        'GBP': '£',
        'SAR': 'ر.س',
        'AED': 'د.إ',
        'KWD': 'د.ك',
        'QAR': 'ر.ق',
        'BHD': 'د.ب',
        'OMR': 'ر.ع',
        'JOD': 'د.أ',
        'LBP': 'ل.ل',
        'MAD': 'د.م',
        'TND': 'د.ت',
        'DZD': 'د.ج',
        'IQD': 'د.ع',
        'SYP': 'ل.س',
        'YER': 'ر.ي',
        'SDG': 'ج.س',
        'LYD': 'د.ل',
      };
      return arabicSymbols[currency] ?? currency;
    }

    // Default behavior for English or when no locale is specified
    // Return currency code instead of symbol
    return currency;
  }

  static double _pow10(int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }

  @override
  List<Object?> get props => [amount, currency];

  @override
  String toString() => formatted;
}
