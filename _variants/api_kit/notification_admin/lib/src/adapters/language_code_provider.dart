/// Callback invoked by [LanguageInterceptor] to read the current language
/// code (e.g. `'en_US'`, `'ar_EG'`) right before sending a request.
///
/// Implementations typically read from the host app's localization layer
/// (e.g. `localization_kit`'s `LocalizationStorageAdapter`,
/// `SharedPreferences`, etc.).
typedef LanguageCodeProvider = Future<String> Function();
