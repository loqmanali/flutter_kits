import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notify_kit/src/mappers.dart';

void main() {
  group('messageFromRemote', () {
    test('maps title, body, data, messageId', () {
      const remote = RemoteMessage(
        notification: RemoteNotification(title: 'Hello', body: 'World'),
        data: {'notificationable_type': 'shipment', 'payload': '{"id":"7"}'},
        messageId: 'msg-1',
      );
      final msg = messageFromRemote(remote);
      expect(msg.title, 'Hello');
      expect(msg.body, 'World');
      expect(msg.data['notificationable_type'], 'shipment');
      expect(msg.messageId, 'msg-1');
    });

    test('data-only message: null title/body, data preserved', () {
      const remote = RemoteMessage(data: {'k': 'v'});
      final msg = messageFromRemote(remote);
      expect(msg.title, isNull);
      expect(msg.body, isNull);
      expect(msg.data, {'k': 'v'});
    });
  });

  group('messageFromLocalPayload', () {
    test('decodes a JSON object payload into data', () {
      final msg = messageFromLocalPayload('{"route":"/proof","id":3}');
      expect(msg.data, {'route': '/proof', 'id': 3});
      expect(msg.messageId, isNull);
    });

    test('null payload -> empty message', () {
      expect(messageFromLocalPayload(null).data, isEmpty);
    });

    test('empty payload -> empty message', () {
      expect(messageFromLocalPayload('').data, isEmpty);
    });

    test('malformed JSON -> empty message, no throw (spec §8)', () {
      expect(messageFromLocalPayload('{oops').data, isEmpty);
    });

    test('non-object JSON (list) -> empty message', () {
      expect(messageFromLocalPayload('[1,2]').data, isEmpty);
    });
  });
}
