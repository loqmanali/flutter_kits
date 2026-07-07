import 'package:dio/dio.dart';

import '../adapters/api_kit_runtime.dart';

/// Attaches the static bearer token configured on
/// [ApiKitRuntime.staticBearerToken] (e.g. an Odoo catalog token) to every
/// outgoing request, unless an `Authorization` header is already present.
///
/// If no static token is configured, the interceptor is a no-op.
class StaticTokenInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = ApiKitRuntime.staticBearerToken;
    if (token != null && token.isNotEmpty) {
      final alreadySet = options.headers.containsKey('Authorization');
      if (!alreadySet) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }
}
