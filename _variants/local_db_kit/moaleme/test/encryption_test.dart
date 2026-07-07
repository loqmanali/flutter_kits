import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_db_kit/local_db_kit.dart';

void main() {
  group('EncryptionConfig', () {
    test('withKey holds the literal key and needs no resolution', () {
      const config = EncryptionConfig.withKey('s3cret');
      expect(config.key, 's3cret');
      expect(config.secureStorageKey, isNull);
      expect(config.needsResolution, isFalse);
    });

    test('fromSecureStorage defers to a keychain slot and needs resolution', () {
      const config = EncryptionConfig.fromSecureStorage();
      expect(config.key, isNull);
      expect(config.secureStorageKey, 'local_db_kit.cipher_key');
      expect(config.needsResolution, isTrue);
    });

    test('fromSecureStorage honours a custom slot name', () {
      const config = EncryptionConfig.fromSecureStorage(storageKey: 'my.slot');
      expect(config.secureStorageKey, 'my.slot');
      expect(config.needsResolution, isTrue);
    });
  });

  group('EncryptionResolver', () {
    setUp(() {
      // In-memory secure storage; reset before each test.
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('returns null for a null config (database is not encrypted)', () async {
      final resolver = EncryptionResolver();
      expect(await resolver.resolve(null), isNull);
    });

    test('returns the literal key for withKey, untouched', () async {
      final resolver = EncryptionResolver();
      final key = await resolver.resolve(const EncryptionConfig.withKey('abc123'));
      expect(key, 'abc123');
    });

    test('generates and persists a key on first fromSecureStorage resolve', () async {
      const storage = FlutterSecureStorage();
      final resolver = EncryptionResolver(secureStorage: storage);

      final key = await resolver.resolve(const EncryptionConfig.fromSecureStorage());

      expect(key, isNotNull);
      expect(key, isNotEmpty);
      // It was written to the slot, so a direct read returns the same value.
      expect(await storage.read(key: 'local_db_kit.cipher_key'), key);
    });

    test('returns the SAME key on subsequent resolves (stable across opens)', () async {
      final resolver = EncryptionResolver();
      final first = await resolver.resolve(const EncryptionConfig.fromSecureStorage());
      final second = await resolver.resolve(const EncryptionConfig.fromSecureStorage());
      expect(second, first);
    });

    test('reuses a pre-existing key in the slot rather than regenerating', () async {
      FlutterSecureStorage.setMockInitialValues(
        {'local_db_kit.cipher_key': 'pre-existing-key'},
      );
      final resolver = EncryptionResolver();
      final key = await resolver.resolve(const EncryptionConfig.fromSecureStorage());
      expect(key, 'pre-existing-key');
    });

    test('different slots hold independent keys', () async {
      final resolver = EncryptionResolver();
      final a = await resolver
          .resolve(const EncryptionConfig.fromSecureStorage(storageKey: 'a'));
      final b = await resolver
          .resolve(const EncryptionConfig.fromSecureStorage(storageKey: 'b'));
      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(a, isNot(b));
    });

    test('generated key is 256 bits (32 bytes, base64url)', () async {
      final resolver = EncryptionResolver();
      final key = await resolver.resolve(const EncryptionConfig.fromSecureStorage());
      // 32 bytes base64url-encoded → 43 chars (no padding) or 44 with padding.
      expect(key!.length, anyOf(43, 44));
    });
  });
}
