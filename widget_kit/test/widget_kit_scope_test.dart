import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

Widget _app({required WidgetKitConfig config, required Widget home}) =>
    MaterialApp(
      home: WidgetKitScope(
        config: config,
        child: Scaffold(body: home),
      ),
    );

void main() {
  group('WidgetKitScope fallback', () {
    testWidgets('of() returns built-in-defaults config when no scope mounted',
        (tester) async {
      late WidgetKitConfig resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = WidgetKitScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Absent scope => every hook unset => widgets fall back to built-ins.
      expect(resolved.behavior.bottomSheetUseSafeArea, isNull);
      expect(resolved.behavior.bottomSheetIsDismissible, isNull);
      expect(resolved.builders.loadingBuilder, isNull);
      expect(resolved.builders.emptyStateBuilder, isNull);
      expect(resolved.builders.errorStateBuilder, isNull);
    });
  });

  group('WidgetKitBuilders injection ("interface")', () {
    testWidgets('loadingBuilder replaces the default LoadingIndicator',
        (tester) async {
      await tester.pumpWidget(
        _app(
          config: WidgetKitConfig(
            builders: WidgetKitBuilders(
              loadingBuilder: (_) => const Text('custom-loader'),
            ),
          ),
          home: const LoadingIndicator(),
        ),
      );

      expect(find.text('custom-loader'), findsOneWidget);
    });

    testWidgets('emptyStateBuilder receives data and replaces the default',
        (tester) async {
      await tester.pumpWidget(
        _app(
          config: WidgetKitConfig(
            builders: WidgetKitBuilders(
              emptyStateBuilder: (_, data) => Text('custom-empty:${data.title}'),
            ),
          ),
          home: const EmptyStateWidget(title: 'T', subtitle: 'S'),
        ),
      );

      expect(find.text('custom-empty:T'), findsOneWidget);
      // Built-in subtitle proves the default widget was NOT built.
      expect(find.text('S'), findsNothing);
    });

    testWidgets('errorStateBuilder replaces the default', (tester) async {
      await tester.pumpWidget(
        _app(
          config: WidgetKitConfig(
            builders: WidgetKitBuilders(
              errorStateBuilder: (_, data) => Text('custom-error:${data.message}'),
            ),
          ),
          home: ErrorStateWidget(message: 'M', onRetry: () {}),
        ),
      );

      expect(find.text('custom-error:M'), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
    });
  });

  group('WidgetKitBehavior wiring', () {
    testWidgets('bottomSheetUseSafeArea:true wraps sheet content in SafeArea',
        (tester) async {
      await tester.pumpWidget(
        _app(
          config: const WidgetKitConfig(
            behavior: WidgetKitBehavior(bottomSheetUseSafeArea: true),
          ),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => UIHelper.showBottomSheet(
                context,
                child: const Text('sheet-body'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('sheet-body'), findsOneWidget);
      // The behavior flowed through: our builder wrapped the child in SafeArea.
      expect(
        find.ancestor(
          of: find.text('sheet-body'),
          matching: find.byType(SafeArea),
        ),
        findsWidgets,
      );
    });
  });
}
