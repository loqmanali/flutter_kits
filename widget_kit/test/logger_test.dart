import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/src/utils/logger.dart';

void main() {
  // Each test configures the static logger; reset to a known state around all
  // of them so order can't leak. We force-enable since reset() ties enabled to
  // kDebugMode.
  setUp(() {
    AppLogger.reset();
    AppLogger.setShowLocation(false);
  });
  tearDown(AppLogger.reset);

  group('AppLogger configuration', () {
    test('setEnabled toggles isEnabled', () {
      AppLogger.setEnabled(true);
      expect(AppLogger.isEnabled, isTrue);
      AppLogger.setEnabled(false);
      expect(AppLogger.isEnabled, isFalse);
    });

    test('setLevel updates the current level', () {
      AppLogger.setLevel(AppLogLevel.error);
      expect(AppLogger.level, AppLogLevel.error);
    });

    test('reset restores level to info', () {
      AppLogger.setLevel(AppLogLevel.error);
      AppLogger.setLogHandler((_, __, ___, ____) {});
      AppLogger.reset();
      expect(AppLogger.level, AppLogLevel.info);
    });
  });

  group('custom log handler routing', () {
    test('receives messages at or above the threshold', () {
      final received = <AppLogLevel>[];
      AppLogger.setEnabled(true);
      AppLogger.setLevel(AppLogLevel.info);
      AppLogger.setLogHandler(
          (level, message, error, stack) => received.add(level));

      AppLogger.debug('skipped — below info');
      AppLogger.info('kept');
      AppLogger.warning('kept');
      AppLogger.error('kept');

      expect(
          received, [AppLogLevel.info, AppLogLevel.warning, AppLogLevel.error]);
    });

    test('passes the message text through to the handler', () {
      String? captured;
      AppLogger.setEnabled(true);
      AppLogger.setLevel(AppLogLevel.debug);
      AppLogger.setLogHandler(
          (level, message, error, stack) => captured = message);

      AppLogger.info('hello world');
      expect(captured, 'hello world');
    });

    test('passes error and stackTrace through', () {
      Object? capturedError;
      StackTrace? capturedStack;
      final stack = StackTrace.current;
      AppLogger.setEnabled(true);
      AppLogger.setLevel(AppLogLevel.debug);
      AppLogger.setLogHandler((level, message, error, st) {
        capturedError = error;
        capturedStack = st;
      });

      AppLogger.error('failed', 'the-error', stack);
      expect(capturedError, 'the-error');
      expect(capturedStack, stack);
    });

    test('emits nothing when disabled', () {
      var calls = 0;
      AppLogger.setEnabled(false);
      AppLogger.setLogHandler((_, __, ___, ____) => calls++);

      AppLogger.error('should be swallowed');
      expect(calls, 0);
    });

    test('level=none silences everything', () {
      var calls = 0;
      AppLogger.setEnabled(true);
      AppLogger.setLevel(AppLogLevel.none);
      AppLogger.setLogHandler((_, __, ___, ____) => calls++);

      AppLogger.error('still silenced');
      expect(calls, 0);
    });

    test('a higher threshold drops lower-severity messages', () {
      final levels = <AppLogLevel>[];
      AppLogger.setEnabled(true);
      AppLogger.setLevel(AppLogLevel.warning);
      AppLogger.setLogHandler((level, _, __, ___) => levels.add(level));

      AppLogger.debug('drop');
      AppLogger.info('drop');
      AppLogger.warning('keep');
      AppLogger.error('keep');

      expect(levels, [AppLogLevel.warning, AppLogLevel.error]);
    });
  });

  group('AppLogLevel ordering', () {
    test('severity is debug < info < warning < error < none', () {
      expect(AppLogLevel.debug.index, lessThan(AppLogLevel.info.index));
      expect(AppLogLevel.info.index, lessThan(AppLogLevel.warning.index));
      expect(AppLogLevel.warning.index, lessThan(AppLogLevel.error.index));
      expect(AppLogLevel.error.index, lessThan(AppLogLevel.none.index));
    });
  });

  group('LogColorConfig', () {
    test('getColor returns a known ANSI code and null for unknown', () {
      expect(LogColorConfig.getColor('red'), '\x1B[31m');
      expect(LogColorConfig.getColor('not-a-color'), isNull);
    });

    test('colorize wraps text in color + reset', () {
      final out = LogColorConfig.colorize('hi', 'red');
      expect(out, startsWith('\x1B[31m'));
      expect(out, endsWith('\x1B[0m'));
      expect(out, contains('hi'));
    });

    test('colorize returns text unchanged for an unknown color', () {
      expect(LogColorConfig.colorize('hi', 'bogus'), 'hi');
    });

    test('bold wraps text in bold + reset', () {
      final out = LogColorConfig.bold('hi');
      expect(out, startsWith('\x1B[1m'));
      expect(out, endsWith('\x1B[0m'));
    });

    test('getLevelColor maps each level (none -> empty)', () {
      expect(LogColorConfig.getLevelColor(AppLogLevel.debug), isNotEmpty);
      expect(LogColorConfig.getLevelColor(AppLogLevel.error), '\x1B[31m');
      expect(LogColorConfig.getLevelColor(AppLogLevel.none), isEmpty);
    });
  });
}
