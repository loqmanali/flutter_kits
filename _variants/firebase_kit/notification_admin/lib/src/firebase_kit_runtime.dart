import 'adapters/firebase_logger.dart';
import 'adapters/firestore_collection_config.dart';
import 'adapters/oauth_provider_adapter.dart';
import 'config/firebase_kit_config.dart';

/// Global injection point for firebase_kit.
///
/// Call [FirebaseKitRuntime.use] once during app startup — before any kit
/// service or Riverpod provider is read — to plug in:
///   * a custom [FirebaseLogger] (defaults to [DeveloperFirebaseLogger])
///   * the collection name mapping ([FirestoreCollectionConfig])
///   * OAuth adapters (Google, Apple, Facebook, …) keyed by Firebase provider id
///   * a kit-wide [FirebaseKitConfig] (AI model, etc.)
///
/// ```dart
/// FirebaseKitRuntime.use(
///   logger: AppLoggerFirebaseAdapter(),
///   collections: const FirestoreCollectionConfig(usersCollection: 'app_users'),
///   oauthAdapters: [GoogleAdapter(), AppleAdapter()],
///   config: const FirebaseKitConfig(
///     ai: FirebaseAiConfig(model: 'gemini-1.5-flash'),
///   ),
/// );
/// ```
class FirebaseKitRuntime {
  FirebaseKitRuntime._();

  static FirebaseLogger _logger = const DeveloperFirebaseLogger();
  static FirestoreCollectionConfig _collections =
      const FirestoreCollectionConfig();
  static FirebaseKitConfig _config = const FirebaseKitConfig();
  static final Map<String, OAuthProviderAdapter> _oauthAdapters = {};

  static FirebaseLogger get logger => _logger;
  static FirestoreCollectionConfig get collections => _collections;
  static FirebaseKitConfig get config => _config;

  /// Returns the registered adapter for [providerId] (e.g. `google.com`).
  /// Throws [StateError] if no adapter was registered for that provider.
  static OAuthProviderAdapter requireOAuthAdapter(String providerId) {
    final adapter = _oauthAdapters[providerId];
    if (adapter == null) {
      throw StateError(
        'No OAuthProviderAdapter registered for "$providerId". '
        'Call FirebaseKitRuntime.use(oauthAdapters: [...]) at startup.',
      );
    }
    return adapter;
  }

  /// Returns the adapter for [providerId], or null if not registered.
  static OAuthProviderAdapter? tryOAuthAdapter(String providerId) =>
      _oauthAdapters[providerId];

  /// All registered OAuth provider ids.
  static Iterable<String> get registeredOAuthProviders =>
      _oauthAdapters.keys;

  /// Configure the kit. Call before any service or provider is used.
  static void use({
    FirebaseLogger? logger,
    FirestoreCollectionConfig? collections,
    FirebaseKitConfig? config,
    List<OAuthProviderAdapter>? oauthAdapters,
  }) {
    if (logger != null) _logger = logger;
    if (collections != null) _collections = collections;
    if (config != null) _config = config;
    if (oauthAdapters != null) {
      for (final adapter in oauthAdapters) {
        _oauthAdapters[adapter.id] = adapter;
      }
    }
  }

  /// Test/reset hook.
  static void reset() {
    _logger = const DeveloperFirebaseLogger();
    _collections = const FirestoreCollectionConfig();
    _config = const FirebaseKitConfig();
    _oauthAdapters.clear();
  }
}
