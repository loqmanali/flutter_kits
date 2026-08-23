/// Logging utilities for the app.
///
/// The SDK uses its own logging system that can be configured to control
/// log verbosity and output. By default, logging is disabled in release mode.
///
/// ## Enabling Debug Logging
///
/// ```dart
/// await AppLogger.initialize(
///   config: config,
///   enableLogging: true,
///   logLevel: AppLogLevel.debug,
/// );
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

part 'logger/log_level.dart';

/// Logger for the Burger Republic app.
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
/// The logger is used internally by the app:
///
/// ```dart
/// AppLogger.debug('Fetching recommendations for cart with 3 items');
/// AppLogger.info('SDK initialized successfully');
/// AppLogger.warning('Using deprecated API: use showUpsellPopup instead');
/// AppLogger.error('Failed to fetch recommendations', error, stackTrace);
/// ```
///
/// ## Configuration
///
/// Configure logging during app initialization:
///
/// ```dart
/// await AppLogger.initialize(
///   config: config,
///   enableLogging: true,
///   logLevel: AppLogLevel.debug,
/// );
/// ```
///
/// Or configure directly:
///
/// ```dart
/// AppLogger.setEnabled(true);
/// AppLogger.setLevel(AppLogLevel.debug);
/// ```
class AppLogger {
  AppLogger._();

  static bool _enabled = kDebugMode;
  static AppLogLevel _level = AppLogLevel.info;
  static AppLogHandler? _customHandler;
  static bool _showLocation = true;

  static const String _tag = 'Burger';

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
  /// AppLogger.info('SDK initialized with store: $storeId');
  /// AppLogger.info('Fetched ${products.length} recommendations');
  /// ```
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log(AppLogLevel.info, message, error, stackTrace);
  }

  /// Logs a warning message.
  ///
  /// Use for potentially problematic situations that don't prevent operation.
  ///
  /// ```dart
  /// AppLogger.warning('No recommendations found for empty cart');
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
      if (line.contains('logger.dart') || line.isEmpty) {
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
  static void reset() {
    _enabled = kDebugMode;
    _level = AppLogLevel.info;
    _customHandler = null;
  }
}
