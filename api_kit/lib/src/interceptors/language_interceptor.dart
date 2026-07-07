import 'package:dio/dio.dart';

import '../adapters/api_kit_runtime.dart';
import 'interceptor_logger_config.dart';

/// Adds the active language code as both the `Accept-Language` header and a
/// `locale` query parameter on every outgoing request.
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
          options.headers['Accept-Language'] = code;
          options.queryParameters['locale'] = code;

          InterceptorLoggerConfig.logInfo(
            title: 'Language Added',
            details: InterceptorLoggerConfig.createRequestDetailsWith(
              options,
              additionalInfo: 'Accept-Language: $code',
            ),
          );
        }
      } catch (_) {
        // Don't block the request if the language lookup fails.
      }
    }
    super.onRequest(options, handler);
  }
}
