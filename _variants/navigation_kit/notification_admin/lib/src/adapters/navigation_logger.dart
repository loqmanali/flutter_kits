import 'dart:developer' as developer;

/// Logger contract used internally by navigation_kit.
///
/// The host app can plug in its own logger (e.g. AppLogger, Sentry, the
/// `logger` package, etc.) via `NavigationKitRuntime.use(logger: ...)`. If
/// none is provided, [DeveloperNavigationLogger] is used as a sensible default.
abstract class NavigationLogger {
  void debug(String message, [Object? error, StackTrace? stackTrace]);
  void info(String message, [Object? error, StackTrace? stackTrace]);
  void warning(String message, [Object? error, StackTrace? stackTrace]);
  void error(String message, [Object? error, StackTrace? stackTrace]);
}

/// Default logger — forwards to `dart:developer.log` so output appears in the
/// IDE debug log channel rather than the raw `print` stream.
class DeveloperNavigationLogger implements NavigationLogger {
  const DeveloperNavigationLogger();

  static const String _name = 'NavigationKit';

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message,
        name: _name, level: 500, error: error, stackTrace: stackTrace);
  }

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message,
        name: _name, level: 800, error: error, stackTrace: stackTrace);
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message,
        name: _name, level: 900, error: error, stackTrace: stackTrace);
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message,
        name: _name, level: 1000, error: error, stackTrace: stackTrace);
  }
}
