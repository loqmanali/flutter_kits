import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

/// Renders the pill indicator for a fixed stage, optionally under a theme.
Widget _pill(TriggerStage stage, {RefreshTriggerTheme? theme}) {
  final controller = AnimationController(
    vsync: const TestVSync(),
    duration: Duration.zero,
  )..value = 1;

  Widget child = Builder(
    builder: (context) => AppPillRefreshIndicator.builder(
      context,
      RefreshTriggerStage(stage, controller, Axis.vertical, false),
    ),
  );

  if (theme != null) {
    child = RefreshTriggerThemeProvider(data: theme, child: child);
  }
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('AppPillRefreshIndicator copy', () {
    testWidgets('falls back to the built-in Arabic strings with no theme',
        (tester) async {
      await tester.pumpWidget(_pill(TriggerStage.refreshing));
      expect(find.text('جاري التحديث…'), findsOneWidget);
    });

    testWidgets('uses RefreshTriggerTheme overrides when supplied',
        (tester) async {
      const theme = RefreshTriggerTheme(
        pullText: 'Pull to refresh',
        releaseText: 'Release to refresh',
        refreshingText: 'Refreshing…',
        completedText: 'Done',
      );

      for (final (stage, expected) in <(TriggerStage, String)>[
        (TriggerStage.idle, 'Pull to refresh'),
        (TriggerStage.refreshing, 'Refreshing…'),
        (TriggerStage.completed, 'Done'),
      ]) {
        await tester.pumpWidget(_pill(stage, theme: theme));
        expect(find.text(expected), findsOneWidget,
            reason: 'stage $stage should render its override');
      }
    });

    testWidgets('pulling past the trigger point switches to releaseText',
        (tester) async {
      const theme = RefreshTriggerTheme(
        pullText: 'Pull',
        releaseText: 'Release',
      );
      await tester.pumpWidget(_pill(TriggerStage.pulling, theme: theme));
      // extentValue is pinned at 1 => past the trigger point.
      expect(find.text('Release'), findsOneWidget);
      expect(find.text('Pull'), findsNothing);
    });
  });

  group('RefreshTriggerTheme value semantics', () {
    test('copyWith round-trips the copy fields', () {
      const base = RefreshTriggerTheme(pullText: 'a', completedText: 'd');
      final copy = base.copyWith(pullText: () => 'z');

      expect(copy.pullText, 'z');
      expect(copy.completedText, 'd', reason: 'untouched fields survive');
    });

    test('equality accounts for the copy fields', () {
      const a = RefreshTriggerTheme(pullText: 'a');
      const b = RefreshTriggerTheme(pullText: 'b');

      expect(a, equals(const RefreshTriggerTheme(pullText: 'a')));
      expect(a, isNot(equals(b)));
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });
}
