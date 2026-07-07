import 'package:dio/dio.dart';

import '../interfaces/language_provider.dart';
import 'interceptor_logger_config.dart';

/// Adds `Accept-Language` to every request, pulling the current code from
/// the injected [LanguageProvider].
class LanguageInterceptor extends Interceptor {
  final LanguageProvider provider;

  LanguageInterceptor({required this.provider});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final code = provider.getLanguageCode();
    options.headers['Accept-Language'] = code;
    InterceptorLoggerConfig.logInfo(
      title: 'Language Added',
      details: InterceptorLoggerConfig.createRequestDetailsWith(
        options,
        additionalInfo: 'Accept-Language: $code',
      ),
    );
    handler.next(options);
  }
}
