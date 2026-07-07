import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localization_kit/localization_kit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocalizationKitRuntime.use(
    defaultLanguages: const [
      LanguageModel(code: 'en_US', name: 'English', isoCode: 'en'),
      LanguageModel(code: 'ar_EG', name: 'العربية', isoCode: 'ar'),
    ],
    defaultIsoCode: 'en',
    defaultApiCode: 'en_US',
  );

  runApp(const ProviderScope(child: _ExampleApp()));
}

class _ExampleApp extends ConsumerWidget {
  const _ExampleApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(languageProvider.notifier).initialize();
    });

    final locale = ref.watch(currentLocaleProvider);

    return MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _Home(),
    );
  }
}

class _Home extends ConsumerWidget {
  const _Home();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(isArabicProvider);
    return Directionality(
      textDirection: ref.watch(textDirectionProvider),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('localization_kit'),
          actions: [
            LanguageToggle(
              supportedLocales: const [Locale('en'), Locale('ar')],
              onChanged: (locale) {
                final iso = locale.languageCode;
                final api = iso == 'ar' ? 'ar_EG' : 'en_US';
                ref
                    .read(languageProvider.notifier)
                    .changeLocale(isoCode: iso, apiCode: api);
              },
            ),
          ],
        ),
        body: Center(
          child: Text(isArabic ? 'مرحباً' : 'Hello'),
        ),
      ),
    );
  }
}
