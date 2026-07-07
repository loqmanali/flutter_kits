import 'package:flutter/material.dart';
import '../models/money.dart';

/// Extension methods for Money class to work with Flutter localization
extension MoneyLocalizationExtension on Money {
  /// Returns formatted amount with currency symbol based on build context locale
  ///
  /// Usage in a Widget:
  /// ```dart
  /// Text(price.formattedWithContext(context))
  /// ```
  String formattedWithContext(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return formattedWithSymbolForLocale(locale);
  }
}
