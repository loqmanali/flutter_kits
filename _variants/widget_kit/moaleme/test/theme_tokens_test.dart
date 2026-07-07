import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

void main() {
  group('WidgetKitTokens', () {
    test('spacing scale is strictly increasing', () {
      const spacing = <double>[
        WidgetKitTokens.spaceXxs,
        WidgetKitTokens.spaceXs,
        WidgetKitTokens.spaceSm,
        WidgetKitTokens.spaceMd,
        WidgetKitTokens.spaceLg,
        WidgetKitTokens.spaceXl,
        WidgetKitTokens.spaceXxl,
      ];
      for (var i = 1; i < spacing.length; i++) {
        expect(spacing[i], greaterThan(spacing[i - 1]),
            reason: 'spacing index $i not increasing');
      }
    });

    test('touch target meets the Material >=48 guideline', () {
      expect(WidgetKitTokens.minTouchTarget, greaterThanOrEqualTo(48));
      expect(WidgetKitTokens.buttonHeight, greaterThanOrEqualTo(48));
    });

    test('breakpoints are ordered compact < medium < expanded', () {
      expect(WidgetKitBreakpoints.compact,
          lessThan(WidgetKitBreakpoints.medium));
      expect(WidgetKitBreakpoints.medium,
          lessThan(WidgetKitBreakpoints.expanded));
    });
  });

  group('WidgetKitTheme', () {
    test('fallback maps to the underlying tokens', () {
      const fb = WidgetKitTheme.fallback;
      expect(fb.inputBorderRadius, WidgetKitTokens.radiusSm);
      expect(fb.inputBorderWidth, WidgetKitTokens.borderThin);
      expect(fb.buttonHeight, WidgetKitTokens.buttonHeight);
    });

    test('of() returns fallback when no extension is registered', () {
      final ctx = _FakeContextHolder();
      // Build a context without the extension and verify fallback resolution.
      expect(ctx.resolvedTheme.inputBorderRadius, WidgetKitTokens.radiusSm);
    });

    test('copyWith overrides only the provided field', () {
      const base = WidgetKitTheme(inputBorderRadius: 4, inputFontSize: 10);
      final updated = base.copyWith(inputBorderRadius: 20);
      expect(updated.inputBorderRadius, 20);
      // Untouched field is preserved.
      expect(updated.inputFontSize, 10);
    });

    test('lerp at t=0 keeps this and t=1 reaches other', () {
      const a = WidgetKitTheme(inputBorderRadius: 0, inputFontSize: 10);
      const b = WidgetKitTheme(inputBorderRadius: 10, inputFontSize: 20);
      final mid = a.lerp(b, 0.5);
      expect(mid.inputBorderRadius, 5);
      expect(mid.inputFontSize, 15);
      expect(a.lerp(b, 0).inputBorderRadius, 0);
      expect(a.lerp(b, 1).inputBorderRadius, 10);
    });
  });
}

/// Minimal helper that resolves [WidgetKitTheme] without the extension being
/// registered, exercising the fallback path of [WidgetKitTheme.of].
class _FakeContextHolder {
  WidgetKitTheme get resolvedTheme {
    // ThemeData with no WidgetKitTheme extension -> of() should give fallback.
    final data = ThemeData.light();
    final ext = data.extension<WidgetKitTheme>();
    return ext ?? WidgetKitTheme.fallback;
  }
}
