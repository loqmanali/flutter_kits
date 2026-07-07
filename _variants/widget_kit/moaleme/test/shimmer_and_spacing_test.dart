import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('ShimmerShape', () {
    testWidgets('rectangle renders a Container with the given size', (tester) async {
      await tester.pumpWidget(
        _wrap(const ShimmerShape.rectangle(width: 120, height: 24)),
      );
      final size = tester.getSize(find.byType(Container));
      expect(size.width, 120);
      expect(size.height, 24);
    });

    testWidgets('circle is laid out as 2*radius square', (tester) async {
      await tester.pumpWidget(
        _wrap(const ShimmerShape.circle(radius: 20)),
      );
      final size = tester.getSize(find.byType(Container));
      expect(size.width, 40);
      expect(size.height, 40);
    });

    testWidgets('circle uses BoxShape.circle (no borderRadius)', (tester) async {
      await tester.pumpWidget(
        _wrap(const ShimmerShape.circle(radius: 15)),
      );
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.borderRadius, isNull);
    });

    testWidgets('rectangle uses a rounded rectangle decoration', (tester) async {
      await tester.pumpWidget(
        _wrap(const ShimmerShape.rectangle(width: 50, height: 50, borderRadius: 10)),
      );
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.rectangle);
      expect(decoration.borderRadius, BorderRadius.circular(10));
    });

    testWidgets('text shape defaults to height 16', (tester) async {
      await tester.pumpWidget(
        _wrap(const ShimmerShape.text(width: 80)),
      );
      final size = tester.getSize(find.byType(Container));
      expect(size.height, 16);
    });

    testWidgets('button shape has default 120x40', (tester) async {
      await tester.pumpWidget(_wrap(const ShimmerShape.button()));
      final size = tester.getSize(find.byType(Container));
      expect(size.width, 120);
      expect(size.height, 40);
    });

    testWidgets('applies a custom background color', (tester) async {
      await tester.pumpWidget(
        _wrap(const ShimmerShape.rectangle(
          width: 10,
          height: 10,
          backgroundColor: Color(0xFF123456),
        )),
      );
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, const Color(0xFF123456));
    });
  });

  group('AppSpacing', () {
    testWidgets('height() produces a vertical SizedBox', (tester) async {
      await tester.pumpWidget(_wrap(const AppSpacing.height(24)));
      final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(box.height, 24);
      expect(box.width, isNull);
    });

    testWidgets('width() produces a horizontal SizedBox', (tester) async {
      await tester.pumpWidget(_wrap(const AppSpacing.width(32)));
      final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(box.width, 32);
      expect(box.height, isNull);
    });

    testWidgets('flex() produces an Expanded with the given flex', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Column(
            children: [Text('a'), AppSpacing.flex(3), Text('b')],
          ),
        ),
      );
      final expanded = tester.widget<Expanded>(find.byType(Expanded));
      expect(expanded.flex, 3);
    });

    testWidgets('static presets map to expected heights', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [AppSpacing.small, AppSpacing.medium, AppSpacing.large],
          ),
        ),
      );
      final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      final heights = boxes.map((b) => b.height).whereType<double>().toSet();
      expect(heights, containsAll(<double>[8, 16, 24]));
    });
  });

  group('AppSpacingContextExtension', () {
    testWidgets('windowHeight/windowWidth reflect MediaQuery size', (tester) async {
      late double h;
      late double w;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Builder(
            builder: (context) {
              h = context.windowHeight;
              w = context.windowWidth;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(h, 800);
      expect(w, 400);
    });
  });
}
