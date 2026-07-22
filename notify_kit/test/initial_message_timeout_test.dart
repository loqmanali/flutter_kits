import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notify_kit/src/fcm_service.dart';

/// Regression test for the freeze where an app awaiting `NotifyKit.init()`
/// before `runApp` sat on its splash screen forever.
///
/// `FirebaseMessaging.getInitialMessage()` never completes on iOS when no APNS
/// token arrives (the normal case on a Simulator). It used to be awaited
/// unbounded, so init could not finish.
///
/// Verified to be a real guard: dropping the `.timeout(...)` from
/// `initialMessageOrNull` makes this fail rather than hang, because fake_async
/// advances virtual time instead of waiting on the wall clock.
void main() {
  test('a never-completing getInitialMessage does not stall init', () {
    fakeAsync((async) {
      final service = FcmService()
        // Never completes — exactly what the platform does with no APNS token.
        ..fetchInitialMessage = () => Completer<RemoteMessage?>().future;

      var settled = false;
      // The production path, not a re-implementation of it.
      unawaited(service.initialMessageOrNull().then((_) => settled = true));

      async.elapse(FcmService.initialMessageTimeout - _tick);
      expect(
        settled,
        isFalse,
        reason: 'must wait the full window before giving up',
      );

      async.elapse(_tick * 2);
      expect(settled, isTrue, reason: 'must give up once the window elapses');
    });
  });

  test('the timeout stays short enough to not be felt at startup', () {
    expect(FcmService.initialMessageTimeout.inSeconds, lessThanOrEqualTo(5));
  });
}

const _tick = Duration(milliseconds: 100);
