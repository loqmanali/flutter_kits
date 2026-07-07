/// api_kit
///
/// Pluggable, project-agnostic API networking layer for Flutter.
///
/// - `DioApiClient` — Dio-powered HTTP client with three factory shapes
///   (user-auth only, static-token only, both).
/// - `ApiKitRuntime` — single configuration point: base URL, timeout,
///   default headers, token storage, refresh/logout callbacks, language
///   code, static bearer token, skip-lists for special endpoints.
/// - `AuthInterceptor` — handles 401 → refresh-token → retry, with
///   a per-request queue while the refresh is in flight.
/// - `LanguageInterceptor` — adds a `locale` query parameter from your
///   localization layer.
/// - `StaticTokenInterceptor` — attaches a service-level bearer token
///   for public endpoints.
/// - Typed `ApiException` hierarchy + `Failure` hierarchy + `ErrorMapper`.
///
/// Quick start:
/// ```dart
/// import 'package:api_kit/api_kit.dart';
///
/// Future<void> main() async {
///   ApiKitRuntime.use(
///     baseUrl: 'https://api.example.com',
///     tokenStorage: MyTokenStorage(),
///     onRefreshToken: MyAuth.refreshAccessToken,
///     onLogout: MyAuth.signOut,
///   );
///
///   final api = DioApiClient.authenticated();
///   final user = await api.get('/me');
/// }
/// ```
library;

// Adapters / runtime
export 'src/adapters/api_kit_runtime.dart';
export 'src/adapters/auth_callbacks.dart';
export 'src/adapters/auth_token_storage_adapter.dart';
export 'src/adapters/language_code_provider.dart';

// Core API surface
export 'src/api_helper.dart';
export 'src/api_token_type.dart';
export 'src/interfaces/api_client.dart';
export 'src/implementations/dio_api_client.dart';

// Interceptors (re-exported in case callers want to plug them into their
// own Dio instance).
export 'src/interceptors/auth_interceptor.dart';
export 'src/interceptors/language_interceptor.dart';
export 'src/interceptors/static_token_interceptor.dart';

// Errors
export 'src/exceptions/api_exception.dart';
export 'src/failures/failure.dart';
export 'src/utilities/error_mapper.dart';
