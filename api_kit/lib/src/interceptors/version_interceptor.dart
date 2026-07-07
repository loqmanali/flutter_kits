import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../adapters/api_kit_runtime.dart';
import 'interceptor_logger_config.dart';

/// {@template version_interceptor}
/// Adds the running app version and platform to every outgoing request.
///
/// Reads [ApiKitRuntime.appVersion]. If no version is configured, the
/// interceptor is a no-op so it is safe to register unconditionally.
///
/// Headers added:
/// - `X-App-Version`
/// - `X-App-Platform` (`android`, `ios`, `web`, or `unknown`)
///
/// The server uses these to decide whether the client is below the minimum
/// supported version (typically responding with `426 Upgrade Required`).
/// {@endtemplate}
class VersionInterceptor extends Interceptor {
  VersionInterceptor() : platform = _detectPlatform();

  /// Current platform string sent on every request.
  final String platform;

  static String _detectPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final appVersion = ApiKitRuntime.appVersion;
    if (appVersion == null || appVersion.isEmpty) {
      handler.next(options);
      return;
    }

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
