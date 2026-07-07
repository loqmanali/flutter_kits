import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppTextFormField', () {
    testWidgets('renders label and hint text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppTextFormField(
            labelText: 'Email',
            hintText: 'you@example.com',
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('you@example.com'), findsOneWidget);
    });

    testWidgets('fires onChanged with the typed value', (tester) async {
      String? changed;
      await tester.pumpWidget(
        _wrap(
          AppTextFormField(
            onChanged: (v) => changed = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'hello');
      await tester.pump();

      expect(changed, 'hello');
    });

    testWidgets('shows validator error after invalid input', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppTextFormField(
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Required field' : null,
          ),
        ),
      );

      // autovalidateMode defaults to onUserInteraction, so typing then
      // clearing triggers validation.
      await tester.enterText(find.byType(TextFormField), 'x');
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      expect(find.text('Required field'), findsOneWidget);
    });

    testWidgets('reflects external controller text', (tester) async {
      final controller = TextEditingController(text: 'preset');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(AppTextFormField(controller: controller)),
      );

      expect(find.text('preset'), findsOneWidget);
    });
  });
}
