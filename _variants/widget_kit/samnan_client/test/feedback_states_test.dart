import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('EmptyStateWidget', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const EmptyStateWidget(
            title: 'No items',
            subtitle: 'Nothing to show here',
          ),
        ),
      );

      expect(find.text('No items'), findsOneWidget);
      expect(find.text('Nothing to show here'), findsOneWidget);
    });

    testWidgets('renders the custom icon when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const EmptyStateWidget(
            icon: Icons.search_off,
            title: 'No results',
            subtitle: 'Try another query',
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('does not render action when only label is given', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const EmptyStateWidget(
            title: 'Empty',
            subtitle: 'sub',
            actionLabel: 'Go',
            // onAction intentionally omitted -> button hidden
          ),
        ),
      );

      expect(find.text('Go'), findsNothing);
    });

    testWidgets('renders action button and fires onAction', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        _wrap(
          EmptyStateWidget(
            title: 'Empty',
            subtitle: 'sub',
            actionLabel: 'Browse',
            onAction: () => tapped++,
          ),
        ),
      );

      expect(find.text('Browse'), findsOneWidget);
      await tester.tap(find.text('Browse'));
      await tester.pump();
      expect(tapped, 1);
    });
  });

  group('ErrorStateWidget', () {
    testWidgets('renders default title and message', (tester) async {
      await tester.pumpWidget(
        _wrap(ErrorStateWidget(message: 'Network unavailable', onRetry: () {})),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Network unavailable'), findsOneWidget);
    });

    testWidgets('uses custom title and retry label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ErrorStateWidget(
            title: 'Oops',
            message: 'boom',
            retryLabel: 'Try again',
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Oops'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('fires onRetry when the retry button is tapped', (
      tester,
    ) async {
      var retried = 0;
      await tester.pumpWidget(
        _wrap(ErrorStateWidget(message: 'failed', onRetry: () => retried++)),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retried, 1);
    });

    testWidgets('hides the message text when message is blank', (tester) async {
      await tester.pumpWidget(
        _wrap(ErrorStateWidget(message: '   ', onRetry: () {})),
      );

      // Only the default title + retry remain; the blank message is not shown.
      expect(find.text('   '), findsNothing);
      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
