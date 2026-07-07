import '../interceptors/force_update_interceptor.dart' show ForceUpdateCallback;
import 'auth_callbacks.dart';
import 'auth_token_storage_adapter.dart';
import 'language_code_provider.dart';

/// Process-wide runtime configuration for api_kit.
///
/// Configure once in `main()` before creating any `DioApiClient`. Read by
/// `DioApiClient` factories and the built-in interceptors.
///
/// ```dart
/// ApiKitRuntime.use(
///   baseUrl: 'https://api.example.com',
///   timeout: const Duration(seconds: 30),
///   appVersion: '2.1.0',
///   tokenStorage: MyTokenStorage(),                 // optional
///   onRefreshToken: MyAuth.refreshAccessToken,      // optional
///   onLogout: MyAuth.signOut,                       // optional
///   onForceUpdate: MyDialogs.showForceUpdate,       // optional
///   languageCodeProvider: () async => MyLang.code,  // optional
///   defaultHeaders: const {'X-App-Version': '1.0.0'},
/// );
/// ```
class ApiKitRuntime {
  ApiKitRuntime._();

  static String _baseUrl = '';
  static Duration _timeout = const Duration(seconds: 30);
  static Map<String, String> _defaultHeaders = const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  static AuthTokenStorageAdapter _tokenStorage = InMemoryAuthTokenStorage();
  static TokenRefreshCallback? _onRefreshToken;
  static LogoutCallback? _onLogout;
  static LanguageCodeProvider? _languageCodeProvider;
  static String? _appVersion;
  static ForceUpdateCallback? _onForceUpdate;
  static bool _enablePrettyLogger = true;
  static void Function(Object object)? _logPrint;

  /// Optional default Odoo-style static bearer token added to specific
  /// requests when [DioApiClient.publicOdoo] (or `ApiTokenType.odooToken`) is
  /// used. Set to null/empty to disable.
  static String? _staticBearerToken;

  /// Endpoints that should bypass the user auth header (e.g. public catalog
  /// routes that use a different token strategy). Defaults to an empty list.
  static List<String> _skipUserAuthEndpoints = const [];

  /// Endpoints that should skip the refresh-token flow on 401 (typically
  /// the auth endpoints themselves to avoid infinite loops).
  static List<String> _skipRefreshEndpoints = const [
    '/auth/login',
    '/auth/register',
    '/auth/registration',
    '/auth/verify-otp',
    '/auth/refresh-token',
    '/auth/logout',
  ];

  /// Configure the runtime. Pass only the fields you want to override.
  static void use({
    String? baseUrl,
    Duration? timeout,
    Map<String, String>? defaultHeaders,
    AuthTokenStorageAdapter? tokenStorage,
    TokenRefreshCallback? onRefreshToken,
    LogoutCallback? onLogout,
    LanguageCodeProvider? languageCodeProvider,
    String? staticBearerToken,
    List<String>? skipUserAuthEndpoints,
    List<String>? skipRefreshEndpoints,
    String? appVersion,
    ForceUpdateCallback? onForceUpdate,
    bool? enablePrettyLogger,
    void Function(Object object)? logPrint,
  }) {
    if (baseUrl != null) _baseUrl = baseUrl;
    if (timeout != null) _timeout = timeout;
    if (defaultHeaders != null) _defaultHeaders = defaultHeaders;
    if (tokenStorage != null) _tokenStorage = tokenStorage;
    if (onRefreshToken != null) _onRefreshToken = onRefreshToken;
    if (onLogout != null) _onLogout = onLogout;
    if (languageCodeProvider != null) {
      _languageCodeProvider = languageCodeProvider;
    }
    if (staticBearerToken != null) _staticBearerToken = staticBearerToken;
    if (skipUserAuthEndpoints != null) {
      _skipUserAuthEndpoints = skipUserAuthEndpoints;
    }
    if (skipRefreshEndpoints != null) {
      _skipRefreshEndpoints = skipRefreshEndpoints;
    }
    if (appVersion != null) _appVersion = appVersion;
    if (onForceUpdate != null) _onForceUpdate = onForceUpdate;
    if (enablePrettyLogger != null) _enablePrettyLogger = enablePrettyLogger;
    if (logPrint != null) _logPrint = logPrint;
  }

  static String get baseUrl => _baseUrl;
  static Duration get timeout => _timeout;
  static Map<String, String> get defaultHeaders => _defaultHeaders;
  static AuthTokenStorageAdapter get tokenStorage => _tokenStorage;
  static TokenRefreshCallback? get onRefreshToken => _onRefreshToken;
  static LogoutCallback? get onLogout => _onLogout;
  static LanguageCodeProvider? get languageCodeProvider =>
      _languageCodeProvider;
  static String? get staticBearerToken => _staticBearerToken;
  static List<String> get skipUserAuthEndpoints => _skipUserAuthEndpoints;
  static List<String> get skipRefreshEndpoints => _skipRefreshEndpoints;
  static String? get appVersion => _appVersion;
  static ForceUpdateCallback? get onForceUpdate => _onForceUpdate;
  static bool get enablePrettyLogger => _enablePrettyLogger;
  static void Function(Object object)? get logPrint => _logPrint;
}
