import 'dart:async';

import 'package:dio/dio.dart';

import '../adapters/api_kit_runtime.dart';

/// Adds the user access token to outgoing requests and handles automatic
/// refresh on `401`.
///
/// Reads everything from [ApiKitRuntime]:
/// - `tokenStorage` — for reading/saving tokens.
/// - `onRefreshToken` — to exchange a refresh token (or access token, for
///   Sanctum-style flows) for a new access token.
/// - `onLogout` — invoked when refresh fails or no usable token is stored.
/// - `skipUserAuthEndpoints` — paths that must NOT have the user token added.
/// - `skipRefreshEndpoints` — paths that must NOT trigger refresh on 401.
///
/// Refresh-token strategy:
/// - If the configured [TokenRefreshCallback] expects a real refresh token,
///   provide one via the storage adapter. The interceptor will hand it off.
/// - For Laravel-Sanctum style flows where the API only mints access tokens
///   (no separate refresh token), have the storage adapter return the
///   current access token from `getRefreshToken()` — the interceptor will
///   pass it through and your callback can re-auth with it as the Bearer.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.dio});

  final Dio dio;

  /// Marks a request as a post-refresh retry so a second 401 on it can never
  /// trigger another refresh (infinite-loop guard).
  static const String _retryAfterRefreshKey = 'retry_after_refresh';

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

    // Respect a per-request Authorization override (e.g. a 2FA challenge
    // token passed via `bearerTokenOverride`): if one is already set, don't
    // replace it with the stored session token.
    final hasExplicitAuth =
        (options.headers['Authorization'] as String?)?.isNotEmpty ?? false;
    if (hasExplicitAuth) {
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
        err.requestOptions.extra[_retryAfterRefreshKey] == true ||
        _shouldSkipRefresh(err.requestOptions.path) ||
        _shouldSkipUserAuth(err.requestOptions.path)) {
      return handler.next(err);
    }

    final refresh = ApiKitRuntime.onRefreshToken;
    if (refresh == null) {
      await _handleLogout();
      return handler.next(err);
    }

    if (_isRefreshing) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;
    var refreshSucceeded = false;
    DioException? pendingError;

    try {
      // Try the refresh token first; if absent (e.g. Sanctum), fall back to
      // the access token so the callback still has *something* to send.
      var seedToken = await ApiKitRuntime.tokenStorage.getRefreshToken();
      if (seedToken == null || seedToken.isEmpty) {
        seedToken = await ApiKitRuntime.tokenStorage.getAccessToken();
      }
      if (seedToken == null || seedToken.isEmpty) {
        await _handleLogout();
        pendingError = err;
        return handler.next(err);
      }

      final newAccessToken = await refresh(seedToken);
      if (newAccessToken == null) {
        await _handleLogout();
        pendingError = err;
        return handler.next(err);
      }

      refreshSucceeded = true;

      try {
        final response = await _retryRequest(err.requestOptions);
        handler.resolve(response);
      } on DioException catch (retryError) {
        // A second 401 after a successful refresh means the new token is not
        // accepted — sign out. Any other retry failure (network blip, 5xx) is
        // the request's own problem; the refreshed session stays valid.
        if (retryError.response?.statusCode == 401) {
          refreshSucceeded = false;
          pendingError = retryError;
          await _handleLogout();
        }
        handler.next(retryError);
      }
    } catch (e) {
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

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
  ) async {
    // Remove the old Authorization header so onRequest can attach the fresh
    // one; `fetch(copyWith(...))` preserves every other request property
    // (extra, responseType, timeouts) that a manual rebuild would drop.
    final headers = Map<String, dynamic>.from(requestOptions.headers)
      ..remove('Authorization');
    final extra = Map<String, dynamic>.from(requestOptions.extra)
      ..[_retryAfterRefreshKey] = true;

    return dio.fetch<dynamic>(
      requestOptions.copyWith(headers: headers, extra: extra),
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
