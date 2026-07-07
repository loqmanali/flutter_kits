// Example of wiring flutter_api_kit into a fresh Flutter app.
//
// This file is illustrative only — copy the pieces you need into your own
// project. The package itself has no SharedPreferences/SecureStorage
// dependency, so plug in whatever you already use.

import 'package:flutter_api_kit/flutter_api_kit.dart';

class MySecureTokenStorage implements TokenStorage {
  String? _access;
  String? _refresh;

  @override
  String? getAccessTokenSync() => _access;

  @override
  Future<String?> getAccessToken() async {
    // e.g. read from flutter_secure_storage
    return _access;
  }

  @override
  Future<String?> getRefreshToken() async => _refresh;

  @override
  Future<void> saveAuthTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _access = accessToken;
    if (refreshToken != null) _refresh = refreshToken;
  }

  @override
  Future<void> clearAuthData() async {
    _access = null;
    _refresh = null;
  }
}

Future<void> bootstrap() async {
  const config = ApiKitConfig(
    baseUrl: 'https://api.example.com/v1',
    appVersion: '1.0.0',
    publicEndpoints: ['/countries', '/banners', '/catalog'],
  );

  final storage = MySecureTokenStorage();
  const language = StaticLanguageProvider('en');

  final client = DioApiClient.authenticated(
    config: config,
    tokenStorage: storage,
    languageProvider: language,
    authOptions: const AuthOptions(enableRefreshTokenFlow: false),
    onLogout: () async {
      // navigate to /login, clear in-memory user state, etc.
    },
    forceUpdateHandler: const NoopForceUpdateHandler(),
  );

  final me = await client.get('/me');
  // ignore: avoid_print
  print(me);
}
