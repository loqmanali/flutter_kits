// Smoke tests that render every gallery page and assert it builds without
// throwing — this deterministically catches the runtime errors that only show
// up at render time (Hero tag clashes, RenderFlex overflows) without needing to
// drive the app by hand.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:widget_kit/widget_kit.dart';

import 'package:widget_kit_example/gallery/categories.dart';

void main() {
  setUpAll(() async => initializeDateFormatting());

  for (final category in galleryCategories) {
    testWidgets('renders "${category.title}" page without errors', (
      tester,
    ) async {
      // A roomy surface so legitimately tall pages don't report false overflows;
      // any *real* overflow/Hero error still throws and fails the test.
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ToastificationWrapper(
          child: MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              extensions: const [WidgetKitTheme()],
            ),
            home: category.build(),
          ),
        ),
      );
      // Let async builders (e.g. shimmer ticks) settle a couple frames.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        tester.takeException(),
        isNull,
        reason: '${category.title} page threw during render',
      );
    });
  }
}
