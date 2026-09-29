import 'package:flutter_test/flutter_test.dart';
import 'package:toast_kit/toast_kit.dart';

import '../support/fake_toast_clock.dart';

void main() {
  const placement = ToastPlacement.topCenter;

  group('dedupe', () {
    test('a second identical request within the window is dropped', () {
      final clock = FakeToastClock();
      final controller = ToastController(clock: clock);
      addTearDown(controller.dispose);

      controller.show(const ToastRequest(title: 'Saved'), placement: placement);
      controller.show(const ToastRequest(title: 'Saved'), placement: placement);

      expect(controller.visibleIn(placement), hasLength(1));
    });

    test('an identical request after the window elapses is admitted', () {
      final clock = FakeToastClock();
      final controller = ToastController(
        clock: clock,
        policy: const ToastPolicy(dedupeWindow: Duration(milliseconds: 500)),
      );
      addTearDown(controller.dispose);

      controller.show(const ToastRequest(title: 'Saved'), placement: placement);
      clock.advance(const Duration(seconds: 1));
      controller.show(const ToastRequest(title: 'Saved'), placement: placement);

      expect(controller.visibleIn(placement), hasLength(2));
    });
  });

  group('capacity and queue', () {
    test('overflow queues, and dismissing one visible toast promotes the next',
        () {
      final controller = ToastController(
        clock: FakeToastClock(),
        policy: const ToastPolicy(maxVisiblePerPlacement: 2),
      );
      addTearDown(controller.dispose);

      controller.show(const ToastRequest(title: 'A'), placement: placement);
      controller.show(const ToastRequest(title: 'B'), placement: placement);
      final third = controller.show(
        const ToastRequest(title: 'C'),
        placement: placement,
      );

      expect(controller.visibleIn(placement), hasLength(2));
      expect(controller.pendingIn(placement), hasLength(1));
      expect(controller.pendingIn(placement).single.request.title, 'C');
      // A pending (never-shown) toast's handle only resolves once promoted
      // and then dismissed — it must not resolve just by being queued.
      expect(third.closed, isA<Future<ToastDismissReason>>());

      final firstVisibleId = controller.visibleIn(placement).first.id;
      controller.dismiss(firstVisibleId);
      // dismiss() on a Pending (never markShown-ed) visible entry removes
      // immediately, synchronously promoting the queue.
      expect(controller.pendingIn(placement), isEmpty);
      expect(
        controller.visibleIn(placement).map((e) => e.request.title),
        containsAll(<String>['B', 'C']),
      );
    });
  });

  group('the frame-occlusion invariant', () {
    test('the timer does not start until markShown is called', () {
      final clock = FakeToastClock();
      final controller = ToastController(clock: clock);
      addTearDown(controller.dispose);

      controller.show(
        const ToastRequest(title: 'A', duration: Duration(seconds: 4)),
        placement: placement,
      );
      clock.advance(const Duration(seconds: 10));

      // No markShown was ever called: nothing should have timed out.
      expect(controller.visibleIn(placement), hasLength(1));
      expect(controller.visibleIn(placement).single.state, isA<ToastPending>());
    });

    test('markShown starts the timer, which then fires on schedule', () async {
      final clock = FakeToastClock();
      final controller = ToastController(clock: clock);
      addTearDown(controller.dispose);

      final handle = controller.show(
        const ToastRequest(title: 'A', duration: Duration(seconds: 4)),
        placement: placement,
      );
      final id = controller.visibleIn(placement).single.id;
      controller.markShown(id);
      expect(controller.visibleIn(placement).single.state, isA<ToastVisible>());

      clock.advance(const Duration(seconds: 3));
      expect(controller.visibleIn(placement).single.state, isA<ToastVisible>());

      clock.advance(const Duration(seconds: 1));
      expect(controller.visibleIn(placement).single.state, isA<ToastLeaving>());

      controller.acknowledgeRemoved(id);
      expect(controller.visibleIn(placement), isEmpty);
      expect(await handle.closed, ToastDismissReason.timeout);
    });

    test('a dismiss() that arrives before markShown prevents later insertion',
        () {
      final clock = FakeToastClock();
      final controller = ToastController(clock: clock);
      addTearDown(controller.dispose);

      controller.show(
        const ToastRequest(title: 'A', duration: Duration(seconds: 4)),
        placement: placement,
      );
      final id = controller.visibleIn(placement).single.id;

      controller.dismiss(id, ToastDismissReason.programmatic);
      expect(controller.visibleIn(placement), isEmpty);

      // markShown arriving late (e.g. a post-frame callback that was
      // already queued) must be a no-op, not a resurrection.
      controller.markShown(id);
      expect(controller.visibleIn(placement), isEmpty);
      expect(controller.pendingIn(placement), isEmpty);
    });
  });

  group('pause/resume', () {
    test('pausing freezes the remaining time; resuming continues it', () {
      final clock = FakeToastClock();
      final controller = ToastController(clock: clock);
      addTearDown(controller.dispose);

      controller.show(
        const ToastRequest(title: 'A', duration: Duration(seconds: 4)),
        placement: placement,
      );
      final id = controller.visibleIn(placement).single.id;
      controller.markShown(id);

      clock.advance(const Duration(seconds: 1));
      controller.pause(id);

      // Paused: five more seconds must not fire the (now-cancelled) timer.
      clock.advance(const Duration(seconds: 5));
      expect(controller.visibleIn(placement).single.state, isA<ToastVisible>());

      controller.resume(id);
      // ~3s were remaining when paused; 2s more should not be enough.
      clock.advance(const Duration(seconds: 2));
      expect(controller.visibleIn(placement).single.state, isA<ToastVisible>());

      // The rest of the original 3s remaining should finish it off.
      clock.advance(const Duration(seconds: 1, milliseconds: 100));
      expect(controller.visibleIn(placement).single.state, isA<ToastLeaving>());
    });
  });

  group('sticky toasts', () {
    test('a null duration never auto-dismisses', () {
      final clock = FakeToastClock();
      final controller = ToastController(clock: clock);
      addTearDown(controller.dispose);

      controller.show(const ToastRequest(title: 'A', duration: null),
          placement: placement);
      final id = controller.visibleIn(placement).single.id;
      controller.markShown(id);

      clock.advance(const Duration(days: 1));
      expect(controller.visibleIn(placement).single.state, isA<ToastVisible>());
    });
  });

  group('ToastHandle.closed', () {
    test('resolves with the reason dismiss() was given', () async {
      final controller = ToastController(clock: FakeToastClock());
      addTearDown(controller.dispose);

      final handle = controller.show(
        const ToastRequest(title: 'A'),
        placement: placement,
      );
      final id = controller.visibleIn(placement).single.id;
      controller.markShown(id);
      controller.dismiss(id, ToastDismissReason.action);
      controller.acknowledgeRemoved(id);

      expect(await handle.closed, ToastDismissReason.action);
    });
  });
}
