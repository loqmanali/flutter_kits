import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcase_kit/showcase_kit.dart';

/// Three targets and a button that starts the tour over them.
class _TourHost extends HookWidget {
  const _TourHost({this.autoPlay = false});

  final bool autoPlay;

  @override
  Widget build(BuildContext context) {
    final steps = useMemoized(
      () => [
        ShowcaseStep(key: GlobalKey(), title: 'One', body: 'first'),
        ShowcaseStep(key: GlobalKey(), title: 'Two', body: 'second'),
        ShowcaseStep(key: GlobalKey(), title: 'Three', body: 'third'),
      ],
    );
    final tour = useShowcaseTour(steps, autoPlay: autoPlay);

    return Scaffold(
      body: Column(
        children: [
          for (final step in steps)
            ShowcaseTarget(
              showcaseKey: step.key,
              child: SizedBox(height: 40, child: Text('target ${step.title}')),
            ),
          TextButton(onPressed: tour.start, child: const Text('go')),
        ],
      ),
    );
  }
}

/// The spotlight ring pulses forever, so `pumpAndSettle` would never return.
/// Pumping past the fade-in is enough to see the settled bubble.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _start(WidgetTester tester, {bool autoPlay = false}) async {
  await tester.pumpWidget(MaterialApp(home: _TourHost(autoPlay: autoPlay)));
  await tester.tap(find.text('go'));
  await _settle(tester);
}

void main() {
  testWidgets('walks forward through the steps and finishes on the last one',
      (tester) async {
    await _start(tester);
    expect(find.text('1 / 3'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await _settle(tester);
    expect(find.text('2 / 3'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await _settle(tester);
    expect(find.text('3 / 3'), findsOneWidget);
    // Last step offers Done, not Next.
    expect(find.text('Next'), findsNothing);

    await tester.tap(find.text('Done'));
    await _settle(tester);
    expect(find.text('3 / 3'), findsNothing);
  });

  testWidgets('Prev on the first step keeps the tour open', (tester) async {
    await _start(tester);

    await tester.tap(find.text('Prev'));
    await _settle(tester);

    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('Prev goes back a step', (tester) async {
    await _start(tester);
    await tester.tap(find.text('Next'));
    await _settle(tester);

    await tester.tap(find.text('Prev'));
    await _settle(tester);

    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('Skip ends the tour', (tester) async {
    await _start(tester);

    await tester.tap(find.text('Skip'));
    await _settle(tester);

    expect(find.text('1 / 3'), findsNothing);
  });

  testWidgets('the backdrop swallows taps meant for the app behind it',
      (tester) async {
    await _start(tester);

    await tester.tap(find.text('go'), warnIfMissed: false);
    await _settle(tester);

    // Still on step 1: the tap never reached the start button.
    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('auto-play advances on its own', (tester) async {
    await _start(tester, autoPlay: true);
    expect(find.text('1 / 3'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await _settle(tester);

    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('unmounting mid-tour disposes the overlay and the timer',
      (tester) async {
    await _start(tester, autoPlay: true);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump(const Duration(seconds: 10));

    expect(find.text('1 / 3'), findsNothing);
    // A leaked auto-play timer would fail the test binding here.
  });
}
