import 'package:flutter_test/flutter_test.dart';
import 'package:local_db_kit/local_db_kit.dart';

void main() {
  group('ConflictResolvers', () {
    RemoteChange remote(DateTime at) => RemoteChange(
          entityId: 'x',
          opType: SyncOpType.update,
          payload: '{}',
          updatedAt: at,
        );

    group('lastWriteWins', () {
      test('newer remote beats older local', () {
        final winner = ConflictResolvers.lastWriteWins(
          remote(DateTime(2026, 5)),
          DateTime(2026, 1),
        );
        expect(winner, ConflictWinner.remote);
      });

      test('older remote loses to newer local', () {
        final winner = ConflictResolvers.lastWriteWins(
          remote(DateTime(2026, 1)),
          DateTime(2026, 5),
        );
        expect(winner, ConflictWinner.local);
      });

      test('equal timestamps keep local (remote must be strictly newer)', () {
        final t = DateTime(2026, 3, 3);
        expect(
          ConflictResolvers.lastWriteWins(remote(t), t),
          ConflictWinner.local,
        );
      });
    });

    test('serverWins always picks remote, even when local is newer', () {
      expect(
        ConflictResolvers.serverWins(remote(DateTime(2020)), DateTime(2030)),
        ConflictWinner.remote,
      );
    });

    test('clientWins always keeps local, even when remote is newer', () {
      expect(
        ConflictResolvers.clientWins(remote(DateTime(2030)), DateTime(2020)),
        ConflictWinner.local,
      );
    });
  });

  group('SyncOperation.copyWith', () {
    final base = SyncOperation(
      id: '1',
      entityType: 'todos',
      entityId: 'e1',
      opType: SyncOpType.create,
      payload: '{}',
      updatedAt: DateTime(2026),
      attempts: 0,
    );

    test('copies only attempts, leaving everything else intact', () {
      final next = base.copyWith(attempts: 3);
      expect(next.attempts, 3);
      expect(next.id, base.id);
      expect(next.entityType, base.entityType);
      expect(next.entityId, base.entityId);
      expect(next.opType, base.opType);
      expect(next.payload, base.payload);
      expect(next.updatedAt, base.updatedAt);
    });

    test('no-arg copyWith preserves attempts', () {
      expect(base.copyWith().attempts, base.attempts);
    });
  });

  group('SyncStatus', () {
    test('isSynced is true only when idle, empty, and error-free', () {
      const synced = SyncStatus(phase: SyncPhase.idle, pendingCount: 0);
      expect(synced.isSynced, isTrue);
    });

    test('isSynced is false while syncing', () {
      const s = SyncStatus(phase: SyncPhase.syncing);
      expect(s.isSynced, isFalse);
    });

    test('isSynced is false with pending changes', () {
      const s = SyncStatus(phase: SyncPhase.idle, pendingCount: 2);
      expect(s.isSynced, isFalse);
    });

    test('isSynced is false when there is a lastError', () {
      const s = SyncStatus(phase: SyncPhase.idle, lastError: 'boom');
      expect(s.isSynced, isFalse);
    });

    test('copyWith updates fields selectively', () {
      const base = SyncStatus(phase: SyncPhase.idle, pendingCount: 1);
      final next = base.copyWith(phase: SyncPhase.syncing, pendingCount: 5);
      expect(next.phase, SyncPhase.syncing);
      expect(next.pendingCount, 5);
    });

    test('copyWith(clearError: true) wipes the error', () {
      const base = SyncStatus(phase: SyncPhase.idle, lastError: 'boom');
      final next = base.copyWith(clearError: true);
      expect(next.lastError, isNull);
    });

    test('copyWith without clearError keeps the existing error', () {
      const base = SyncStatus(phase: SyncPhase.idle, lastError: 'boom');
      final next = base.copyWith(pendingCount: 9);
      expect(next.lastError, 'boom');
      expect(next.pendingCount, 9);
    });

    test('a new error via copyWith overrides the previous one', () {
      const base = SyncStatus(phase: SyncPhase.idle, lastError: 'old');
      final next = base.copyWith(lastError: 'new');
      expect(next.lastError, 'new');
    });
  });

  group('LocalDbOptions', () {
    test('sensible defaults', () {
      const o = LocalDbOptions();
      expect(o.name, 'app.sqlite');
      expect(o.encryption, isNull);
      expect(o.isEncrypted, isFalse);
      expect(o.foreignKeys, isTrue);
      expect(o.logStatements, isFalse);
      expect(o.directory, DbDirectory.documents);
    });

    test('isEncrypted reflects a provided EncryptionConfig', () {
      const o = LocalDbOptions(encryption: EncryptionConfig.withKey('k'));
      expect(o.isEncrypted, isTrue);
    });

    test('copyWith overrides only the named fields', () {
      const base = LocalDbOptions(name: 'a.sqlite');
      final next = base.copyWith(
        name: 'b.sqlite',
        foreignKeys: false,
        directory: DbDirectory.support,
        logStatements: true,
      );
      expect(next.name, 'b.sqlite');
      expect(next.foreignKeys, isFalse);
      expect(next.directory, DbDirectory.support);
      expect(next.logStatements, isTrue);
    });

    test('copyWith with no args is an equivalent copy', () {
      const base = LocalDbOptions(name: 'x.sqlite', logStatements: true);
      final next = base.copyWith();
      expect(next.name, base.name);
      expect(next.logStatements, base.logStatements);
      expect(next.foreignKeys, base.foreignKeys);
      expect(next.directory, base.directory);
    });
  });

  group('PullResult / RemoteChange value plumbing', () {
    test('PullResult carries its changes and cursor', () {
      final result = PullResult(
        changes: [
          RemoteChange(
            entityId: 'a',
            opType: SyncOpType.delete,
            payload: '',
            updatedAt: DateTime(2026),
          ),
        ],
        nextCursor: 'c1',
      );
      expect(result.changes, hasLength(1));
      expect(result.changes.single.opType, SyncOpType.delete);
      expect(result.nextCursor, 'c1');
    });
  });
}
