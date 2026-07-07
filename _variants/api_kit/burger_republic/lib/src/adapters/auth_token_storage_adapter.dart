/// Contract for persisting auth tokens.
///
/// Implementations typically wrap `SharedPreferences`, `flutter_secure_storage`,
/// Hive, or a project-wide storage facade (e.g. `storage_kit`).
abstract class AuthTokenStorageAdapter {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  /// Save the access + refresh token pair after a successful login or refresh.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Clear all auth-related data. Called on logout or when token refresh fails.
  Future<void> clearAuthData();
}

/// In-memory implementation — used as a safe default and for tests.
class InMemoryAuthTokenStorage implements AuthTokenStorageAdapter {
  String? _access;
  String? _refresh;

  @override
  Future<String?> getAccessToken() async => _access;

  @override
  Future<String?> getRefreshToken() async => _refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<void> clearAuthData() async {
    _access = null;
    _refresh = null;
  }
}
