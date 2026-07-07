import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization_kit/localization_kit.dart';

void main() {
  group('Localization name/flag lookup', () {
    test('returns the registered display name', () {
      expect(Localization.getLanguageName('en'), 'English');
      expect(Localization.getLanguageName('ar'), 'العربية');
    });

    test('falls back to the iso code when no name override exists', () {
      expect(Localization.getLanguageName('fr'), 'fr');
    });

    test('returns the registered flag emoji', () {
      expect(Localization.getLanguageFlag('en'), '🇺🇸');
      expect(Localization.getLanguageFlag('ar'), '🇸🇦');
    });

    test('falls back to the globe emoji for unknown languages', () {
      expect(Localization.getLanguageFlag('zz'), '🌐');
    });

    test('honours runtime overrides', () {
      Localization.languageNameOverrides['fr'] = 'Français';
      Localization.languageFlagOverrides['fr'] = '🇫🇷';
      addTearDown(() {
        Localization.languageNameOverrides.remove('fr');
        Localization.languageFlagOverrides.remove('fr');
      });

      expect(Localization.getLanguageName('fr'), 'Français');
      expect(Localization.getLanguageFlag('fr'), '🇫🇷');
    });
  });

  group('LocalizationContextX RTL helper', () {
    Future<void> pumpWithLocale(
      WidgetTester tester,
      Locale locale,
      TextDirection direction,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: direction,
          child: Localizations(
            locale: locale,
            delegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            child: const _Probe(),
          ),
        ),
      );
      // Localizations resolves its delegates asynchronously; settle so the
      // probe rebuilds with the real locale.
      await tester.pumpAndSettle();
    }

    testWidgets('isArabic + isRtl are true under an Arabic RTL tree',
        (tester) async {
      await pumpWithLocale(tester, const Locale('ar'), TextDirection.rtl);

      final state = tester.state<_ProbeState>(find.byType(_Probe));
      expect(state.capturedIsArabic, isTrue);
      expect(state.capturedIsRtl, isTrue);
    });

    testWidgets('isArabic + isRtl are false under an English LTR tree',
        (tester) async {
      await pumpWithLocale(tester, const Locale('en'), TextDirection.ltr);

      final state = tester.state<_ProbeState>(find.byType(_Probe));
      expect(state.capturedIsArabic, isFalse);
      expect(state.capturedIsRtl, isFalse);
    });
  });
}

class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  late bool capturedIsArabic;
  late bool capturedIsRtl;

  @override
  Widget build(BuildContext context) {
    capturedIsArabic = context.isArabic;
    capturedIsRtl = context.isRtl;
    return const SizedBox.shrink();
  }
}
