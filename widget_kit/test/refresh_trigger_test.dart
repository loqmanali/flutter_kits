import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

const _completeDuration = Duration(milliseconds: 50);

Widget _host({
  RefreshTriggerController? controller,
  ScrollController? scrollController,
  FutureVoidCallback? onRefresh,
  LoadMoreCallback? onLoadMore,
  bool enableLoadMore = false,
  bool refreshOnStart = false,
  RefreshTriggerDisplayMode? displayMode,
  double minExtent = 50,
  double maxExtent = 100,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: RefreshTrigger(
          controller: controller,
          minExtent: minExtent,
          maxExtent: maxExtent,
          completeDuration: _completeDuration,
          onRefresh: onRefresh,
          onLoadMore: onLoadMore,
          enableLoadMore: enableLoadMore,
          refreshOnStart: refreshOnStart,
          displayMode: displayMode,
          child: ListView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            children: [
              for (var i = 0; i < 20; i++)
                SizedBox(height: 40, child: Text('item $i')),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Drags the list far enough to pass `minExtent`, in frame-sized steps so the
/// deferred extent updates land the way they do on a real device.
Future<void> _pull(WidgetTester tester, double dy) async {
  final gesture =
      await tester.startGesture(tester.getCenter(find.byType(ListView)));
  for (var moved = 0.0; moved < dy.abs(); moved += 20) {
    await gesture.moveBy(Offset(0, dy.isNegative ? -20 : 20));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pump();
  await tester.pump();
}

void main() {
  group('refresh', () {
    testWidgets('pulling past minExtent runs onRefresh then settles to idle',
        (tester) async {
      final completer = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(_host(onRefresh: () {
        calls++;
        return completer.future;
      }));

      await _pull(tester, 150);
      expect(calls, 1, reason: 'the pull crossed minExtent');
      expect(find.text('Refreshing...'), findsOneWidget);

      completer.complete();
      await tester.pump();
      expect(find.text('Completed'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('Completed'), findsNothing);
    });

    testWidgets('a short pull never fires onRefresh', (tester) async {
      var calls = 0;
      await tester.pumpWidget(_host(onRefresh: () async => calls++));

      await _pull(tester, 30);
      await tester.pumpAndSettle();

      expect(calls, 0);
    });

    testWidgets('a throwing onRefresh lands on the failed stage',
        (tester) async {
      await tester.pumpWidget(_host(onRefresh: () async => throw 'boom'));

      await _pull(tester, 150);
      await tester.pump();

      expect(find.text('Failed'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('refreshOnStart fires once after the first frame',
        (tester) async {
      var calls = 0;
      await tester.pumpWidget(
          _host(refreshOnStart: true, onRefresh: () async => calls++));

      await tester.pump();
      expect(calls, 1);
      await tester.pumpAndSettle();
    });
  });

  group('load more', () {
    testWidgets('pulling up at the end runs onLoadMore', (tester) async {
      final completer = Completer<void>();
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      var calls = 0;
      await tester.pumpWidget(_host(
        scrollController: scroll,
        enableLoadMore: true,
        onLoadMore: () {
          calls++;
          return completer.future;
        },
      ));

      // Reach the end of the list first, then pull past it.
      scroll.jumpTo(scroll.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(calls, 0, reason: 'a programmatic jump must not trigger a load');

      await _pull(tester, -150);

      expect(calls, 1);
      expect(find.text('Loading...'), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('stays disabled when enableLoadMore is false', (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      var calls = 0;
      await tester.pumpWidget(
        _host(scrollController: scroll, onLoadMore: () async => calls++),
      );

      scroll.jumpTo(scroll.position.maxScrollExtent);
      await tester.pumpAndSettle();
      await _pull(tester, -150);

      expect(calls, 0);
      await tester.pumpAndSettle();
    });

    testWidgets('noMoreData blocks further loads until the next refresh',
        (tester) async {
      final controller = RefreshTriggerController();
      addTearDown(controller.dispose);
      var loads = 0;

      await tester.pumpWidget(_host(
        controller: controller,
        enableLoadMore: true,
        onRefresh: () async {},
        onLoadMore: () async {
          loads++;
          controller.finishLoadMore(noMoreData: true);
        },
      ));

      await controller.requestLoadMore();
      await tester.pumpAndSettle();
      expect(loads, 1);
      expect(controller.noMoreData, isTrue);

      await controller.requestLoadMore();
      await tester.pumpAndSettle();
      expect(loads, 1, reason: 'no more data means no more calls');

      // A successful refresh re-opens the list.
      await controller.requestRefresh();
      await tester.pumpAndSettle();
      expect(controller.noMoreData, isFalse);

      await controller.requestLoadMore();
      await tester.pumpAndSettle();
      expect(loads, 2);
    });
  });

  group('controller', () {
    testWidgets('requestRefresh drives the stage and notifies listeners',
        (tester) async {
      final controller = RefreshTriggerController();
      addTearDown(controller.dispose);
      final stages = <TriggerStage>[];
      controller.addListener(() => stages.add(controller.refreshStage));

      await tester.pumpWidget(_host(
        controller: controller,
        onRefresh: () async {},
      ));

      await controller.requestRefresh();
      await tester.pumpAndSettle();

      expect(
        stages,
        containsAllInOrder(<TriggerStage>[
          TriggerStage.refreshing,
          TriggerStage.completed,
          TriggerStage.idle,
        ]),
      );
      expect(controller.isRefreshing, isFalse);
    });

    testWidgets('finishRefresh(success: false) ends on failed', (tester) async {
      final controller = RefreshTriggerController();
      addTearDown(controller.dispose);
      final completer = Completer<void>();

      await tester.pumpWidget(_host(
        controller: controller,
        onRefresh: () => completer.future,
      ));

      unawaited(controller.requestRefresh());
      await tester.pump();
      expect(controller.isRefreshing, isTrue);

      controller.finishRefresh(success: false);
      await tester.pump();
      expect(controller.refreshStage, TriggerStage.failed);

      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  group('robustness', () {
    testWidgets('a synchronously throwing onRefresh still reaches failed',
        (tester) async {
      // Not `async` on purpose: it throws before returning a future.
      Future<void> boom() => throw StateError('boom');

      await tester.pumpWidget(_host(onRefresh: boom));
      await _pull(tester, 150);
      await tester.pump();

      expect(find.text('Failed'), findsOneWidget,
          reason: 'the stage must not get stuck on refreshing');
      await tester.pumpAndSettle();
    });

    testWidgets('maxExtent == minExtent does not produce NaN geometry',
        (tester) async {
      await tester.pumpWidget(_host(
        minExtent: 50,
        maxExtent: 50,
        displayMode: RefreshTriggerDisplayMode.inset,
        onRefresh: () async {},
      ));

      await _pull(tester, 200);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('accessibility', () {
    testWidgets('the resting indicator stays out of the semantics tree',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_host(onRefresh: () async {}));

      expect(find.text('Pull to refresh'), findsOneWidget,
          reason: 'it is built, just parked off-screen');
      expect(find.bySemanticsLabel('Pull to refresh'), findsNothing,
          reason: 'a screen reader must not read it from anywhere in the list');

      handle.dispose();
    });

    testWidgets('the running indicator is announced', (tester) async {
      final handle = tester.ensureSemantics();

      final completer = Completer<void>();
      await tester.pumpWidget(_host(onRefresh: () => completer.future));

      await _pull(tester, 150);
      expect(find.bySemanticsLabel('Refreshing...'), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();
      handle.dispose();
    });

    testWidgets('reduced motion settles the indicator without animating',
        (tester) async {
      await tester.pumpWidget(_host(
        disableAnimations: true,
        displayMode: RefreshTriggerDisplayMode.inset,
        onRefresh: () async {},
      ));
      final restingTop = tester.getTopLeft(find.byType(ListView)).dy;

      await _pull(tester, 150);
      await tester.pump(_completeDuration);
      // One frame past the completed window is enough — no 250ms slide back.
      await tester.pump();

      expect(tester.getTopLeft(find.byType(ListView)).dy, restingTop);
    });
  });

  group('display modes', () {
    testWidgets('inset mode gives the indicator real layout space',
        (tester) async {
      await tester.pumpWidget(_host(
        displayMode: RefreshTriggerDisplayMode.inset,
        onRefresh: () async {},
      ));

      final before = tester.getTopLeft(find.byType(ListView)).dy;

      await _pull(tester, 150);
      await tester.pump();
      final during = tester.getTopLeft(find.byType(ListView)).dy;

      expect(during, greaterThan(before), reason: 'content is pushed down');
      await tester.pumpAndSettle();
    });

    testWidgets('overlay mode leaves the content in place', (tester) async {
      await tester.pumpWidget(_host(onRefresh: () async {}));

      final before = tester.getTopLeft(find.byType(ListView)).dy;
      await _pull(tester, 150);
      await tester.pump();

      expect(tester.getTopLeft(find.byType(ListView)).dy, before);
      await tester.pumpAndSettle();
    });
  });
}
