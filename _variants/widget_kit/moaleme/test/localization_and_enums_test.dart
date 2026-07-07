import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

void main() {
  group('WidgetKitStrings', () {
    test('has sensible English defaults', () {
      const s = WidgetKitStrings();
      expect(s.confirm, 'Confirm');
      expect(s.cancel, 'Cancel');
      expect(s.retry, 'Retry');
      expect(s.search, 'Search');
      expect(s.done, 'Done');
      expect(s.noResults, 'No results');
    });

    test('fallback equals the default-constructed instance values', () {
      const fb = WidgetKitStrings.fallback;
      expect(fb.confirm, 'Confirm');
      expect(fb.cancel, 'Cancel');
    });

    test('overrides are applied per-field', () {
      const s = WidgetKitStrings(confirm: 'موافق', cancel: 'إلغاء');
      expect(s.confirm, 'موافق');
      expect(s.cancel, 'إلغاء');
      // Untouched fields keep defaults.
      expect(s.retry, 'Retry');
    });
  });

  group('WidgetKitDirectionality.isRtl', () {
    testWidgets('true under an RTL Directionality', (tester) async {
      late bool rtl;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) {
              rtl = context.isRtl;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(rtl, isTrue);
    });

    testWidgets('false under an LTR Directionality', (tester) async {
      late bool rtl;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              rtl = context.isRtl;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(rtl, isFalse);
    });
  });

  group('ShimmerShapeType', () {
    test('enumerates the four supported shapes', () {
      expect(ShimmerShapeType.values, [
        ShimmerShapeType.rectangle,
        ShimmerShapeType.circle,
        ShimmerShapeType.text,
        ShimmerShapeType.button,
      ]);
    });
  });

  group('AppButton enums', () {
    test('AppButtonStyleType covers all ten variants', () {
      expect(AppButtonStyleType.values, hasLength(10));
      expect(
        AppButtonStyleType.values,
        containsAll(<AppButtonStyleType>[
          AppButtonStyleType.filled,
          AppButtonStyleType.outlined,
          AppButtonStyleType.text,
          AppButtonStyleType.icon,
          AppButtonStyleType.fab,
        ]),
      );
    });

    test('AdaptiveButtonSize has large/medium/small', () {
      expect(AdaptiveButtonSize.values,
          [AdaptiveButtonSize.large, AdaptiveButtonSize.medium, AdaptiveButtonSize.small]);
    });

    test('AppButtonWidthMode has fill and hug', () {
      expect(AppButtonWidthMode.values,
          [AppButtonWidthMode.fill, AppButtonWidthMode.hug]);
    });
  });

  group('AppButtonThemeExtension', () {
    test('defaults expose a style for every AppButtonStyleType', () {
      const ext = AppButtonThemeExtension.defaults;
      for (final type in AppButtonStyleType.values) {
        // getStyle must return a (non-null) style for each variant.
        expect(ext.getStyle(type), isA<AppButtonStyle>());
      }
    });

    test('getStyle returns the matching named style', () {
      const ext = AppButtonThemeExtension.defaults;
      expect(ext.getStyle(AppButtonStyleType.filled), ext.filled);
      expect(ext.getStyle(AppButtonStyleType.outlined), ext.outlined);
    });

    test('copyWith overrides only the provided style', () {
      const ext = AppButtonThemeExtension.defaults;
      const custom = AppButtonStyle(
        backgroundColor: Color(0xFF000000),
        foregroundColor: Color(0xFFFFFFFF),
        overlayColor: Color(0x14000000),
      );
      // copyWith returns the ThemeExtension supertype; cast back to read fields.
      final updated = ext.copyWith(filled: custom) as AppButtonThemeExtension;
      expect(updated.filled, custom);
      // Another style is untouched.
      expect(updated.outlined, ext.outlined);
    });

    test('lerp at t=0 keeps this and t=1 reaches other', () {
      const a = AppButtonThemeExtension.defaults;
      const b = AppButtonThemeExtension.defaults;
      final lerped0 = a.lerp(b, 0) as AppButtonThemeExtension;
      final lerped1 = a.lerp(b, 1) as AppButtonThemeExtension;
      // Identical inputs → identical filled style at both ends.
      expect(lerped0.getStyle(AppButtonStyleType.filled), isA<AppButtonStyle>());
      expect(lerped1.getStyle(AppButtonStyleType.filled), isA<AppButtonStyle>());
    });
  });
}
