import 'dart:io';

import 'package:dio/dio.dart';

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
      throw const ApiException('No internet connection');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
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
      throw const ApiException('No internet connection');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
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
      throw const ApiException('No internet connection');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
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
      throw const ApiException('No internet connection');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
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
      throw const ApiException('No internet connection');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
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
        if (data != null) ...data,
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
      throw const ApiException('No internet connection');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  ApiException _handleError(DioException error) {
    final statusCode = error.response?.statusCode;

    String? message;
    if (error.response?.data != null && error.response!.data is Map) {
      message = error.response!.data['message'] as String?;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(message ?? 'Request timeout',
            statusCode: statusCode);
      case DioExceptionType.cancel:
        return ApiException(message ?? 'Request cancelled',
            statusCode: statusCode);
      case DioExceptionType.connectionError:
        return ApiException(message ?? 'No internet connection',
            statusCode: statusCode);
      case DioExceptionType.badCertificate:
        return ApiException(message ?? 'Bad certificate',
            statusCode: statusCode);
      case DioExceptionType.badResponse:
        return ApiException(message ?? 'Request failed',
            statusCode: statusCode);
      case DioExceptionType.unknown:
        return ApiException(message ?? 'Request failed',
            statusCode: statusCode);
      case DioExceptionType.transformTimeout:
        return ApiException(message ?? 'Request timeout',
            statusCode: statusCode);
    }
  }
}
