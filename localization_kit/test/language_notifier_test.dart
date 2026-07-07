import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization_kit/localization_kit.dart';

/// A fully in-memory fake of the storage seam that records writes so tests can
/// assert that [LanguageNotifier.changeLocale] persists the user's choice.
class FakeStorage implements LocalizationStorageAdapter {
  FakeStorage({this.isoCode, this.apiCode});

  String? isoCode;
  String? apiCode;

  final List<String> setLocaleCalls = [];
  final List<String> setLanguageCalls = [];

  @override
  Future<String?> getLocaleCode() async => isoCode;

  @override
  Future<String?> getLanguageCode() async => apiCode;

  @override
  Future<void> setLocaleCode(String value) async {
    isoCode = value;
    setLocaleCalls.add(value);
  }

  @override
  Future<void> setLanguageCode(String value) async {
    apiCode = value;
    setLanguageCalls.add(value);
  }
}

const _en = LanguageModel(code: 'en_US', name: 'English', isoCode: 'en');
const _ar = LanguageModel(code: 'ar_EG', name: 'العربية', isoCode: 'ar');

void main() {
  late FakeStorage storage;
  late List<String> headerSyncCalls;

  setUp(() {
    storage = FakeStorage();
    headerSyncCalls = [];
    // Re-establish a clean, known runtime for every test. The runtime is
    // process-wide static state, so each test must inject its own seam.
    LocalizationKitRuntime.use(
      storage: storage,
      defaultLanguages: const [_en, _ar],
      defaultIsoCode: 'en',
      defaultApiCode: 'en_US',
      onLanguageChanged: (code) async => headerSyncCalls.add(code),
    );
  });

  ProviderContainer makeContainer() => ProviderContainer.test();

  test('build() yields the default English state', () {
    final container = makeContainer();
    final state = container.read(languageProvider);

    expect(state.locale, const Locale('en'));
    expect(state.apiCode, 'en_US');
    expect(state.languages, isEmpty);
  });

  test('initialize() loads the stored locale and pushes header sync', () async {
    storage.isoCode = 'ar';
    storage.apiCode = 'ar_EG';

    final container = makeContainer();
    final notifier = container.read(languageProvider.notifier);

    await notifier.initialize();
    // Let the background language-fetch future settle.
    await Future<void>.delayed(Duration.zero);

    final state = container.read(languageProvider);
    expect(state.locale, const Locale('ar'));
    expect(state.apiCode, 'ar_EG');
    expect(state.isLoading, isFalse);
    expect(state.languages, [_en, _ar]);
    expect(headerSyncCalls, ['ar_EG']);
  });

  test('initialize() falls back to runtime defaults when storage is empty',
      () async {
    final container = makeContainer();
    final notifier = container.read(languageProvider.notifier);

    await notifier.initialize();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(languageProvider);
    expect(state.locale, const Locale('en'));
    expect(state.apiCode, 'en_US');
    expect(headerSyncCalls, ['en_US']);
  });

  test('changeLocale() persists to storage, syncs headers and updates state',
      () async {
    final container = makeContainer();
    final notifier = container.read(languageProvider.notifier);

    await notifier.changeLocale(isoCode: 'ar', apiCode: 'ar_EG');

    expect(storage.setLocaleCalls, ['ar']);
    expect(storage.setLanguageCalls, ['ar_EG']);
    expect(headerSyncCalls, ['ar_EG']);

    final state = container.read(languageProvider);
    expect(state.locale, const Locale('ar'));
    expect(state.apiCode, 'ar_EG');
    // languages was empty, so changeLocale backfills it from defaults.
    expect(state.languages, [_en, _ar]);

    expect(notifier.currentLocale, const Locale('ar'));
    expect(notifier.currentApiCode, 'ar_EG');
  });

  test('fetchLanguages(useLocal: true) populates from runtime defaults',
      () async {
    final container = makeContainer();
    final notifier = container.read(languageProvider.notifier);

    await notifier.fetchLanguages(useLocal: true);

    final state = container.read(languageProvider);
    expect(state.languages, [_en, _ar]);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
  });

  test('computed slice providers reflect the notifier state', () async {
    final container = makeContainer();
    final notifier = container.read(languageProvider.notifier);

    await notifier.changeLocale(isoCode: 'ar', apiCode: 'ar_EG');

    expect(container.read(currentLocaleProvider), const Locale('ar'));
    expect(container.read(currentApiCodeProvider), 'ar_EG');
    expect(container.read(isArabicProvider), isTrue);
    expect(container.read(textDirectionProvider), TextDirection.rtl);
    expect(container.read(availableLanguagesProvider), [_en, _ar]);
    expect(container.read(languageLoadingProvider), isFalse);
  });
}
