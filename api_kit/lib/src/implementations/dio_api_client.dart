import 'dart:io';

import 'package:dio/dio.dart';

import '../adapters/api_kit_runtime.dart';
import '../api_token_type.dart';
import '../exceptions/api_exception.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/force_update_interceptor.dart';
import '../interceptors/language_interceptor.dart';
import '../interceptors/pretty_dio_logger.dart';
import '../interceptors/static_token_interceptor.dart';
import '../interceptors/version_interceptor.dart';
import '../interfaces/api_client.dart';

/// Concrete implementation of [ApiClient] using Dio.
///
/// All configuration (`baseUrl`, `timeout`, `defaultHeaders`, token storage,
/// auth callbacks, language code, static bearer token, app version, force-
/// update handler) is read from [ApiKitRuntime] — there's no host-app
/// coupling.
///
/// Factory shapes:
/// - [DioApiClient()] — user auth + static token
/// - [DioApiClient.authenticated] — user token only
/// - [DioApiClient.publicStatic] — static bearer token only
/// - [DioApiClient.public] — no auth at all (still gets language / version /
///   force-update interceptors)
/// - [DioApiClient.bare] — completely raw, no interceptors (useful for the
///   refresh-token request itself to avoid recursion)
/// - [DioApiClient.fromTokenType] — dispatches on an [ApiTokenType]
class DioApiClient implements ApiClient {
  DioApiClient._internal({
    Duration? timeout,
    required bool useAuth,
    required bool useStaticToken,
    bool useAppCommonInterceptors = true,
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

    if (useAppCommonInterceptors) {
      // Version + force update piggy-back on ApiKitRuntime config; both are
      // no-ops if not configured, so it's safe to always register them.
      _dio.interceptors.add(VersionInterceptor());
      _dio.interceptors.add(ForceUpdateInterceptor());

      if (ApiKitRuntime.enablePrettyLogger) {
        final hostLogPrint = ApiKitRuntime.logPrint;
        _dio.interceptors.add(
          hostLogPrint == null
              ? PrettyDioLogger()
              : PrettyDioLogger.builder(
                  (builder) => builder
                    ..setLogPrint(hostLogPrint)
                    ..setEnableColors(false),
                ),
        );
      }
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

  /// Public client — no auth at all. Still includes language / version /
  /// force-update / pretty-logger so behaviour matches the authenticated
  /// client for non-auth concerns.
  factory DioApiClient.public({
    Duration? timeout,
    List<Interceptor> extraInterceptors = const [],
  }) {
    return DioApiClient._internal(
      timeout: timeout,
      useAuth: false,
      useStaticToken: false,
      extraInterceptors: extraInterceptors,
    );
  }

  /// Bare client — NO interceptors of any kind.
  ///
  /// Use this for the refresh-token request itself so the auth interceptor
  /// doesn't try to refresh while refreshing.
  factory DioApiClient.bare({
    Duration? timeout,
    List<Interceptor> extraInterceptors = const [],
  }) {
    return DioApiClient._internal(
      timeout: timeout,
      useAuth: false,
      useStaticToken: false,
      useAppCommonInterceptors: false,
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
  Future<List<int>> getBytes(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        endpoint,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? const <int>[];
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

  @override
  Future<String> downloadToFile(
    String endpoint, {
    required String savePath,
    Map<String, dynamic>? queryParameters,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      await _dio.download(
        endpoint,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onProgress,
      );
      return savePath;
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
    String? minVersion;
    String? storeUrl;
    if (error.response?.data != null && error.response!.data is Map) {
      final data = error.response!.data as Map;
      message = data['message'] as String?;
      minVersion = data['min_version'] as String?;
      storeUrl = data['store_url'] as String?;
    }

    if (statusCode == 426) {
      return AppUpdateRequiredException(
        message: message,
        minVersion: minVersion,
        storeUrl: storeUrl,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
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
    }
  }
}
