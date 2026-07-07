import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:local_db_kit/src/encryption/encryption_resolver.dart';
import 'package:local_db_kit/src/local_db_options.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Entry point for the kit's plumbing.
///
/// You bring a `@DriftDatabase` and its tables; this class builds the
/// [QueryExecutor] underneath it. Nothing here knows about your schema.
///
/// ```dart
/// @DriftDatabase(tables: [Users, Orders])
/// class MyDb extends $MyDb {
///   MyDb(super.e);
///   @override
///   int get schemaVersion => 1;
/// }
///
/// final db = MyDb(LocalDbKit.openExecutor(const LocalDbOptions(name: 'my.sqlite')));
/// ```
///
/// On sqlite3 v3 the native library is bundled via build hooks (see the
/// `hooks:` block in this package's pubspec). Encryption uses the
/// SQLite3MultipleCiphers build — there is no runtime library override to
/// register, and `sqlcipher_flutter_libs` is not used.
abstract final class LocalDbKit {
  /// Builds a lazily-opened on-disk [QueryExecutor] for [options].
  ///
  /// The (async) path resolution, native setup, and optional key resolution all
  /// run on first query via [LazyDatabase] — not in your database constructor.
  /// The native sqlite work runs on a background isolate so it stays off the UI
  /// thread.
  static QueryExecutor openExecutor(LocalDbOptions options) {
    return LazyDatabase(() async {
      final file = await _resolveFile(options);

      if (Platform.isAndroid) {
        // The default sqlite temp location isn't always writable by the native
        // library on Android. Harmless elsewhere.
        sqlite3.tempDirectory = (await getTemporaryDirectory()).path;
      }

      final passphrase = await EncryptionResolver().resolve(options.encryption);

      // Opening an encrypted database over a file that isn't encrypted with
      // this key (e.g. a plaintext DB left by a pre-encryption app version, or
      // a key that was rotated/lost from the keychain) can't be decrypted by
      // SQLCipher. When encryption is on and a stale file blocks the open,
      // discard the file and start a fresh encrypted database. Safe because
      // callers that enable encryption treat this store as a re-syncable
      // cache, not the source of truth. Probed synchronously here (off the UI
      // thread already, inside LazyDatabase) so the failure surfaces now, not
      // on the first real query.
      if (passphrase != null && file.existsSync()) {
        _wipeIfUndecryptable(file, passphrase);
      }

      // Encrypted databases open on the CURRENT isolate, not a background one.
      // `NativeDatabase.createInBackground` spawns a Dart isolate whose FFI
      // `@Native` lookups for `package:sqlite3` don't inherit the app's
      // native-asset mapping to the bundled SQLite3MultipleCiphers build — so
      // there the connection resolves to a plain SQLite with no cipher support,
      // and the key pragmas throw. Opening here keeps the mc library that the
      // main isolate (and the wipe probe above) already sees. The open is a
      // one-time cost at boot, not per-query, so the UI-thread impact is
      // negligible. Plain (unencrypted) databases keep the background open.
      if (passphrase != null) {
        return NativeDatabase(
          file,
          logStatements: options.logStatements,
          setup: (db) => _configureConnection(db, options, passphrase),
        );
      }

      return NativeDatabase.createInBackground(
        file,
        logStatements: options.logStatements,
        setup: (db) => _configureConnection(db, options, passphrase),
      );
    });
  }

  /// An in-memory executor for tests and ephemeral use. Never touches disk and
  /// is never encrypted (there is no file to protect).
  static QueryExecutor inMemory({bool foreignKeys = true}) {
    return NativeDatabase.memory(
      setup: (db) {
        if (foreignKeys) db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  /// Deletes the on-disk file for [options], if it exists. Useful for "log out
  /// and wipe local data" flows. The database must be closed first.
  static Future<void> deleteDatabase(LocalDbOptions options) async {
    final file = await _resolveFile(options);
    if (file.existsSync()) await file.delete();
  }

  /// Runs the per-connection setup: applies the encryption key (when present)
  /// before any other access, then enforces foreign keys.
  ///
  /// Runs on the background isolate opened by [NativeDatabase.createInBackground].
  static void _configureConnection(
    Database db,
    LocalDbOptions options,
    String? passphrase,
  ) {
    if (passphrase != null) {
      // Guard against silently writing plaintext: if the bundled sqlite build
      // is plain upstream (no `source: sqlite3mc` hook), the key pragmas are
      // accepted as no-ops and the data would NOT be encrypted. SQLCipher
      // exposes `cipher_version`; SQLite3MultipleCiphers exposes `cipher`.
      if (!_hasCipherSupport(db)) {
        throw StateError(
          'local_db_kit: encryption was requested but the bundled sqlite3 has '
          'no cipher support. Add the `hooks: { user_defines: { sqlite3: '
          '{ source: sqlite3mc } } }` block to your app pubspec.yaml.',
        );
      }
      // SQLite3MultipleCiphers, configured for SQLCipher-compatible encryption.
      // These must run before any read/write on the connection.
      final escaped = passphrase.replaceAll("'", "''");
      db
        ..execute("PRAGMA cipher = 'sqlcipher';")
        ..execute('PRAGMA legacy = 4;')
        ..execute("PRAGMA key = '$escaped';");
    }

    if (options.foreignKeys) {
      db.execute('PRAGMA foreign_keys = ON;');
    }
  }

  static bool _hasCipherSupport(Database db) {
    if (db.select('PRAGMA cipher_version;').isNotEmpty) {
      return true;
    }

    return db.select('PRAGMA cipher;').isNotEmpty;
  }

  /// Probes [file] with [passphrase]; deletes it if it can't be decrypted.
  ///
  /// Opens the file directly with sqlite3, applies the SQLCipher key pragmas,
  /// and runs a trivial read. A wrong key (or a plaintext file) makes that read
  /// throw — in which case the file is unusable with this key and is removed so
  /// the caller can start fresh. A clean open is closed again untouched.
  ///
  // ponytail: exercised only on a real sqlite3mc build (device/integration
  // test), not the host VM which has no cipher support — verify in the example
  // app's integration_test, not a unit test that would silently no-op.
  static void _wipeIfUndecryptable(File file, String passphrase) {
    Database? probe;
    try {
      probe = sqlite3.open(file.path);
      final escaped = passphrase.replaceAll("'", "''");
      probe
        ..execute("PRAGMA cipher = 'sqlcipher';")
        ..execute('PRAGMA legacy = 4;')
        ..execute("PRAGMA key = '$escaped';")
        // Forces sqlite to read page 1 with the key; throws on a bad key.
        ..select('PRAGMA user_version;');
    } catch (_) {
      try {
        probe?.close();
      } catch (_) {
        // Already dead — nothing to release.
      }
      probe = null;
      file.deleteSync();
      return;
    }
    probe.close();
  }

  static Future<File> _resolveFile(LocalDbOptions options) async {
    final dir = await _baseDirectory(options.directory);
    return File(p.join(dir.path, options.name));
  }

  static Future<Directory> _baseDirectory(DbDirectory which) {
    switch (which) {
      case DbDirectory.documents:
        return getApplicationDocumentsDirectory();
      case DbDirectory.support:
        return getApplicationSupportDirectory();
      case DbDirectory.temporary:
        return getTemporaryDirectory();
    }
  }
}
