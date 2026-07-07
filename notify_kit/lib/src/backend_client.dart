import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'config.dart';
import 'models.dart';

class NotifyBackendClient {
  const NotifyBackendClient({http.Client? httpClient})
      : _httpClient = httpClient;

  final http.Client? _httpClient;

  /// Hard cap per request: a slow/unreachable notify-hub must never wedge
  /// token registration or init.
  static const Duration _timeout = Duration(seconds: 10);

  Future<void> registerDevice({
    required NotifyBackendConfig backend,
    required String token,
    required String platform,
    NotifyUserProfile? user,
    NotifyDeviceProfile? device,
  }) {
    return _send(
      backend,
      'POST',
      backend.devicesEndpoint,
      body: {
        'token': token,
        'platform': platform,
        if (user != null) 'external_user_id': user.id,
        if (user != null) 'user': user.toJson(),
        if (device != null) 'locale': device.locale,
        if (device != null) 'device': device.toJson(),
      },
    );
  }

  /// Removes the device server-side, e.g. on logout. Fire-and-forget.
  Future<void> unregisterDevice({
    required NotifyBackendConfig backend,
    required String token,
  }) {
    return _send(backend, 'DELETE', backend.deviceEndpoint(token));
  }

  /// Subscribes the device to notify-hub topic slugs (or unsubscribes when
  /// [subscribe] is false). Fire-and-forget.
  Future<void> setTopics({
    required NotifyBackendConfig backend,
    required String token,
    required List<String> topics,
    required bool subscribe,
  }) {
    return _send(
      backend,
      subscribe ? 'POST' : 'DELETE',
      backend.deviceTopicsEndpoint(token),
      body: {'topics': topics},
    );
  }

  /// Reports that a campaign notification was opened. Fire-and-forget.
  Future<void> reportOpened({
    required NotifyBackendConfig backend,
    required String notificationId,
    required String token,
  }) {
    return _send(
      backend,
      'POST',
      backend.openedEventEndpoint,
      body: {'notification_id': notificationId, 'token': token},
    );
  }

  /// Lists the app's subscribable topics. Unlike the fire-and-forget writes,
  /// this returns data — so failures THROW (network/HTTP/decode) for the app
  /// to surface a retry, rather than being indistinguishable from "no topics".
  Future<List<NotifyTopic>> fetchTopics({
    required NotifyBackendConfig backend,
  }) async {
    final client = _httpClient ?? http.Client();
    final closeClient = _httpClient == null;

    try {
      final response = await client
          .get(
            backend.topicsEndpoint,
            headers: {
              'Accept': 'application/json',
              'X-Api-Key': backend.apiKey,
            },
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw NotifyBackendException(
          'fetchTopics failed (${response.statusCode})',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded case {'data': final List<dynamic> data}) {
        return data
            .cast<Map<String, dynamic>>()
            .map(NotifyTopic.fromJson)
            .toList();
      }
      throw const NotifyBackendException('fetchTopics: unexpected response');
    } on NotifyBackendException {
      rethrow;
    } catch (error) {
      throw NotifyBackendException('fetchTopics failed: $error');
    } finally {
      if (closeClient) {
        client.close();
      }
    }
  }

  /// One request, all failures swallowed + logged (spec §8): a backend call
  /// must never take down the app or a subscription.
  Future<void> _send(
    NotifyBackendConfig backend,
    String method,
    Uri url, {
    Map<String, Object?>? body,
  }) async {
    final client = _httpClient ?? http.Client();
    final closeClient = _httpClient == null;

    try {
      final request = http.Request(method, url)
        ..headers.addAll({
          'Accept': 'application/json',
          if (body != null) 'Content-Type': 'application/json; charset=utf-8',
          'X-Api-Key': backend.apiKey,
        });
      if (body != null) {
        request.body = jsonEncode(body);
      }

      final response = await http.Response.fromStream(
        await client.send(request).timeout(_timeout),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'notify_kit: $method $url failed '
          '(${response.statusCode}): ${response.body}',
        );
      }
    } catch (error) {
      debugPrint('notify_kit: $method $url failed: $error');
    } finally {
      if (closeClient) {
        client.close();
      }
    }
  }
}
