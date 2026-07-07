# api_kit

Pluggable, project-agnostic API networking layer for Flutter.

`api_kit` ships the **infrastructure** of HTTP networking — a Dio-powered
client, auth-token refresh with request queuing, language header injection,
typed exceptions/failures, error mapping — without baking in any specific
backend, endpoint list, storage, or DI framework. Drop it into any project
by configuring three adapters at startup.

## What you get

- `DioApiClient` — concrete `ApiClient` implementation backed by Dio, with
  three factory shapes:
  - `DioApiClient()` — user auth **and** static bearer token.
  - `DioApiClient.authenticated()` — user auth only.
  - `DioApiClient.publicStatic()` — static bearer token only.
  - `DioApiClient.fromTokenType(...)` — pick by `ApiTokenType`.
- `AuthInterceptor` — attaches the user access token, refreshes on 401,
  queues concurrent requests during a refresh, falls back to logout when
  refresh fails.
- `LanguageInterceptor` — adds `locale` query parameter from your
  localization layer (pluggable callback).
- `StaticTokenInterceptor` — attaches a service-level bearer token to public
  endpoints.
- `ApiException` hierarchy (Auth, Server, NotFound, Validation, Timeout, …).
- `Failure` hierarchy for domain layers (Either-style flows).
- `ErrorMapper` to convert exceptions → failures.
- `ApiHelper` to dispatch on `ApiTokenType` without depending on Riverpod /
  get_it / any DI framework.

## What you bring

- Your endpoint constants and request models (api_kit doesn't presume your
  backend's shape).
- An `AuthTokenStorageAdapter` (or use the in-memory default for tests).
- `onRefreshToken` and `onLogout` callbacks if you want automatic refresh.
- Optionally, a `languageCodeProvider` if you want `locale=` on every
  request.
- Optionally, a `staticBearerToken` for the public-token flow.

## Install

```yaml
dependencies:
  api_kit:
    path: ../packages/api_kit
```

```dart
import 'package:api_kit/api_kit.dart';
```

## Quick start

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiKitRuntime.use(
    baseUrl: 'https://api.example.com',
    timeout: const Duration(seconds: 30),
    defaultHeaders: const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-App-Version': '1.0.0',
    },

    // Optional:
    // tokenStorage: MySharedPrefsTokenStorage(),
    // onRefreshToken: MyAuth.refreshAccessToken,
    // onLogout: MyAuth.signOut,
    // languageCodeProvider: () async => MyLang.code,
    // staticBearerToken: '<service-account-bearer>',
    // skipUserAuthEndpoints: ['/catalog/', '/public/'],
  );

  final api = DioApiClient.authenticated();
  final user = await api.get('/me');

  runApp(MyApp(api: api));
}
```

That's enough for a user-authenticated client with automatic 401 → refresh →
retry.

## Adapters

### `AuthTokenStorageAdapter` (required for auth flows)

```dart
class SharedPrefsTokenStorage implements AuthTokenStorageAdapter {
  static const _kAccess = 'auth.access';
  static const _kRefresh = 'auth.refresh';

  @override
  Future<String?> getAccessToken() async =>
      (await SharedPreferences.getInstance()).getString(_kAccess);

  @override
  Future<String?> getRefreshToken() async =>
      (await SharedPreferences.getInstance()).getString(_kRefresh);

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAccess, accessToken);
    await p.setString(_kRefresh, refreshToken);
  }

  @override
  Future<void> clearAuthData() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kAccess);
    await p.remove(_kRefresh);
  }
}
```

Default: in-memory (`InMemoryAuthTokenStorage`) — handy for tests.

### `TokenRefreshCallback` (optional, but needed for auto-refresh)

```dart
ApiKitRuntime.use(
  onRefreshToken: (refreshToken) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
    final response = await dio.post('/auth/refresh-token', data: {'refresh_token': refreshToken});
    final newAccess = response.data['access_token'] as String?;
    final newRefresh = response.data['refresh_token'] as String?;
    if (newAccess != null && newRefresh != null) {
      await ApiKitRuntime.tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
    }
    return newAccess; // returning null triggers logout
  },
);
```

### `LogoutCallback` (optional)

```dart
ApiKitRuntime.use(
  onLogout: () async {
    await MyAuth.clearProfile();
    await rootNavigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  },
);
```

### `LanguageCodeProvider` (optional)

```dart
ApiKitRuntime.use(
  languageCodeProvider: () async {
    // E.g. from localization_kit:
    return await LocalizationKitRuntime.storage.getLanguageCode() ?? 'en_US';
  },
);
```

The interceptor adds `?locale=<code>` to every request automatically.

### Static bearer token (optional)

If your backend has a "public" mode that needs a service-account token (a
common pattern with Odoo's catalog routes):

```dart
ApiKitRuntime.use(staticBearerToken: 'EAA...long-token...');

final publicApi = DioApiClient.publicStatic();
final catalog = await publicApi.get('/catalog/products');
```

### Skip lists

The kit ships sensible defaults for `skipRefreshEndpoints` (covers
`/auth/login`, `/auth/refresh-token`, …). Override either list to match your
backend:

```dart
ApiKitRuntime.use(
  skipUserAuthEndpoints: ['/catalog/', '/public/'],
  skipRefreshEndpoints:  ['/auth/'],
);
```

## Using `ApiHelper`

When different endpoints need different token strategies, route them through
`ApiHelper`:

```dart
final helper = ApiHelper((type) => switch (type) {
  ApiTokenType.userToken   => userClient,
  ApiTokenType.staticToken => publicClient,
  ApiTokenType.both        => fullClient,
});

final me = await helper.executeApiCall(
  tokenType: ApiTokenType.userToken,
  apiCall: (c) => c.get('/me'),
);
```

## Errors

`DioApiClient` converts every Dio error into a typed `ApiException`:

```dart
try {
  await api.get('/orders');
} on UnauthorizedException catch (e) {
  // 401
} on NotFoundException catch (_) {
  // 404
} on TimeoutException catch (_) {
  // connect/send/receive timeout
} on NoInternetConnectionException catch (_) {
  // SocketException
} on ApiException catch (e) {
  // fallback
}
```

For a clean-arch repository layer, map exceptions to `Failure`s:

```dart
Future<Either<Failure, User>> getUser() async {
  try {
    final json = await api.get('/me');
    return Right(User.fromJson(json));
  } on ApiException catch (e) {
    return Left(ErrorMapper.mapExceptionToFailure(e));
  }
}
```

## What's intentionally NOT in the package

- **Endpoint constants** (`/auth/login`, `/catalog/...`, etc.) — these are
  project-specific and belong in your app.
- **Riverpod / get_it / Injectable wiring** — api_kit only requires a
  function (`ApiClientResolver`) to map `ApiTokenType` to an `ApiClient`,
  so you stay free to pick any DI tool.
- **Project-wide storage / auth state** — wired through adapters.

## Notes

- The auth interceptor's refresh-then-queue logic is safe for concurrent
  requests: the first 401 triggers a single refresh; everything else queues
  and replays once the new token lands.
- Both the language interceptor and the static-token interceptor are safe
  no-ops when their config is absent.
- Want to plug `api_kit`'s interceptors into your own Dio instance? They're
  all exported. Construct your `Dio` and call
  `dio.interceptors.addAll([LanguageInterceptor(), AuthInterceptor(dio: dio), StaticTokenInterceptor()])`.
