import 'package:flutter_test/flutter_test.dart';
import 'package:storage_kit/storage_kit.dart';

import 'fake_adapter.dart';

void main() {
  late FakeAdapter adapter;

  setUp(() async {
    adapter = FakeAdapter();
    await AppStorage.initializeWithAdapter(adapter);
  });

  tearDown(() async {
    await AppStorage.resetForTesting();
  });

  group('AppStorage initialization', () {
    test('initializeWithAdapter sets isInitialized and calls init()', () {
      expect(AppStorage.isInitialized, isTrue);
      expect(adapter.initCalled, isTrue);
    });

    test('instance throws StateError before initialization', () async {
      await AppStorage.resetForTesting();
      expect(() => AppStorage.instance, throwsStateError);
      expect(AppStorage.isInitialized, isFalse);
      // re-init so tearDown has something to reset cleanly
      await AppStorage.initializeWithAdapter(adapter);
    });

    test('initializeWithAdapter is idempotent — second call is ignored', () async {
      final second = FakeAdapter();
      await AppStorage.initializeWithAdapter(second);
      // The first adapter is still the active one.
      expect(second.initCalled, isFalse);
      expect(identical(AppStorage.instance.adapter, adapter), isTrue);
    });

    test('exposes underlying adapter via getter', () {
      expect(AppStorage.instance.adapter, same(adapter));
    });
  });

  group('AppStorage typed round-trips', () {
    test('String round-trip', () async {
      expect(await AppStorage.instance.setString('locale', 'ar'), isTrue);
      expect(await AppStorage.instance.getString('locale'), 'ar');
    });

    test('int round-trip', () async {
      await AppStorage.instance.setInt('count', 42);
      expect(await AppStorage.instance.getInt('count'), 42);
    });

    test('double round-trip', () async {
      await AppStorage.instance.setDouble('ratio', 1.5);
      expect(await AppStorage.instance.getDouble('ratio'), 1.5);
    });

    test('bool round-trip', () async {
      await AppStorage.instance.setBool('dark', true);
      expect(await AppStorage.instance.getBool('dark'), isTrue);
    });

    test('List<String> round-trip preserves order and is a copy', () async {
      final original = ['a', 'b', 'c'];
      await AppStorage.instance.setStringList('items', original);
      final read = await AppStorage.instance.getStringList('items');
      expect(read, ['a', 'b', 'c']);
      // Mutating the source list must not mutate stored data (defensive copy).
      original.add('d');
      expect(await AppStorage.instance.getStringList('items'), ['a', 'b', 'c']);
    });

    test('missing keys return null for every typed getter', () async {
      expect(await AppStorage.instance.getString('missing'), isNull);
      expect(await AppStorage.instance.getInt('missing'), isNull);
      expect(await AppStorage.instance.getDouble('missing'), isNull);
      expect(await AppStorage.instance.getBool('missing'), isNull);
      expect(await AppStorage.instance.getStringList('missing'), isNull);
    });
  });

  group('AppStorage key management', () {
    test('containsKey reflects presence and removal', () async {
      expect(await AppStorage.instance.containsKey('k'), isFalse);
      await AppStorage.instance.setString('k', 'v');
      expect(await AppStorage.instance.containsKey('k'), isTrue);
      await AppStorage.instance.remove('k');
      expect(await AppStorage.instance.containsKey('k'), isFalse);
    });

    test('getKeys returns all stored keys', () async {
      await AppStorage.instance.setString('a', '1');
      await AppStorage.instance.setInt('b', 2);
      await AppStorage.instance.setBool('c', false);
      expect(await AppStorage.instance.getKeys(), {'a', 'b', 'c'});
    });

    test('clear() removes everything when no allowList given', () async {
      await AppStorage.instance.setString('a', '1');
      await AppStorage.instance.setString('b', '2');
      await AppStorage.instance.clear();
      expect(await AppStorage.instance.getKeys(), isEmpty);
    });

    test('clear(allowList:) preserves only the allow-listed keys', () async {
      await AppStorage.instance.setString('token', 'keep');
      await AppStorage.instance.setString('cache', 'drop');
      await AppStorage.instance.setInt('temp', 9);
      await AppStorage.instance.clear(allowList: {'token'});
      expect(await AppStorage.instance.getKeys(), {'token'});
      expect(await AppStorage.instance.getString('token'), 'keep');
      expect(await AppStorage.instance.getString('cache'), isNull);
    });

    test('reload and close delegate to the adapter', () async {
      await AppStorage.instance.reload();
      expect(adapter.reloadCalled, isTrue);
      // resetForTesting() will call close(); verify direct delegation here too.
      await AppStorage.instance.close();
      expect(adapter.closeCalled, isTrue);
    });
  });

  group('StorageType enum', () {
    test('has exactly the two supported backends', () {
      expect(StorageType.values, [StorageType.sharedPrefs, StorageType.hive]);
    });

    test('values are stable by name', () {
      expect(StorageType.sharedPrefs.name, 'sharedPrefs');
      expect(StorageType.hive.name, 'hive');
    });
  });
}
