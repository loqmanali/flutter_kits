part of '../logger.dart';

// Severity levels and the ANSI colour table.
/// Log levels for the app logger.
///
/// Log levels are ordered by severity from least to most severe:
/// [debug] < [info] < [warning] < [error]
///
/// When a log level is set, only messages at that level or higher are logged.
enum AppLogLevel {
  /// Detailed information for debugging purposes.
  ///
  /// Use for verbose output that helps during development but would be
  /// too noisy in production.
  debug,

  /// General informational messages.
  ///
  /// Use for significant events that are part of normal operation,
  /// such as successful initialization or configuration changes.
  info,

  /// Warning messages for potentially problematic situations.
  ///
  /// Use when something unexpected happened but the SDK can continue
  /// operating, such as a deprecated API being used.
  warning,

  /// Error messages for failures.
  ///
  /// Use when an operation failed and could not be completed,
  /// such as a network error or invalid configuration.
  error,

  /// No logging (completely silent).
  ///
  /// Use to disable all app logging output.
  none,
}

/// Function signature for custom log handlers.
///
/// Parameters:
/// - [level]: The severity level of the log message
/// - [message]: The log message
/// - [error]: Optional error object associated with the log
/// - [stackTrace]: Optional stack trace for error logs
///
/// ## Example
///
/// ```dart
/// void myLogHandler(
///   AppLogLevel level,
///   String message,
///   Object? error,
///   StackTrace? stackTrace,
/// ) {
///   final timestamp = DateTime.now().toIso8601String();
///   print('[$timestamp] [${level.name.toUpperCase()}] $message');
///   if (error != null) {
///     print('Error: $error');
///   }
///   if (stackTrace != null) {
///     print('Stack trace:\n$stackTrace');
///   }
/// }
/// ```
typedef AppLogHandler = void Function(
  AppLogLevel level,
  String message,
  Object? error,
  StackTrace? stackTrace,
);

/// {@template log_color_config}
/// Color configuration and utilities for logger output.
///
/// Provides ANSI color codes and standardized color formatting methods
/// to add visual distinction to log messages.
/// {@endtemplate}
class LogColorConfig {
  /// ANSI Color Codes for console output
  static const _colors = {
    'reset': '\x1B[0m',
    'red': '\x1B[31m',
    'green': '\x1B[32m',
    'yellow': '\x1B[33m',
    'blue': '\x1B[34m',
    'magenta': '\x1B[35m',
    'cyan': '\x1B[36m',
    'white': '\x1B[37m',
    'gray': '\x1B[90m',
    'brightRed': '\x1B[91m',
    'brightGreen': '\x1B[92m',
    'brightYellow': '\x1B[93m',
    'brightBlue': '\x1B[94m',
    'bold': '\x1B[1m',
  };

  /// Get color code by name - utility for external usage
  static String? getColor(String colorName) => _colors[colorName];

  /// Apply color formatting to text - utility for external usage
  static String colorize(String text, String colorName) {
    final color = _colors[colorName];
    if (color == null) return text;
    return '$color$text${_colors['reset']}';
  }

  /// Apply bold formatting to text
  static String bold(String text) =>
      '${_colors['bold']}$text${_colors['reset']}';

  /// Apply bold and color formatting to text
  static String boldColorize(String text, String colorName) {
    return bold(colorize(text, colorName));
  }

  /// Get color for a specific log level
  static String getLevelColor(AppLogLevel level) {
    switch (level) {
      case AppLogLevel.debug:
        return _colors['cyan']!;
      case AppLogLevel.info:
        return _colors['blue']!;
      case AppLogLevel.warning:
        return _colors['yellow']!;
      case AppLogLevel.error:
        return _colors['red']!;
      case AppLogLevel.none:
        return '';
    }
  }

  /// Colorize a log level prefix
  static String colorizeLevelPrefix(String prefix, AppLogLevel level) {
    final color = getLevelColor(level);
    if (color.isEmpty) return prefix;
    return '$color$prefix${_colors['reset']}';
  }
}
