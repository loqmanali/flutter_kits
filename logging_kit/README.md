# logging_kit

One shared, dependency-light logger for the chat stack.

`logging_kit` is the single logging surface for `packages_v2` (plan.md §16
decision 7, Principle P6: one shared logger, no `print()`). It was extracted
from `widget_kit`'s internal logger so that lower layers can log without
pulling in `widget_kit`'s heavy UI dependencies. It depends **only** on
`flutter` (for `foundation`'s `kDebugMode`) and writes through
`dart:developer`'s `log()`.

## Public API

The barrel `package:logging_kit/logging_kit.dart` exports exactly:

- `enum AppLogLevel { debug, info, warning, error, none }`
- `typedef AppLogHandler = void Function(AppLogLevel, String, Object?, StackTrace?)`
- `class LogColorConfig` — ANSI colour helpers
  (`colorize`, `bold`, `boldColorize`, `getColor`, `getLevelColor`,
  `colorizeLevelPrefix`)
- `class AppLogger` — the static logger

Nothing under `lib/src/` is otherwise public.

## Usage

```dart
import 'package:logging_kit/logging_kit.dart';

AppLogger.debug('Fetching messages for room ${room.id}');
AppLogger.info('Chat initialized successfully');
AppLogger.warning('Using deprecated API: use sendMessage instead');

try {
  await sendMessage(text);
} catch (e, st) {
  AppLogger.error('Failed to send message', e, st);
}
```

### Defaults

- `_enabled` defaults to `kDebugMode` (logging is off in release builds).
- `level` defaults to `AppLogLevel.info`.
- Only messages at or above the current level are emitted. `AppLogLevel.none`
  silences everything.

### Configuration

```dart
AppLogger.setEnabled(true);           // force on/off
AppLogger.setLevel(AppLogLevel.debug); // change threshold
AppLogger.setShowLocation(false);     // hide file:line prefix
AppLogger.reset();                    // restore defaults (handy in tests)
```

### Custom handler

Redirect every log to your own sink (Crashlytics, a file, a test capture):

```dart
AppLogger.setLogHandler((level, message, error, stackTrace) {
  myLogger.log(level.name, message, error, stackTrace);
});

AppLogger.setLogHandler(null); // restore the default console output
```

When a handler is set it fully replaces the default coloured console output.

## HTTP request/response logging

`HttpLogger` prints a bounded, one-line-per-request summary plus an optional
redacted body — it exists to stop an app's HTTP client from ever again
dumping thousands of raw log lines a second onto the UI isolate (that's what
motivated this module: a debug PrettyDioLogger config printing full,
un-truncated response bodies, one of them 3,417 lines, causing measurable
frame drops).

`HttpLogPolicy` controls it:

- `enabled` — defaults to `kDebugMode`.
- `maxBodyChars` (default 4000) — the raw body is cut to this length
  **before** any JSON decode/pretty-print is attempted, so a huge response
  is never fully parsed just to be logged.
- `maxBodyLines` (default 40) — the (pretty-printed) body is then capped to
  this many lines, with a trailing `… N more lines not printed` marker.
- `bodies` (`HttpLogBodies.never | onError | always`, default `always`) —
  default is `always` rather than `onError` because the old behaviour logged
  every body; the bug being fixed was the *unbounded size* of that output,
  which `maxBodyChars`/`maxBodyLines` now cap. Switch to `onError` for an
  even quieter default.
- `redactKeys` — an exact-match (case-insensitive) key list, checked at any
  nesting depth in maps/lists and in form-encoded/query strings. Default:
  `password`, `password_confirmation`, `current_password`, `new_password`,
  `token`, `access_token`, `refresh_token`, `fcm_token`, `otp`, `code`,
  `card_number`, `cvv`, `cvc`, `pin`, `authorization`, `cookie`,
  `set-cookie`. Matching is by exact key name only — a `statusCode` field is
  never touched by the `code` entry.

Headers are never printed by `HttpLogger` (they were rarely useful and are
themselves a source of the noise this exists to fix).

```dart
HttpLogger.logRequest(HttpLogRequest(method: 'GET', uri: uri));
HttpLogger.logResponse(HttpLogResponse(
  method: 'GET', uri: uri, statusCode: 200,
  duration: elapsed, body: response.data,
));
HttpLogger.logError(HttpLogError(
  method: 'GET', uri: uri, duration: elapsed,
  error: exception, body: exception.response?.data,
));
```

Produces, for example:

```
→ GET /orders?page=1
← 200 GET /orders?page=1 · 394ms · 12.3KB
```

### Dio adapter example

`logging_kit` depends only on `flutter` — wire it to `dio` from the app:

```dart
class HttpLogInterceptor extends Interceptor {
  HttpLogInterceptor({this.policy = const HttpLogPolicy()});
  final HttpLogPolicy policy;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now();
    HttpLogger.logRequest(
      HttpLogRequest(method: options.method, uri: options.uri, body: options.data),
      policy: policy,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final start = response.requestOptions.extra['startTime'] as DateTime?;
    HttpLogger.logResponse(
      HttpLogResponse(
        method: response.requestOptions.method,
        uri: response.requestOptions.uri,
        statusCode: response.statusCode,
        duration: start == null ? Duration.zero : DateTime.now().difference(start),
        body: response.data,
      ),
      policy: policy,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final start = err.requestOptions.extra['startTime'] as DateTime?;
    HttpLogger.logError(
      HttpLogError(
        method: err.requestOptions.method,
        uri: err.requestOptions.uri,
        statusCode: err.response?.statusCode,
        duration: start == null ? Duration.zero : DateTime.now().difference(start),
        body: err.response?.data,
        error: err,
        stackTrace: err.stackTrace,
      ),
      policy: policy,
    );
    handler.next(err);
  }
}
```

## Testing

```sh
cd packages_v2/logging_kit
dart analyze   # No issues found!
flutter test
```
