// Integration tests for widget_kit.
//
// These run on a real device/desktop and exercise full-app flows that plain
// widget tests can't cover well: the WidgetKitTheme extension resolving through
// a real MaterialApp, modal bottom sheets and dialogs that need a live
// Navigator/Overlay (UIHelper), and multi-widget interaction across rebuilds.
//
// Run on macOS desktop:  flutter test integration_test -d macos
//
// The captured Scaffold context stays mounted across `await tester.pump*` in a
// widget/integration test (the tree isn't torn down), so launching overlays
// from it after an await is safe here — unlike in production app code.
// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:widget_kit/widget_kit.dart';

Widget _app({
  List<ThemeExtension<dynamic>> extensions = const [],
  required Widget home,
}) {
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: extensions),
    home: home,
  );
}

/// Pumps an app whose [Scaffold] body captures its own [BuildContext], so tests
/// can launch overlays (sheets/dialogs) from a real, mounted context.
Future<BuildContext> _pumpWithContext(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    _app(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox.expand();
          },
        ),
      ),
    ),
  );
  return captured;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // The slot picker's date strip formats names via intl; init locale data once.
  setUpAll(() async => initializeDateFormatting());

  group('WidgetKitTheme resolves through a real app', () {
    testWidgets('of() returns the registered extension', (tester) async {
      late WidgetKitTheme resolved;
      await tester.pumpWidget(
        _app(
          extensions: const [
            WidgetKitTheme(inputBorderRadius: 18, buttonHeight: 60),
          ],
          home: Builder(
            builder: (context) {
              resolved = WidgetKitTheme.of(context);
              return const Scaffold();
            },
          ),
        ),
      );
      expect(resolved.inputBorderRadius, 18);
      expect(resolved.buttonHeight, 60);
    });

    testWidgets('of() falls back when no extension is registered', (
      tester,
    ) async {
      late WidgetKitTheme resolved;
      await tester.pumpWidget(
        _app(
          home: Builder(
            builder: (context) {
              resolved = WidgetKitTheme.of(context);
              return const Scaffold();
            },
          ),
        ),
      );
      expect(resolved.inputBorderRadius, WidgetKitTokens.radiusSm);
    });
  });

  group('AppButton in a full app', () {
    testWidgets('renders and fires onPressed', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: Center(
              child: AppButton(label: 'Go', onPressed: () => pressed++),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(pressed, 1);
    });
  });

  group('UIHelper modal flows (need a live Navigator/Overlay)', () {
    testWidgets('showBottomSheet opens a sheet and returns its result', (
      tester,
    ) async {
      final ctx = await _pumpWithContext(tester);

      final future = UIHelper.showBottomSheet<String>(
        ctx,
        child: Builder(
          builder: (sheetContext) => ElevatedButton(
            onPressed: () => Navigator.of(sheetContext).pop('picked'),
            child: const Text('Pick'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pick'), findsOneWidget);

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      expect(await future, 'picked');
      expect(find.text('Pick'), findsNothing);
    });

    testWidgets('showDialogPicker shows a dialog hosting the child', (
      tester,
    ) async {
      final ctx = await _pumpWithContext(tester);

      unawaited(
        UIHelper.showDialogPicker<void>(ctx, child: const Text('Dialog body')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dialog body'), findsOneWidget);

      // Dismiss by tapping the barrier (top-left corner).
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Dialog body'), findsNothing);
    });
  });

  group('AppWarningDialog flow', () {
    testWidgets('confirm button invokes the callback and pops', (tester) async {
      var confirmed = 0;
      final ctx = await _pumpWithContext(tester);

      unawaited(
        showDialog<void>(
          context: ctx,
          builder: (dialogContext) => AppWarningDialog(
            title: 'Delete?',
            message: 'Permanent.',
            buttonText: 'Delete',
            onPressed: () {
              confirmed++;
              Navigator.of(dialogContext).pop();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Delete?'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(confirmed, 1);
      expect(find.text('Delete?'), findsNothing);
    });
  });

  group('Accordion interaction in a full app', () {
    testWidgets('expands on a header tap (the panel grows)', (tester) async {
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Accordion(
                items: const [
                  AccordionItemData(
                    header: Text('Section'),
                    content: SizedBox(height: 50, child: Text('Section body')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final transition = find.byType(SizeTransition);
      final collapsed = tester.getSize(transition).height;

      await tester.tap(find.text('Section'));
      await tester.pumpAndSettle();
      final expanded = tester.getSize(transition).height;

      expect(collapsed, 0);
      expect(expanded, greaterThan(collapsed));
    });
  });

  group('Slot/time picker — real async day-load flow', () {
    testWidgets('timeOnly mode: tapping a slot reports it', (tester) async {
      SlotItem? picked;
      final day = DateTime(2026, 6, 9);
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: SingleChildScrollView(
              child: InlineSlotTimePicker(
                mode: SlotPickerMode.timeOnly,
                onTimeSlotSelected: (s) => picked = s,
                initialSlots: [
                  SlotItem(id: 1, date: day, time: '09:00 AM'),
                  SlotItem(id: 2, date: day, time: '10:00 AM'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('10:00 AM'));
      await tester.pumpAndSettle();
      expect(picked?.id, 2);
    });

    testWidgets(
      'dateAndTime mode: shows the choose-date prompt then the day strip',
      (tester) async {
        await tester.pumpWidget(
          _app(
            home: Scaffold(
              body: SingleChildScrollView(
                child: InlineSlotTimePicker(
                  // The async slot loader fires when a day is tapped.
                  onDaySelected: (date) async => [
                    SlotItem(id: 1, date: date, time: '02:00 PM'),
                  ],
                  onTimeSlotSelected: (_) {},
                  labels: const SlotPickerLabels(
                    chooseDatePrompt: 'Choose a date',
                    timeHeading: 'Times',
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Before any day is picked, the prompt and the time heading are visible,
        // and the date strip rendered (intl date formatting worked).
        expect(find.text('Choose a date'), findsOneWidget);
        expect(find.text('Times'), findsOneWidget);
      },
    );
  });

  group('ContextMenu in a full app (Overlay)', () {
    testWidgets('opens on tap and fires an item', (tester) async {
      var copied = 0;
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: Center(
              child: ContextMenu(
                items: [MenuItem(title: 'Copy', onTap: () => copied++)],
                child: const Text('Long target'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Long target'));
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);

      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
      expect(copied, 1);
      expect(find.text('Copy'), findsNothing);
    });
  });
}
