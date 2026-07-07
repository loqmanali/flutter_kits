import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

CarouselItem _item(String id) =>
    WidgetCarouselItem(id: id, builder: (_) => const SizedBox());

List<CarouselItem> _items(int n) =>
    List.generate(n, (i) => _item('item$i'));

void main() {
  group('CarouselState — derived getters', () {
    test('itemCount / isEmpty / isNotEmpty', () {
      const empty = CarouselState();
      expect(empty.itemCount, 0);
      expect(empty.isEmpty, isTrue);
      expect(empty.isNotEmpty, isFalse);

      final full = CarouselState(items: _items(3));
      expect(full.itemCount, 3);
      expect(full.isEmpty, isFalse);
      expect(full.isNotEmpty, isTrue);
    });

    test('hasNext / hasPrevious reflect position', () {
      final state = CarouselState(items: _items(3), currentIndex: 1);
      expect(state.hasNext, isTrue);
      expect(state.hasPrevious, isTrue);

      final first = state.copyWith(currentIndex: 0);
      expect(first.hasPrevious, isFalse);

      final last = state.copyWith(currentIndex: 2);
      expect(last.hasNext, isFalse);
    });

    test('currentItem is null when empty, otherwise the indexed item', () {
      const empty = CarouselState();
      expect(empty.currentItem, isNull);

      final items = _items(3);
      final state = CarouselState(items: items, currentIndex: 1);
      expect(state.currentItem, items[1]);
    });

    test('currentItem clamps an out-of-range index', () {
      final items = _items(2);
      final state = CarouselState(items: items, currentIndex: 99);
      expect(state.currentItem, items[1]); // clamped to last
    });
  });

  group('CarouselState — navigation (no loop)', () {
    test('next stops at the last index', () {
      final state = CarouselState(items: _items(3), currentIndex: 2);
      expect(state.next().currentIndex, 2);
    });

    test('next advances by one', () {
      final state = CarouselState(items: _items(3), currentIndex: 0);
      expect(state.next().currentIndex, 1);
    });

    test('previous stops at the first index', () {
      final state = CarouselState(items: _items(3), currentIndex: 0);
      expect(state.previous().currentIndex, 0);
    });

    test('previous goes back by one', () {
      final state = CarouselState(items: _items(3), currentIndex: 2);
      expect(state.previous().currentIndex, 1);
    });
  });

  group('CarouselState — navigation (loop)', () {
    test('next wraps from last to first', () {
      final state = CarouselState(items: _items(3), currentIndex: 2);
      expect(state.next(loop: true).currentIndex, 0);
    });

    test('previous wraps from first to last', () {
      final state = CarouselState(items: _items(3), currentIndex: 0);
      expect(state.previous(loop: true).currentIndex, 2);
    });
  });

  group('CarouselState — goTo / clampIndex', () {
    test('goTo clamps to valid bounds', () {
      final state = CarouselState(items: _items(3));
      expect(state.goTo(1).currentIndex, 1);
      expect(state.goTo(99).currentIndex, 2); // clamped to last
      expect(state.goTo(-5).currentIndex, 0); // clamped to first
    });

    test('goTo on empty is a no-op', () {
      const empty = CarouselState();
      expect(empty.goTo(5).currentIndex, 0);
    });

    test('clampIndex pulls an out-of-range index back into bounds', () {
      final state = CarouselState(items: _items(2), currentIndex: 10);
      expect(state.clampIndex().currentIndex, 1);
    });

    test('next/previous on an empty state return the same state', () {
      const empty = CarouselState();
      expect(empty.next().currentIndex, 0);
      expect(empty.previous().currentIndex, 0);
    });
  });

  group('CarouselState — copyWith & equality', () {
    test('copyWith overrides only named fields', () {
      final base = CarouselState(items: _items(2), currentIndex: 0);
      final next = base.copyWith(currentIndex: 1, isPaused: true);
      expect(next.currentIndex, 1);
      expect(next.isPaused, isTrue);
      expect(next.items, base.items);
    });

    test('value equality holds for identical content', () {
      final items = _items(2);
      final a = CarouselState(items: items, currentIndex: 1);
      final b = CarouselState(items: items, currentIndex: 1);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differs when the index differs', () {
      final items = _items(2);
      final a = CarouselState(items: items, currentIndex: 0);
      final b = CarouselState(items: items, currentIndex: 1);
      expect(a, isNot(b));
    });
  });

  group('CarouselConfig presets', () {
    test('exposes the documented presets', () {
      // Each preset is a const CarouselConfig with its sub-configs wired up.
      for (final config in <CarouselConfig>[
        CarouselConfig.banner,
        CarouselConfig.hero,
        CarouselConfig.cards,
        CarouselConfig.productShowcase,
        CarouselConfig.fullScreen,
        CarouselConfig.thumbnail,
        CarouselConfig.onboarding,
      ]) {
        expect(config.visual, isA<VisualConfig>());
        expect(config.layout, isA<LayoutConfig>());
        expect(config.indicator, isA<IndicatorConfig>());
        expect(config.autoScroll, isA<AutoScrollConfig>());
      }
    });
  });

  group('ImageCarouselItem', () {
    test('asset constructor carries the asset path and id', () {
      const item = ImageCarouselItem.asset('assets/x.png', id: 'a1');
      expect(item.assetPath, 'assets/x.png');
      expect(item.networkUrl, isNull);
      expect(item.id, 'a1');
    });

    test('network constructor carries the url', () {
      const item = ImageCarouselItem.network('https://e.com/i.jpg');
      expect(item.networkUrl, 'https://e.com/i.jpg');
      expect(item.assetPath, isNull);
    });

    test('onTap invokes the supplied callback', () {
      var tapped = 0;
      final item =
          ImageCarouselItem.asset('x.png', onTapCallback: () => tapped++);
      item.onTap();
      expect(tapped, 1);
    });
  });
}
