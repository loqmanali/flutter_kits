/// Storage contract for auth tokens.
///
/// Implement this against whatever your project already uses
/// (`flutter_secure_storage`, `SharedPreferences`, Hive, an in-memory cache,
/// etc.). The package provides `InMemoryTokenStorage` for tests and demos.
abstract class TokenStorage {
  /// Synchronous read for the request hot path (interceptor `onRequest`).
  /// Return `null` if not yet loaded — the interceptor will fall back to
  /// [getAccessToken].
  String? getAccessTokenSync();

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> saveAuthTokens({
    required String accessToken,
    String? refreshToken,
  });

  Future<void> clearAuthData();
}
