# Money Class Locale-Aware Formatting

## Overview

The `Money` class has been updated to support locale-aware currency symbol display. Now when the app language is Arabic, currency symbols like "ج.م" will be displayed, and when the language is English, currency codes like "EGP" will be displayed.

## Changes Made

### 1. Updated `_getCurrencySymbol` Method

The method now accepts an optional `Locale` parameter:

```dart
static String _getCurrencySymbol(String currency, {Locale? locale}) {
  // If locale is provided and is Arabic, return Arabic symbols
  if (locale != null && locale.languageCode == 'ar') {
    const arabicSymbols = {
      'EGP': 'ج.م',
      'USD': '\$',
      'EUR': '€',
      // ... other currencies
    };
    return arabicSymbols[currency] ?? currency;
  }
  
  // Default behavior for English or when no locale is specified
  // Return currency code instead of symbol
  return currency;
}
```

### 2. Added New Method `formattedWithSymbolForLocale`

```dart
String formattedWithSymbolForLocale(Locale locale) {
  final symbol = _getCurrencySymbol(currency, locale: locale);
  return '$formattedAmount $symbol';
}
```

### 3. Created Riverpod Extension

Added `MoneyRiverpodExtension` in `/packages/commerce_kit/core/extensions/money_riverpod_extension.dart`:

```dart
extension MoneyRiverpodExtension on Money {
  String formattedWithLocale(WidgetRef ref) {
    final locale = ref.watch(currentLocaleProvider);
    return formattedWithSymbolForLocale(locale);
  }

  String formattedWithContext(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return formattedWithSymbolForLocale(locale);
  }
}
```

## Usage Examples

### In a Widget with Riverpod

```dart
class PriceWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const price = Money(99.99, currency: 'EGP');
    
    // Shows "99.99 ج.م" in Arabic, "99.99 EGP" in English
    return Text(price.formattedWithLocale(ref));
  }
}
```

### Using Build Context

```dart
class PriceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const price = Money(99.99, currency: 'EGP');
    
    // Shows "99.99 ج.م" in Arabic, "99.99 EGP" in English
    return Text(price.formattedWithContext(context));
  }
}
```

### Manual Locale Specification

```dart
const price = Money(99.99, currency: 'EGP');

// Force Arabic display
print(price.formattedWithSymbolForLocale(const Locale('ar'))); // "99.99 ج.م"

// Force English display  
print(price.formattedWithSymbolForLocale(const Locale('en'))); // "99.99 EGP"
```

## Behavior

- **Arabic Locale (`ar`)**: Shows Arabic currency symbols (ج.م, ر.س, د.إ, etc.)
- **English Locale (`en`) or Default**: Shows ISO currency codes (EGP, SAR, AED, etc.)
- **Backward Compatibility**: Existing `formattedWithSymbol` property continues to work but now defaults to currency codes

## Migration Guide

To update existing code to use the new locale-aware formatting:

### Before
```dart
Text(price.formattedWithSymbol)
```

### After (Riverpod)
```dart
Text(price.formattedWithLocale(ref))
```

### After (Context)
```dart
Text(price.formattedWithContext(context))
```

## Supported Currencies

The following currencies have Arabic symbols defined:

- EGP: ج.م
- USD: $
- EUR: €
- GBP: £
- SAR: ر.س
- AED: د.إ
- KWD: د.ك
- QAR: ر.ق
- BHD: د.ب
- OMR: ر.ع
- JOD: د.أ
- LBP: ل.ل
- MAD: د.م
- TND: د.ت
- DZD: د.ج
- IQD: د.ع
- SYP: ل.س
- YER: ر.ي
- SDG: ج.س
- LYD: د.ل

For any other currency, the currency code will be displayed as fallback.
