import 'package:flutter_test/flutter_test.dart';
import 'package:storage_kit/storage_kit.dart';

/// In-memory [StorageAdapter] whose writes to keys in [failKeys] silently
/// fail (return `false`, nothing stored) — mirrors what [SharedPrefsAdapter]
/// / [HiveAdapter] do internally: every write is wrapped in a try/catch that
/// swallows the exception and returns `false`, so a failure is never visible
/// to the caller except through that boolean.
class _FailingWriteAdapter implements StorageAdapter {
  Set<String> failKeys;
  _FailingWriteAdapter({this.failKeys = const {}});

  final Map<String, Object?> _data = {};

  @override
  Future<void> init() async {}

  @override
  Future<String?> getString(String key) async => _data[key] as String?;

  @override
  Future<bool> setString(String key, String value) async {
    if (failKeys.contains(key)) return false;
    _data[key] = value;
    return true;
  }

  @override
  Future<int?> getInt(String key) async => _data[key] as int?;

  @override
  Future<bool> setInt(String key, int value) async {
    if (failKeys.contains(key)) return false;
    _data[key] = value;
    return true;
  }

  @override
  Future<double?> getDouble(String key) async => _data[key] as double?;

  @override
  Future<bool> setDouble(String key, double value) async {
    if (failKeys.contains(key)) return false;
    _data[key] = value;
    return true;
  }

  @override
  Future<bool?> getBool(String key) async => _data[key] as bool?;

  @override
  Future<bool> setBool(String key, bool value) async {
    if (failKeys.contains(key)) return false;
    _data[key] = value;
    return true;
  }

  @override
  Future<List<String>?> getStringList(String key) async =>
      _data[key] as List<String>?;

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    if (failKeys.contains(key)) return false;
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> containsKey(String key) async => _data.containsKey(key);

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> clear({Set<String>? allowList}) async {
    _data.removeWhere((key, _) => allowList == null || !allowList.contains(key));
    return true;
  }

  @override
  Future<Set<String>> getKeys() async => _data.keys.toSet();

  @override
  Future<void> reload() async {}

  @override
  Future<void> close() async {}
}

void main() {
  setUp(() {
    AppStorage.reset();
  });

  test(
    'saveAuthTokens: failed accessToken write does not poison the sync cache',
    () async {
      final adapter = _FailingWriteAdapter(
        failKeys: {StorageKeys.accessToken},
      );
      await AppStorage.initializeWithAdapter(adapter);

      final ok = await AppStorage.instance.saveAuthTokens(
        accessToken: 'new-token',
      );

      expect(ok, isFalse);
      expect(AppStorage.instance.getAccessTokenSync(), isNull);
      expect(await AppStorage.instance.getAccessToken(), isNull);
    },
  );

  test(
    'saveAccessToken: a failed write rolls the cache back to the still-persisted token',
    () async {
      final adapter = _FailingWriteAdapter();
      await AppStorage.initializeWithAdapter(adapter);
      await AppStorage.instance.saveAccessToken('old-token');

      adapter.failKeys = {StorageKeys.accessToken};
      final ok = await AppStorage.instance.saveAccessToken('new-token');

      expect(ok, isFalse);
      expect(AppStorage.instance.getAccessTokenSync(), 'old-token');
      expect(await AppStorage.instance.getAccessToken(), 'old-token');
    },
  );

  test('saveAuthTokens: a successful write updates the sync cache', () async {
    final adapter = _FailingWriteAdapter();
    await AppStorage.initializeWithAdapter(adapter);

    final ok = await AppStorage.instance.saveAuthTokens(
      accessToken: 'good-token',
    );

    expect(ok, isTrue);
    expect(AppStorage.instance.getAccessTokenSync(), 'good-token');
    expect(await AppStorage.instance.getAccessToken(), 'good-token');
  });
}
