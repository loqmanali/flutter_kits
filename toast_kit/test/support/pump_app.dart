import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toast_kit/toast_kit.dart';

/// Wraps [home] in a [MaterialApp] whose `builder` installs a [ToastHost]
/// above the [Navigator] — the shape every app is meant to use this kit in.
Future<GlobalKey<ToastHostState>> pumpToastApp(
  WidgetTester tester, {
  required Widget home,
  TextDirection textDirection = TextDirection.ltr,
  ThemeData? theme,
}) async {
  final key = GlobalKey<ToastHostState>();
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      builder: (context, child) => Directionality(
        textDirection: textDirection,
        child: ToastHost(key: key, child: child!),
      ),
      home: home,
    ),
  );
  return key;
}

/// Pumps exactly enough for a just-`show()`n toast to build, report
/// `markShown` from its post-frame callback, and finish its enter
/// animation — the point at which its geometry and gestures are stable
/// enough to assert against.
Future<void> pumpUntilShown(WidgetTester tester) async {
  await tester.pump(); // build; the post-frame callback fires within this.
  await tester.pump(const Duration(milliseconds: 250)); // finish entering.
}
