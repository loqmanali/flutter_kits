import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('CustomStarRating', () {
    testWidgets('renders the requested number of stars', (tester) async {
      await tester.pumpWidget(
        _wrap(const CustomStarRating(initialRating: 0, starCount: 5)),
      );
      // Each star renders an Icon (filled/half/empty all use an Icon widget).
      expect(find.byType(Icon), findsNWidgets(5));
    });

    testWidgets('tapping a star reports that star\'s index+1 rating',
        (tester) async {
      double? reported;
      await tester.pumpWidget(
        _wrap(
          CustomStarRating(
            initialRating: 0,
            onRatingChanged: (r) => reported = r,
          ),
        ),
      );

      // Tap the 3rd star (index 2) → rating 3.0. tap() hits the center, and the
      // onTap handler resolves to index + 1.
      final stars = find.byType(Icon);
      await tester.tap(stars.at(2));
      await tester.pump();

      expect(reported, 3.0);
    });

    testWidgets('readOnly ignores taps and never fires the callback',
        (tester) async {
      var fired = 0;
      await tester.pumpWidget(
        _wrap(
          CustomStarRating(
            initialRating: 2,
            readOnly: true,
            onRatingChanged: (_) => fired++,
          ),
        ),
      );

      await tester.tap(find.byType(Icon).at(4), warnIfMissed: false);
      await tester.pump();

      expect(fired, 0);
    });

    testWidgets(
        'does not re-fire when the tapped rating equals the current one',
        (tester) async {
      var fired = 0;
      await tester.pumpWidget(
        _wrap(
          CustomStarRating(
            initialRating: 3, // already 3 stars
            allowHalfRating: false,
            onRatingChanged: (_) => fired++,
          ),
        ),
      );

      // Tapping the 3rd star resolves to 3.0 again → no change → no callback.
      await tester.tap(find.byType(Icon).at(2));
      await tester.pump();

      expect(fired, 0);
    });

    testWidgets('clamps an over-range initialRating to starCount',
        (tester) async {
      // initialRating 99 with 5 stars → all 5 should render in the FILLED color
      // (the rating was clamped to 5), and none in the empty color.
      const filled = Color(0xFFFFD700);
      const empty = Color(0xFF9CA3AF);
      await tester.pumpWidget(
        _wrap(
          const CustomStarRating(
            initialRating: 99,
            starCount: 5,
            filledColor: filled,
            emptyColor: empty,
          ),
        ),
      );

      // Scope to the IconThemes the widget wraps each star in (they carry the
      // explicit filled/empty color), and assert none is the empty color.
      final starThemes = tester
          .widgetList<IconTheme>(find.byType(IconTheme))
          .where((t) => t.data.color == filled || t.data.color == empty)
          .toList();
      expect(starThemes, hasLength(5));
      expect(starThemes.every((t) => t.data.color == filled), isTrue);
    });

    testWidgets('asserts starCount > 0', (tester) async {
      expect(
        () => CustomStarRating(initialRating: 0, starCount: 0),
        throwsAssertionError,
      );
    });

    testWidgets('asserts iconSize > 0', (tester) async {
      expect(
        () => CustomStarRating(initialRating: 0, iconSize: 0),
        throwsAssertionError,
      );
    });
  });
}
