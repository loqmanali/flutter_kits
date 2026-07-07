import 'package:local_db_kit/src/encryption/encryption_config.dart';

/// Immutable configuration for opening a local database.
///
/// Pass this to [LocalDbKit.openExecutor] (or the Riverpod providers). It carries
/// no domain assumptions — only how and where the file lives and whether it is
/// encrypted.
class LocalDbOptions {
  const LocalDbOptions({
    this.name = 'app.sqlite',
    this.encryption,
    this.foreignKeys = true,
    this.logStatements = false,
    this.directory = DbDirectory.documents,
  });

  /// File name for the on-disk database. Use distinct names to run several
  /// isolated stores side by side (e.g. one per signed-in account).
  final String name;

  /// When non-null, the database is encrypted at rest with SQLCipher using the
  /// supplied key. When null (the default) the database is plain sqlite.
  final EncryptionConfig? encryption;

  /// Enforce `PRAGMA foreign_keys = ON` on every connection. On by default —
  /// relational integrity is the point of using this kit.
  final bool foreignKeys;

  /// Echo every SQL statement to the Drift log. Handy while developing; leave
  /// off in release builds.
  final bool logStatements;

  /// Which base directory the [name] is resolved against.
  final DbDirectory directory;

  /// Whether this database is encrypted.
  bool get isEncrypted => encryption != null;

  LocalDbOptions copyWith({
    String? name,
    EncryptionConfig? encryption,
    bool? foreignKeys,
    bool? logStatements,
    DbDirectory? directory,
  }) {
    return LocalDbOptions(
      name: name ?? this.name,
      encryption: encryption ?? this.encryption,
      foreignKeys: foreignKeys ?? this.foreignKeys,
      logStatements: logStatements ?? this.logStatements,
      directory: directory ?? this.directory,
    );
  }
}

/// Base directory the database file is resolved against.
enum DbDirectory {
  /// `getApplicationDocumentsDirectory()` — persists across launches, backed up
  /// by the OS. The right default for user data.
  documents,

  /// `getApplicationSupportDirectory()` — persists across launches, not exposed
  /// to the user, typically excluded from iCloud backup. Good for caches you
  /// still want to survive restarts.
  support,

  /// `getTemporaryDirectory()` — the OS may purge this. Only for throwaway data.
  temporary,
}
