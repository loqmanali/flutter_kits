/// Persistence contract for the user's chosen language.
///
/// The kit needs to:
/// - Remember the ISO language code (`'en'`, `'ar'`, …) so the UI locale
///   sticks across app launches.
/// - Remember a separate "API code" (`'en_US'`, `'ar_EG'`, …) that some
///   backends require in `Accept-Language` headers / query params.
///
/// Implementations are typically thin wrappers around `SharedPreferences`,
/// Hive, secure storage, or the host app's own storage facade.
abstract class LocalizationStorageAdapter {
  Future<String?> getLocaleCode();
  Future<void> setLocaleCode(String isoCode);

  Future<String?> getLanguageCode();
  Future<void> setLanguageCode(String apiCode);
}

/// In-memory adapter — used as a safe default before the host app wires its
/// own storage, and as a stand-in for tests.
class InMemoryLocalizationStorageAdapter implements LocalizationStorageAdapter {
  String? _isoCode;
  String? _apiCode;

  @override
  Future<String?> getLocaleCode() async => _isoCode;

  @override
  Future<void> setLocaleCode(String isoCode) async => _isoCode = isoCode;

  @override
  Future<String?> getLanguageCode() async => _apiCode;

  @override
  Future<void> setLanguageCode(String apiCode) async => _apiCode = apiCode;
}
