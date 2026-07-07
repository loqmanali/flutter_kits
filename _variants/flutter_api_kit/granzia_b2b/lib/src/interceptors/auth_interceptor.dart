import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../config/api_kit_config.dart';
import '../config/auth_options.dart';
import '../interfaces/token_storage.dart';
import 'interceptor_logger_config.dart';

/// Invoked when the auth flow decides the user must be signed out.
typedef LogoutCallback = Future<void> Function();

/// Pluggable token-refresh implementation.
///
/// Receives the current refresh token, returns the new token pair, or
/// `null` if the refresh failed (which triggers logout).
typedef RefreshTokenCallback = Future<TokenPair?> Function(String refreshToken);

/// Pair returned from a successful refresh.
class TokenPair {
  final String accessToken;
  final String refreshToken;
  const TokenPair({required this.accessToken, required this.refreshToken});
}

/// Bearer-token injection + 401 handling + optional refresh-token flow.
///
/// The refresh flow is concurrency-safe: while a refresh is in flight,
/// concurrent 401s are queued and replayed once the new token lands.
class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final Dio dio;
  final ApiKitConfig config;
  final AuthOptions authOptions;
  final LogoutCallback? onLogout;

  /// Optional custom refresh implementation. If `null` and refresh is
  /// enabled, the interceptor falls back to a default POST to
  /// `config.refreshTokenEndpoint` expecting a JSON body of
  /// `{ access_token, refresh_token }`.
  final RefreshTokenCallback? refreshTokenCallback;

  /// Separate Dio for refresh calls — no interceptors, so refresh requests
  /// never recurse back through this same interceptor.
  late final Dio _refreshDio;

  static const String _retryAfterRefreshKey = 'retry_after_refresh';

  int _refreshAttemptCount = 0;
  bool _isRefreshing = false;
  final _pendingRequests =
      <({RequestOptions options, ErrorInterceptorHandler handler})>[];
  Completer<void>? _tokenLoadCompleter;

  AuthInterceptor({
    required this.tokenStorage,
    required this.dio,
    required this.config,
    this.authOptions = AuthOptions.defaults,
    this.onLogout,
    this.refreshTokenCallback,
  }) {
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log('AuthInterceptor onRequest: ${options.method} ${options.path}');

    if (_shouldSkipUserAuth(options.path, options.method)) {
      _logAuthSkipped(options, 'Public endpoint');
      handler.next(options);
      return;
    }

    final cached = tokenStorage.getAccessTokenSync();
    if (cached == null || cached.isEmpty) {
      developer.log('Token not in cache, loading from storage...');

      if (_tokenLoadCompleter != null && !_tokenLoadCompleter!.isCompleted) {
        _tokenLoadCompleter!.future.then((_) {
          final loaded = tokenStorage.getAccessTokenSync();
          _applyTokenAndProceed(loaded, options, handler);
        }).catchError((_) {
          _logNoAuth(options);
          handler.next(options);
        });
        return;
      }

      _tokenLoadCompleter = Completer<void>();
      tokenStorage.getAccessToken().then((loaded) {
        _tokenLoadCompleter!.complete();
        _applyTokenAndProceed(loaded, options, handler);
      }).catchError((_) {
        _tokenLoadCompleter!.completeError('Failed to load token');
        _logNoAuth(options);
        handler.next(options);
      });
      return;
    }

    _applyTokenAndProceed(cached, options, handler);
  }

  void _applyTokenAndProceed(
    String? token,
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      _logAuthAdded(options, token);
    } else {
      _logNoAuth(options);
    }
    handler.next(options);
  }

  bool _shouldSkipUserAuth(String path, String method) {
    return config.publicEndpoints
        .any((endpoint) => path.startsWith(endpoint));
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _logError(err);

    if (err.response?.statusCode != 401 ||
        _shouldSkipRefresh(err.requestOptions.path) ||
        _isRetryAfterRefresh(err.requestOptions) ||
        _shouldSkipUserAuth(
          err.requestOptions.path,
          err.requestOptions.method,
        )) {
      return handler.next(err);
    }

    if (!authOptions.enableRefreshTokenFlow) {
      _logRefreshDisabled(err.requestOptions);
      await _handleLogout();
      return handler.next(err);
    }

    if (_isRefreshing) {
      _logRequestQueued(err.requestOptions);
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;
    var refreshSucceeded = false;
    DioException? pendingError;
    _logTokenRefreshStarted(err.requestOptions);

    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _logNoRefreshToken();
        _refreshAttemptCount = 0;
        await _handleLogout();
        pendingError = err;
        return handler.next(err);
      }

      if (_refreshAttemptCount >= config.maxRefreshAttempts) {
        _logMaxRefreshAttemptsExceeded();
        _refreshAttemptCount = 0;
        await _handleLogout();
        pendingError = err;
        return handler.next(err);
      }

      _refreshAttemptCount++;

      final newTokens = await _performTokenRefresh(refreshToken);
      if (newTokens == null) {
        _logTokenRefreshFailed();
        _refreshAttemptCount = 0;
        await _handleLogout();
        pendingError = err;
        return handler.next(err);
      }

      await tokenStorage.saveAuthTokens(
        accessToken: newTokens.accessToken,
        refreshToken: newTokens.refreshToken,
      );

      _refreshAttemptCount = 0;
      refreshSucceeded = true;
      _logTokenRefreshSuccess();

      try {
        final response = await _retryRequest(err.requestOptions);
        handler.resolve(response);
      } on DioException catch (retryError) {
        if (retryError.response?.statusCode == 401) {
          refreshSucceeded = false;
          pendingError = retryError;
          await _handleLogout();
        }
        handler.next(retryError);
      }
    } catch (e) {
      _logTokenRefreshError(e);
      _refreshAttemptCount = 0;
      await _handleLogout();
      if (e is DioException) {
        pendingError = e;
        handler.next(e);
      } else {
        pendingError = err;
        handler.next(err);
      }
    } finally {
      _isRefreshing = false;
      if (refreshSucceeded) {
        await _processPendingRequests();
      } else if (pendingError != null) {
        _rejectPendingRequests(pendingError);
      }
    }
  }

  bool _isRetryAfterRefresh(RequestOptions options) =>
      options.extra[_retryAfterRefreshKey] == true;

  DioException _mapErrorToRequest(
    DioException source,
    RequestOptions requestOptions,
  ) {
    return DioException(
      requestOptions: requestOptions,
      response: source.response,
      type: source.type,
      error: source.error,
      stackTrace: source.stackTrace,
      message: source.message,
    );
  }

  Future<TokenPair?> _performTokenRefresh(String refreshToken) async {
    if (refreshTokenCallback != null) {
      try {
        return await refreshTokenCallback!(refreshToken);
      } catch (e) {
        developer.log('Custom refresh callback threw: $e');
        return null;
      }
    }

    try {
      final response = await _refreshDio.post(
        config.refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final access = data['access_token'] as String?;
        final refresh = data['refresh_token'] as String?;
        if (access != null && refresh != null) {
          return TokenPair(accessToken: access, refreshToken: refresh);
        }
      }
      return null;
    } catch (e) {
      developer.log('Default refresh failed: $e');
      return null;
    }
  }

  bool _shouldSkipRefresh(String path) =>
      config.skipRefreshEndpoints.any((endpoint) => path.contains(endpoint));

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
  ) async {
    final headers = Map<String, dynamic>.from(requestOptions.headers)
      ..remove('Authorization');
    final extra = Map<String, dynamic>.from(requestOptions.extra)
      ..[_retryAfterRefreshKey] = true;

    return dio.fetch<dynamic>(
      requestOptions.copyWith(headers: headers, extra: extra),
    );
  }

  Future<void> _processPendingRequests() async {
    final requests = List<({RequestOptions options, ErrorInterceptorHandler handler})>.from(
      _pendingRequests,
    );
    _pendingRequests.clear();

    for (final request in requests) {
      try {
        final response = await _retryRequest(request.options);
        request.handler.resolve(response);
      } on DioException catch (e) {
        request.handler.next(_mapErrorToRequest(e, request.options));
      } catch (e) {
        request.handler
            .next(DioException(requestOptions: request.options, error: e));
      }
    }
  }

  void _rejectPendingRequests(DioException? error) {
    if (error == null) return;
    for (final request in _pendingRequests) {
      request.handler.next(_mapErrorToRequest(error, request.options));
    }
    _pendingRequests.clear();
  }

  Future<void> _handleLogout() async {
    _logLogoutTriggered();
    await tokenStorage.clearAuthData();
    await onLogout?.call();
  }

  String _tokenPreview(String token) =>
      token.length <= 20 ? token : '${token.substring(0, 20)}...';

  // ---- logging helpers ----

  void _logAuthAdded(RequestOptions options, String token) {
    InterceptorLoggerConfig.logSuccess(
      title: 'Auth Token Added',
      details: [
        ...InterceptorLoggerConfig.createRequestDetails(options),
        'Token: ${_tokenPreview(token)}',
        'Header: Authorization: Bearer <token>',
      ],
    );
  }

  void _logNoAuth(RequestOptions options) {
    InterceptorLoggerConfig.logWarning(
      title: 'No Auth Token',
      details: [
        ...InterceptorLoggerConfig.createRequestDetails(options),
        'Reason: No token found in storage',
      ],
    );
  }

  void _logAuthSkipped(RequestOptions options, String reason) {
    InterceptorLoggerConfig.logSkipped(
      title: 'Auth Skipped',
      details: [
        ...InterceptorLoggerConfig.createRequestDetails(options),
        'Reason: $reason',
      ],
    );
  }

  void _logError(DioException err) {
    InterceptorLoggerConfig.logError(
      title: 'Auth Error',
      details: [
        '${err.type}: ${err.message}',
        '${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.uri}',
        if (err.response?.data != null) 'Response: ${err.response?.data}',
      ],
    );
  }

  void _logRequestQueued(RequestOptions options) {
    InterceptorLoggerConfig.logWarning(
      title: 'Request Queued',
      details: [
        ...InterceptorLoggerConfig.createRequestDetails(options),
        'Reason: Token refresh in progress',
      ],
    );
  }

  void _logRefreshDisabled(RequestOptions options) {
    InterceptorLoggerConfig.logSkipped(
      title: 'Token Refresh Disabled',
      details: [
        ...InterceptorLoggerConfig.createRequestDetails(options),
        'Reason: AuthOptions.enableRefreshTokenFlow = false',
      ],
    );
  }

  void _logTokenRefreshStarted(RequestOptions options) {
    InterceptorLoggerConfig.logInfo(
      title: 'Token Refresh Started',
      details: ['For request: ${options.method} ${options.uri}'],
    );
  }

  void _logNoRefreshToken() {
    InterceptorLoggerConfig.logError(
      title: 'No Refresh Token',
      details: [
        'Reason: No refresh token found in storage',
        'Action: Logging out user',
      ],
    );
  }

  void _logTokenRefreshFailed() {
    InterceptorLoggerConfig.logError(
      title: 'Token Refresh Failed',
      details: [
        'Reason: Refresh callback returned null',
        'Action: Logging out user',
      ],
    );
  }

  void _logTokenRefreshSuccess() {
    InterceptorLoggerConfig.logSuccess(
      title: 'Token Refresh Success',
      details: [
        'New token obtained and saved',
        'Action: Retrying original request',
      ],
    );
  }

  void _logTokenRefreshError(dynamic error) {
    InterceptorLoggerConfig.logError(
      title: 'Token Refresh Error',
      details: ['Error: $error', 'Action: Logging out user'],
    );
  }

  void _logLogoutTriggered() {
    InterceptorLoggerConfig.logWarning(
      title: 'Logout Triggered',
      details: [
        'Auth data cleared from storage',
        'Logout callback executed',
      ],
    );
  }

  void _logMaxRefreshAttemptsExceeded() {
    InterceptorLoggerConfig.logError(
      title: 'Max Refresh Attempts Exceeded',
      details: [
        'Reason: Exceeded ${config.maxRefreshAttempts} refresh attempts',
        'Action: Logging out user',
      ],
    );
  }
}
