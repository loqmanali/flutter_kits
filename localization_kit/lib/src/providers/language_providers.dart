import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/language_model.dart';
import '../models/language_state.dart';
import 'language_notifier.dart';

/// Main provider exposing [LanguageNotifier] + [LanguageState].
final languageProvider =
    NotifierProvider<LanguageNotifier, LanguageState>(LanguageNotifier.new);

// ─── Computed slices ──────────────────────────────────────────────────────

final currentLocaleProvider = Provider<Locale>(
  (ref) => ref.watch(languageProvider).locale,
);

final currentApiCodeProvider = Provider<String>(
  (ref) => ref.watch(languageProvider).apiCode,
);

final isArabicProvider = Provider<bool>(
  (ref) => ref.watch(languageProvider).isArabic,
);

final availableLanguagesProvider = Provider<List<LanguageModel>>(
  (ref) => ref.watch(languageProvider).languages,
);

final languageLoadingProvider = Provider<bool>(
  (ref) => ref.watch(languageProvider).isLoading,
);

final textDirectionProvider = Provider<TextDirection>(
  (ref) => ref.watch(languageProvider).textDirection,
);
