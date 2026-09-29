import 'dart:async';

import 'package:confirm_kit/confirm_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Choice { save, discard, keep }

/// A page with a single button that opens whatever [onTap] builds.
Widget _host(void Function(BuildContext context) onTap) {
  return MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => onTap(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _tapOpen(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

/// `canPop` of the [PopScope] the confirmation installs around itself.
bool _canPop(WidgetTester tester) {
  final popScope = tester
      .widgetList(find.descendant(
        of: find.byWidgetPredicate((widget) => widget is ConfirmDialog),
        matching: find.byWidgetPredicate((widget) => widget is PopScope),
      ))
      .first as PopScope;
  return popScope.canPop;
}

void main() {
  group('ConfirmDialog', () {
    testWidgets('renders title/message and pops true on confirm',
        (tester) async {
      Future<bool?>? popped;
      await tester.pumpWidget(_host((context) {
        popped = const ConfirmDialog<bool>(
          title: 'Delete address?',
          message: 'This cannot be undone.',
        ).show(context);
      }));

      await _tapOpen(tester);
      expect(find.text('Delete address?'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(await popped, isTrue);
      expect(find.text('Delete address?'), findsNothing);
    });

    testWidgets('pops false on cancel', (tester) async {
      Future<bool?>? popped;
      await tester.pumpWidget(_host((context) {
        popped = const ConfirmDialog<bool>(title: 'Leave?').show(context);
      }));

      await _tapOpen(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await popped, isFalse);
    });

    testWidgets('destructive intent uses the delete label and warning icon',
        (tester) async {
      await tester.pumpWidget(_host((context) {
        const ConfirmDialog<bool>(
          title: 'Delete account?',
          intent: ConfirmIntent.destructive,
        ).show(context);
      }));

      await _tapOpen(tester);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('showCancel: false renders a single acknowledge button',
        (tester) async {
      await tester.pumpWidget(_host((context) {
        const ConfirmDialog<bool>(
          title: 'Notifications blocked',
          intent: ConfirmIntent.info,
          showCancel: false,
        ).show(context);
      }));

      await _tapOpen(tester);
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('async confirm shows a spinner, locks the dialog, then pops',
        (tester) async {
      final gate = Completer<void>();
      Future<bool?>? popped;
      await tester.pumpWidget(_host((context) {
        popped = ConfirmDialog<bool>(
          title: 'Cancel order?',
          onConfirm: () => gate.future,
        ).show(context);
      }));

      await _tapOpen(tester);
      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // The other action is disabled while the work runs...
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
      // ...and so is the back button.
      expect(_canPop(tester), isFalse);

      gate.complete();
      await tester.pumpAndSettle();

      expect(await popped, isTrue);
      expect(find.text('Cancel order?'), findsNothing);
    });

    testWidgets('custom actions pop their own result type', (tester) async {
      Future<_Choice?>? popped;
      await tester.pumpWidget(_host((context) {
        popped = const ConfirmDialog<_Choice>(
          title: 'Unsaved changes',
          actions: [
            ConfirmAction.cancel(label: 'Keep editing', result: _Choice.keep),
            ConfirmAction.destructive(
              label: 'Discard',
              result: _Choice.discard,
              style: ConfirmActionStyle.text,
            ),
            ConfirmAction(label: 'Save', result: _Choice.save),
          ],
        ).show(context);
      }));

      await _tapOpen(tester);
      // Three actions stack instead of sharing a row.
      expect(find.byType(Row), findsWidgets);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(await popped, _Choice.discard);
    });

    testWidgets('sheet surface renders without a Dialog', (tester) async {
      await tester.pumpWidget(_host((context) {
        const ConfirmDialog<bool>(
          title: 'Pick one',
          surface: ConfirmSurface.sheet,
        ).show(context);
      }));

      await _tapOpen(tester);
      expect(find.text('Pick one'), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('dismissible: false keeps the route from popping itself',
        (tester) async {
      await tester.pumpWidget(_host((context) {
        const ConfirmDialog<bool>(title: 'Required', dismissible: false)
            .show(context);
      }));

      await _tapOpen(tester);
      expect(_canPop(tester), isFalse);
    });

    testWidgets('bare surface embeds without popping the page', (tester) async {
      var pressed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ConfirmDialog<bool>(
            title: 'Inline',
            surface: ConfirmSurface.bare,
            showCancel: false,
            onConfirm: () => pressed = true,
          ),
        ),
      ));

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
      expect(find.text('Inline'), findsOneWidget);
    });
  });

  group('ConfirmKitTheme', () {
    test('merge overrides only the fields that are set', () {
      final merged = ConfirmKitTheme.fallback
          .merge(const ConfirmKitTheme(borderRadius: 4));

      expect(merged.borderRadius, 4);
      expect(merged.contentPadding, const EdgeInsets.all(20));
      expect(merged.strings, ConfirmStrings.fallback);
    });

    test('intent colors fall back to ColorScheme roles', () {
      const scheme = ColorScheme.light();
      const theme = ConfirmKitTheme(destructiveColor: Color(0xFF123456));

      expect(
        theme.colorFor(ConfirmIntent.destructive, scheme),
        const Color(0xFF123456),
      );
      expect(theme.colorFor(ConfirmIntent.primary, scheme), scheme.primary);
    });
  });
}
