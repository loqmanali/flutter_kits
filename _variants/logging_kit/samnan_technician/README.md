# logging_kit

A tiny, dependency-light logging package — one shared, statically-accessed
logger for the chat stack.

`logging_kit` is the single logging surface for the chat stack — one shared
logger, no `print()`. It was extracted from `widget_kit`'s internal logger so
that lower layers can log without pulling in `widget_kit`'s heavy UI
dependencies.

It depends **only** on `flutter` — specifically `foundation`'s `kDebugMode` — and
writes through `dart:developer`'s `log()`. Nothing else.

## Features

- **One static logger.** `AppLogger` is a `final class` with a private
  constructor — the static-only intent is compiler-enforced, not just a
  convention.
- **Level filtering.** Five levels (`debug` < `info` < `warning` < `error` <
  `none`); only messages at or above the active threshold are emitted.
- **Off in release by default.** Logging is gated on `kDebugMode`, so production
  builds stay silent unless you explicitly opt in.
- **Pluggable handler.** Redirect every log to your own sink (Crashlytics, a
  file, a test capture) with a single call.
- **Coloured console output.** ANSI-coloured, level-prefixed lines via
  `LogColorConfig`.
- **Caller location.** Optionally prefixes each log with the originating
  `file.dart:line`, derived from the current stack trace.

## Installation

This is a workspace-local package (`publish_to: none`). Add it as a path
dependency:

```yaml
dependencies:
  logging_kit:
    path: ../logging_kit
```

Requirements: Dart SDK `^3.8.0`, Flutter `>=3.10.0`.

## Public API

The barrel `package:logging_kit/logging_kit.dart` exports exactly:

| Symbol | Kind | Purpose |
| --- | --- | --- |
| `AppLogger` | `final class` | The static logger and its configuration. |
| `AppLogLevel` | `enum` | `debug`, `info`, `warning`, `error`, `none`. |
| `AppLogHandler` | `typedef` | `void Function(AppLogLevel, String, Object?, StackTrace?)` — custom sink signature. |
| `LogColorConfig` | `final class` | ANSI colour helpers (`colorize`, `bold`, `boldColorize`, `getColor`, `getLevelColor`, `colorizeLevelPrefix`). |

Everything under `lib/src/` is otherwise private.

## Usage

```dart
import 'package:logging_kit/logging_kit.dart';

AppLogger.debug('Fetching messages for room ${room.id}');
AppLogger.info('Chat initialized successfully');
AppLogger.warning('Using deprecated API: use sendMessage instead');

try {
  await sendMessage(text);
} catch (e, stackTrace) {
  AppLogger.error('Failed to send message', e, stackTrace);
}
```

Each log method takes a required `message` plus an optional `error` and
`stackTrace`:

```dart
static void debug(String message, [Object? error, StackTrace? stackTrace]);
static void info(String message, [Object? error, StackTrace? stackTrace]);
static void warning(String message, [Object? error, StackTrace? stackTrace]);
static void error(String message, [Object? error, StackTrace? stackTrace]);
```

## Defaults

| Setting | Default | Notes |
| --- | --- | --- |
| Enabled | `kDebugMode` | Logging is off in release builds. |
| Level | `AppLogLevel.info` | `debug` messages are dropped until you lower the threshold. |
| Show location | `true` | Prefixes logs with `file.dart:line`. |
| Handler | none | Falls back to the coloured `dart:developer` console output. |

Only messages at or above the current level are emitted. `AppLogLevel.none`
silences everything.

## Configuration

```dart
AppLogger.setEnabled(true);             // Force logging on or off
AppLogger.setLevel(AppLogLevel.debug);  // Change the threshold
AppLogger.setShowLocation(false);       // Hide the file:line prefix
AppLogger.reset();                      // Restore defaults (handy in tests)
```

Read-only getters expose the current state:

```dart
if (AppLogger.isEnabled) { /* ... */ }
final threshold = AppLogger.level;
```

## Custom handler

Replace the default console output entirely — useful for routing logs to
Crashlytics, a file, or a test capture buffer:

```dart
AppLogger.setLogHandler((level, message, error, stackTrace) {
  FirebaseCrashlytics.instance.log('[${level.name}] $message');
  if (error != null) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
});

AppLogger.setLogHandler(null); // Restore the default console output
```

When a handler is set it **fully replaces** the default coloured console output.
If `showLocation` is enabled, the `file.dart:line` prefix is prepended to the
`message` passed to your handler.

## Colours

`LogColorConfig` exposes the ANSI helpers used internally, available for your own
formatting:

```dart
LogColorConfig.colorize('done', 'green');             // wrap text in a colour
LogColorConfig.bold('important');                     // bold
LogColorConfig.boldColorize('alert', 'red');          // bold + colour
LogColorConfig.getLevelColor(AppLogLevel.warning);    // colour for a level
LogColorConfig.colorizeLevelPrefix('[WARN]', level);  // colour a prefix
```

Unknown colour names are returned unchanged, and `AppLogLevel.none` maps to no
colour.

## Testing

```sh
cd logging_kit
dart analyze   # Expect: No issues found!
flutter test
```

The custom-handler hook makes assertions straightforward: install a capturing
handler in `setUp`, log, and assert on what it received. Call `AppLogger.reset()`
in `tearDown` to remove the handler and restore defaults so tests stay isolated.
See `test/app_logger_test.dart` for the full suite (handler invocation, level
filtering, `setEnabled(false)`, `reset()`, and `LogColorConfig`).
