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

## Testing

```sh
cd packages_v2/logging_kit
dart analyze   # No issues found!
flutter test
```
