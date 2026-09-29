import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toast_kit/toast_kit.dart';

void main() {
  const scheme = ColorScheme.light();

  test('merge layers only the non-null fields of the override on fallback', () {
    const override = ToastKitTheme(
      borderRadius: 24,
      defaultLayoutKey: 'filled',
    );
    final merged = ToastKitTheme.fallback.merge(override);

    expect(merged.borderRadius, 24);
    expect(merged.defaultLayoutKey, 'filled');
    // Untouched fields still fall back.
    expect(merged.maxTitleLines, ToastKitTheme.fallback.maxTitleLines);
    expect(merged.elevation, ToastKitTheme.fallback.elevation);
  });

  test(
      'merge adds custom layouts on top of the built-ins rather than replacing them',
      () {
    final custom = FakeLayout();
    final merged = ToastKitTheme.fallback.merge(
      ToastKitTheme(layouts: {'custom': custom}),
    );

    expect(merged.layoutFor('custom'), same(custom));
    expect(merged.layoutFor('flat'), isA<ToastLayout>()); // built-in survived.
  });

  test(
      'lerp interpolates numeric fields and switches discrete ones at the midpoint',
      () {
    const a = ToastKitTheme(borderRadius: 0, maxWidth: 100);
    const b = ToastKitTheme(borderRadius: 20, maxWidth: 300);

    final quarter = a.lerp(b, 0.25);
    expect(quarter.borderRadius, 5);
    expect(quarter.maxWidth, 150);

    final threeQuarters = a.lerp(b, 0.75);
    expect(threeQuarters.borderRadius, 15);
  });

  test(
      'accentFor falls back to a literal for success/warning, to the ColorScheme otherwise',
      () {
    const theme = ToastKitTheme();
    expect(theme.accentFor(ToastTone.error, scheme), scheme.error);
    expect(theme.accentFor(ToastTone.info, scheme), scheme.tertiary);
    expect(theme.accentFor(ToastTone.success, scheme), isNot(scheme.primary));
  });

  test(
      'foregroundFor clears 4.5:1 contrast against backgroundFor for every tone',
      () {
    const theme = ToastKitTheme.fallback;
    for (final tone in ToastTone.values) {
      final background = theme.backgroundFor(tone, scheme);
      final foreground = theme.foregroundFor(tone, scheme);
      final ratio = _contrastRatio(foreground, background);
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason:
            '$tone: $foreground on $background is only ${ratio.toStringAsFixed(2)}:1',
      );
    }
  });

  test('==/hashCode agree for two themes built the same way', () {
    const a = ToastKitTheme(borderRadius: 12, maxTitleLines: 3);
    const b = ToastKitTheme(borderRadius: 12, maxTitleLines: 3);
    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
  });
}

double _contrastRatio(Color a, Color b) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  final la = luminance(a) + 0.05;
  final lb = luminance(b) + 0.05;
  return la > lb ? la / lb : lb / la;
}

class FakeLayout implements ToastLayout {
  @override
  Widget build(BuildContext context, ToastView view) => const SizedBox.shrink();
}
