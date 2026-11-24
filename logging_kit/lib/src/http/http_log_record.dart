/// A completed request, about to be sent.
class HttpLogRequest {
  const HttpLogRequest({
    required this.method,
    required this.uri,
    this.headers = const {},
    this.body,
  });

  final String method;
  final Uri uri;
  final Map<String, dynamic> headers;
  final Object? body;
}

/// A response that came back successfully (2xx or otherwise, but not an
/// exception — use [HttpLogError] for that).
class HttpLogResponse {
  const HttpLogResponse({
    required this.method,
    required this.uri,
    required this.statusCode,
    required this.duration,
    this.headers = const {},
    this.body,
  });

  final String method;
  final Uri uri;
  final int? statusCode;
  final Duration duration;
  final Map<String, dynamic> headers;
  final Object? body;
}

/// A request that failed (network error, timeout, non-2xx thrown as an
/// exception by the HTTP client, etc).
class HttpLogError {
  const HttpLogError({
    required this.method,
    required this.uri,
    required this.duration,
    required this.error,
    this.statusCode,
    this.headers = const {},
    this.body,
    this.stackTrace,
  });

  final String method;
  final Uri uri;
  final int? statusCode;
  final Duration duration;
  final Map<String, dynamic> headers;
  final Object? body;
  final Object error;
  final StackTrace? stackTrace;
}
