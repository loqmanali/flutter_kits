# notify_kit

FCM + local notifications behind **one `init()` call**, with unified tap
routing across foreground / background / terminated states. No Firebase
types in your app code (except the optional background handler).

## Why

Hand-rolled FCM wiring tends to accumulate the same defects: the
`getInitialMessage()` result gets discarded (cold-start taps do nothing),
`onMessage` listeners get re-registered per screen (duplicate dialogs),
`onTokenRefresh` is forgotten (stale tokens server-side), and local
notifications never get their tap callback registered. notify_kit fixes all
of these by construction: subscriptions are created exactly once inside a
guarded `init()`, and every tap — background, cold-start, or local — arrives
at the same `onTap` callback.

## Install

```yaml
dependencies:
  notify_kit:
    path: packages/notify_kit   # or a git dependency once extracted
```

## Usage

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:notify_kit/notify_kit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotifyKit.init(NotifyConfig(
    androidChannel: const AndroidChannelConfig(
      id: 'default_channel',
      name: 'Notifications',
      icon: 'ic_notification',
    ),
    backend: NotifyBackendConfig(
      // Host only — the /api/v1/devices path is fixed by notify-hub.
      baseUrl: Uri.parse('https://notify.example.com'),
      apiKey: 'nh_your_app_api_key',
    ),
    user: const NotifyUserProfile(
      id: 'driver-42',
      name: 'Driver Name',
      email: 'driver@example.com',
      phone: '+201000000000',
    ),
    device: const NotifyDeviceProfile(
      locale: 'ar',
      model: 'iPhone 15',
      manufacturer: 'Apple',
      osVersion: 'iOS 18.5',
      appVersion: '3.2.1',
    ),
    onToken: (token) {
      // Optional: still called on init and every refresh.
    },
    onForegroundMessage: (msg) {
      // App is open: you decide the UI — toast, dialog, or ignore.
    },
    onTap: (msg, source) {
      // Unified: background tap, cold-start tap (source == terminated),
      // and local-notification tap (source == local).
      final type = msg.data['type'];
      if (type == 'shipment') {
        // navigate...
      }
    },
  ));

  runApp(const MyApp());
}
```

If user data is only available after login, call:

```dart
await NotifyKit.registerDevice(
  user: const NotifyUserProfile(
    id: 'driver-42',
    name: 'Driver Name',
    email: 'driver@example.com',
    phone: '+201000000000',
  ),
);
```

On logout, remove the device so it stops receiving pushes:

```dart
await NotifyKit.unregisterDevice();
```

Topic subscriptions (notify-hub topic slugs, for broadcast pushes). Fetch the
available topics to build a subscription screen, then subscribe by slug:

```dart
final topics = await NotifyKit.fetchTopics(); // List<NotifyTopic> (slug, name)
await NotifyKit.subscribeToTopics(['city-cairo', 'promos']);
await NotifyKit.unsubscribeFromTopics(['promos']);
```

`fetchTopics` returns data, so unlike the fire-and-forget subscribe calls it
**throws** `NotifyBackendException` on network/HTTP failure — catch it to show
a retry.

The package ships **no subscription screen** — the UI is yours (theme,
language, state management). A minimal, dependency-free example you can adapt:

```dart
class TopicSubscriptionScreen extends StatefulWidget {
  const TopicSubscriptionScreen({super.key, this.subscribed = const {}});

  /// Slugs the device is already subscribed to (load from your own storage).
  final Set<String> subscribed;

  @override
  State<TopicSubscriptionScreen> createState() => _State();
}

class _State extends State<TopicSubscriptionScreen> {
  late Future<List<NotifyTopic>> _future = NotifyKit.fetchTopics();
  late final Set<String> _selected = {...widget.subscribed};

  @override
  Widget build(BuildContext context) => FutureBuilder<List<NotifyTopic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () =>
                    setState(() => _future = NotifyKit.fetchTopics()),
                child: const Text('Retry'),
              ),
            );
          }
          final topics = snapshot.data!;
          return ListView(
            children: [
              for (final topic in topics)
                SwitchListTile(
                  title: Text(topic.name),
                  value: _selected.contains(topic.slug),
                  onChanged: (on) {
                    setState(() =>
                        on ? _selected.add(topic.slug) : _selected.remove(topic.slug));
                    on
                        ? NotifyKit.subscribeToTopics([topic.slug])
                        : NotifyKit.unsubscribeFromTopics([topic.slug]);
                  },
                ),
            ],
          );
        },
      );
}
```

Campaign **open tracking is automatic**: when a tapped push carries a
`notification_id` in its data and a `backend` is configured, notify_kit
reports the open to notify-hub itself — no app code needed.

Local notification:

```dart
await NotifyKit.showLocal(
  title: 'Arrived',
  body: 'You have reached your destination',
  payload: {'route': '/proof'},
);
```

## Crash reporting (Crashlytics, Sentry, ...)

Errors thrown by your handlers are caught so they never kill a
subscription, and logged via `debugPrint`. To also record them in your
crash reporter, wire the `onError` sink — the package deliberately has no
dependency on any crash-reporting SDK:

```dart
await NotifyKit.init(NotifyConfig(
  // ...
  onError: (context, error, stack) => FirebaseCrashlytics.instance
      .recordError(error, stack, reason: 'notify_kit: $context'),
));
```

`context` names the failing handler (`onTap(local)`, `onForegroundMessage`,
`onToken`, ...). A throwing `onError` handler is swallowed too.

Optional FCM background-isolate handler (data processing while the app is
backgrounded — no UI). FCM requires a **top-level** function in *your* app:

```dart
@pragma('vm:entry-point')
Future<void> myBackgroundHandler(RemoteMessage message) async {
  // No UI here. Runs in a separate isolate.
}

// before runApp:
NotifyKit.registerBackgroundHandler(myBackgroundHandler);
```

## Platform setup checklist (your app, not the package)

### Both
- [ ] `Firebase.initializeApp(...)` before `NotifyKit.init(...)` (`firebase_core` configured via FlutterFire CLI).

### Android
- [ ] `android/app/google-services.json` present.
- [ ] A white/transparent notification drawable matching `AndroidChannelConfig.icon` (e.g. `android/app/src/main/res/drawable/ic_notification.png`).
- [ ] `POST_NOTIFICATIONS` (Android 13+) is merged from the firebase_messaging manifest; the runtime prompt comes from `requestPermissionOnInit`.

### iOS
- [ ] `ios/Runner/GoogleService-Info.plist` present.
- [ ] Push Notifications capability + `aps-environment` entitlement.
- [ ] APNs key uploaded in the Firebase console.
- [ ] `UIBackgroundModes` includes `remote-notification` in `Info.plist`.

## What the package deliberately does NOT do

- Foreground UI: `onForegroundMessage` gives you the message; showing a
  toast/dialog is app policy.
- Scheduled notifications, multiple Android channels, action buttons —
  out of scope until a real consumer needs them.
- The in-app notification-center screen (REST history) — domain logic.
