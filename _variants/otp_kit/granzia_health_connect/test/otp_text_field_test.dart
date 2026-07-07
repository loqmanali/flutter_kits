import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:otp_kit/otp_kit.dart';

/// Behavior tests for the single-hidden-field OTPTextField:
/// sequential typing, backspace walking back, paste distribution,
/// truncation, charset filtering, and completion dedupe.
void main() {
  // Default length is 4 — every test below types 4-digit codes.
  const config = OTPConfig(
    enableAnimations: false,
    enableHapticFeedback: false,
    showCursor: false,
  );

  Future<void> pumpField(
    WidgetTester tester, {
    OTPConfig cfg = config,
    void Function(String)? onCompleted,
    void Function(String)? onChanged,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: OTPTextField(
              config: cfg,
              onCompleted: onCompleted,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
    // Run the post-frame stale-state guard / autofocus.
    await tester.pump();
  }

  testWidgets('typing fills cells in order and reports every change', (
    tester,
  ) async {
    final changes = <String>[];
    await pumpField(tester, onChanged: changes.add);

    await tester.enterText(find.byType(TextField), '1');
    await tester.pump();
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(changes, ['1', '12']);
  });

  testWidgets('entering the full code fires onCompleted with the value', (
    tester,
  ) async {
    final completed = <String>[];
    await pumpField(tester, onCompleted: completed.add);

    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();

    expect(completed, ['1234']);
  });

  testWidgets('deleting walks the value back and clears trailing cells', (
    tester,
  ) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextField), '123');
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    // Backspace = the platform hands us the shorter value.
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();

    expect(find.text('3'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('paste longer than length is truncated and completes', (
    tester,
  ) async {
    final completed = <String>[];
    await pumpField(tester, onCompleted: completed.add);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    expect(completed, ['1234']);
    expect(find.text('5'), findsNothing);
  });

  testWidgets('non-digits are rejected for numeric input', (tester) async {
    final changes = <String>[];
    await pumpField(tester, onChanged: changes.add);

    await tester.enterText(find.byType(TextField), '1a2b');
    await tester.pump();

    expect(changes.last, '12');
    expect(find.text('a'), findsNothing);
  });

  testWidgets('dedupeCompletion suppresses re-submitting the same code', (
    tester,
  ) async {
    final completed = <String>[];
    await pumpField(
      tester,
      cfg: config.copyWith(dedupeCompletion: true),
      onCompleted: completed.add,
    );

    final field = find.byType(TextField);
    await tester.enterText(field, '1234');
    await tester.pump();
    await tester.enterText(field, '123');
    await tester.pump();
    await tester.enterText(field, '1234');
    await tester.pump();

    expect(completed, ['1234']);

    // A different code still completes.
    await tester.enterText(field, '123');
    await tester.pump();
    await tester.enterText(field, '1235');
    await tester.pump();
    expect(completed, ['1234', '1235']);
  });

  testWidgets('leftover provider state does not fire completion on first '
      'keystroke', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Pre-seed the shared controller with a full, stale code — mimicking a
    // previous mount whose value outlived it.
    container.read(otpControllerProvider(config).notifier).setValue('9999');

    final completed = <String>[];
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: OTPTextField(config: config, onCompleted: completed.add),
          ),
        ),
      ),
    );
    await tester.pump();

    // Typing one digit must NOT auto-submit the stale code.
    await tester.enterText(find.byType(TextField), '1');
    await tester.pump();

    expect(completed, isEmpty);
    expect(find.text('9'), findsNothing);
  });

  testWidgets('a failing custom rule sets the error state, not onCompleted', (
    tester,
  ) async {
    final completed = <String>[];
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: OTPTextField(
              config: config,
              customValidationRules: const [
                NoRepeatedDigitsRule(errorMessage: 'repeated'),
              ],
              onCompleted: completed.add,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), '1111');
    await tester.pump();

    expect(completed, isEmpty);
  });
}
