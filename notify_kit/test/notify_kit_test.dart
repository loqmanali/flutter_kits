import 'package:flutter_test/flutter_test.dart';
import 'package:notify_kit/notify_kit.dart';
import 'package:notify_kit/src/fcm_service.dart';
import 'package:notify_kit/src/local_service.dart';

class _FakeLocal implements LocalService {
  _FakeLocal({this.failInitCalls = 0});

  /// The first [failInitCalls] calls to [init] throw instead of succeeding —
  /// simulates a platform-channel failure so retry behaviour can be tested.
  int failInitCalls;

  int initCalls = 0;
  int showCalls = 0;
  int scheduleDailyCalls = 0;
  int scheduleAtCalls = 0;
  int? lastScheduleHour;
  int? lastScheduleMinute;
  AndroidChannelConfig? lastChannel;

  @override
  Future<void> init(
    AndroidChannelConfig channel,
    NotifyTapHandler? onTap, {
    NotifyErrorHandler? onError,
  }) async {
    initCalls++;
    if (initCalls <= failInitCalls) {
      throw StateError('simulated platform-channel failure');
    }
    lastChannel = channel;
  }

  @override
  Future<void> show({
    int id = 0,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
  }) async {
    showCalls++;
  }

  @override
  Future<void> scheduleDaily({
    required int id,
    String? title,
    String? body,
    required int hour,
    required int minute,
    Map<String, dynamic>? payload,
  }) async {
    scheduleDailyCalls++;
    lastScheduleHour = hour;
    lastScheduleMinute = minute;
  }

  @override
  Future<void> scheduleAt({
    required int id,
    String? title,
    String? body,
    required DateTime when,
    Map<String, dynamic>? payload,
  }) async {
    scheduleAtCalls++;
  }

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}
}

class _FakeFcm implements FcmService {
  int initCalls = 0;
  int registerDeviceCalls = 0;
  int unregisterDeviceCalls = 0;
  List<String>? lastTopics;
  bool? lastSubscribe;
  List<String>? lastFcmTopics;

  @override
  Future<void> init(NotifyConfig config) async {
    initCalls++;
  }

  /// Unused here — the bounded-fetch behaviour has its own test in
  /// `initial_message_timeout_test.dart`, against the real [FcmService].
  @override
  Future<RemoteMessage?> Function() fetchInitialMessage = () async => null;

  @override
  Future<RemoteMessage?> initialMessageOrNull() async => null;

  @override
  Stream<NotifyMessage> get foregroundMessages => const Stream.empty();

  @override
  Future<bool> waitForApnsToken({
    int maxAttempts = 10,
    Duration delay = const Duration(milliseconds: 500),
  }) async => true;

  @override
  Future<void> subscribeToFcmTopics(List<String> topics) async {
    lastFcmTopics = topics;
  }

  @override
  Future<void> unsubscribeFromFcmTopics(List<String> topics) async {
    lastFcmTopics = topics;
  }

  @override
  Future<String?> getToken() async => 'fake-token';

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> registerDevice(
    NotifyConfig config, {
    NotifyUserProfile? user,
    NotifyDeviceProfile? device,
  }) async {
    registerDeviceCalls++;
  }

  @override
  Future<void> unregisterDevice(NotifyConfig config) async {
    unregisterDeviceCalls++;
  }

  int reportOpenedCalls = 0;

  @override
  void reportOpened(NotifyConfig config, NotifyMessage message) {
    reportOpenedCalls++;
  }

  @override
  Future<void> setTopics(
    NotifyConfig config,
    List<String> topics, {
    required bool subscribe,
  }) async {
    lastTopics = topics;
    lastSubscribe = subscribe;
  }

  @override
  Future<List<NotifyTopic>> fetchTopics(NotifyConfig config) async =>
      const [NotifyTopic(slug: 'news', name: 'News')];
}

void main() {
  const config = NotifyConfig(
    androidChannel: AndroidChannelConfig(
      id: 'c1',
      name: 'Channel',
      icon: 'ic_notification',
    ),
  );

  late _FakeLocal local;
  late _FakeFcm fcm;

  setUp(() {
    local = _FakeLocal();
    fcm = _FakeFcm();
    NotifyKit.resetForTest(local: local, fcm: fcm);
  });

  test('init throws StateError when Firebase is not initialized', () async {
    await expectLater(
      NotifyKit.init(config, firebaseReady: () => false),
      throwsStateError,
    );
    expect(local.initCalls, 0);
    expect(fcm.initCalls, 0);
  });

  test('init succeeds after a failed attempt (guard not stuck)', () async {
    await expectLater(
      NotifyKit.init(config, firebaseReady: () => false),
      throwsStateError,
    );
    await NotifyKit.init(config, firebaseReady: () => true);
    expect(local.initCalls, 1);
    expect(fcm.initCalls, 1);
  });

  test(
    'a service failure does not latch _initialized — retry actually runs',
    () async {
      final flakyLocal = _FakeLocal(failInitCalls: 1);
      NotifyKit.resetForTest(local: flakyLocal, fcm: fcm);

      await expectLater(
        NotifyKit.init(config, firebaseReady: () => true),
        throwsStateError,
      );
      expect(flakyLocal.initCalls, 1);
      expect(fcm.initCalls, 0);

      // Retry: the flag must not have latched on the failed attempt.
      await NotifyKit.init(config, firebaseReady: () => true);
      expect(flakyLocal.initCalls, 2);
      expect(fcm.initCalls, 1);

      // Kit is now genuinely initialized: a gated method no longer throws.
      await expectLater(NotifyKit.showLocal(title: 't'), completes);
      expect(flakyLocal.showCalls, 1);
    },
  );

  test(
    'concurrent init calls share one in-flight attempt (no duplicate subscriptions)',
    () async {
      final first = NotifyKit.init(config, firebaseReady: () => true);
      final second = NotifyKit.init(config, firebaseReady: () => true);

      await Future.wait([first, second]);

      expect(local.initCalls, 1);
      expect(fcm.initCalls, 1);
    },
  );

  test('second init is a no-op (duplicate-listener fix)', () async {
    await NotifyKit.init(config, firebaseReady: () => true);
    await NotifyKit.init(config, firebaseReady: () => true);
    expect(local.initCalls, 1);
    expect(fcm.initCalls, 1);
  });

  test('init passes the android channel to LocalService', () async {
    await NotifyKit.init(config, firebaseReady: () => true);
    expect(local.lastChannel?.id, 'c1');
  });

  test('showLocal before init throws StateError', () {
    expect(() => NotifyKit.showLocal(title: 't'), throwsStateError);
  });

  test('showLocal after init delegates to LocalService', () async {
    await NotifyKit.init(config, firebaseReady: () => true);
    await NotifyKit.showLocal(title: 't', body: 'b', payload: {'r': '/x'});
    expect(local.showCalls, 1);
  });

  test('scheduleDaily before init throws StateError', () {
    expect(
      () => NotifyKit.scheduleDaily(id: 1, hour: 8, minute: 0),
      throwsStateError,
    );
  });

  test('scheduleDaily after init delegates to LocalService', () async {
    await NotifyKit.init(config, firebaseReady: () => true);
    await NotifyKit.scheduleDaily(id: 7, title: 't', hour: 21, minute: 30);
    expect(local.scheduleDailyCalls, 1);
    expect(local.lastScheduleHour, 21);
    expect(local.lastScheduleMinute, 30);
  });

  test('scheduleAt before init throws StateError', () {
    expect(
      () => NotifyKit.scheduleAt(id: 1, when: DateTime(2030)),
      throwsStateError,
    );
  });

  test('scheduleAt after init delegates to LocalService', () async {
    await NotifyKit.init(config, firebaseReady: () => true);
    await NotifyKit.scheduleAt(id: 8, title: 't', when: DateTime(2030));
    expect(local.scheduleAtCalls, 1);
  });

  test('getToken delegates to FcmService', () async {
    await NotifyKit.init(config, firebaseReady: () => true);
    expect(await NotifyKit.getToken(), 'fake-token');
  });

  test('registerDevice delegates when backend is configured', () async {
    final backendConfig = NotifyConfig(
      androidChannel: config.androidChannel,
      backend: NotifyBackendConfig(
        baseUrl: Uri.parse('https://notify.example.com'),
        apiKey: 'nh_secret',
      ),
    );

    await NotifyKit.init(backendConfig, firebaseReady: () => true);
    await NotifyKit.registerDevice(
      user: const NotifyUserProfile(id: 'driver-42'),
    );

    expect(fcm.registerDeviceCalls, 1);
  });

  NotifyConfig withBackend() => NotifyConfig(
        androidChannel: config.androidChannel,
        backend: NotifyBackendConfig(
          baseUrl: Uri.parse('https://notify.example.com'),
          apiKey: 'nh_secret',
        ),
      );

  test('unregisterDevice delegates when backend is configured', () async {
    await NotifyKit.init(withBackend(), firebaseReady: () => true);
    await NotifyKit.unregisterDevice();

    expect(fcm.unregisterDeviceCalls, 1);
  });

  test('unregisterDevice is a no-op without a backend', () async {
    await NotifyKit.init(config, firebaseReady: () => true);
    await NotifyKit.unregisterDevice();

    expect(fcm.unregisterDeviceCalls, 0);
  });

  test('subscribeToTopics delegates with subscribe: true', () async {
    await NotifyKit.init(withBackend(), firebaseReady: () => true);
    await NotifyKit.subscribeToTopics(['news', 'promos']);

    expect(fcm.lastTopics, ['news', 'promos']);
    expect(fcm.lastSubscribe, isTrue);
  });

  test('unsubscribeFromTopics delegates with subscribe: false', () async {
    await NotifyKit.init(withBackend(), firebaseReady: () => true);
    await NotifyKit.unsubscribeFromTopics(['news']);

    expect(fcm.lastTopics, ['news']);
    expect(fcm.lastSubscribe, isFalse);
  });

  test('topic calls are no-ops without a backend', () async {
    await NotifyKit.init(config, firebaseReady: () => true);
    await NotifyKit.subscribeToTopics(['news']);

    expect(fcm.lastTopics, isNull);
  });

  test('fetchTopics delegates when backend is configured', () async {
    await NotifyKit.init(withBackend(), firebaseReady: () => true);
    final topics = await NotifyKit.fetchTopics();

    expect(topics.single.slug, 'news');
  });

  test('fetchTopics returns empty without a backend', () async {
    await NotifyKit.init(config, firebaseReady: () => true);

    expect(await NotifyKit.fetchTopics(), isEmpty);
  });
}
