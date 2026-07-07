/// Central configuration for the API kit.
///
/// One instance is created per Dio client and passed into the interceptors
/// that need it. Everything project-specific lives here — `baseUrl`,
/// `appVersion`, public endpoints, refresh endpoint, etc.
class ApiKitConfig {
  /// Base URL for all requests (no trailing slash needed).
  final String baseUrl;

  /// Default connect/receive timeout, in milliseconds.
  final int timeoutMs;

  /// Current app version, sent as `X-App-Version`.
  final String appVersion;

  /// Endpoints that should bypass the auth interceptor entirely.
  ///
  /// Matched with `path.startsWith(endpoint)`.
  final List<String> publicEndpoints;

  /// Endpoints that should not trigger a refresh on 401.
  final List<String> skipRefreshEndpoints;

  /// Endpoint used for token refresh, e.g. `auth/refresh-token`.
  final String refreshTokenEndpoint;

  /// Max times a single request will retry token refresh before bailing.
  final int maxRefreshAttempts;

  /// Default headers added to every request.
  final Map<String, String> defaultHeaders;

  /// Whether to add the pretty Dio logger interceptor.
  final bool enableLogger;

  const ApiKitConfig({
    required this.baseUrl,
    required this.appVersion,
    this.timeoutMs = 60000,
    this.publicEndpoints = const [],
    this.skipRefreshEndpoints = const [
      '/auth/login',
      '/auth/register',
      '/auth/registration',
      '/auth/verify-otp',
      '/auth/refresh-token',
      '/auth/logout',
    ],
    this.refreshTokenEndpoint = 'auth/refresh-token',
    this.maxRefreshAttempts = 2,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    this.enableLogger = true,
  });

  ApiKitConfig copyWith({
    String? baseUrl,
    int? timeoutMs,
    String? appVersion,
    List<String>? publicEndpoints,
    List<String>? skipRefreshEndpoints,
    String? refreshTokenEndpoint,
    int? maxRefreshAttempts,
    Map<String, String>? defaultHeaders,
    bool? enableLogger,
  }) {
    return ApiKitConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      timeoutMs: timeoutMs ?? this.timeoutMs,
      appVersion: appVersion ?? this.appVersion,
      publicEndpoints: publicEndpoints ?? this.publicEndpoints,
      skipRefreshEndpoints: skipRefreshEndpoints ?? this.skipRefreshEndpoints,
      refreshTokenEndpoint: refreshTokenEndpoint ?? this.refreshTokenEndpoint,
      maxRefreshAttempts: maxRefreshAttempts ?? this.maxRefreshAttempts,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      enableLogger: enableLogger ?? this.enableLogger,
    );
  }
}
