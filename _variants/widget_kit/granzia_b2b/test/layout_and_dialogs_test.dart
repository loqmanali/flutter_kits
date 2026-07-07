import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppBackButton', () {
    testWidgets('fires onTap when tapped', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        _wrap(Center(child: AppBackButton(onTap: () => tapped++))),
      );

      await tester.tap(find.byType(AppBackButton));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('renders an icon', (tester) async {
      await tester.pumpWidget(
        _wrap(Center(child: AppBackButton(onTap: () {}))),
      );
      expect(find.byType(Icon), findsOneWidget);
    });
  });

  group('PageTopBar', () {
    testWidgets('renders the title', (tester) async {
      await tester.pumpWidget(
        _wrap(const PageTopBar(title: 'Settings')),
      );
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders provided actions', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PageTopBar(
            title: 'Profile',
            actions: [Icon(Icons.edit), Icon(Icons.share)],
          ),
        ),
      );
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('fires onBackPressed when the back affordance is tapped',
        (tester) async {
      var back = 0;
      await tester.pumpWidget(
        _wrap(
          PageTopBar(title: 'Detail', onBackPressed: () => back++),
        ),
      );
      // Tap the back button (an AppBackButton when onBackPressed is supplied).
      await tester.tap(find.byType(AppBackButton));
      await tester.pump();
      expect(back, 1);
    });
  });

  group('SheetHeader', () {
    testWidgets('renders the title', (tester) async {
      await tester.pumpWidget(
        _wrap(const SheetHeader(title: 'Pick a country')),
      );
      expect(find.text('Pick a country'), findsOneWidget);
    });

    testWidgets('fires onClose when the close button is tapped', (tester) async {
      var closed = 0;
      await tester.pumpWidget(
        _wrap(SheetHeader(title: 'Header', onClose: () => closed++)),
      );
      // The close affordance is an icon button; tap the close icon.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(closed, 1);
    });
  });

  group('AppWarningDialog', () {
    testWidgets('renders title, message and both buttons', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppWarningDialog(
            title: 'Delete?',
            message: 'This cannot be undone.',
            buttonText: 'Delete',
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Delete?'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget); // default cancel label
    });

    testWidgets('fires onPressed when the confirm button is tapped',
        (tester) async {
      var confirmed = 0;
      await tester.pumpWidget(
        _wrap(
          AppWarningDialog(
            title: 'Sure?',
            message: 'msg',
            buttonText: 'Yes',
            onPressed: () => confirmed++,
          ),
        ),
      );

      await tester.tap(find.text('Yes'));
      await tester.pump();
      expect(confirmed, 1);
    });

    testWidgets('uses a custom cancel label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppWarningDialog(
            title: 't',
            message: 'm',
            buttonText: 'ok',
            cancelText: 'Not now',
            onPressed: () {},
          ),
        ),
      );
      expect(find.text('Not now'), findsOneWidget);
    });
  });

  group('LoadingIndicator', () {
    testWidgets('circular type renders a CircularProgressIndicator',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const Center(child: LoadingIndicator(type: LoadingIndicatorType.circular))),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders without error for the adaptive type', (tester) async {
      await tester.pumpWidget(
        _wrap(const Center(child: LoadingIndicator(type: LoadingIndicatorType.adaptive))),
      );
      // adaptive resolves to a platform indicator; just assert it builds & shows
      // a progress-like widget without throwing.
      expect(find.byType(LoadingIndicator), findsOneWidget);
    });
  });
}
