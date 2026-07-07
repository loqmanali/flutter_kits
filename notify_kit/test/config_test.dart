import 'package:flutter_test/flutter_test.dart';
import 'package:notify_kit/notify_kit.dart';

void main() {
  const channel = AndroidChannelConfig(
    id: 'default_channel',
    name: 'Notifications',
    icon: 'ic_notification',
  );

  test('NotifyConfig defaults: permission + foreground banner on, no handlers',
      () {
    const config = NotifyConfig(androidChannel: channel);
    expect(config.requestPermissionOnInit, isTrue);
    expect(config.showSystemBannerInForeground, isTrue);
    expect(config.backend, isNull);
    expect(config.user, isNull);
    expect(config.device, isNull);
    expect(config.onToken, isNull);
    expect(config.onForegroundMessage, isNull);
    expect(config.onTap, isNull);
    expect(config.onError, isNull);
  });

  test('NotifyBackendConfig builds the fixed devices path from baseUrl', () {
    final config = NotifyBackendConfig(
      baseUrl: Uri.parse('https://notify.example.com'),
      apiKey: 'nh_secret',
    );

    expect(config.apiKey, 'nh_secret');
    expect(
      config.devicesEndpoint,
      Uri.parse('https://notify.example.com/api/v1/devices'),
    );
  });

  test('NotifyBackendConfig tolerates trailing slash and base path', () {
    expect(
      NotifyBackendConfig(
        baseUrl: Uri.parse('https://notify.example.com/'),
        apiKey: 'k',
      ).devicesEndpoint,
      Uri.parse('https://notify.example.com/api/v1/devices'),
    );
    expect(
      NotifyBackendConfig(
        baseUrl: Uri.parse('https://notify.example.com/hub'),
        apiKey: 'k',
      ).devicesEndpoint,
      Uri.parse('https://notify.example.com/hub/api/v1/devices'),
    );
  });

  test('AndroidChannelConfig holds values, description optional', () {
    expect(channel.id, 'default_channel');
    expect(channel.name, 'Notifications');
    expect(channel.icon, 'ic_notification');
    expect(channel.description, isNull);
  });
}
