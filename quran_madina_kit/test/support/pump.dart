import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';
import 'package:quran_madina_kit/src/widget.dart' show resetMadinaBootCache;

/// Call once at the top of a widget-test `main()`.
///
/// Both the kit's boot cache and `rootBundle`'s asset cache store *futures*.
/// Each `testWidgets` case runs in its own fake-async zone, and a future
/// created in an earlier case's zone never delivers its completion into a later
/// one — so without clearing both, every test after the first hangs on the
/// placeholder.
void setUpMadinaTests() {
  setUp(() {
    resetMadinaBootCache();
    rootBundle.clear();
  });
}

/// Wraps [child] in the minimum tree a [QuranMadinaView] needs.
Widget madinaHost(
  Widget child, {
  MadinaConfig config = const MadinaConfig(font: 'Hafs', fontSize: 16),
  MadinaTheme? theme,
  Color? textColour,
}) =>
    MaterialApp(
      home: MadinaScope(
        config: config,
        theme: theme,
        child: Scaffold(
          body: DefaultTextStyle(
            style: TextStyle(color: textColour ?? const Color(0xFF000000)),
            child: Center(child: child),
          ),
        ),
      ),
    );

/// Pumps [app] and drives the kit's boot to completion.
///
/// `pumpAndSettle` alone is not enough: widget tests run on a fake clock, which
/// never advances the real asset I/O (`rootBundle`) and font loading that the
/// boot awaits, so the future stays pending and the view renders its
/// placeholder forever. [WidgetTester.runAsync] hands control back to the real
/// event loop between pumps. This is a test-harness constraint only — in a
/// running app the future completes on its own.
Future<void> pumpMadina(
  WidgetTester tester,
  Widget app, {
  int turns = 6,
}) async {
  await tester.pumpWidget(app);
  await settleMadina(tester, turns: turns);
}

/// Drives pending boot/shard I/O without re-pumping a new tree — use after a
/// rebuild that changes which juz' shards are needed.
Future<void> settleMadina(WidgetTester tester, {int turns = 6}) async {
  for (var i = 0; i < turns; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
}
