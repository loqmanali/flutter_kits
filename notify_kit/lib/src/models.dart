/// A platform-agnostic notification message.
///
/// Produced from an FCM [RemoteMessage] or a local-notification payload —
/// consumers never need to import firebase_messaging.
///
/// `final class`: a value type, not an extension point (API lockdown).
final class NotifyMessage {
  const NotifyMessage({
    this.title,
    this.body,
    this.data = const {},
    this.messageId,
  });

  final String? title;
  final String? body;

  /// FCM `data` block, or the decoded payload of a local notification.
  final Map<String, dynamic> data;

  /// Null for local notifications.
  final String? messageId;
}

/// Where a notification tap came from.
enum NotifyTapSource {
  /// Tap on a system notification while the app was in the background.
  background,

  /// Tap that cold-started the app (delivered via getInitialMessage).
  terminated,

  /// Tap on a local notification shown by [NotifyKit.showLocal].
  local,
}

typedef NotifyTapHandler = void Function(
  NotifyMessage message,
  NotifyTapSource source,
);
typedef NotifyMessageHandler = void Function(NotifyMessage message);
typedef NotifyTokenHandler = void Function(String token);

/// Sink for errors thrown by user-supplied handlers. Wire it to your
/// crash reporter (Crashlytics, Sentry, ...) in the app.
typedef NotifyErrorHandler = void Function(
  String context,
  Object error,
  StackTrace stack,
);

/// Thrown by data-returning backend calls (e.g. [NotifyKit.fetchTopics]) when
/// the request fails. Fire-and-forget writes never throw; only reads do.
final class NotifyBackendException implements Exception {
  const NotifyBackendException(this.message);

  final String message;

  @override
  String toString() => 'NotifyBackendException: $message';
}

/// A notify-hub topic the device can subscribe to. Fetched via
/// [NotifyKit.fetchTopics] to render a subscription screen.
final class NotifyTopic {
  const NotifyTopic({required this.slug, required this.name});

  factory NotifyTopic.fromJson(Map<String, dynamic> json) => NotifyTopic(
        slug: json['slug'] as String,
        name: json['name'] as String,
      );

  /// Stable id passed to [NotifyKit.subscribeToTopics].
  final String slug;

  /// Human-readable label for display.
  final String name;
}

/// Optional user profile sent to notify-hub with the FCM token.
final class NotifyUserProfile {
  const NotifyUserProfile({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.data = const {},
  });

  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final Map<String, Object?> data;

  Map<String, Object?> toJson() => {
        'id': id,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (data.isNotEmpty) 'data': data,
      };
}

/// Optional device/app metadata sent to notify-hub with the FCM token.
final class NotifyDeviceProfile {
  const NotifyDeviceProfile({
    this.locale,
    this.model,
    this.manufacturer,
    this.osVersion,
    this.appVersion,
    this.data = const {},
  });

  final String? locale;
  final String? model;
  final String? manufacturer;
  final String? osVersion;
  final String? appVersion;
  final Map<String, Object?> data;

  Map<String, Object?> toJson() => {
        if (locale != null) 'locale': locale,
        if (model != null) 'model': model,
        if (manufacturer != null) 'manufacturer': manufacturer,
        if (osVersion != null) 'os_version': osVersion,
        if (appVersion != null) 'app_version': appVersion,
        if (data.isNotEmpty) 'data': data,
      };
}
