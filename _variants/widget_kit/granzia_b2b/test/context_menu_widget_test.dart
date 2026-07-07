import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('ContextMenu', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ContextMenu(
            items: [MenuItem(title: 'Copy', onTap: () {})],
            child: const Text('Target'),
          ),
        ),
      );
      expect(find.text('Target'), findsOneWidget);
      // Menu is not shown until triggered.
      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('tapping opens the menu with its items', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ContextMenu(
            items: [
              MenuItem(title: 'Copy', onTap: () {}),
              MenuItem(title: 'Delete', onTap: () {}),
            ],
            child: const Text('Target'),
          ),
        ),
      );

      await tester.tap(find.text('Target'));
      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('tapping an item fires its onTap and dismisses the menu',
        (tester) async {
      var copied = 0;
      await tester.pumpWidget(
        _wrap(
          ContextMenu(
            items: [MenuItem(title: 'Copy', onTap: () => copied++)],
            child: const Text('Target'),
          ),
        ),
      );

      await tester.tap(find.text('Target'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      expect(copied, 1);
      expect(find.text('Copy'), findsNothing); // menu dismissed
    });

    testWidgets('onMenuShown fires when the menu opens', (tester) async {
      var shown = 0;
      await tester.pumpWidget(
        _wrap(
          ContextMenu(
            items: [MenuItem(title: 'X', onTap: () {})],
            onMenuShown: () => shown++,
            child: const Text('Target'),
          ),
        ),
      );

      await tester.tap(find.text('Target'));
      await tester.pumpAndSettle();
      expect(shown, 1);
    });

    testWidgets('a disabled item does not fire onTap', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        _wrap(
          ContextMenu(
            items: [
              MenuItem(title: 'Nope', enabled: false, onTap: () => tapped++),
            ],
            child: const Text('Target'),
          ),
        ),
      );

      await tester.tap(find.text('Target'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nope'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tapped, 0);
    });

    testWidgets('longPress trigger opens on long press, not tap', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ContextMenu(
            trigger: MenuTrigger.longPress,
            items: [MenuItem(title: 'Item', onTap: () {})],
            child: const Text('Target'),
          ),
        ),
      );

      // A plain tap should NOT open it.
      await tester.tap(find.text('Target'));
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsNothing);

      // A long press opens it.
      await tester.longPress(find.text('Target'));
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsOneWidget);
    });

    testWidgets('renders a submenu trigger for items with subItems',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          ContextMenu(
            items: [
              MenuItem(
                title: 'More',
                onTap: () {},
                subItems: [MenuItem(title: 'Nested', onTap: () {})],
              ),
            ],
            child: const Text('Target'),
          ),
        ),
      );

      await tester.tap(find.text('Target'));
      await tester.pumpAndSettle();
      // The parent row is shown; it has sub-items (rendered as a submenu trigger).
      expect(find.text('More'), findsOneWidget);
    });
  });
}
