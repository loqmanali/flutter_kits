import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

CarouselItem _labelled(String text) => WidgetCarouselItem(
      id: text,
      builder: (_) => Text(text),
    );

void main() {
  group('CarouselStateNotifier (via ProviderContainer)', () {
    late ProviderContainer container;
    late CarouselStateNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      // Keep the autoDispose provider alive for the test's duration.
      container.listen(carouselStateProvider, (_, __) {},
          fireImmediately: true);
      notifier = container.read(carouselStateProvider.notifier);
    });
    tearDown(() => container.dispose());

    test('starts empty', () {
      expect(container.read(carouselStateProvider).isEmpty, isTrue);
    });

    test('setItems populates and clamps the index', () {
      notifier.setItems([_labelled('a'), _labelled('b')]);
      expect(container.read(carouselStateProvider).itemCount, 2);
    });

    test('next/previous move the current index within bounds', () {
      notifier.setItems([_labelled('a'), _labelled('b'), _labelled('c')]);
      notifier.next();
      expect(container.read(carouselStateProvider).currentIndex, 1);
      notifier.next();
      notifier.next(); // already last → stays
      expect(container.read(carouselStateProvider).currentIndex, 2);
      notifier.previous();
      expect(container.read(carouselStateProvider).currentIndex, 1);
    });

    test('next(loop: true) wraps around', () {
      notifier.setItems([_labelled('a'), _labelled('b')]);
      notifier.goTo(1);
      notifier.next(loop: true);
      expect(container.read(carouselStateProvider).currentIndex, 0);
    });

    test('setCurrentIndex ignores out-of-range values', () {
      notifier.setItems([_labelled('a'), _labelled('b')]);
      notifier.setCurrentIndex(99); // ignored
      expect(container.read(carouselStateProvider).currentIndex, 0);
      notifier.setCurrentIndex(1);
      expect(container.read(carouselStateProvider).currentIndex, 1);
    });

    test('removeItemAt removes and re-clamps the index', () {
      notifier.setItems([_labelled('a'), _labelled('b'), _labelled('c')]);
      notifier.goTo(2);
      notifier.removeItemAt(2);
      final state = container.read(carouselStateProvider);
      expect(state.itemCount, 2);
      expect(state.currentIndex, 1); // clamped from 2 → 1
    });

    test('addItem appends', () {
      notifier.setItems([_labelled('a')]);
      notifier.addItem(_labelled('b'));
      expect(container.read(carouselStateProvider).itemCount, 2);
    });

    test('flags: paused / dragging / animating are settable', () {
      notifier.setPaused(true);
      notifier.setDragging(true);
      notifier.setAnimating(true);
      final state = container.read(carouselStateProvider);
      expect(state.isPaused, isTrue);
      expect(state.isDragging, isTrue);
      expect(state.isAnimating, isTrue);
    });

    test('clear empties the carousel', () {
      notifier.setItems([_labelled('a'), _labelled('b')]);
      notifier.clear();
      expect(container.read(carouselStateProvider).isEmpty, isTrue);
    });
  });

  group('Carousel widget', () {
    Widget wrap(Widget child) => ProviderScope(
          child: MaterialApp(home: Scaffold(body: child)),
        );

    testWidgets('renders the first item', (tester) async {
      await tester.pumpWidget(
        wrap(
          SizedBox(
            height: 260,
            child: Carousel(
              items: [_labelled('Slide 1'), _labelled('Slide 2')],
              config: CarouselConfig.banner,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Slide 1'), findsOneWidget);
    });

    testWidgets('uses a PageView under the hood', (tester) async {
      await tester.pumpWidget(
        wrap(
          SizedBox(
            height: 260,
            child: Carousel(
              items: [_labelled('A'), _labelled('B')],
              config: CarouselConfig.banner,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('handles an empty item list without throwing', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            height: 260,
            child: Carousel(items: [], config: CarouselConfig.banner),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Carousel), findsOneWidget);
    });
  });
}
