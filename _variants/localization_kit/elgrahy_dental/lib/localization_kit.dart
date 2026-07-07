/// localization_kit
///
/// Project-agnostic localization toolkit for Flutter:
///
/// - Persists the user's chosen language across app launches via a pluggable
///   [LocalizationStorageAdapter] (defaults to in-memory).
/// - Optionally fetches a live list of supported languages from a backend
///   via [LocalizationApi].
/// - Syncs the active language code into HTTP client headers via the
///   [LanguageHeaderSync] callback.
/// - Exposes Riverpod state ([languageProvider], [currentLocaleProvider],
///   [isArabicProvider], …) so widgets can react to changes.
/// - Ships ready-made widgets: [LanguageSelector], [LanguageToggle],
///   [L10nListener].
///
/// **What's not in the box** — and intentionally so — is your generated
/// `AppLocalizations`. Every Flutter app ships its own, generated from its
/// own ARB files via `flutter gen-l10n`. The kit deliberately stays out of
/// that pipeline so it can drop into any project unchanged.
///
/// See `README.md` for the full integration walkthrough.
library;

export 'src/adapters/language_header_sync.dart';
export 'src/adapters/localization_api.dart';
export 'src/adapters/localization_kit_runtime.dart';
export 'src/adapters/localization_storage_adapter.dart';
export 'src/localization.dart';
export 'src/models/language_model.dart';
export 'src/models/language_state.dart';
export 'src/providers/language_notifier.dart';
export 'src/providers/language_providers.dart';
export 'src/widgets/l10n_listener.dart';
export 'src/widgets/language_selector.dart';
