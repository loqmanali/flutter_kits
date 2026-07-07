import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

void main() {
  group('MenuPositionCalculator.calculateAdjustedPosition', () {
    const screen = Size(400, 800);
    const menu = Size(100, 200);

    Offset adjust(Offset at, {double pad = MenuPositionCalculator.defaultEdgePadding}) =>
        MenuPositionCalculator.calculateAdjustedPosition(
          at,
          menu,
          screen,
          edgePadding: pad,
        );

    test('a fully-on-screen position is returned unchanged', () {
      final result = adjust(const Offset(50, 50));
      expect(result, const Offset(50, 50));
    });

    test('clamps right overflow to screen width - menu width - padding', () {
      // x=350 + menu 100 = 450 > 400 → x' = 400 - 100 - 10 = 290.
      final result = adjust(const Offset(350, 50));
      expect(result.dx, 290);
    });

    test('clamps bottom overflow to screen height - menu height - padding', () {
      // y=700 + menu 200 = 900 > 800 → y' = 800 - 200 - 10 = 590.
      final result = adjust(const Offset(50, 700));
      expect(result.dy, 590);
    });

    test('clamps left overflow to padding', () {
      final result = adjust(const Offset(-30, 50));
      expect(result.dx, MenuPositionCalculator.defaultEdgePadding);
    });

    test('clamps top overflow to padding', () {
      final result = adjust(const Offset(50, -30));
      expect(result.dy, MenuPositionCalculator.defaultEdgePadding);
    });

    test('clamps both axes at once (bottom-right corner)', () {
      final result = adjust(const Offset(390, 790));
      expect(result.dx, 290);
      expect(result.dy, 590);
    });

    test('honours a custom edge padding', () {
      // Right overflow with pad=20 → x' = 400 - 100 - 20 = 280.
      final result = adjust(const Offset(390, 50), pad: 20);
      expect(result.dx, 280);
    });

    test('a menu larger than the screen still clamps left/top to padding', () {
      // contentSize wider than screen: right-overflow branch pushes x negative,
      // then the left-overflow branch pulls it back to padding.
      final result = MenuPositionCalculator.calculateAdjustedPosition(
        const Offset(200, 200),
        const Size(600, 1000), // bigger than the 400x800 screen
        screen,
      );
      expect(result.dx, MenuPositionCalculator.defaultEdgePadding);
      expect(result.dy, MenuPositionCalculator.defaultEdgePadding);
    });
  });

  group('MenuItem', () {
    test('hasSubItems is false when subItems is null', () {
      final item = MenuItem(title: 'Copy', onTap: () {});
      expect(item.hasSubItems, isFalse);
    });

    test('hasSubItems is false when subItems is empty', () {
      final item = MenuItem(title: 'Copy', onTap: () {}, subItems: const []);
      expect(item.hasSubItems, isFalse);
    });

    test('hasSubItems is true when subItems is non-empty', () {
      final item = MenuItem(
        title: 'More',
        onTap: () {},
        subItems: [MenuItem(title: 'Sub', onTap: () {})],
      );
      expect(item.hasSubItems, isTrue);
    });

    test('defaults: enabled true, no icon', () {
      final item = MenuItem(title: 'X', onTap: () {});
      expect(item.enabled, isTrue);
      expect(item.icon, isNull);
    });

    test('carries optional icon and disabled flag', () {
      final item = MenuItem(
        title: 'Delete',
        icon: Icons.delete,
        enabled: false,
        onTap: () {},
      );
      expect(item.icon, Icons.delete);
      expect(item.enabled, isFalse);
    });
  });
}
