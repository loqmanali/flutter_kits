import 'dart:io';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../adapters/api_kit_runtime.dart';
import '../api_token_type.dart';
import '../exceptions/api_exception.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/language_interceptor.dart';
import '../interceptors/static_token_interceptor.dart';
import '../interfaces/api_client.dart';

/// Concrete implementation of [ApiClient] using Dio.
///
/// All configuration (`baseUrl`, `timeout`, `defaultHeaders`, token storage,
/// auth callbacks, language code, static bearer token) is read from
/// [ApiKitRuntime] — there's no host-app coupling.
///
/// Three factory shapes match [ApiTokenType]:
/// - [DioApiClient()] - Both user auth + static token
/// - [DioApiClient.authenticated] - User token only
/// - [DioApiClient.publicStatic] - Static bearer token only
///
/// Or use [DioApiClient.fromTokenType] to dispatch on an [ApiTokenType].
class DioApiClient implements ApiClient {
  DioApiClient._internal({
    Duration? timeout,
    required bool useAuth,
    required bool useStaticToken,
    List<Interceptor> extraInterceptors = const [],
  }) {
    final resolvedTimeout = timeout ?? ApiKitRuntime.timeout;

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiKitRuntime.baseUrl,
        connectTimeout: resolvedTimeout,
        receiveTimeout: resolvedTimeout,
        headers: {...ApiKitRuntime.defaultHeaders},
      ),
    );

    // Language interceptor runs first so the locale is on the request before
    // anything else sees it.
    _dio.interceptors.add(LanguageInterceptor());

    if (useAuth) {
      _dio.interceptors.add(AuthInterceptor(dio: _dio));
    }

    if (useStaticToken) {
      _dio.interceptors.add(StaticTokenInterceptor());
    }

    _dio.interceptors.addAll(extraInterceptors);
  }

  late final Dio _dio;

  /// The underlying Dio instance — useful for advanced configuration or
  /// adding custom interceptors after construction.
  Dio get dio => _dio;

  /// Default constructor — uses both user auth + static bearer token.
  DioApiClient({
    Duration? timeout,
    List<Interceptor> extraInterceptors = const [],
  }) : this._internal(
         timeout: timeout,
         useAuth: true,
         useStaticToken: true,
         extraInterceptors: extraInterceptors,
       );

  /// User auth only.
  factory DioApiClient.authenticated({
    Duration? timeout,
    List<Interceptor> extraInterceptors = const [],
  }) {
    return DioApiClient._internal(
      timeout: timeout,
      useAuth: true,
      useStaticToken: false,
      extraInterceptors: extraInterceptors,
    );
  }

  /// Static bearer token only (no user auth).
  factory DioApiClient.publicStatic({
    Duration? timeout,
    List<Interceptor> extraInterceptors = const [],
  }) {
    return DioApiClient._internal(
      timeout: timeout,
      useAuth: false,
      useStaticToken: true,
      extraInterceptors: extraInterceptors,
    );
  }

  /// Dispatches to the right factory based on [tokenType].
  factory DioApiClient.fromTokenType({
    required ApiTokenType tokenType,
    Duration? timeout,
    List<Interceptor> extraInterceptors = const [],
  }) {
    switch (tokenType) {
      case ApiTokenType.userToken:
        return DioApiClient.authenticated(
          timeout: timeout,
          extraInterceptors: extraInterceptors,
        );
      case ApiTokenType.staticToken:
        return DioApiClient.publicStatic(
          timeout: timeout,
          extraInterceptors: extraInterceptors,
        );
      case ApiTokenType.both:
        return DioApiClient(
          timeout: timeout,
          extraInterceptors: extraInterceptors,
        );
    }
  }

  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    } on SocketException {
      throw const NoInternetConnectionException();
    } catch (e) {
      throw UnexpectedException('Unexpected error: $e');
    }
  }

  @override
  Future<dynamic> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? bearerTokenOverride,
  }) async {
    try {
      Options? options;
      if (bearerTokenOverride != null) {
        options = Options(
          headers: {
            ...ApiKitRuntime.defaultHeaders,
            'Authorization': 'Bearer $bearerTokenOverride',
          },
        );
      }
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    } on SocketException {
      throw const NoInternetConnectionException();
    } catch (e) {
      throw UnexpectedException('Unexpected error: $e');
    }
  }

  @override
  Future<dynamic> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    } on SocketException {
      throw const NoInternetConnectionException();
    } catch (e) {
      throw UnexpectedException('Unexpected error: $e');
    }
  }

  @override
  Future<dynamic> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    } on SocketException {
      throw const NoInternetConnectionException();
    } catch (e) {
      throw UnexpectedException('Unexpected error: $e');
    }
  }

  @override
  Future<dynamic> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    } on SocketException {
      throw const NoInternetConnectionException();
    } catch (e) {
      throw UnexpectedException('Unexpected error: $e');
    }
  }

  @override
  Future<dynamic> uploadFile(
    String endpoint, {
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final fileName = filePath.split('/').last;

      final formData = FormData.fromMap({
        ...?data,
        fieldName: await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    } on SocketException {
      throw const NoInternetConnectionException();
    } catch (e) {
      throw UnexpectedException('Unexpected error: $e');
    }
  }

  /// Maps a [DioException] to the richest [ApiException] subclass we can.
  ///
  /// Delegates to the top-level [mapDioError] so the classification logic can be
  /// unit-tested in isolation (callers still do `throw _handleError(e)`).
  ApiException _handleError(DioException error) => mapDioError(error);
}

/// Classifies a [DioException] into a typed [ApiException] subclass.
///
/// Outer switch is on [DioException.type]; for `badResponse`/`unknown` we branch
/// on the HTTP status code. Codes with a dedicated subclass throw that subclass
/// (its fixed `statusCode` is already correct). Codes WITHOUT one throw the base
/// [ApiException] (or [ServerException] for 5xx) carrying the *real* status code
/// so it is never lost — e.g. a 429 stays 429, a 504 stays 504.
///
/// Transport failures (timeouts/cancel/connectionError/badCertificate) carry NO
/// status code: even if Dio attached a partial `response.statusCode`, the
/// failure is transport, not HTTP, so we leave the code null.
///
/// Exhaustiveness: a defensive `default`-style fallthrough is NOT used — the
/// switch covers every [DioExceptionType] value in the installed Dio. If Dio
/// adds a new type on upgrade this fails to compile, surfacing the gap at build
/// time; the `unknown` arm already absorbs anything Dio classifies loosely.
@visibleForTesting
ApiException mapDioError(DioException error) {
  final message = _extractMessage(error);

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      // All three timeout variants are transport-level; no HTTP code.
      return TimeoutException(message);

    case DioExceptionType.cancel:
      // Explicit CancelToken cancellation — not a server error.
      return CancellationException(message);

    case DioExceptionType.connectionError:
      // DNS/socket failure, host unreachable → network is down.
      return NoInternetConnectionException(message);

    case DioExceptionType.badCertificate:
      // TLS certificate validation failed.
      return BadCertificateException(message);

    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      // A SocketException surfacing through Dio (often as `unknown`) still means
      // no connectivity — guard for it before falling back to status mapping.
      if (error.error is SocketException) {
        return NoInternetConnectionException(message);
      }
      return _mapByStatusCode(error, message);
  }
}

/// Maps a `badResponse`/`unknown` [DioException] by its HTTP status code.
ApiException _mapByStatusCode(DioException error, String? message) {
  final statusCode = error.response?.statusCode;

  switch (statusCode) {
    // ---- Codes WITH a dedicated subclass (fixed statusCode already correct).
    case 400:
      return BadRequestException(message);
    case 401:
      // Prefer UnauthorizedException (carries 401) over AuthException (no code).
      return UnauthorizedException(message);
    case 403:
      return ForbiddenException(message);
    case 404:
      return NotFoundException(message);
    case 405:
      return MethodNotAllowedException(message);
    case 406:
      return NotAcceptableException(message);
    case 409:
      return ConflictException(message);
    case 422:
      // ValidationException now carries 422 by default AND the parsed field
      // errors from the response body.
      return ValidationException(
        message: message,
        fieldErrors: _extractFieldErrors(error),
      );
    case 500:
      return InternalServerErrorException(message);
    case 501:
      return NotImplementedException(message);
    case 503:
      return ServiceUnavailableException(message);

    // ---- Codes WITHOUT a dedicated subclass: preserve the REAL code.
    default:
      if (statusCode == null) {
        // badResponse/unknown with no code: anomalous/malformed response.
        return UnexpectedException(message);
      }
      if (statusCode >= 500 && statusCode <= 599) {
        // Other 5xx (502/504/505/507/508/511/…): ServerException forwards the
        // real code so e.g. a 504 is reported as 504.
        return ServerException(message ?? 'Server error', statusCode);
      }
      // Other 4xx (402/407/408/410/411/413/415/423/429/…) and any non-4xx/5xx
      // code that surfaced as an error: base ApiException keeps the real code.
      // NOTE: we do NOT use BadRequestException here — it hard-codes 400 and
      // would discard the true status (e.g. a 429 would be misreported as 400).
      return ApiException(message ?? 'Request failed', statusCode: statusCode);
  }
}

/// Extracts a server-provided message from the response body, if any.
///
/// Only returns a non-empty `String` value of `response.data['message']` when
/// `response.data` is a `Map`. Empty/whitespace or non-String values are treated
/// as absent (returns null) so each subclass's built-in default text is used.
String? _extractMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map) {
    final raw = data['message'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw;
    }
  }
  return null;
}

/// Parses per-field validation errors from a 422 response body.
///
/// Looks at `response.data['errors']` (a common shape) and flattens it into a
/// `Map<String, String>`. List values (e.g. Laravel's `{"email": ["required"]}`)
/// take their first entry. Returns null when there's nothing usable.
Map<String, String>? _extractFieldErrors(DioException error) {
  final data = error.response?.data;
  if (data is! Map) return null;
  final errors = data['errors'];
  if (errors is! Map) return null;

  final result = <String, String>{};
  errors.forEach((key, value) {
    final fieldKey = key.toString();
    if (value is String && value.trim().isNotEmpty) {
      result[fieldKey] = value;
    } else if (value is List && value.isNotEmpty) {
      result[fieldKey] = value.first.toString();
    }
  });
  return result.isEmpty ? null : result;
}
