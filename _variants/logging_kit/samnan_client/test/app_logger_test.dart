import 'package:flutter_test/flutter_test.dart';
import 'package:logging_kit/logging_kit.dart';

/// A captured log entry, used to assert what the custom handler received.
class _Captured {
  const _Captured(this.level, this.message, this.error, this.stackTrace);

  final AppLogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
}

void main() {
  // Each test installs its own capturing handler. reset() in tearDown
  // restores defaults (and removes the handler) so tests stay isolated.
  late List<_Captured> captured;

  setUp(() {
    captured = <_Captured>[];
    AppLogger.reset();
    AppLogger.setEnabled(true);
    // Location frames are derived from a real StackTrace; turn off so the
    // asserted message text is deterministic across runtimes.
    AppLogger.setShowLocation(false);
    AppLogger.setLogHandler((level, message, error, stackTrace) {
      captured.add(_Captured(level, message, error, stackTrace));
    });
  });

  tearDown(AppLogger.reset);

  group('custom handler invocation', () {
    test('is invoked with the level, message, error and stack trace', () {
      final err = Exception('boom');
      final st = StackTrace.current;

      AppLogger.error('something failed', err, st);

      expect(captured, hasLength(1));
      final entry = captured.single;
      expect(entry.level, AppLogLevel.error);
      expect(entry.message, 'something failed');
      expect(entry.error, same(err));
      expect(entry.stackTrace, same(st));
    });

    test('maps each helper to the correct level', () {
      AppLogger.setLevel(AppLogLevel.debug);

      AppLogger.debug('d');
      AppLogger.info('i');
      AppLogger.warning('w');
      AppLogger.error('e');

      expect(captured.map((c) => c.level).toList(), <AppLogLevel>[
        AppLogLevel.debug,
        AppLogLevel.info,
        AppLogLevel.warning,
        AppLogLevel.error,
      ]);
    });
  });

  group('level filtering', () {
    test('drops messages below the configured threshold', () {
      AppLogger.setLevel(AppLogLevel.warning);

      AppLogger.debug('dropped');
      AppLogger.info('dropped');
      AppLogger.warning('kept');
      AppLogger.error('kept');

      expect(captured.map((c) => c.message).toList(), <String>['kept', 'kept']);
    });

    test('AppLogLevel.none drops everything', () {
      AppLogger.setLevel(AppLogLevel.none);

      AppLogger.debug('x');
      AppLogger.info('x');
      AppLogger.warning('x');
      AppLogger.error('x');

      expect(captured, isEmpty);
    });
  });

  group('setEnabled(false)', () {
    test('makes every log call a no-op', () {
      AppLogger.setLevel(AppLogLevel.debug);
      AppLogger.setEnabled(false);

      expect(AppLogger.isEnabled, isFalse);

      AppLogger.debug('x');
      AppLogger.info('x');
      AppLogger.warning('x');
      AppLogger.error('x', Exception('e'), StackTrace.current);

      expect(captured, isEmpty);
    });
  });

  group('reset()', () {
    test('restores default level, removes the handler and re-enables', () {
      AppLogger.setLevel(AppLogLevel.error);
      AppLogger.setEnabled(false);

      AppLogger.reset();

      // Default level is info.
      expect(AppLogger.level, AppLogLevel.info);
      // Default enabled state mirrors kDebugMode; tests run in debug.
      expect(AppLogger.isEnabled, isTrue);

      // The captured handler from setUp is gone — nothing is recorded even
      // though logging is enabled at info level.
      AppLogger.info('after reset');
      expect(captured, isEmpty);
    });
  });

  group('LogColorConfig', () {
    test('colorize wraps text in ANSI codes and resets', () {
      final out = LogColorConfig.colorize('hi', 'red');
      expect(out, '\x1B[31mhi\x1B[0m');
    });

    test('colorize returns text unchanged for unknown colour', () {
      expect(LogColorConfig.colorize('hi', 'not-a-colour'), 'hi');
    });

    test('bold wraps text in the bold ANSI code', () {
      expect(LogColorConfig.bold('hi'), '\x1B[1mhi\x1B[0m');
    });

    test('getLevelColor returns empty for none and a code otherwise', () {
      expect(LogColorConfig.getLevelColor(AppLogLevel.none), isEmpty);
      expect(LogColorConfig.getLevelColor(AppLogLevel.error), isNotEmpty);
    });

    test('colorizeLevelPrefix leaves prefix untouched for none', () {
      expect(
        LogColorConfig.colorizeLevelPrefix('[X]', AppLogLevel.none),
        '[X]',
      );
    });
  });
}
