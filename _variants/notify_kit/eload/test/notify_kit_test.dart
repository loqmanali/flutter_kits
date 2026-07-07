import 'package:flutter_test/flutter_test.dart';
import 'package:notify_kit/notify_kit.dart';
import 'package:notify_kit/src/fcm_service.dart';
import 'package:notify_kit/src/local_service.dart';

class _FakeLocal implements LocalService {
  int initCalls = 0;
  int showCalls = 0;
  AndroidChannelConfig? lastChannel;

  @override
  Future<void> init(
    AndroidChannelConfig channel,
    NotifyTapHandler? onTap, {
    NotifyErrorHandler? onError,
  }) async {
    initCalls++;
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

  @override
  Future<void> init(NotifyConfig config) async {
    initCalls++;
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
