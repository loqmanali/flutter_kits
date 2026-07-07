import 'package:dio/dio.dart';

import '../adapters/api_kit_runtime.dart';

/// Adds the active language code as a `locale` query parameter on every
/// outgoing request.
///
/// The code is read via [ApiKitRuntime.languageCodeProvider]. If no provider
/// is configured, the interceptor is a no-op.
class LanguageInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final provider = ApiKitRuntime.languageCodeProvider;
    if (provider != null) {
      try {
        final code = await provider();
        if (code.isNotEmpty) {
          options.queryParameters['locale'] = code;
        }
      } catch (_) {
        // Don't block the request if the language lookup fails.
      }
    }
    super.onRequest(options, handler);
  }
}
