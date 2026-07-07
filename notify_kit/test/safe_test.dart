import 'package:flutter_test/flutter_test.dart';
import 'package:notify_kit/src/safe.dart';

void main() {
  test('runSafely executes the callback', () {
    var ran = false;
    runSafely('test', () => ran = true);
    expect(ran, isTrue);
  });

  test('runSafely swallows a throwing callback (spec §8)', () {
    expect(
      () => runSafely('test', () => throw StateError('boom')),
      returnsNormally,
    );
  });

  test('runSafely reports the error to onError with context and stack', () {
    String? reportedContext;
    Object? reportedError;
    StackTrace? reportedStack;

    runSafely(
      'onTap(local)',
      () => throw StateError('boom'),
      onError: (context, error, stack) {
        reportedContext = context;
        reportedError = error;
        reportedStack = stack;
      },
    );

    expect(reportedContext, 'onTap(local)');
    expect(reportedError, isA<StateError>());
    expect(reportedStack, isNotNull);
  });

  test('runSafely does not call onError on success', () {
    var called = false;
    runSafely('test', () {}, onError: (_, __, ___) => called = true);
    expect(called, isFalse);
  });

  test('a throwing onError handler is swallowed too', () {
    expect(
      () => runSafely(
        'test',
        () => throw StateError('boom'),
        onError: (_, __, ___) => throw ArgumentError('handler bug'),
      ),
      returnsNormally,
    );
  });
}
