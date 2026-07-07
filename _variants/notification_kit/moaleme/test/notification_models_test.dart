import 'package:flutter_test/flutter_test.dart';
import 'package:notification_kit/notification_kit.dart';

/// Pure-layer gate tests for notification_kit.
///
/// These tests exercise only deterministic logic (models' JSON round-trips,
/// entity equality/copyWith, failure equality, config constants, and the pure
/// payload parser). They never touch FCM, local-notification platform
/// channels, storage, or Firebase, so they run in CI.
void main() {
  group('NotificationPayloadModel', () {
    test('fromJson -> toJson round-trip preserves all fields', () {
      final json = <String, dynamic>{
        'type': 'order',
        'targetId': '12345',
        'route': '/order/12345',
        'parameters': <String, dynamic>{'source': 'notification'},
        'externalUrl': null,
      };

      final model = NotificationPayloadModel.fromJson(json);

      expect(model.type, DeepLinkType.order);
      expect(model.targetId, '12345');
      expect(model.route, '/order/12345');
      expect(model.parameters, {'source': 'notification'});

      // Round-trip back to JSON yields the same logical content.
      expect(model.toJson(), {
        'type': 'order',
        'targetId': '12345',
        'route': '/order/12345',
        'parameters': {'source': 'notification'},
        'externalUrl': null,
      });
    });

    test('fromJson falls back to custom for unknown type', () {
      final model = NotificationPayloadModel.fromJson({'type': 'not_a_type'});
      expect(model.type, DeepLinkType.custom);
    });

    test('Equatable props match the equivalent base entity', () {
      const model = NotificationPayloadModel(
        type: DeepLinkType.product,
        targetId: 'prod_1',
      );
      const entity = NotificationPayload(
        type: DeepLinkType.product,
        targetId: 'prod_1',
      );
      // Equatable's == checks runtimeType, so a subclass instance is never ==
      // its base even with identical data. The meaningful invariant is that
      // the carried data (props) is identical.
      expect(model.props, entity.props);

      // Two models with the same data ARE equal.
      const model2 = NotificationPayloadModel(
        type: DeepLinkType.product,
        targetId: 'prod_1',
      );
      expect(model, model2);
      expect(model.hashCode, model2.hashCode);
    });
  });

  group('NotificationScheduleModel', () {
    test('fromJson -> toJson round-trip preserves all fields', () {
      const iso = '2023-01-01T12:00:00.000Z';
      final json = <String, dynamic>{
        'scheduledDate': iso,
        'repeatInterval': 'daily',
        'allowWhileIdle': true,
        'exact': false,
      };

      final model = NotificationScheduleModel.fromJson(json);

      expect(model.scheduledDate, DateTime.parse(iso));
      expect(model.repeatInterval, RepeatInterval.daily);
      expect(model.allowWhileIdle, isTrue);
      expect(model.exact, isFalse);

      final out = model.toJson();
      expect(out['scheduledDate'], DateTime.parse(iso).toIso8601String());
      expect(out['repeatInterval'], 'daily');
      expect(out['allowWhileIdle'], true);
      expect(out['exact'], false);
    });

    test('fromJson applies defaults for missing optional fields', () {
      final model = NotificationScheduleModel.fromJson({
        'scheduledDate': '2023-06-01T08:30:00.000Z',
        'repeatInterval': 'bogus',
      });
      expect(model.repeatInterval, RepeatInterval.none); // fallback
      expect(model.allowWhileIdle, isFalse); // default
      expect(model.exact, isTrue); // default
    });
  });

  group('NotificationSettingsModel', () {
    test('fromJson applies documented defaults for absent keys', () {
      final model = NotificationSettingsModel.fromJson(<String, dynamic>{});
      expect(model.enabled, isTrue);
      expect(model.soundEnabled, isTrue);
      expect(model.vibrationEnabled, isTrue);
      expect(model.promotionalEnabled, isTrue);
      expect(model.channelSettings, isEmpty);
      expect(model.topicSubscriptions, isEmpty);
      expect(model.quietHoursStart, isNull);
      expect(model.quietHoursEnd, isNull);
    });

    test('fromJson -> toJson round-trip preserves nested maps and dates', () {
      const startIso = '2023-01-01T22:00:00.000Z';
      const endIso = '2023-01-01T08:00:00.000Z';
      final json = <String, dynamic>{
        'enabled': false,
        'soundEnabled': false,
        'channelSettings': {'orders': true, 'promotions': false},
        'topicSubscriptions': {'news': true},
        'customSoundPath': '/sounds/ping.mp3',
        'quietHoursStart': startIso,
        'quietHoursEnd': endIso,
      };

      final model = NotificationSettingsModel.fromJson(json);
      expect(model.enabled, isFalse);
      expect(model.soundEnabled, isFalse);
      expect(model.channelSettings, {'orders': true, 'promotions': false});
      expect(model.topicSubscriptions, {'news': true});
      expect(model.customSoundPath, '/sounds/ping.mp3');
      expect(model.quietHoursStart, DateTime.parse(startIso));

      final out = model.toJson();
      expect(out['enabled'], false);
      expect(out['channelSettings'], {'orders': true, 'promotions': false});
      expect(out['quietHoursStart'], DateTime.parse(startIso).toIso8601String());
      expect(out['quietHoursEnd'], DateTime.parse(endIso).toIso8601String());
    });

    test('copyWith clear flags explicitly null out nullable fields', () {
      final base = NotificationSettingsModel.fromJson({
        'customSoundPath': '/sounds/ping.mp3',
        'quietHoursStart': '2023-01-01T22:00:00.000Z',
      });
      expect(base.customSoundPath, isNotNull);
      expect(base.quietHoursStart, isNotNull);

      final cleared = base.copyWith(
        clearCustomSoundPath: true,
        clearQuietHoursStart: true,
      );
      expect(cleared.customSoundPath, isNull);
      expect(cleared.quietHoursStart, isNull);

      // A plain copyWith without clear keeps the original value.
      final kept = base.copyWith(enabled: false);
      expect(kept.customSoundPath, '/sounds/ping.mp3');
      expect(kept.enabled, isFalse);
    });
  });

  group('NotificationModel', () {
    final createdAt = DateTime.parse('2023-01-01T12:00:00.000Z');

    test('fromJson -> toJson round-trip with nested payload and actions', () {
      final json = <String, dynamic>{
        'id': 'msg_123',
        'title': 'New Message',
        'body': 'You have a new message',
        'imageUrl': 'https://example.com/i.jpg',
        'priority': 'high',
        'status': 'delivered',
        'createdAt': createdAt.toIso8601String(),
        'isLocal': true,
        'payload': {'type': 'order', 'targetId': '12345'},
        'actions': [
          {'id': 'view', 'title': 'View Order'},
        ],
      };

      final model = NotificationModel.fromJson(json);
      expect(model.id, 'msg_123');
      expect(model.title, 'New Message');
      expect(model.priority, NotificationPriority.high);
      expect(model.status, NotificationStatus.delivered);
      expect(model.isLocal, isTrue);
      expect(model.payload!.type, DeepLinkType.order);
      expect(model.payload!.targetId, '12345');
      expect(model.actions, hasLength(1));
      expect(model.actions.single.id, 'view');
      // requiresForeground defaults to true per action model.
      expect(model.actions.single.requiresForeground, isTrue);

      final out = model.toJson();
      expect(out['id'], 'msg_123');
      expect(out['priority'], 'high');
      expect(out['status'], 'delivered');
      expect(out['createdAt'], createdAt.toIso8601String());
      expect(out['payload'], {
        'type': 'order',
        'targetId': '12345',
        'route': null,
        'parameters': null,
        'externalUrl': null,
      });
      expect(out['actions'], [
        {
          'id': 'view',
          'title': 'View Order',
          'icon': null,
          'isDestructive': false,
          'requiresForeground': true,
        },
      ]);
    });

    test('fromJson uses safe enum fallbacks and default actions list', () {
      final model = NotificationModel.fromJson({
        'id': 'x',
        'title': 't',
        'body': 'b',
        'priority': 'unknown',
        'status': 'unknown',
        'createdAt': createdAt.toIso8601String(),
      });
      expect(model.priority, NotificationPriority.defaultPriority);
      expect(model.status, NotificationStatus.sent);
      expect(model.actions, isEmpty);
      expect(model.payload, isNull);
      expect(model.isLocal, isFalse);
    });

    test('fromEntity then toJson serializes a domain entity faithfully', () {
      final entity = NotificationEntity(
        id: 'e1',
        title: 'Title',
        body: 'Body',
        createdAt: createdAt,
        payload: const NotificationPayloadModel(
          type: DeepLinkType.product,
          targetId: 'p9',
        ),
        actions: const [NotificationActionModel(id: 'a', title: 'A')],
      );

      final model = NotificationModel.fromEntity(entity);
      // Equatable's == checks runtimeType, so the NotificationModel subclass is
      // not == the NotificationEntity base; compare the carried data (props).
      expect(model.props, entity.props);

      final out = model.toJson();
      expect(out['id'], 'e1');
      expect(out['payload'], isNotNull);
      expect((out['actions'] as List), hasLength(1));
    });
  });

  group('NotificationEntity copyWith & equality', () {
    final createdAt = DateTime.parse('2023-01-01T12:00:00.000Z');

    test('copyWith overrides only the given field and keeps the rest', () {
      final original = NotificationEntity(
        id: 'n1',
        title: 'Original',
        body: 'Body',
        createdAt: createdAt,
      );

      final updated = original.copyWith(
        status: NotificationStatus.read,
        title: 'Changed',
      );

      expect(updated.title, 'Changed');
      expect(updated.status, NotificationStatus.read);
      // Untouched fields are identical.
      expect(updated.id, original.id);
      expect(updated.body, original.body);
      expect(updated.createdAt, original.createdAt);

      // Different status -> not equal; same data -> equal.
      expect(updated, isNot(equals(original)));
      expect(original.copyWith(), equals(original));
    });
  });

  group('NotificationFailure equality', () {
    test('same data compares equal, differing code does not', () {
      const a = FCMFailure(message: 'boom', code: 'X');
      const b = FCMFailure(message: 'boom', code: 'X');
      const c = FCMFailure(message: 'boom', code: 'Y');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('different failure subtypes with same data are not equal', () {
      const fcm = FCMFailure(message: 'm');
      const storage = StorageFailure(message: 'm');
      // Equatable compares props but runtimeType differs -> not equal.
      expect(fcm, isNot(equals(storage)));
    });
  });

  group('config & constants', () {
    test('NotificationDefaults expose the documented defaults', () {
      expect(NotificationDefaults.enabled, isTrue);
      expect(NotificationDefaults.defaultChannelId, 'general');
      expect(NotificationDefaults.defaultIcon, '@mipmap/ic_launcher');
      expect(NotificationDefaults.defaultSound, 'default');
    });

    test('NotificationKeys are stable, distinct storage keys', () {
      final keys = <String>{
        NotificationKeys.fcmToken,
        NotificationKeys.settings,
        NotificationKeys.history,
        NotificationKeys.unreadCount,
        NotificationKeys.badgeCount,
        NotificationKeys.subscribedTopics,
        NotificationKeys.pendingNotifications,
      };
      // No collisions and a couple of anchored values.
      expect(keys, hasLength(7));
      expect(NotificationKeys.fcmToken, 'notification_fcm_token');
      expect(NotificationKeys.settings, 'notification_settings');
    });

    test('NotificationChannels maps sound names to the right channel id', () {
      expect(
        NotificationChannels.getChannelIdForSound('notification_sound_1'),
        NotificationChannels.sound1ChannelId,
      );
      expect(
        NotificationChannels.getChannelIdForSound('notification_sound_2'),
        NotificationChannels.sound2ChannelId,
      );
      expect(
        NotificationChannels.getChannelIdForSound(null),
        'high_importance_channel',
      );
      expect(
        NotificationChannels.getChannelIdForSound('something_else'),
        'high_importance_channel',
      );
      // Predefined channels list is non-empty and includes the general id.
      expect(NotificationChannels.channels, isNotEmpty);
      expect(
        NotificationChannels.channels.map((c) => c.id),
        contains(NotificationChannels.generalChannelId),
      );
    });
  });

  group('NotificationPayloadParser (pure)', () {
    test('returns null for empty data', () {
      expect(NotificationPayloadParser.parse(<String, dynamic>{}), isNull);
    });

    test('parses a nested JSON-string payload', () {
      final payload = NotificationPayloadParser.parse({
        'payload': '{"type":"order","targetId":"12345","route":"/order/12345"}',
      });
      expect(payload, isNotNull);
      expect(payload!.type, DeepLinkType.order);
      expect(payload.targetId, '12345');
      expect(payload.route, '/order/12345');
    });

    test('parses a flat payload that carries a type key', () {
      final payload = NotificationPayloadParser.parse({
        'type': 'product',
        'targetId': 'p1',
      });
      expect(payload!.type, DeepLinkType.product);
      expect(payload.targetId, 'p1');
    });

    test('infers type for simple key-value data without a type key', () {
      final payload = NotificationPayloadParser.parse({'order': '999'});
      expect(payload, isNotNull);
      expect(payload!.type, DeepLinkType.order);
      expect(payload.targetId, '999');
      expect(payload.route, '/order');
    });

    test('malformed nested JSON string is swallowed and yields null', () {
      final payload =
          NotificationPayloadParser.parse({'payload': '{not valid json'});
      expect(payload, isNull);
    });
  });
}
