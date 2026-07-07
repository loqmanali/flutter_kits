import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'interceptor_logger_config.dart';

/// Adds version + platform headers to every request.
///
/// - `X-App-Version` — `appVersion`
/// - `X-App-Platform` — auto-detected (`android` / `ios` / `web` / `unknown`)
class VersionInterceptor extends Interceptor {
  final String appVersion;
  final String platform;

  VersionInterceptor({required this.appVersion}) : platform = _detectPlatform();

  static String _detectPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-App-Version'] = appVersion;
    options.headers['X-App-Platform'] = platform;

    InterceptorLoggerConfig.logInfo(
      title: 'Version Headers Added',
      details: InterceptorLoggerConfig.createRequestDetailsWith(
        options,
        additionalInfo: 'X-App-Version: $appVersion, X-App-Platform: $platform',
      ),
    );
    handler.next(options);
  }
}
