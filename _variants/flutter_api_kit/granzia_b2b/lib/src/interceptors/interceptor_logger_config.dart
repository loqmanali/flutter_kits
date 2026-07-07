import 'dart:developer';

import 'package:dio/dio.dart';

/// Shared configuration and utilities for interceptor logging.
///
/// Provides ANSI color codes and standardized logging methods to reduce
/// duplication across interceptors.
class InterceptorLoggerConfig {
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

  static const int boxWidth = 73;
  static const int prettyBoxWidth = 90;

  static String? getColor(String colorName) => _colors[colorName];

  static String colorize(String text, String colorName) {
    final color = _colors[colorName];
    if (color == null) return text;
    return '$color$text${_colors['reset']}';
  }

  static String bold(String text) =>
      '${_colors['bold']}$text${_colors['reset']}';

  static String createPrettyBox(
    String header,
    String text, {
    String color = 'cyan',
  }) {
    final coloredHeader = bold(colorize(header, color));
    final line = '═' * prettyBoxWidth;
    return '''
${colorize('╔╣', color)} $coloredHeader
${colorize('║', color)}  $text
${colorize('╚', color)}$line${colorize('╝', color)}''';
  }

  static void logSection({
    required String color,
    required String title,
    required List<String> details,
  }) {
    final line = '─' * boxWidth;
    log('$color┌── $title $line${_colors['reset']}');
    for (final detail in details) {
      log('$color│ $detail${_colors['reset']}');
    }
    log('$color└$line${_colors['reset']}');
  }

  static void logSuccess({
    required String title,
    required List<String> details,
  }) =>
      logSection(color: _colors['green']!, title: title, details: details);

  static void logError({
    required String title,
    required List<String> details,
  }) =>
      logSection(color: _colors['red']!, title: title, details: details);

  static void logWarning({
    required String title,
    required List<String> details,
  }) =>
      logSection(color: _colors['yellow']!, title: title, details: details);

  static void logInfo({
    required String title,
    required List<String> details,
  }) =>
      logSection(color: _colors['blue']!, title: title, details: details);

  static void logSkipped({
    required String title,
    required List<String> details,
  }) =>
      logSection(color: _colors['cyan']!, title: title, details: details);

  static List<String> createRequestDetails(RequestOptions options) {
    return [
      '${options.method} ${options.uri}',
      'Path: ${options.path}',
    ];
  }

  static List<String> createRequestDetailsWith(
    RequestOptions options, {
    String? additionalInfo,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParams,
  }) {
    final details = createRequestDetails(options);
    if (additionalInfo != null) details.add(additionalInfo);
    if (headers != null && headers.isNotEmpty) {
      details.add('Headers: ${headers.keys.join(', ')}');
    }
    if (queryParams != null && queryParams.isNotEmpty) {
      details.add('Query Params: ${queryParams.keys.join(', ')}');
    }
    return details;
  }
}
