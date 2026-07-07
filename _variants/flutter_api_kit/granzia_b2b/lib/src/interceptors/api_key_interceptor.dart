import 'package:dio/dio.dart';

import 'interceptor_logger_config.dart';

/// Generic header-injection interceptor.
///
/// Often used for static API keys: `ApiKeyInterceptor(headerName: 'api-key',
/// value: '<key>')`. Set [redactInLogs] to log a masked preview only.
class ApiKeyInterceptor extends Interceptor {
  final String headerName;
  final String value;
  final bool redactInLogs;

  const ApiKeyInterceptor({
    required this.headerName,
    required this.value,
    this.redactInLogs = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[headerName] = value;

    final preview = redactInLogs
        ? '${value.substring(0, value.length > 8 ? 8 : value.length)}…'
        : value;

    InterceptorLoggerConfig.logInfo(
      title: 'API Key Header Added',
      details: [
        ...InterceptorLoggerConfig.createRequestDetails(options),
        'Header: $headerName: $preview',
      ],
    );
    handler.next(options);
  }
}
