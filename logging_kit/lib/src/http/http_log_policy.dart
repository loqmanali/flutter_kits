import 'package:flutter/foundation.dart';

/// Controls when a request/response/error body is logged.
enum HttpLogBodies {
  /// Never log bodies, only the one-line summary.
  never,

  /// Only log the body of a request/response that produced an [HttpLogger.logError].
  onError,

  /// Always log bodies (still subject to [HttpLogPolicy.maxBodyChars] /
  /// [HttpLogPolicy.maxBodyLines] caps).
  always,
}

/// {@template http_log_policy}
/// Configuration for [HttpLogger]: whether it logs at all, how much of a
/// body it prints, and which map/query keys get redacted.
///
/// Decision: [bodies] defaults to [HttpLogBodies.always] rather than
/// `onError`, matching the previous PrettyDioLogger behaviour of logging
/// every request/response body in debug builds — the performance problem
/// being fixed here was the *unbounded* size of that output (7,000+
/// lines/sec, one 3,417-line response), not that bodies were logged at all.
/// [maxBodyChars] and [maxBodyLines] are what cap it now.
/// {@endtemplate}
@immutable
class HttpLogPolicy {
  /// {@macro http_log_policy}
  const HttpLogPolicy({
    this.enabled = kDebugMode,
    this.maxBodyLines = 40,
    this.maxBodyChars = 4000,
    this.bodies = HttpLogBodies.always,
    this.redactKeys = defaultRedactKeys,
  });

  /// Master on/off switch. Defaults to off in release builds.
  final bool enabled;

  /// Maximum number of lines of a (pretty-printed) body to print before
  /// appending a `… N more lines not printed` marker.
  final int maxBodyLines;

  /// Maximum number of characters read from the raw body *before* any
  /// JSON decoding/pretty-printing is attempted, so a huge response is
  /// never fully parsed or formatted just to be logged.
  final int maxBodyChars;

  /// When request/response bodies are logged at all.
  final HttpLogBodies bodies;

  /// Map/form/query keys (matched case-insensitively, at any nesting
  /// depth) whose value is replaced with `***` before logging.
  final Set<String> redactKeys;

  /// Exact-match key list. Deliberately simple: matched by exact key name
  /// only, not by substring or heuristic. This is why plain `code` (e.g. an
  /// HTTP status code carried as `statusCode`, not `code`) is unaffected —
  /// only a field literally named `code` (as in an OTP/verification code)
  /// is redacted.
  static const Set<String> defaultRedactKeys = {
    'password',
    'password_confirmation',
    'current_password',
    'new_password',
    'token',
    'access_token',
    'refresh_token',
    'fcm_token',
    'otp',
    'code',
    'card_number',
    'cvv',
    'cvc',
    'pin',
    'authorization',
    'cookie',
    'set-cookie',
  };
}
