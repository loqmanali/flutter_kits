import 'package:adaptive_kit/adaptive_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a widget at a fixed logical size for the context-based API.
Future<void> _pumpAt(
  WidgetTester tester,
  Size size, {
  required WidgetBuilder child,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(builder: child),
      ),
    ),
  );
}

void main() {
  // ---- Singleton API (Adaptive / AdaptiveLayout) -------------------------
  group('Adaptive singleton', () {
    test('phone / tablet / desktop by shortest side', () {
      Adaptive.i.update(width: 390, height: 844, orientation: Orientation.portrait);
      expect(Adaptive.i.isPhone, isTrue);
      expect(Adaptive.i.shouldUseTabletLayout, isFalse);

      Adaptive.i.update(width: 800, height: 1280, orientation: Orientation.portrait);
      expect(Adaptive.i.isTablet, isTrue);
      expect(Adaptive.i.shouldUseTabletLayout, isTrue);

      Adaptive.i.update(width: 1440, height: 900, orientation: Orientation.landscape);
      expect(Adaptive.i.isDesktop, isTrue);
    });

    test('phone landscape uses the tablet layout', () {
      Adaptive.i.update(width: 844, height: 390, orientation: Orientation.landscape);
      expect(Adaptive.i.isPhone, isTrue);
      expect(Adaptive.i.shouldUseTabletLayout, isTrue);
      expect(Adaptive.i.isLandscapeInMobile, isTrue);
    });

    test('value() resolves per form factor, mobile fallback', () {
      Adaptive.i.update(width: 800, height: 1280, orientation: Orientation.portrait);
      expect(Adaptive.i.value(mobile: 1, tablet: 2, desktop: 3), 2);
      Adaptive.i.update(width: 390, height: 844, orientation: Orientation.portrait);
      expect(Adaptive.i.value(mobile: 1, tablet: 2, desktop: 3), 1);
    });
  });

  group('AdaptiveLayout', () {
    testWidgets('falls back to mobile when no tablet body', (tester) async {
      Adaptive.i.update(width: 800, height: 1280, orientation: Orientation.portrait);
      await tester.pumpWidget(const AdaptiveLayout(
        mobile: Text('mobile', textDirection: TextDirection.ltr),
      ));
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('picks tablet body on a tablet', (tester) async {
      Adaptive.i.update(width: 800, height: 1280, orientation: Orientation.portrait);
      await tester.pumpWidget(const AdaptiveLayout(
        mobile: Text('mobile', textDirection: TextDirection.ltr),
        tablet: Text('tablet', textDirection: TextDirection.ltr),
      ));
      expect(find.text('tablet'), findsOneWidget);
    });
  });

  // ---- Context API (ContextBreakpoints / ResponsiveLayout) ----------------
  group('ContextBreakpoints', () {
    testWidgets('mobile / tablet / desktop by width', (tester) async {
      await _pumpAt(tester, const Size(390, 844), child: (context) {
        expect(context.isMobile, isTrue);
        expect(context.displaySize, DisplaySize.mobile);
        return const SizedBox();
      });
      await _pumpAt(tester, const Size(800, 1200), child: (context) {
        expect(context.isTablet, isTrue);
        expect(context.responsiveColumns(), 2);
        return const SizedBox();
      });
      await _pumpAt(tester, const Size(1440, 900), child: (context) {
        expect(context.isDesktop, isTrue);
        return const SizedBox();
      });
    });
  });

  group('ResponsiveLayout', () {
    Widget triad() => ResponsiveLayout(
          mobile: (_) => const Text('m'),
          tablet: (_) => const Text('t'),
          desktop: (_) => const Text('d'),
        );

    testWidgets('picks body by width with fallback', (tester) async {
      await _pumpAt(tester, const Size(390, 844), child: (_) => triad());
      expect(find.text('m'), findsOneWidget);
      await _pumpAt(tester, const Size(800, 1200), child: (_) => triad());
      expect(find.text('t'), findsOneWidget);
      await _pumpAt(tester, const Size(1440, 900), child: (_) => triad());
      expect(find.text('d'), findsOneWidget);
      // Desktop width, no desktop body → tablet.
      await _pumpAt(
        tester,
        const Size(1440, 900),
        child: (_) => ResponsiveLayout(
          mobile: (_) => const Text('m'),
          tablet: (_) => const Text('t'),
        ),
      );
      expect(find.text('t'), findsOneWidget);
    });
  });
}
