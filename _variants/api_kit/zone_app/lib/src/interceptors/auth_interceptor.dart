import 'dart:async';

import 'package:dio/dio.dart';

import '../adapters/api_kit_runtime.dart';

/// Adds the user access token to outgoing requests and handles automatic
/// refresh on `401`.
///
/// Reads everything from [ApiKitRuntime]:
/// - `tokenStorage` — for reading/saving tokens.
/// - `onRefreshToken` — to exchange a refresh token for a new access token.
/// - `onLogout` — invoked when refresh fails or no refresh token is stored.
/// - `skipUserAuthEndpoints` — paths that must NOT have the user token added.
/// - `skipRefreshEndpoints` — paths that must NOT trigger refresh on 401.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.dio});

  final Dio dio;

  bool _isRefreshing = false;

  final _pendingRequests =
      <({RequestOptions options, ErrorInterceptorHandler handler})>[];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldSkipUserAuth(options.path)) {
      handler.next(options);
      return;
    }

    final token = await ApiKitRuntime.tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  bool _shouldSkipUserAuth(String path) {
    return ApiKitRuntime.skipUserAuthEndpoints
        .any((endpoint) => path.startsWith(endpoint));
  }

  bool _shouldSkipRefresh(String path) {
    return ApiKitRuntime.skipRefreshEndpoints
        .any((endpoint) => path.contains(endpoint));
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    if (!isUnauthorized ||
        _shouldSkipRefresh(err.requestOptions.path) ||
        _shouldSkipUserAuth(err.requestOptions.path)) {
      return handler.next(err);
    }

    final refresh = ApiKitRuntime.onRefreshToken;
    if (refresh == null) return handler.next(err);

    if (_isRefreshing) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken =
          await ApiKitRuntime.tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _handleLogout();
        return handler.next(err);
      }

      final newAccessToken = await refresh(refreshToken);
      if (newAccessToken == null) {
        await _handleLogout();
        return handler.next(err);
      }

      final response = await _retryRequest(err.requestOptions);
      handler.resolve(response);

      await _processPendingRequests();
    } catch (_) {
      await _handleLogout();
      handler.next(err);
      _rejectPendingRequests(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
  ) async {
    // Remove the old Authorization header so onRequest can attach the fresh one.
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers.remove('Authorization');

    final options = Options(
      method: requestOptions.method,
      headers: headers,
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> _processPendingRequests() async {
    final requests =
        List<({RequestOptions options, ErrorInterceptorHandler handler})>.from(
      _pendingRequests,
    );
    _pendingRequests.clear();

    for (final request in requests) {
      try {
        final response = await _retryRequest(request.options);
        request.handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          request.handler.next(e);
        } else {
          request.handler.next(
            DioException(requestOptions: request.options, error: e),
          );
        }
      }
    }
  }

  void _rejectPendingRequests(DioException error) {
    for (final request in _pendingRequests) {
      request.handler.next(error);
    }
    _pendingRequests.clear();
  }

  Future<void> _handleLogout() async {
    await ApiKitRuntime.tokenStorage.clearAuthData();
    await ApiKitRuntime.onLogout?.call();
  }
}
