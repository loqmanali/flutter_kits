import '../models/language_model.dart';
import 'language_header_sync.dart';
import 'localization_api.dart';
import 'localization_storage_adapter.dart';

/// Process-wide runtime configuration for localization_kit.
///
/// Configure once near the top of `main()` before reading any provider.
/// All defaults are sensible — for the simplest setup, pass at least
/// [defaultLanguages] so the kit knows which locales your app supports.
///
/// ```dart
/// LocalizationKitRuntime.use(
///   defaultLanguages: const [
///     LanguageModel(code: 'en_US', name: 'English', isoCode: 'en'),
///     LanguageModel(code: 'ar_EG', name: 'العربية', isoCode: 'ar'),
///   ],
///   defaultIsoCode: 'en',
///   defaultApiCode: 'en_US',
///   storage: MyStorageAdapter(),                 // optional
///   api: MyLanguageApi(),                        // optional (remote list)
///   onLanguageChanged: MyApiClient.syncHeaders,  // optional
/// );
/// ```
class LocalizationKitRuntime {
  LocalizationKitRuntime._();

  static LocalizationStorageAdapter _storage =
      InMemoryLocalizationStorageAdapter();
  static LocalizationApi? _api;
  static LanguageHeaderSync? _onLanguageChanged;
  static List<LanguageModel> _defaultLanguages = const [
    LanguageModel(code: 'en_US', name: 'English', isoCode: 'en'),
  ];
  static String _defaultIsoCode = 'en';
  static String _defaultApiCode = 'en_US';

  /// Configure the runtime. Pass only the fields you want to override —
  /// others keep their previous (or default) values.
  static void use({
    LocalizationStorageAdapter? storage,
    LocalizationApi? api,
    LanguageHeaderSync? onLanguageChanged,
    List<LanguageModel>? defaultLanguages,
    String? defaultIsoCode,
    String? defaultApiCode,
  }) {
    if (storage != null) _storage = storage;
    if (api != null) _api = api;
    if (onLanguageChanged != null) _onLanguageChanged = onLanguageChanged;
    if (defaultLanguages != null) _defaultLanguages = defaultLanguages;
    if (defaultIsoCode != null) _defaultIsoCode = defaultIsoCode;
    if (defaultApiCode != null) _defaultApiCode = defaultApiCode;
  }

  static LocalizationStorageAdapter get storage => _storage;
  static LocalizationApi? get api => _api;
  static LanguageHeaderSync? get onLanguageChanged => _onLanguageChanged;
  static List<LanguageModel> get defaultLanguages => _defaultLanguages;
  static String get defaultIsoCode => _defaultIsoCode;
  static String get defaultApiCode => _defaultApiCode;
}
