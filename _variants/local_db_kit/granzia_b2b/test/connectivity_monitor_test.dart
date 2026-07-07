import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_db_kit/local_db_kit.dart';

void main() {
  group('ManualConnectivityMonitor', () {
    test('reports its initial state', () async {
      final online = ManualConnectivityMonitor(initial: true);
      addTearDown(online.dispose);
      expect(await online.isOnline, isTrue);

      final offline = ManualConnectivityMonitor(initial: false);
      addTearDown(offline.dispose);
      expect(await offline.isOnline, isFalse);
    });

    test('onlineChanges emits the current value first', () async {
      final monitor = ManualConnectivityMonitor(initial: true);
      addTearDown(monitor.dispose);
      expect(await monitor.onlineChanges.first, isTrue);
    });

    test('set() updates isOnline and emits transitions', () async {
      final monitor = ManualConnectivityMonitor(initial: false);
      addTearDown(monitor.dispose);

      final seen = <bool>[];
      final sub = monitor.onlineChanges.listen(seen.add);
      await Future<void>.delayed(Duration.zero);

      monitor.set(true);
      monitor.set(false);
      await Future<void>.delayed(Duration.zero);

      expect(await monitor.isOnline, isFalse);
      expect(seen, [false, true, false]);
      await sub.cancel();
    });

    test('distinct: repeated identical values are not re-emitted', () async {
      final monitor = ManualConnectivityMonitor(initial: false);
      addTearDown(monitor.dispose);

      final seen = <bool>[];
      final sub = monitor.onlineChanges.listen(seen.add);
      await Future<void>.delayed(Duration.zero);

      monitor.set(true);
      monitor.set(true); // duplicate — should be dropped by distinct()
      await Future<void>.delayed(Duration.zero);

      expect(seen, [false, true]);
      await sub.cancel();
    });
  });

  group('StreamConnectivityMonitor', () {
    test('uses the initial value until the source emits', () async {
      final controller = StreamController<bool>();
      final monitor = StreamConnectivityMonitor(controller.stream, initial: true);
      addTearDown(() async {
        await monitor.dispose();
        await controller.close();
      });

      expect(await monitor.isOnline, isTrue);
    });

    test('tracks values pushed onto the source stream', () async {
      final controller = StreamController<bool>.broadcast();
      final monitor =
          StreamConnectivityMonitor(controller.stream, initial: false);
      addTearDown(() async {
        await monitor.dispose();
        await controller.close();
      });

      controller.add(true);
      await Future<void>.delayed(Duration.zero);
      expect(await monitor.isOnline, isTrue);

      controller.add(false);
      await Future<void>.delayed(Duration.zero);
      expect(await monitor.isOnline, isFalse);
    });

    test('onlineChanges yields the latest value first', () async {
      final controller = StreamController<bool>.broadcast();
      final monitor =
          StreamConnectivityMonitor(controller.stream, initial: false);
      addTearDown(() async {
        await monitor.dispose();
        await controller.close();
      });

      controller.add(true);
      await Future<void>.delayed(Duration.zero);

      expect(await monitor.onlineChanges.first, isTrue);
    });

    test('dispose cancels the source subscription cleanly', () async {
      final controller = StreamController<bool>.broadcast();
      final monitor =
          StreamConnectivityMonitor(controller.stream, initial: false);

      await monitor.dispose();
      // Pushing after dispose must not throw.
      controller.add(true);
      await Future<void>.delayed(Duration.zero);
      await controller.close();
    });
  });
}
