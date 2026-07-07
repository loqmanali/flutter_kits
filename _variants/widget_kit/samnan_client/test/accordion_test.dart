import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

// Content widgets carry a fixed intrinsic height and a key so we can measure
// whether a panel is expanded (height > 0) or collapsed (clipped to ~0) after
// the SizeTransition settles.
const _contentHeight = 60.0;

Widget _content(String key) => SizedBox(
  key: ValueKey('content_$key'),
  height: _contentHeight,
  child: Text('body_$key'),
);

Widget _accordion({required bool allowMultipleOpen}) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      child: Accordion(
        allowMultipleOpen: allowMultipleOpen,
        items: [
          AccordionItemData(header: const Text('H0'), content: _content('0')),
          AccordionItemData(header: const Text('H1'), content: _content('1')),
        ],
      ),
    ),
  ),
);

/// The visible (clipped) height of a panel = the height of the SizeTransition
/// that wraps this panel's content. The child SizedBox keeps its intrinsic
/// height regardless of collapse; the SizeTransition is what actually shrinks.
double _panelHeightOf(WidgetTester tester, String key) {
  final transition = find.ancestor(
    of: find.byKey(ValueKey('content_$key')),
    matching: find.byType(SizeTransition),
  );
  expect(transition, findsOneWidget, reason: 'panel $key has a SizeTransition');
  return tester.getSize(transition).height;
}

void main() {
  group('Accordion', () {
    testWidgets('renders all headers', (tester) async {
      await tester.pumpWidget(_accordion(allowMultipleOpen: false));
      expect(find.text('H0'), findsOneWidget);
      expect(find.text('H1'), findsOneWidget);
    });

    testWidgets('starts fully collapsed (content clipped to zero height)', (
      tester,
    ) async {
      await tester.pumpWidget(_accordion(allowMultipleOpen: false));
      await tester.pumpAndSettle();
      expect(_panelHeightOf(tester, '0'), 0);
      expect(_panelHeightOf(tester, '1'), 0);
    });

    testWidgets('tapping a header expands that panel', (tester) async {
      await tester.pumpWidget(_accordion(allowMultipleOpen: false));
      await tester.pumpAndSettle();

      await tester.tap(find.text('H0'));
      await tester.pumpAndSettle();

      expect(
        _panelHeightOf(tester, '0'),
        greaterThanOrEqualTo(_contentHeight),
        reason: 'panel 0 expanded',
      );
    });

    testWidgets('tapping an expanded header collapses it again', (
      tester,
    ) async {
      await tester.pumpWidget(_accordion(allowMultipleOpen: false));
      await tester.pumpAndSettle();

      await tester.tap(find.text('H0'));
      await tester.pumpAndSettle();
      expect(
        _panelHeightOf(tester, '0'),
        greaterThanOrEqualTo(_contentHeight),
        reason: 'panel 0 expanded',
      );

      await tester.tap(find.text('H0'));
      await tester.pumpAndSettle();
      expect(_panelHeightOf(tester, '0'), 0);
    });

    testWidgets('single-open mode: opening one closes the other', (
      tester,
    ) async {
      await tester.pumpWidget(_accordion(allowMultipleOpen: false));
      await tester.pumpAndSettle();

      await tester.tap(find.text('H0'));
      await tester.pumpAndSettle();
      expect(
        _panelHeightOf(tester, '0'),
        greaterThanOrEqualTo(_contentHeight),
        reason: 'panel 0 expanded',
      );

      await tester.tap(find.text('H1'));
      await tester.pumpAndSettle();
      // Panel 1 is now open and panel 0 has closed.
      expect(
        _panelHeightOf(tester, '1'),
        greaterThanOrEqualTo(_contentHeight),
        reason: 'panel 1 expanded',
      );
      expect(_panelHeightOf(tester, '0'), 0);
    });

    testWidgets('multi-open mode: both panels can be open at once', (
      tester,
    ) async {
      await tester.pumpWidget(_accordion(allowMultipleOpen: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('H0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('H1'));
      await tester.pumpAndSettle();

      expect(
        _panelHeightOf(tester, '0'),
        greaterThanOrEqualTo(_contentHeight),
        reason: 'panel 0 expanded',
      );
      expect(
        _panelHeightOf(tester, '1'),
        greaterThanOrEqualTo(_contentHeight),
        reason: 'panel 1 expanded',
      );
    });
  });
}
