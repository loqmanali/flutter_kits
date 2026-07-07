import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_ui_kit/system_ui_kit.dart';

void main() {
  test('overlayForColor uses dark status icons on light backgrounds', () {
    final overlay = SystemUiKit.overlayForColor(
      Colors.white,
      themeBrightness: Brightness.light,
    );

    expect(overlay.statusBarIconBrightness, Brightness.dark);
    expect(overlay.statusBarBrightness, Brightness.light);
  });

  test('overlayForColor uses light status icons on dark backgrounds', () {
    final overlay = SystemUiKit.overlayForColor(
      Colors.black,
      themeBrightness: Brightness.light,
    );

    expect(overlay.statusBarIconBrightness, Brightness.light);
    expect(overlay.statusBarBrightness, Brightness.dark);
  });
}
