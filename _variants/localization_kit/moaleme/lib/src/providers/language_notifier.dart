import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/localization_kit_runtime.dart';
import '../models/language_model.dart';
import '../models/language_state.dart';

/// Riverpod notifier that owns the current language and exposes commands
/// for changing it.
///
/// On creation (via `ref.read(languageProvider)` after configuring
/// [LocalizationKitRuntime]), the notifier:
///
/// 1. Reads the stored locale + API code (falling back to the runtime
///    defaults).
/// 2. Calls the [LocalizationKitRuntime.onLanguageChanged] callback so HTTP
///    clients pick up the language headers.
/// 3. If [LocalizationKitRuntime.api] is set, fetches the live language list
///    in the background.
class LanguageNotifier extends Notifier<LanguageState> {
  @override
  LanguageState build() => const LanguageState();

  /// Load the saved language and (optionally) fetch the remote language list.
  ///
  /// Pass [useLocal] = false to force a remote fetch when the
  /// [LocalizationKitRuntime.api] is configured.
  Future<void> initialize({bool useLocal = true}) async {
    final defaults = LocalizationKitRuntime.defaultLanguages;
    final defaultIso = LocalizationKitRuntime.defaultIsoCode;
    final defaultApi = LocalizationKitRuntime.defaultApiCode;

    try {
      final storage = LocalizationKitRuntime.storage;
      final isoCode = await storage.getLocaleCode() ?? defaultIso;
      final apiCode = await storage.getLanguageCode() ?? defaultApi;

      // Push the language code out to e.g. HTTP headers immediately.
      await LocalizationKitRuntime.onLanguageChanged?.call(apiCode);

      state = state.copyWith(
        locale: Locale(isoCode),
        apiCode: apiCode,
        languages: defaults,
        isLoading: true,
      );

      // Fetch language list in the background — don't block init on it.
      _fetchLanguages(useLocal: useLocal).then((_) {
        state = state.copyWith(isLoading: false);
      }).catchError((Object e) {
        debugPrint('[localization_kit] language fetch error: $e');
        state = state.copyWith(isLoading: false);
      });
    } catch (e, stackTrace) {
      debugPrint('[localization_kit] init error: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        locale: Locale(defaultIso),
        apiCode: defaultApi,
        languages: defaults,
        isLoading: false,
      );
    }
  }

  /// Force-refresh the list of available languages.
  Future<void> fetchLanguages({bool useLocal = false}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _fetchLanguages(useLocal: useLocal);
  }

  Future<void> _fetchLanguages({required bool useLocal}) async {
    try {
      final api = LocalizationKitRuntime.api;
      final List<LanguageModel> languages;
      if (useLocal || api == null) {
        languages = LocalizationKitRuntime.defaultLanguages;
      } else {
        languages = await api.getLanguages();
      }
      state = state.copyWith(languages: languages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Switch the active language. Persists to storage and notifies the
  /// configured header-sync callback.
  Future<void> changeLocale({
    required String isoCode,
    required String apiCode,
  }) async {
    final newLocale = Locale(isoCode);

    final storage = LocalizationKitRuntime.storage;
    await storage.setLocaleCode(isoCode);
    await storage.setLanguageCode(apiCode);

    await LocalizationKitRuntime.onLanguageChanged?.call(apiCode);

    state = state.copyWith(locale: newLocale, apiCode: apiCode);

    if (state.languages.isEmpty) {
      await _fetchLanguages(useLocal: true);
    }
  }

  Locale get currentLocale => state.locale;
  String get currentApiCode => state.apiCode;
}
