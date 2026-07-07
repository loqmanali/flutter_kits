# flutter_api_kit

A reusable, framework-agnostic HTTP/API toolkit for Flutter.

Extracted from a production app, generalized so it can be dropped into any
Flutter project regardless of the state-management library, storage layer,
or backend in use.

## What it gives you

- `ApiClient` abstract interface: `get`, `post`, `put`, `patch`, `delete`,
  `getBytes`, `uploadFile`.
- `DioApiClient` implementation with three factory modes:
  - `authenticated()` — attaches a bearer token via `AuthInterceptor`.
  - `public()` — no auth, still adds language + version headers.
  - `bare()` — only the logger (used for refresh-token requests).
- Pluggable interceptors (each one optional and independently configurable):
  - `AuthInterceptor` — bearer-token injection, 401 handling, optional
    refresh-token flow with concurrency-safe request queueing.
  - `LanguageInterceptor` — `Accept-Language` header from a pluggable
    `LanguageProvider`.
  - `VersionInterceptor` — `X-App-Version` + `X-App-Platform` headers.
  - `ForceUpdateInterceptor` — handles `426 Upgrade Required` via a
    pluggable `ForceUpdateHandler`.
  - `ApiKeyInterceptor` — generic header injection.
  - `PrettyDioLogger` — colored, structured request/response logger.
- A full `ApiException` hierarchy + corresponding `Failure` hierarchy and
  an `ErrorMapper` that converts one to the other.
- `ApiResponseReader` — safe accessors for `{ data: ... }` style envelopes.
- `JsonSafe` — null-safe JSON primitive parsers.

## Design principles

1. **No hard dependency** on Riverpod, Bloc, GetX, SharedPreferences, or any
   specific storage / auth implementation. The package only depends on
   `dio` and `equatable`.
2. **Inject everything**:
   - Storage via the `TokenStorage` interface (in-memory implementation
     bundled; plug in your own backed by `flutter_secure_storage`,
     `SharedPreferences`, Hive, etc.).
   - Language via the `LanguageProvider` interface.
   - Force-update UI via the `ForceUpdateHandler` interface.
   - Logout side-effect via the `LogoutCallback` typedef.
   - Refresh-token flow via the `RefreshTokenCallback` typedef.
3. **Per-project configuration** through `ApiKitConfig`: base URL, timeout,
   app version, public endpoints, refresh endpoint, max refresh attempts.

## Quickstart

```dart
import 'package:flutter_api_kit/flutter_api_kit.dart';

final config = ApiKitConfig(
  baseUrl: 'https://api.example.com/v1',
  appVersion: '1.0.0',
  publicEndpoints: const ['/countries', '/banners'],
  enableRefreshTokenFlow: false,
);

final storage = InMemoryTokenStorage();
final language = StaticLanguageProvider('en');

final client = DioApiClient.authenticated(
  config: config,
  tokenStorage: storage,
  languageProvider: language,
  onLogout: () async {
    // your app's logout logic
  },
);

final data = await client.get('/me');
```

## Files

```
lib/
├── flutter_api_kit.dart                    # barrel export
└── src/
    ├── config/
    │   ├── api_kit_config.dart             # central configuration
    │   ├── api_token_type.dart
    │   └── auth_options.dart
    ├── interfaces/
    │   ├── api_client.dart
    │   ├── token_storage.dart
    │   ├── language_provider.dart
    │   └── force_update_handler.dart
    ├── implementations/
    │   ├── dio_api_client.dart
    │   └── in_memory_token_storage.dart
    ├── interceptors/
    │   ├── auth_interceptor.dart
    │   ├── language_interceptor.dart
    │   ├── version_interceptor.dart
    │   ├── force_update_interceptor.dart
    │   ├── api_key_interceptor.dart
    │   ├── pretty_dio_logger.dart
    │   └── interceptor_logger_config.dart
    ├── exceptions/
    │   └── api_exception.dart
    ├── failures/
    │   └── failure.dart
    └── utilities/
        ├── error_mapper.dart
        ├── api_response_reader.dart
        └── json_safe.dart
```

## Usage in another project

Add to your app's `pubspec.yaml`:

```yaml
dependencies:
  flutter_api_kit:
    path: ../path/to/flutter_api_kit
```

Then implement the three interfaces (`TokenStorage`, `LanguageProvider`,
optionally `ForceUpdateHandler`) using whatever your project already uses,
and wire the client up once at app start.
