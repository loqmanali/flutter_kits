import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toast_kit/toast_kit.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets(
      'show renders the toast, and it auto-dismisses after its duration',
      (tester) async {
    final host = await pumpToastApp(tester, home: const SizedBox());
    host.currentState!.show(
      const ToastRequest(title: 'Saved', duration: Duration(seconds: 2)),
    );
    await pumpUntilShown(tester);

    expect(find.text('Saved'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('a toast survives a Navigator push and pop', (tester) async {
    final host = await pumpToastApp(
      tester,
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('Second'))),
          ),
          child: const Text('Push'),
        ),
      ),
    );
    host.currentState!
        .show(const ToastRequest(title: 'Sticky', duration: null));
    await pumpUntilShown(tester);
    expect(find.text('Sticky'), findsOneWidget);

    await tester.tap(find.text('Push'));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('Sticky'), findsOneWidget);

    Navigator.of(tester.element(find.text('Second'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Sticky'), findsOneWidget);
  });

  testWidgets('topCenter renders at the top and horizontally centered',
      (tester) async {
    final host = await pumpToastApp(tester, home: const SizedBox());
    host.currentState!.show(
      const ToastRequest(title: 'Top', placement: ToastPlacement.topCenter),
    );
    await pumpUntilShown(tester);

    final screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final rect = tester.getRect(find.byType(ToastItemWidget));
    expect(rect.top, lessThan(200));
    expect(rect.center.dx, closeTo(screenWidth / 2, 1));
  });

  testWidgets(
      'a start anchor sits on the leading edge, mirrored between LTR and RTL', (
    tester,
  ) async {
    Future<double> leftEdgeFor(TextDirection direction) async {
      final host = await pumpToastApp(
        tester,
        home: const SizedBox(),
        textDirection: direction,
      );
      host.currentState!.show(
        const ToastRequest(
          title: 'Edge',
          placement: ToastPlacement(anchor: ToastHorizontalAnchor.start),
        ),
      );
      await pumpUntilShown(tester);
      final rect = tester.getRect(find.byType(ToastItemWidget));
      await tester.pumpWidget(const SizedBox());
      return rect.left;
    }

    final ltrLeft = await leftEdgeFor(TextDirection.ltr);
    final rtlLeft = await leftEdgeFor(TextDirection.rtl);

    // start in LTR is the physical left; start in RTL is the physical right,
    // so the RTL toast must sit further right than the LTR one.
    expect(rtlLeft, greaterThan(ltrLeft));
  });

  testWidgets('the close button dismisses with ToastDismissReason.closeButton',
      (tester) async {
    final host = await pumpToastApp(tester, home: const SizedBox());
    final handle = host.currentState!.show(
      const ToastRequest(
          title: 'X', duration: null), // sticky -> close button shows.
    );
    await pumpUntilShown(tester);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(await handle.closed, ToastDismissReason.closeButton);
  });

  testWidgets('an action button runs its callback then dismisses with .action',
      (tester) async {
    var pressed = false;
    final host = await pumpToastApp(tester, home: const SizedBox());
    final handle = host.currentState!.show(
      ToastRequest(
        title: 'Undo?',
        action: ToastAction(label: 'Undo', onPressed: () => pressed = true),
      ),
    );
    await pumpUntilShown(tester);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
    expect(await handle.closed, ToastDismissReason.action);
  });

  testWidgets('a horizontal drag past the threshold dismisses with .swipe',
      (tester) async {
    final host = await pumpToastApp(tester, home: const SizedBox());
    final handle =
        host.currentState!.show(const ToastRequest(title: 'Swipe me'));
    await pumpUntilShown(tester);

    await tester.drag(find.text('Swipe me'), const Offset(300, 0));
    await tester.pumpAndSettle();

    expect(await handle.closed, ToastDismissReason.swipe);
  });

  testWidgets('accessibleNavigation keeps a timed toast until dismissed',
      (tester) async {
    tester.view.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(accessibleNavigation: true);
    addTearDown(
        tester.view.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final host = await pumpToastApp(tester, home: const SizedBox());
    host.currentState!.show(
      const ToastRequest(title: 'Read me', duration: Duration(seconds: 1)),
    );
    await pumpUntilShown(tester);

    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Read me'), findsOneWidget);
  });

  testWidgets(
      'disableAnimations skips motion: the toast appears and leaves instantly',
      (
    tester,
  ) async {
    tester.view.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
        tester.view.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final host = await pumpToastApp(tester, home: const SizedBox());
    host.currentState!.show(
      const ToastRequest(title: 'Instant', duration: Duration(seconds: 1)),
    );
    await tester.pump();
    expect(find.text('Instant'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(); // the deferred post-frame acknowledgeRemoved.
    expect(find.text('Instant'), findsNothing);
  });

  group('the frame-occlusion regression', () {
    testWidgets(
      'a toast occluded before its first frame is not dismissed early, and is not stuck',
      (tester) async {
        final host = await pumpToastApp(tester, home: const SizedBox());
        host.currentState!.show(
          const ToastRequest(title: 'Occluded', duration: Duration(seconds: 2)),
        );

        // No frame has rendered yet: time passes with nobody watching,
        // simulating a native modal covering the app. If the bug this kit
        // exists for were present (timer started at show()), the toast
        // would already be burned through by the time a frame finally
        // renders.
        await tester.binding.delayed(const Duration(seconds: 10));

        // The modal goes away: the first frame renders now.
        await tester.pump();
        expect(find.text('Occluded'), findsOneWidget,
            reason: 'must appear once frames resume');

        // A post-frame callback reports it shown and starts the timer only
        // now; it must stay up for its full duration from this point.
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Occluded'), findsOneWidget,
            reason: 'must not be stuck nor early-gone');

        await tester.pump(const Duration(seconds: 1, milliseconds: 100));
        await tester.pumpAndSettle();
        expect(find.text('Occluded'), findsNothing);

        // The controller ends with nothing left in any queue.
        expect(host.currentState!.debugController.activePlacements, isEmpty);
      },
    );
  });
}
