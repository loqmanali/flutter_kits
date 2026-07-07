import '../interfaces/token_storage.dart';

/// In-memory implementation of [TokenStorage].
///
/// Useful for tests and prototypes. Not persistent — tokens are lost on
/// process restart.
class InMemoryTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;

  InMemoryTokenStorage({String? accessToken, String? refreshToken})
      : _accessToken = accessToken,
        _refreshToken = refreshToken;

  @override
  String? getAccessTokenSync() => _accessToken;

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveAuthTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    if (refreshToken != null) _refreshToken = refreshToken;
  }

  @override
  Future<void> clearAuthData() async {
    _accessToken = null;
    _refreshToken = null;
  }
}
