/// Enum to define which token strategy an API endpoint requires.
///
/// Maps to the [DioApiClient] factories:
/// - [userToken]   -> `DioApiClient.authenticated()`
/// - [staticToken] -> `DioApiClient.publicStatic()`
/// - [both]        -> `DioApiClient()`
enum ApiTokenType {
  /// Uses the user authentication token (requires login).
  ///
  /// Internally uses `DioApiClient.authenticated()`:
  /// - ✅ AuthInterceptor (adds user access token from storage)
  /// - ❌ Static bearer token
  userToken,

  /// Uses a static bearer token only — useful for public endpoints that
  /// require a service-level credential (e.g. Odoo's catalog token).
  ///
  /// Internally uses `DioApiClient.publicStatic()`:
  /// - ❌ AuthInterceptor
  /// - ✅ Static bearer token from [ApiKitRuntime.staticBearerToken]
  staticToken,

  /// Uses both user token and static bearer token.
  ///
  /// Internally uses `DioApiClient()` (default constructor).
  both,
}

extension ApiTokenTypeExtension on ApiTokenType {
  /// Returns a human-readable description.
  String get description {
    switch (this) {
      case ApiTokenType.userToken:
        return 'User Token Only (Requires Login)';
      case ApiTokenType.staticToken:
        return 'Static Token Only (Public)';
      case ApiTokenType.both:
        return 'Both Tokens';
    }
  }
}
