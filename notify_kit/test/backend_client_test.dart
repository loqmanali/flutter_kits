import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:notify_kit/notify_kit.dart';
import 'package:notify_kit/src/backend_client.dart';

void main() {
  test('registerDevice posts token, user profile, and device metadata',
      () async {
    http.Request? captured;
    final client = NotifyBackendClient(
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response('{"id": 1}', 201);
      }),
    );

    await client.registerDevice(
      backend: NotifyBackendConfig(
        baseUrl: Uri.parse('https://notify.example.com'),
        apiKey: 'nh_secret',
      ),
      token: 'fcm-token',
      platform: 'android',
      user: const NotifyUserProfile(
        id: 'driver-42',
        name: 'Driver',
        email: 'driver@example.com',
        phone: '+201000000000',
      ),
      device: const NotifyDeviceProfile(
        locale: 'ar',
        model: 'Pixel',
        manufacturer: 'Google',
        osVersion: 'Android 15',
        appVersion: '1.2.3',
      ),
    );

    expect(
      captured?.url,
      Uri.parse('https://notify.example.com/api/v1/devices'),
    );
    expect(captured?.headers['X-Api-Key'], 'nh_secret');
    final body = jsonDecode(captured!.body) as Map<String, dynamic>;
    expect(body['token'], 'fcm-token');
    expect(body['platform'], 'android');
    expect(body['external_user_id'], 'driver-42');
    expect(body['user'], {
      'id': 'driver-42',
      'name': 'Driver',
      'email': 'driver@example.com',
      'phone': '+201000000000',
    });
    expect(body['device'], {
      'locale': 'ar',
      'model': 'Pixel',
      'manufacturer': 'Google',
      'os_version': 'Android 15',
      'app_version': '1.2.3',
    });
  });

  final backend = NotifyBackendConfig(
    baseUrl: Uri.parse('https://notify.example.com'),
    apiKey: 'nh_secret',
  );

  test('unregisterDevice DELETEs the token-scoped endpoint', () async {
    http.Request? captured;
    final client = NotifyBackendClient(
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response('', 204);
      }),
    );

    await client.unregisterDevice(backend: backend, token: 'fcm token/1');

    expect(captured?.method, 'DELETE');
    expect(
      captured?.url,
      Uri.parse('https://notify.example.com/api/v1/devices/fcm%20token%2F1'),
    );
    expect(captured?.headers['X-Api-Key'], 'nh_secret');
  });

  test('setTopics POSTs slugs on subscribe, DELETEs on unsubscribe', () async {
    final methods = <String>[];
    final client = NotifyBackendClient(
      httpClient: MockClient((request) async {
        methods.add(request.method);
        expect(
          request.url,
          Uri.parse('https://notify.example.com/api/v1/devices/tok/topics'),
        );
        expect(jsonDecode(request.body), {
          'topics': ['news', 'promos'],
        });
        return http.Response('{"status":"ok"}', 200);
      }),
    );

    await client.setTopics(
      backend: backend,
      token: 'tok',
      topics: ['news', 'promos'],
      subscribe: true,
    );
    await client.setTopics(
      backend: backend,
      token: 'tok',
      topics: ['news', 'promos'],
      subscribe: false,
    );

    expect(methods, ['POST', 'DELETE']);
  });

  test('reportOpened POSTs notification_id and token', () async {
    http.Request? captured;
    final client = NotifyBackendClient(
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response('{"status":"ok"}', 200);
      }),
    );

    await client.reportOpened(
      backend: backend,
      notificationId: 'camp-9',
      token: 'tok',
    );

    expect(captured?.method, 'POST');
    expect(
      captured?.url,
      Uri.parse('https://notify.example.com/api/v1/events/opened'),
    );
    expect(jsonDecode(captured!.body), {
      'notification_id': 'camp-9',
      'token': 'tok',
    });
  });

  test('fetchTopics parses the data array into NotifyTopic list', () async {
    final client = NotifyBackendClient(
      httpClient: MockClient((request) async {
        expect(request.method, 'GET');
        expect(
          request.url,
          Uri.parse('https://notify.example.com/api/v1/topics'),
        );
        return http.Response(
          jsonEncode({
            'data': [
              {'slug': 'cairo', 'name': 'Cairo'},
              {'slug': 'promos', 'name': 'Promos'},
            ],
          }),
          200,
        );
      }),
    );

    final topics = await client.fetchTopics(backend: backend);

    expect(topics.map((t) => t.slug), ['cairo', 'promos']);
    expect(topics.first.name, 'Cairo');
  });

  test('fetchTopics throws NotifyBackendException on a non-200', () async {
    final client = NotifyBackendClient(
      httpClient: MockClient((request) async => http.Response('nope', 500)),
    );

    expect(
      () => client.fetchTopics(backend: backend),
      throwsA(isA<NotifyBackendException>()),
    );
  });

  test('fetchTopics throws on an unexpected body shape', () async {
    final client = NotifyBackendClient(
      httpClient: MockClient((request) async => http.Response('{"x":1}', 200)),
    );

    expect(
      () => client.fetchTopics(backend: backend),
      throwsA(isA<NotifyBackendException>()),
    );
  });
}
