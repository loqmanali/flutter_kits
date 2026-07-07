import 'package:flutter_test/flutter_test.dart';
import 'package:force_update_gate/force_update_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('session mode', () {
    test('never persists', () async {
      final store = DismissalStore();
      await store.recordDismissal(
        mode: ForceUpdateSkipMode.session,
        cooldown: const Duration(hours: 1),
        storeVersion: '1.0.1',
      );
      expect(
        await store.isDismissed(
          mode: ForceUpdateSkipMode.session,
          storeVersion: '1.0.1',
        ),
        isFalse,
      );
    });
  });

  group('cooldown mode', () {
    test('persists for the cooldown duration', () async {
      final store = DismissalStore();
      final now = DateTime(2026, 1, 1, 12);
      await store.recordDismissal(
        mode: ForceUpdateSkipMode.cooldown,
        cooldown: const Duration(hours: 24),
        storeVersion: '1.0.1',
        now: now,
      );

      expect(
        await store.isDismissed(
          mode: ForceUpdateSkipMode.cooldown,
          storeVersion: '1.0.1',
          now: now.add(const Duration(hours: 23)),
        ),
        isTrue,
      );

      expect(
        await store.isDismissed(
          mode: ForceUpdateSkipMode.cooldown,
          storeVersion: '1.0.1',
          now: now.add(const Duration(hours: 25)),
        ),
        isFalse,
      );
    });

    test('zero cooldown is a no-op', () async {
      final store = DismissalStore();
      await store.recordDismissal(
        mode: ForceUpdateSkipMode.cooldown,
        cooldown: Duration.zero,
        storeVersion: '1.0.1',
      );
      expect(
        await store.isDismissed(
          mode: ForceUpdateSkipMode.cooldown,
          storeVersion: '1.0.1',
        ),
        isFalse,
      );
    });
  });

  group('version mode', () {
    test('persists until the store version changes', () async {
      final store = DismissalStore();
      await store.recordDismissal(
        mode: ForceUpdateSkipMode.version,
        cooldown: Duration.zero,
        storeVersion: '1.0.1',
      );

      expect(
        await store.isDismissed(
          mode: ForceUpdateSkipMode.version,
          storeVersion: '1.0.1',
        ),
        isTrue,
      );

      expect(
        await store.isDismissed(
          mode: ForceUpdateSkipMode.version,
          storeVersion: '1.0.2',
        ),
        isFalse,
      );
    });
  });

  test('clear() wipes all keys', () async {
    final store = DismissalStore();
    await store.recordDismissal(
      mode: ForceUpdateSkipMode.cooldown,
      cooldown: const Duration(hours: 1),
      storeVersion: '1.0.1',
    );
    await store.recordDismissal(
      mode: ForceUpdateSkipMode.version,
      cooldown: Duration.zero,
      storeVersion: '1.0.1',
    );
    await store.clear();
    expect(
      await store.isDismissed(
        mode: ForceUpdateSkipMode.cooldown,
        storeVersion: '1.0.1',
      ),
      isFalse,
    );
    expect(
      await store.isDismissed(
        mode: ForceUpdateSkipMode.version,
        storeVersion: '1.0.1',
      ),
      isFalse,
    );
  });
}
