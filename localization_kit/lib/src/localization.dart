import 'package:flutter/material.dart';

/// Small utility for friendly language names / flag emoji lookup.
///
/// Not exhaustive — the kit doesn't presume which languages your app
/// supports. Override [languageNameOverrides] / [languageFlagOverrides] to
/// provide your own values:
///
/// ```dart
/// Localization.languageNameOverrides['fr'] = 'Français';
/// Localization.languageFlagOverrides['fr'] = '🇫🇷';
/// ```
class Localization {
  Localization._();

  static final Map<String, String> languageNameOverrides = <String, String>{
    'en': 'English',
    'ar': 'العربية',
  };

  static final Map<String, String> languageFlagOverrides = <String, String>{
    'en': '🇺🇸',
    'ar': '🇸🇦',
  };

  /// Returns a friendly display name for [languageCode], falling back to the
  /// ISO code itself if no mapping is registered.
  static String getLanguageName(String languageCode) =>
      languageNameOverrides[languageCode] ?? languageCode;

  /// Returns a flag emoji for [languageCode], falling back to a globe.
  static String getLanguageFlag(String languageCode) =>
      languageFlagOverrides[languageCode] ?? '🌐';
}

/// Helper extension to check RTL status from any [BuildContext].
extension LocalizationContextX on BuildContext {
  /// True if the current locale's language is Arabic.
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  /// True if the ambient [Directionality] is right-to-left.
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
