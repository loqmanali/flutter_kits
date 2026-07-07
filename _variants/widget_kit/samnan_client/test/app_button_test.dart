import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('AppButton', () {
    testWidgets('renders the label text', (tester) async {
      await tester.pumpWidget(_wrap(const AppButton(label: 'Continue')));

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('fires onPressed when tapped', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Tap me', onPressed: () => pressed++)),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(pressed, 1);
    });

    testWidgets('does not fire onPressed when isDisabled is true', (
      tester,
    ) async {
      var pressed = 0;
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Disabled',
            isDisabled: true,
            onPressed: () => pressed++,
          ),
        ),
      );

      await tester.tap(find.text('Disabled'), warnIfMissed: false);
      await tester.pump();

      expect(pressed, 0);
    });

    testWidgets('does not fire onPressed while isLoading', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Loading',
            isLoading: true,
            onPressed: () => pressed++,
          ),
        ),
      );

      // While loading the label is replaced by the loading indicator, so tap
      // the underlying FilledButton instead.
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump();

      expect(pressed, 0);
      // Label is not shown while loading.
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('renders the provided icon alongside the label', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppButton(label: 'With icon', icon: Icon(Icons.add))),
      );

      expect(find.text('With icon'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('icon style renders the icon and fires onPressed', (
      tester,
    ) async {
      var pressed = 0;
      await tester.pumpWidget(
        _wrap(
          AppButton(
            style: AppButtonStyleType.icon,
            icon: const Icon(Icons.favorite),
            onPressed: () => pressed++,
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pump();

      expect(pressed, 1);
    });
  });
}
