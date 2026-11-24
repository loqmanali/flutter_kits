import 'dart:convert';

import 'package:logging_kit/src/app_logger.dart';
import 'package:logging_kit/src/http/http_log_policy.dart';
import 'package:logging_kit/src/http/http_log_record.dart';

const _jsonEncoder = JsonEncoder.withIndent('  ');

/// Logs HTTP requests/responses/errors through [AppLogger], bounded by an
/// [HttpLogPolicy] so a large or fast API can never flood the UI isolate
/// with thousands of print lines a second.
///
/// One summary line is always emitted (headers are never printed — they're
/// the main source of noise and rarely useful once redacted). The body is
/// printed per [HttpLogPolicy.bodies], pretty-printed when it's JSON,
/// truncated by char count before formatting and then by line count after.
final class HttpLogger {
  HttpLogger._();

  /// Logs an outgoing request. Call before the request is sent.
  static void logRequest(
    HttpLogRequest request, {
    HttpLogPolicy policy = const HttpLogPolicy(),
  }) {
    if (!policy.enabled) return;
    AppLogger.debug('→ ${request.method} ${_pathOf(request.uri, policy)}');
    _logBody(request.body, policy, isError: false, level: AppLogLevel.debug);
  }

  /// Logs a response that came back (regardless of status code — use
  /// [logError] for a thrown/network-level failure).
  static void logResponse(
    HttpLogResponse response, {
    HttpLogPolicy policy = const HttpLogPolicy(),
  }) {
    if (!policy.enabled) return;
    final size = _sizeSuffix(response.body);
    AppLogger.debug(
      '← ${response.statusCode ?? '-'} ${response.method} '
      '${_pathOf(response.uri, policy)} · '
      '${response.duration.inMilliseconds}ms$size',
    );
    _logBody(response.body, policy, isError: false, level: AppLogLevel.debug);
  }

  /// Logs a failed request (network error, timeout, thrown exception).
  static void logError(
    HttpLogError error, {
    HttpLogPolicy policy = const HttpLogPolicy(),
  }) {
    if (!policy.enabled) return;
    AppLogger.error(
      '✗ ${error.statusCode ?? '-'} ${error.method} '
      '${_pathOf(error.uri, policy)} · ${error.duration.inMilliseconds}ms',
      error.error,
      error.stackTrace,
    );
    _logBody(error.body, policy, isError: true, level: AppLogLevel.error);
  }

  static void _logBody(
    Object? body,
    HttpLogPolicy policy, {
    required bool isError,
    required AppLogLevel level,
  }) {
    if (body == null) return;
    final shouldLog =
        policy.bodies == HttpLogBodies.always ||
        (isError && policy.bodies == HttpLogBodies.onError);
    if (!shouldLog) return;

    final formatted = formatHttpBody(body, policy);
    if (formatted.isEmpty) return;
    if (level == AppLogLevel.error) {
      AppLogger.error(formatted);
    } else {
      AppLogger.debug(formatted);
    }
  }

  static String _pathOf(Uri uri, HttpLogPolicy policy) {
    final path = uri.path.isEmpty ? '/' : uri.path;
    if (uri.query.isEmpty) return path;
    return '$path?${redactQueryString(uri.query, policy.redactKeys)}';
  }

  static String _sizeSuffix(Object? body) {
    if (body == null) return '';
    final bytes = switch (body) {
      final String s => utf8.encode(s).length,
      _ => utf8.encode(jsonEncode(body)).length,
    };
    final kb = bytes / 1024;
    return kb < 0.1 ? ' · ${bytes}B' : ' · ${kb.toStringAsFixed(1)}KB';
  }
}

/// Formats [body] for logging: truncates the raw text to
/// [HttpLogPolicy.maxBodyChars] *before* attempting to decode/pretty-print
/// it (so a huge body is never fully parsed just to be logged), redacts
/// [HttpLogPolicy.redactKeys] at any nesting depth, then caps the result to
/// [HttpLogPolicy.maxBodyLines] lines.
///
/// Exposed (not just used internally) so callers/tests can preview exactly
/// what will be printed.
String formatHttpBody(Object? body, HttpLogPolicy policy) {
  if (body == null) return '';

  final rawMeasure = body is String ? body : _tryEncode(body);
  final truncated = rawMeasure.length > policy.maxBodyChars;
  final String rawCapped = truncated
      ? rawMeasure.substring(0, policy.maxBodyChars)
      : rawMeasure;

  // ponytail: once truncated we log the raw capped text as-is rather than
  // trying to decode/redact a JSON fragment — a cut-off object is not valid
  // JSON anyway. Full redaction only applies to bodies under the char cap.
  final Object structured = truncated
      ? rawCapped
      : (body is String ? (_tryDecode(body) ?? body) : body);

  final redacted = redactHttpValue(structured, policy.redactKeys);

  final pretty = switch (redacted) {
    Map<dynamic, dynamic>() || List() => _jsonEncoder.convert(redacted),
    _ => redacted.toString(),
  };
  final withTruncationNote = truncated ? '$pretty…' : pretty;

  final lines = withTruncationNote.split('\n');
  if (lines.length <= policy.maxBodyLines) return withTruncationNote;

  final shown = lines.take(policy.maxBodyLines).join('\n');
  final more = lines.length - policy.maxBodyLines;
  return '$shown\n… $more more lines not printed';
}

/// Redacts [value] recursively: any Map key in [redactKeys] (matched
/// case-insensitively) has its value replaced with `'***'`; List elements
/// and nested Maps are walked at any depth; a form-encoded/query String
/// (`a=1&password=secret`) has matching keys redacted too.
Object? redactHttpValue(Object? value, Set<String> redactKeys) {
  if (value is Map) {
    return value.map((key, v) {
      if (redactKeys.contains(key.toString().toLowerCase())) {
        return MapEntry(key, '***');
      }
      return MapEntry(key, redactHttpValue(v, redactKeys));
    });
  }
  if (value is List) {
    return value.map((e) => redactHttpValue(e, redactKeys)).toList();
  }
  if (value is String && _looksFormEncoded(value)) {
    return redactQueryString(value, redactKeys);
  }
  return value;
}

/// Redacts a query/form-encoded string (`a=1&password=secret`): each
/// `key=value` pair whose (URL-decoded) key is in [redactKeys] has its
/// value replaced with `***`.
String redactQueryString(String query, Set<String> redactKeys) {
  return query.split('&').map((pair) {
    final i = pair.indexOf('=');
    if (i == -1) return pair;
    final rawKey = pair.substring(0, i);
    final key = Uri.decodeQueryComponent(rawKey).toLowerCase();
    if (redactKeys.contains(key)) return '$rawKey=***';
    return pair;
  }).join('&');
}

bool _looksFormEncoded(String s) =>
    s.isNotEmpty && s.contains('=') && !s.startsWith('{') && !s.startsWith('[');

String _tryEncode(Object? value) {
  try {
    return jsonEncode(value);
  } catch (_) {
    return value.toString();
  }
}

Object? _tryDecode(String s) {
  try {
    return jsonDecode(s);
  } catch (_) {
    return null;
  }
}
