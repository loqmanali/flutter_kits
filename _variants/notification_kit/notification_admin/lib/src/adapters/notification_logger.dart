import 'dart:developer' as developer;

/// Logger contract used internally by notification_kit.
///
/// The host app can plug in its own logger (e.g. Sentry, Logger package, etc.)
/// via [NotificationKitRuntime.use]. If none is provided, [DeveloperLogLogger]
/// is used as a sensible default that routes through `dart:developer.log`.
abstract class NotificationLogger {
  void debug(String message, [Object? error, StackTrace? stackTrace]);
  void info(String message, [Object? error, StackTrace? stackTrace]);
  void warning(String message, [Object? error, StackTrace? stackTrace]);
  void error(String message, [Object? error, StackTrace? stackTrace]);
}

/// Default logger — forwards to `dart:developer.log` so output appears in the
/// IDE debug log channel rather than the raw `print` stream.
class DeveloperLogLogger implements NotificationLogger {
  const DeveloperLogLogger();

  static const String _name = 'NotificationKit';

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: _name, level: 500, error: error, stackTrace: stackTrace);
  }

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: _name, level: 800, error: error, stackTrace: stackTrace);
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: _name, level: 900, error: error, stackTrace: stackTrace);
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: _name, level: 1000, error: error, stackTrace: stackTrace);
  }
}
