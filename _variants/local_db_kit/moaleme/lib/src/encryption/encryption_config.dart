/// How to encrypt a local database at rest.
///
/// The kit never invents or stores keys for you — you supply one. The most
/// common, safe pattern is to keep a random key in the platform keychain and
/// hand it here; [EncryptionConfig.fromSecureStorage] does exactly that.
class EncryptionConfig {
  /// Encrypt with a key you already hold in memory.
  ///
  /// [key] is the SQLCipher passphrase. Anything non-empty works; a long random
  /// string is strongly recommended. Losing the key means losing the data — the
  /// file cannot be decrypted without it.
  const EncryptionConfig.withKey(this.key) : _secureStorageKey = null;

  /// Encrypt with a key fetched from (or generated into) the platform's secure
  /// storage — Keychain on iOS/macOS, Keystore-backed prefs on Android.
  ///
  /// On first use a fresh 256-bit random key is generated and stored under
  /// [storageKey]; subsequent opens read it back. Resolve it with
  /// [EncryptionResolver.resolve] before opening the database.
  const EncryptionConfig.fromSecureStorage({String storageKey = 'local_db_kit.cipher_key'})
      : key = null,
        _secureStorageKey = storageKey;

  /// The literal passphrase, when provided via [EncryptionConfig.withKey].
  final String? key;

  final String? _secureStorageKey;

  /// The secure-storage slot to read/write the key, when this config defers to
  /// the keychain. Null for [EncryptionConfig.withKey].
  String? get secureStorageKey => _secureStorageKey;

  /// Whether the key must be resolved from secure storage before opening.
  bool get needsResolution => key == null && _secureStorageKey != null;
}
