/// Logging utilities for the chat stack.
///
/// This package provides one shared static logger that can be configured to
/// control log verbosity and output. By default, logging is disabled in
/// release mode and set to [AppLogLevel.info] in debug mode.
///
/// ## Enabling Debug Logging
///
/// ```dart
/// AppLogger.setEnabled(true);
/// AppLogger.setLevel(AppLogLevel.debug);
/// ```
///
/// ## Custom Log Handler
///
/// You can provide a custom log handler to integrate with your app's
/// logging infrastructure:
///
/// ```dart
/// AppLogger.setLogHandler((level, message, error, stackTrace) {
///   myLogger.log(level.name, message, error, stackTrace);
/// });
/// ```
library;

import 'dart:developer';

import 'package:flutter/foundation.dart';

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
  /// Use when something unexpected happened but the app can continue
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
///   debugPrint('[$timestamp] [${level.name.toUpperCase()}] $message');
///   if (error != null) {
///     debugPrint('Error: $error');
///   }
///   if (stackTrace != null) {
///     debugPrint('Stack trace:\n$stackTrace');
///   }
/// }
/// ```
typedef AppLogHandler =
    void Function(
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
final class LogColorConfig {
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

/// Logger for the chat stack.
///
/// This class provides logging functionality for the app with configurable
/// verbosity levels and custom log handlers.
///
/// ## Default Behavior
///
/// By default, logging is:
/// - Disabled in release mode
/// - Set to [AppLogLevel.info] in debug mode
/// - Output to the debug console via [log]
///
/// ## Usage
///
/// ```dart
/// AppLogger.debug('Fetching messages for room ${room.id}');
/// AppLogger.info('Chat initialized successfully');
/// AppLogger.warning('Using deprecated API: use sendMessage instead');
/// AppLogger.error('Failed to fetch messages', error, stackTrace);
/// ```
///
/// ## Configuration
///
/// ```dart
/// AppLogger.setEnabled(true);
/// AppLogger.setLevel(AppLogLevel.debug);
/// ```
///
/// `final` makes the private-constructor, static-only intent compiler-enforced
/// rather than convention. (M-5)
final class AppLogger {
  AppLogger._();

  static bool _enabled = kDebugMode;
  static AppLogLevel _level = AppLogLevel.info;
  static AppLogHandler? _customHandler;
  static bool _showLocation = false;

  static const String _tag = 'Log';

  /// Whether logging is currently enabled.
  ///
  /// Returns `true` if logging is enabled, `false` otherwise.
  static bool get isEnabled => _enabled;

  /// The current minimum log level.
  ///
  /// Only messages at this level or higher will be logged.
  static AppLogLevel get level => _level;

  /// Enables or disables logging.
  ///
  /// When disabled, all log methods become no-ops for better performance.
  ///
  /// ```dart
  /// AppLogger.setEnabled(true);  // Enable logging
  /// AppLogger.setEnabled(false); // Disable logging
  /// ```
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Sets the minimum log level.
  ///
  /// Only messages at this level or higher will be logged.
  ///
  /// ```dart
  /// AppLogger.setLevel(AppLogLevel.debug); // Log everything
  /// AppLogger.setLevel(AppLogLevel.error); // Only log errors
  /// AppLogger.setLevel(AppLogLevel.none);  // Disable all logging
  /// ```
  static void setLevel(AppLogLevel level) {
    _level = level;
  }

  /// Sets a custom log handler.
  ///
  /// When set, all log messages will be passed to this handler instead
  /// of the default console output.
  ///
  /// Pass `null` to restore the default behavior.
  ///
  /// ```dart
  /// AppLogger.setLogHandler((level, message, error, stackTrace) {
  ///   FirebaseCrashlytics.instance.log('[$level] $message');
  ///   if (error != null) {
  ///     FirebaseCrashlytics.instance.recordError(error, stackTrace);
  ///   }
  /// });
  /// ```
  static void setLogHandler(AppLogHandler? handler) {
    _customHandler = handler;
  }

  /// Enables or disables showing file location in logs.
  ///
  /// When enabled, logs will show the file name and line number where
  /// the log was called.
  ///
  /// ```dart
  /// AppLogger.setShowLocation(true);  // Show location
  /// AppLogger.setShowLocation(false); // Hide location
  /// ```
  static void setShowLocation(bool show) {
    _showLocation = show;
  }

  /// Logs a debug message.
  ///
  /// Use for detailed information useful during development.
  ///
  /// ```dart
  /// AppLogger.debug('Request payload: $json');
  /// AppLogger.debug('Cache hit for key: $key');
  /// ```
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log(AppLogLevel.debug, message, error, stackTrace);
  }

  /// Logs an informational message.
  ///
  /// Use for significant events in normal operation.
  ///
  /// ```dart
  /// AppLogger.info('Chat initialized with room: $roomId');
  /// AppLogger.info('Fetched ${messages.length} messages');
  /// ```
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log(AppLogLevel.info, message, error, stackTrace);
  }

  /// Logs a warning message.
  ///
  /// Use for potentially problematic situations that don't prevent operation.
  ///
  /// ```dart
  /// AppLogger.warning('No messages found for empty room');
  /// AppLogger.warning('Using fallback configuration');
  /// ```
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log(AppLogLevel.warning, message, error, stackTrace);
  }

  /// Logs an error message.
  ///
  /// Use when an operation fails.
  ///
  /// ```dart
  /// try {
  ///   await fetchData();
  /// } catch (e, stackTrace) {
  ///   AppLogger.error('Failed to fetch data', e, stackTrace);
  /// }
  /// ```
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(AppLogLevel.error, message, error, stackTrace);
  }

  static void _log(
    AppLogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // Skip if logging is disabled or level is below threshold
    if (!_enabled || level.index < _level.index || _level == AppLogLevel.none) {
      return;
    }

    // Get caller location information
    final location = _showLocation ? _getCallerLocation() : '';

    // Use custom handler if provided
    if (_customHandler != null) {
      if (_showLocation && location.isNotEmpty) {
        _customHandler!(level, '$location$message', error, stackTrace);
      } else {
        _customHandler!(level, message, error, stackTrace);
      }
      return;
    }

    // Default logging behavior
    final prefix = _getLevelPrefix(level);
    final color = LogColorConfig.getLevelColor(level);

    // Log location on separate line if enabled
    if (_showLocation && location.isNotEmpty) {
      final locationMessage = '[$_tag] $prefix $location';
      if (color.isNotEmpty) {
        log('$color$locationMessage${LogColorConfig._colors['reset']}');
      } else {
        log(locationMessage);
      }
    }

    // Log the main message
    final fullMessage = _showLocation && location.isNotEmpty
        ? '  $message'
        : '[$_tag] $prefix $message';

    if (color.isNotEmpty) {
      log('$color$fullMessage${LogColorConfig._colors['reset']}');
    } else {
      log(fullMessage);
    }

    if (error != null) {
      final errorMessage = '[$_tag] Error: $error';
      if (color.isNotEmpty) {
        log('$color$errorMessage${LogColorConfig._colors['reset']}');
      } else {
        log(errorMessage);
      }
    }

    if (stackTrace != null) {
      final stackTraceMessage = '[$_tag] Stack trace:\n$stackTrace';
      if (color.isNotEmpty) {
        log('$color$stackTraceMessage${LogColorConfig._colors['reset']}');
      } else {
        log(stackTraceMessage);
      }
    }
  }

  /// Extracts caller location information from the current stack trace.
  ///
  /// Returns a formatted string with file path and line number.
  static String _getCallerLocation() {
    final stackTrace = StackTrace.current;
    final trace = stackTrace.toString().split('\n');

    // Skip frames from the logger itself
    for (var i = 0; i < trace.length; i++) {
      final line = trace[i].trim();

      // Skip logger frames
      if (line.contains('app_logger.dart') || line.isEmpty) {
        continue;
      }

      // Try to extract location from the frame
      final location = _extractLocation(line);
      if (location != null) {
        return '$location ';
      }
    }
    return '';
  }

  /// Extracts file path and line number from a stack trace line.
  ///
  /// Returns formatted string like `file.dart:42`
  static String? _extractLocation(String line) {
    // Try different patterns for stack trace formats
    // Pattern 1: package:package_name/path/to/file.dart:line:column
    var match = RegExp(r'package:[^/]+/([^:]+):(\d+)').firstMatch(line);
    if (match != null) {
      final file = match.group(1);
      final lineNum = match.group(2);
      final fileName = file?.split('/').last;
      return '$fileName:$lineNum';
    }

    // Pattern 2: /absolute/path/lib/file.dart:line
    match = RegExp(r'lib/([^:]+):(\d+)').firstMatch(line);
    if (match != null) {
      final file = match.group(1);
      final lineNum = match.group(2);
      final fileName = file?.split('/').last;
      return '$fileName:$lineNum';
    }

    // Pattern 3: file.dart:line
    match = RegExp(r'(\w+\.dart):(\d+)').firstMatch(line);
    if (match != null) {
      final file = match.group(1);
      final lineNum = match.group(2);
      return '$file:$lineNum';
    }

    return null;
  }

  static String _getLevelPrefix(AppLogLevel level) {
    final prefix = switch (level) {
      AppLogLevel.debug => '[DEBUG]',
      AppLogLevel.info => '[INFO]',
      AppLogLevel.warning => '[WARN]',
      AppLogLevel.error => '[ERROR]',
      AppLogLevel.none => '',
    };
    return LogColorConfig.colorizeLevelPrefix(prefix, level);
  }

  /// Resets the logger to default settings.
  ///
  /// This method is primarily useful for testing.
  ///
  /// - Enables logging in debug mode, disables in release mode
  /// - Sets level to [AppLogLevel.info]
  /// - Removes any custom log handler
  /// - Keeps location display disabled
  static void reset() {
    _enabled = kDebugMode;
    _level = AppLogLevel.info;
    _customHandler = null;
    _showLocation = false;
  }
}
