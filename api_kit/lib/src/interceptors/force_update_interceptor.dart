import 'package:dio/dio.dart';

import '../adapters/api_kit_runtime.dart';
import 'interceptor_logger_config.dart';

/// Called by [ForceUpdateInterceptor] when the server returns `426`.
///
/// Implementations typically present a non-dismissible "please update"
/// dialog and open the relevant store. Kept as a callback so api_kit stays
/// free of UI dependencies.
typedef ForceUpdateCallback = void Function({
  String? message,
  String? minVersion,
  String? currentVersion,
});

/// {@template force_update_interceptor}
/// Watches for `426 Upgrade Required` responses and forwards them to
/// [ApiKitRuntime.onForceUpdate].
///
/// The interceptor never blocks the request flow — it always passes the
/// error along after firing the callback so error handling further up the
/// stack still runs (e.g. mapping to [AppUpdateRequiredFailure]).
/// {@endtemplate}
class ForceUpdateInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 426) {
      _handleForceUpdate(err);
    }
    handler.next(err);
  }

  void _handleForceUpdate(DioException err) {
    String? message;
    String? minVersion;

    final data = err.response?.data;
    if (data is Map) {
      message = data['message'] as String?;
      minVersion = data['min_version'] as String?;
    }

    InterceptorLoggerConfig.logError(
      title: 'Force Update Required',
      details: [
        '${err.requestOptions.method} ${err.requestOptions.uri}',
        if (ApiKitRuntime.appVersion != null)
          'Current Version: ${ApiKitRuntime.appVersion}',
        if (minVersion != null) 'Required Version: $minVersion',
        if (ApiKitRuntime.onForceUpdate == null)
          'Action: no onForceUpdate callback registered'
        else
          'Action: invoking onForceUpdate callback',
      ],
    );

    ApiKitRuntime.onForceUpdate?.call(
      message: message,
      minVersion: minVersion,
      currentVersion: ApiKitRuntime.appVersion,
    );
  }
}
