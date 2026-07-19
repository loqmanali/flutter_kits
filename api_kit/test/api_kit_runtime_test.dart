import 'package:api_kit/api_kit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTokenStorage implements AuthTokenStorageAdapter {
  @override
  Future<String?> getAccessToken() async => 'fake';

  @override
  Future<String?> getRefreshToken() async => 'fake';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}

  @override
  Future<void> clearAuthData() async {}
}

void main() {
  // ApiKitRuntime is process-wide static state; `use()` only overwrites
  // non-null fields, so leftover config from one test would otherwise leak
  // into the next. Guarantee a clean slate on both sides of every test.
  setUp(ApiKitRuntime.resetForTesting);
  tearDown(ApiKitRuntime.resetForTesting);

  test('use() followed by resetForTesting() restores every default', () {
    ApiKitRuntime.use(
      baseUrl: 'https://api.example.com',
      timeout: const Duration(seconds: 5),
      defaultHeaders: const {'X-Test': '1'},
      tokenStorage: _FakeTokenStorage(),
      onRefreshToken: (refreshToken) async => 'new-token',
      onLogout: () async {},
      languageCodeProvider: () async => 'ar_EG',
      staticBearerToken: 'static-token',
      skipUserAuthEndpoints: const ['/public'],
      skipRefreshEndpoints: const ['/custom-skip'],
      appVersion: '9.9.9',
      onForceUpdate: ({message, minVersion, currentVersion}) {},
      enablePrettyLogger: false,
      logPrint: (object) {},
    );

    // Sanity check: `use()` really did overwrite the defaults.
    expect(ApiKitRuntime.baseUrl, 'https://api.example.com');
    expect(ApiKitRuntime.skipUserAuthEndpoints, ['/public']);

    ApiKitRuntime.resetForTesting();

    expect(ApiKitRuntime.baseUrl, '');
    expect(ApiKitRuntime.timeout, const Duration(seconds: 30));
    expect(ApiKitRuntime.defaultHeaders, const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });
    expect(ApiKitRuntime.tokenStorage, isA<InMemoryAuthTokenStorage>());
    expect(ApiKitRuntime.onRefreshToken, isNull);
    expect(ApiKitRuntime.onLogout, isNull);
    expect(ApiKitRuntime.languageCodeProvider, isNull);
    expect(ApiKitRuntime.staticBearerToken, isNull);
    expect(ApiKitRuntime.skipUserAuthEndpoints, isEmpty);
    expect(ApiKitRuntime.skipRefreshEndpoints, [
      '/auth/login',
      '/auth/register',
      '/auth/registration',
      '/auth/verify-otp',
      '/auth/refresh-token',
      '/auth/logout',
    ]);
    expect(ApiKitRuntime.appVersion, isNull);
    expect(ApiKitRuntime.onForceUpdate, isNull);
    expect(ApiKitRuntime.enablePrettyLogger, isTrue);
    expect(ApiKitRuntime.logPrint, isNull);
  });

  test('use() only overwrites non-null fields (merge semantics unchanged)', () {
    ApiKitRuntime.use(baseUrl: 'https://first.example.com');
    ApiKitRuntime.use(timeout: const Duration(seconds: 1));

    // Second use() call didn't pass baseUrl — it must survive.
    expect(ApiKitRuntime.baseUrl, 'https://first.example.com');
    expect(ApiKitRuntime.timeout, const Duration(seconds: 1));
  });
}
