import 'package:flutter/foundation.dart';

/// Logger contract used internally by notification_kit.
///
/// The host app can plug in its own logger (e.g. Sentry, Logger package, etc.)
/// via [NotificationKitRuntime.use]. If none is provided, [DebugPrintLogger]
/// is used as a sensible default.
abstract class NotificationLogger {
  void debug(String message, [Object? error, StackTrace? stackTrace]);
  void info(String message, [Object? error, StackTrace? stackTrace]);
  void warning(String message, [Object? error, StackTrace? stackTrace]);
  void error(String message, [Object? error, StackTrace? stackTrace]);
}

/// Default logger — forwards to [debugPrint].
class DebugPrintLogger implements NotificationLogger {
  const DebugPrintLogger();

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[NotificationKit][DEBUG] $message${error != null ? ' | $error' : ''}');
  }

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[NotificationKit][INFO] $message${error != null ? ' | $error' : ''}');
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[NotificationKit][WARN] $message${error != null ? ' | $error' : ''}');
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[NotificationKit][ERROR] $message${error != null ? ' | $error' : ''}');
  }
}
