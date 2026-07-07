import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:storage_kit/storage_kit.dart';

import 'fake_adapter.dart';

void main() {
  group('StorageInspector.humanizeBytes (pure)', () {
    test('formats bytes below 1 KB with no decimals', () {
      expect(StorageInspector.humanizeBytes(0), '0 B');
      expect(StorageInspector.humanizeBytes(512), '512 B');
      expect(StorageInspector.humanizeBytes(1023), '1023 B');
    });

    test('formats KB with one decimal when value < 10', () {
      expect(StorageInspector.humanizeBytes(1024), '1.0 KB');
      expect(StorageInspector.humanizeBytes(1536), '1.5 KB');
    });

    test('drops the decimal for KB values >= 10', () {
      expect(StorageInspector.humanizeBytes(1024 * 10), '10 KB');
      expect(StorageInspector.humanizeBytes(1024 * 100), '100 KB');
    });

    test('scales up to MB and GB', () {
      expect(StorageInspector.humanizeBytes(1024 * 1024), '1.0 MB');
      expect(StorageInspector.humanizeBytes(1024 * 1024 * 1024), '1.0 GB');
    });

    test('caps at GB even for very large inputs', () {
      const huge = 5 * 1024 * 1024 * 1024;
      expect(StorageInspector.humanizeBytes(huge), '5.0 GB');
    });
  });

  group('StorageInspector.getUsageSummary', () {
    late FakeAdapter adapter;

    setUp(() async {
      adapter = FakeAdapter();
      await AppStorage.initializeWithAdapter(adapter);
    });

    tearDown(() async {
      await AppStorage.resetForTesting();
    });

    test('skips keys with no stored value', () async {
      await AppStorage.instance.setString('present', 'hello');
      final summary = await StorageInspector.getUsageSummary(
        keys: {'present', 'absent'},
      );
      expect(summary.entries.map((e) => e.key), ['present']);
    });

    test('sorts entries from largest to smallest and sums totalBytes',
        () async {
      await AppStorage.instance.setString('small', 'x');
      await AppStorage.instance.setString('big', 'x' * 200);
      final summary = await StorageInspector.getUsageSummary(
        keys: {'small', 'big'},
      );

      // Sorted largest-first.
      expect(summary.entries.first.key, 'big');
      expect(summary.entries.last.key, 'small');
      expect(
        summary.entries.first.sizeBytes,
        greaterThan(summary.entries.last.sizeBytes),
      );

      // total == sum of per-entry sizes.
      final manualTotal =
          summary.entries.fold<int>(0, (acc, e) => acc + e.sizeBytes);
      expect(summary.totalBytes, manualTotal);
    });

    test('byte size of a plain string equals its JSON-encoded utf8 length',
        () async {
      const value = 'café'; // multi-byte char ensures utf8 != length.
      await AppStorage.instance.setString('k', value);
      final summary = await StorageInspector.getUsageSummary(keys: {'k'});
      final expected = utf8.encode(jsonEncode(value)).length;
      expect(summary.entries.single.sizeBytes, expected);
    });

    test('truncates long previews with an ellipsis at 120 chars', () async {
      // 300 chars of JSON -> preview should be exactly 120 chars + ellipsis.
      await AppStorage.instance.setString('long', 'a' * 300);
      final summary = await StorageInspector.getUsageSummary(keys: {'long'});
      final preview = summary.entries.single.preview!;
      expect(preview.endsWith('…'), isTrue);
      expect(preview.length, 121); // 120 chars + the ellipsis glyph
    });

    test('decodes JSON-encoded ints stored as strings (numeric preview)',
        () async {
      // _readAny tries getString first; a value like "5" decodes to int 5.
      await AppStorage.instance.setString('num', '5');
      final summary = await StorageInspector.getUsageSummary(keys: {'num'});
      // jsonEncode(5) == '5' -> 1 byte.
      expect(summary.entries.single.sizeBytes, 1);
    });

    test('getUsageSummaryForAllKeys inspects every key in storage', () async {
      await AppStorage.instance.setString('a', 'one');
      await AppStorage.instance.setInt('b', 1234);
      final summary = await StorageInspector.getUsageSummaryForAllKeys();
      expect(summary.entries.map((e) => e.key).toSet(), {'a', 'b'});
      expect(summary.totalBytes, greaterThan(0));
    });
  });
}
