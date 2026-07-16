import 'package:carousel_kit/carousel_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression: an in-flight `CarouselController.animateToPage` future resolves
/// after the widget is gone. Before the `_disposed` guard this called
/// `setState()` on a defunct State and `notifyListeners()` on a disposed
/// ChangeNotifier.
void main() {
  testWidgets('auto-scroll mid-animation does not fire after dispose',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 200,
          child: Carousel(
            config: const CarouselConfig(
              visual: VisualConfig(height: 200),
              autoScroll: AutoScrollConfig(
                enabled: true,
                interval: Duration(milliseconds: 100),
              ),
            ),
            items: [
              for (var i = 0; i < 3; i++)
                WidgetCarouselItem(builder: (_) => Text('item $i')),
            ],
          ),
        ),
      ),
    );

    // Let the auto-scroll timer fire so animateToPage() is in flight.
    await tester.pump(const Duration(milliseconds: 150));

    // Tear the carousel down mid-animation, then let the future resolve.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });
}
