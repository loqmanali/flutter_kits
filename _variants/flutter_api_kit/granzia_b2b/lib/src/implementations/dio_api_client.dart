import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

import '../config/api_kit_config.dart';
import '../config/api_token_type.dart';
import '../config/auth_options.dart';
import '../exceptions/api_exception.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/force_update_interceptor.dart';
import '../interceptors/language_interceptor.dart';
import '../interceptors/pretty_dio_logger.dart';
import '../interceptors/version_interceptor.dart';
import '../interfaces/api_client.dart';
import '../interfaces/force_update_handler.dart';
import '../interfaces/language_provider.dart';
import '../interfaces/token_storage.dart';

/// Concrete [ApiClient] backed by Dio.
///
/// Three factories cover the common cases:
/// - [DioApiClient.authenticated] — auth + language + version interceptors
/// - [DioApiClient.public]        — language + version, no auth
/// - [DioApiClient.bare]          — only the logger (used for refresh calls)
///
/// Use [DioApiClient.fromTokenType] when the call site already has an
/// [ApiTokenType] handy and wants the appropriate factory chosen for it.
class DioApiClient implements ApiClient {
  late final Dio _dio;
  final ApiKitConfig config;

  DioApiClient._internal({
    required this.config,
    required bool useAuth,
    LanguageProvider? languageProvider,
    TokenStorage? tokenStorage,
    AuthOptions authOptions = AuthOptions.defaults,
    LogoutCallback? onLogout,
    RefreshTokenCallback? refreshTokenCallback,
    ForceUpdateHandler? forceUpdateHandler,
    List<Interceptor> extraInterceptors = const [],
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: Duration(milliseconds: config.timeoutMs),
        receiveTimeout: Duration(milliseconds: config.timeoutMs),
        headers: Map<String, String>.from(config.defaultHeaders),
      ),
    );

    if (languageProvider != null) {
      _dio.interceptors.add(LanguageInterceptor(provider: languageProvider));
    }

    if (useAuth && tokenStorage != null) {
      _dio.interceptors.add(
        AuthInterceptor(
          tokenStorage: tokenStorage,
          dio: _dio,
          config: config,
          authOptions: authOptions,
          onLogout: onLogout,
          refreshTokenCallback: refreshTokenCallback,
        ),
      );
    }

    _dio.interceptors.add(VersionInterceptor(appVersion: config.appVersion));

    if (forceUpdateHandler != null) {
      _dio.interceptors.add(
        ForceUpdateInterceptor(
          currentVersion: config.appVersion,
          forceUpdateHandler: forceUpdateHandler,
        ),
      );
    }

    for (final i in extraInterceptors) {
      _dio.interceptors.add(i);
    }

    if (config.enableLogger) {
      _dio.interceptors.add(
        PrettyDioLogger(
          config: const LoggerConfig(
            requestBody: true,
            responseBody: true,
          ),
        ),
      );
    }
  }

  /// Auth-aware client (default).
  factory DioApiClient.authenticated({
    required ApiKitConfig config,
    required TokenStorage tokenStorage,
    LanguageProvider? languageProvider,
    AuthOptions authOptions = AuthOptions.defaults,
    LogoutCallback? onLogout,
    RefreshTokenCallback? refreshTokenCallback,
    ForceUpdateHandler? forceUpdateHandler,
    List<Interceptor> extraInterceptors = const [],
  }) {
    return DioApiClient._internal(
      config: config,
      useAuth: true,
      tokenStorage: tokenStorage,
      languageProvider: languageProvider,
      authOptions: authOptions,
      onLogout: onLogout,
      refreshTokenCallback: refreshTokenCallback,
      forceUpdateHandler: forceUpdateHandler,
      extraInterceptors: extraInterceptors,
    );
  }

  /// Public client — no auth interceptor, but still gets language/version.
  factory DioApiClient.public({
    required ApiKitConfig config,
    LanguageProvider? languageProvider,
    ForceUpdateHandler? forceUpdateHandler,
    List<Interceptor> extraInterceptors = const [],
  }) {
    return DioApiClient._internal(
      config: config,
      useAuth: false,
      languageProvider: languageProvider,
      forceUpdateHandler: forceUpdateHandler,
      extraInterceptors: extraInterceptors,
    );
  }

  /// Bare client — only the pretty logger. Used for refresh-token requests
  /// to avoid a circular dependency where AuthInterceptor would try to
  /// refresh during refresh.
  factory DioApiClient.bare({required ApiKitConfig config}) {
    return DioApiClient._internal(config: config, useAuth: false);
  }

  /// Dispatches to the right factory for a given [ApiTokenType].
  factory DioApiClient.fromTokenType({
    required ApiTokenType tokenType,
    required ApiKitConfig config,
    TokenStorage? tokenStorage,
    LanguageProvider? languageProvider,
    AuthOptions authOptions = AuthOptions.defaults,
    LogoutCallback? onLogout,
    RefreshTokenCallback? refreshTokenCallback,
    ForceUpdateHandler? forceUpdateHandler,
    List<Interceptor> extraInterceptors = const [],
  }) {
    switch (tokenType) {
      case ApiTokenType.userToken:
        if (tokenStorage == null) {
          throw ArgumentError(
            'tokenStorage is required for ApiTokenType.userToken',
          );
        }
        return DioApiClient.authenticated(
          config: config,
          tokenStorage: tokenStorage,
          languageProvider: languageProvider,
          authOptions: authOptions,
          onLogout: onLogout,
          refreshTokenCallback: refreshTokenCallback,
          forceUpdateHandler: forceUpdateHandler,
          extraInterceptors: extraInterceptors,
        );
      case ApiTokenType.none:
        return DioApiClient.public(
          config: config,
          languageProvider: languageProvider,
          forceUpdateHandler: forceUpdateHandler,
          extraInterceptors: extraInterceptors,
        );
    }
  }

  /// Underlying Dio instance — exposed for advanced use (cancel tokens,
  /// streamed responses, etc.).
  Dio get dio => _dio;

  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
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
    Duration? receiveTimeout,
  }) async {
    try {
      if (receiveTimeout != null) {
        log('post($endpoint) using receiveTimeout=${receiveTimeout.inSeconds}s');
      }
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: receiveTimeout != null
            ? Options(
                receiveTimeout: receiveTimeout,
                sendTimeout: receiveTimeout,
              )
            : null,
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
    String? minVersion;
    String? storeUrl;

    if (error.response?.data != null && error.response!.data is Map) {
      final data = error.response!.data as Map;
      message = data['message'] as String?;
      minVersion = data['min_version'] as String?;
      storeUrl = data['storeUrl'] as String?;
    }

    if (statusCode == 426) {
      return AppUpdateRequiredException(
        message: message ?? 'Please update your app to continue.',
        minVersion: minVersion,
        storeUrl: storeUrl,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(message ?? 'Request timeout', statusCode: statusCode);
      case DioExceptionType.cancel:
        return ApiException(message ?? 'Request cancelled', statusCode: statusCode);
      case DioExceptionType.connectionError:
        return ApiException(message ?? 'No internet connection', statusCode: statusCode);
      case DioExceptionType.badCertificate:
        return ApiException(message ?? 'Bad certificate', statusCode: statusCode);
      case DioExceptionType.badResponse:
        return ApiException(message ?? 'Request failed', statusCode: statusCode);
      default:
        return ApiException(message ?? 'Request failed', statusCode: statusCode);
    }
  }
}
