// ignore_for_file: unnecessary_library_name

/// logging_kit — one shared static logger for the chat stack.
///
/// Public API: [AppLogger], [AppLogLevel], [AppLogHandler], [LogColorConfig],
/// plus the HTTP logging helpers ([HttpLogger], [HttpLogPolicy],
/// [HttpLogBodies], [HttpLogRequest], [HttpLogResponse], [HttpLogError]).
/// Depends only on flutter (foundation); no other runtime dependencies —
/// no `dio`, so HTTP-client adapters live in the app, not here.
library logging_kit;

export 'src/app_logger.dart';
export 'src/http/http_log_policy.dart';
export 'src/http/http_log_record.dart';
export 'src/http/http_logger.dart';
