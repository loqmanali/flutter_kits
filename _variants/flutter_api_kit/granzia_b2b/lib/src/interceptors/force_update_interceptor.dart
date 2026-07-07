import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../interfaces/force_update_handler.dart';
import 'interceptor_logger_config.dart';

/// Handles 426 Upgrade Required by delegating to the injected
/// [ForceUpdateHandler]. The package itself never renders UI.
class ForceUpdateInterceptor extends Interceptor {
  final String currentVersion;
  final ForceUpdateHandler forceUpdateHandler;

  ForceUpdateInterceptor({
    required this.currentVersion,
    required this.forceUpdateHandler,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 426) {
      _handleForceUpdate(err);
    }
    handler.next(err);
  }

  void _handleForceUpdate(DioException err) {
    developer.log('Force update required (426)');

    String? message;
    String? minVersion;
    String? storeUrl;

    if (err.response?.data != null && err.response!.data is Map) {
      final data = err.response!.data as Map;
      message = data['message'] as String?;
      minVersion = data['min_version'] as String?;
      storeUrl = data['storeUrl'] as String?;
    }

    InterceptorLoggerConfig.logError(
      title: 'Force Update Required',
      details: [
        '${err.requestOptions.method} ${err.requestOptions.uri}',
        'Current Version: $currentVersion',
        if (minVersion != null) 'Required Version: $minVersion',
        'Action: Delegating to ForceUpdateHandler',
      ],
    );

    forceUpdateHandler.showForceUpdateDialog(
      message: message,
      minVersion: minVersion,
      currentVersion: currentVersion,
      storeUrl: storeUrl,
    );
  }
}
