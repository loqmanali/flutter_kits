import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_db_kit/src/encryption/encryption_config.dart';

/// Resolves an [EncryptionConfig] into a concrete passphrase.
///
/// For [EncryptionConfig.withKey] this is a no-op. For
/// [EncryptionConfig.fromSecureStorage] it reads the key from the platform
/// keychain, generating and persisting a fresh random one the first time.
class EncryptionResolver {
  EncryptionResolver({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  /// Returns the passphrase to hand to SQLCipher, or null if [config] is null
  /// (i.e. the database is not encrypted).
  Future<String?> resolve(EncryptionConfig? config) async {
    if (config == null) return null;
    if (!config.needsResolution) return config.key;

    final slot = config.secureStorageKey!;
    final existing = await _secureStorage.read(key: slot);
    if (existing != null && existing.isNotEmpty) return existing;

    final generated = _generateKey();
    await _secureStorage.write(key: slot, value: generated);
    return generated;
  }

  /// 256 bits of cryptographically-secure randomness, base64url-encoded so it is
  /// a safe SQLCipher passphrase string.
  static String _generateKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
