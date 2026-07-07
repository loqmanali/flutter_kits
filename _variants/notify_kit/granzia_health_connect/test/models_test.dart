import 'package:flutter_test/flutter_test.dart';
import 'package:notify_kit/notify_kit.dart';

void main() {
  group('NotifyMessage', () {
    test('defaults: null title/body/messageId, empty data', () {
      const msg = NotifyMessage();
      expect(msg.title, isNull);
      expect(msg.body, isNull);
      expect(msg.messageId, isNull);
      expect(msg.data, isEmpty);
    });

    test('holds provided values', () {
      const msg = NotifyMessage(
        title: 't',
        body: 'b',
        data: {'k': 'v'},
        messageId: 'id-1',
      );
      expect(msg.title, 't');
      expect(msg.body, 'b');
      expect(msg.data, {'k': 'v'});
      expect(msg.messageId, 'id-1');
    });
  });

  test('NotifyTapSource has exactly background, terminated, local', () {
    expect(NotifyTapSource.values, [
      NotifyTapSource.background,
      NotifyTapSource.terminated,
      NotifyTapSource.local,
    ]);
  });

  test('NotifyUserProfile serializes only provided values', () {
    const profile = NotifyUserProfile(
      id: 'driver-42',
      name: 'Driver',
      email: 'driver@example.com',
      phone: '+201000000000',
      data: {'role': 'driver'},
    );

    expect(profile.toJson(), {
      'id': 'driver-42',
      'name': 'Driver',
      'email': 'driver@example.com',
      'phone': '+201000000000',
      'data': {'role': 'driver'},
    });
  });

  test('NotifyDeviceProfile serializes snake-case backend keys', () {
    const profile = NotifyDeviceProfile(
      locale: 'ar',
      model: 'iPhone 15',
      manufacturer: 'Apple',
      osVersion: 'iOS 18.5',
      appVersion: '3.2.1',
      data: {'build': '321'},
    );

    expect(profile.toJson(), {
      'locale': 'ar',
      'model': 'iPhone 15',
      'manufacturer': 'Apple',
      'os_version': 'iOS 18.5',
      'app_version': '3.2.1',
      'data': {'build': '321'},
    });
  });
}
