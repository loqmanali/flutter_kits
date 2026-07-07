# notify_kit

FCM + local notifications behind **one `init()` call**, with unified tap
routing across foreground / background / terminated states, raw FCM topic
management, and optional [notify-hub](../../../../backend/notify-hub) device
registration with automatic open tracking.

The package is designed to be the **single source of notifications** in the
app: no app file outside it should import `firebase_messaging` or
`flutter_local_notifications` directly.

## Why

Hand-rolled FCM wiring tends to accumulate the same defects: the
`getInitialMessage()` result gets discarded (cold-start taps do nothing),
`onMessage` listeners get re-registered per screen (duplicate dialogs),
`onTokenRefresh` is forgotten (stale tokens server-side), local notifications
never get their tap callback registered, and — the sneakiest one — message
listeners get registered *after* slow network calls, leaving the app deaf for
seconds at startup. notify_kit fixes all of these by construction:

- Subscriptions are created exactly once inside a guarded `init()`.
- Message listeners are registered **before** any network I/O (token
  registration cannot delay or block them).
- Every tap — background, cold-start, or local — arrives at the same `onTap`
  callback.
- All backend calls are fire-and-forget with a **10s timeout**; a slow or
  unreachable backend can never wedge init or message delivery.

## Install

```yaml
dependencies:
  notify_kit:
    path: packages/notify_kit
```

## Quick start

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:notify_kit/notify_kit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Must be registered before runApp — handles data-only pushes that arrive
  // while the app is backgrounded/terminated. The kit ships a default handler.
  NotifyKit.registerBackgroundHandler(notifyKitBackgroundHandler);

  await NotifyKit.init(NotifyConfig(
    // kDefaultAndroidChannel = 'high_importance_channel'. Its id MUST match
    // com.google.firebase.messaging.default_notification_channel_id in your
    // AndroidManifest.xml (see Platform setup below).
    androidChannel: kDefaultAndroidChannel,

    // The app displays foreground pushes itself (see "Foreground
    // notifications" below) — keep the iOS system banner off so nothing
    // double-displays.
    showSystemBannerInForeground: false,

    // Optional notify-hub registration; remove to run without a backend.
    backend: NotifyBackendConfig(
      baseUrl: Uri.parse('https://notify.example.com'),
      apiKey: 'nh_your_app_api_key',
    ),

    onForegroundMessage: (message) {
      // App is open: show YOUR UI — an in-app toast/dialog. Do not rely on
      // system banners here (see "Foreground notifications").
    },
    onTap: (message, source) {
      // Unified: background tap, cold-start tap (source == terminated),
      // and local-notification tap (source == local).
      // e.g. goRouter.go(resolveRoute(message.data));
    },
    onError: (context, error, stack) =>
        MyCrashReporter.record(error, stack, reason: 'notify_kit: $context'),
  ));

  // Raw FCM broadcast topics (server targets them directly via FCM).
  await NotifyKit.subscribeToFcmTopics(['all_users', 'ios_users']);

  runApp(const MyApp());
}
```

## Foreground notifications — how they work and why

**iOS shows nothing for an FCM push while the app is in the foreground unless
somebody explicitly presents it.** There are three ways to show it, and only
one of them is reliable:

| Approach | Mechanism | Verdict |
|---|---|---|
| System banner | `setForegroundNotificationPresentationOptions` + the `UNUserNotificationCenter` delegate chain | ❌ Fragile — depends on which plugin owns the delegate (see below) |
| Local notification re-display | `NotifyKit.showLocal` from `onForegroundMessage` | ⚠️ Also travels through the same delegate chain |
| **In-app UI (toast / dialog)** | Pure Flutter widget from `onForegroundMessage` / `foregroundMessages` | ✅ Deterministic — no OS delegate involved |

**Recommended pattern** (what the samnan client app does):

```dart
onForegroundMessage: (message) {
  final content = extractTitleBody({
    if (message.title != null) 'title': message.title,
    if (message.body != null) 'body': message.body,
    ...message.data,
  });
  if (content == null) return;
  UIHelper.showToast(title: content.title, description: content.body);
},
```

Pair it with `showSystemBannerInForeground: false` so a working delegate
chain can never double-display.

For additional foreground consumers (auto-refresh on push, badges, …) use the
broadcast stream instead of fighting over the single callback:

```dart
NotifyKit.foregroundMessages.listen((_) => refreshMyLists());
```

The stream is safe to subscribe to before `init()`; it starts emitting once
`init()` has run.

### The iOS delegate trap (read this before touching AppDelegate)

Foreground delivery (`onMessage`) only works if `firebase_messaging`'s native
code receives the `willPresent` callback. Two hard-won rules:

1. **Use classic plugin registration in AppDelegate** —
   `GeneratedPluginRegistrant.register(with: self)` inside
   `didFinishLaunchingWithOptions`. The newer *implicit-engine* template
   (`didInitializeImplicitFlutterEngine`) registers plugins after the
   app-delegate lifecycle has started, so `firebase_messaging` never attaches
   its foreground pipeline: pushes arrive in the background but the app stays
   **deaf in the foreground** (no `onMessage`, ever). This exact bug cost a
   full day of debugging in the samnan client app.

2. **Never take `UNUserNotificationCenter.delegate` yourself**, and never let
   `flutter_local_notifications` request iOS permissions (notify_kit already
   initializes it with `requestAlertPermission: false` etc. — permission is
   requested once, by `firebase_messaging`, during `init()`). If any other
   code claims the delegate, `firebase_messaging` backs off to a forwarding
   chain in which `flutter_local_notifications` can swallow the callback for
   FCM messages (flutter_local_notifications issue #111).

A known-good AppDelegate (this is samnan's, trimmed):

```swift
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)   // classic — NOT implicit engine
    application.registerForRemoteNotifications()     // guarantees APNS kicks in
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken    // belt & braces
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
```

## Platform setup checklist

### Both platforms

- [ ] `Firebase.initializeApp(...)` **before** `NotifyKit.init(...)` (init
      throws a `StateError` otherwise).
- [ ] `NotifyKit.registerBackgroundHandler(...)` **before** `runApp`.

### Android

- [ ] `android/app/google-services.json` present.
- [ ] Default channel meta-data in `AndroidManifest.xml`, matching
      `kDefaultChannelId`:

  ```xml
  <meta-data
      android:name="com.google.firebase.messaging.default_notification_channel_id"
      android:value="high_importance_channel" />
  ```

- [ ] A launcher/notification icon matching the channel config (the default
      config uses `@mipmap/ic_launcher`).
- [ ] `POST_NOTIFICATIONS` (Android 13+) is merged from the firebase_messaging
      manifest; the runtime prompt comes from `requestPermissionOnInit`.
- [ ] *(Local-network notify-hub only)* debug builds need cleartext HTTP:
      add `android:usesCleartextTraffic="true"` to
      `android/app/src/debug/AndroidManifest.xml` (debug variant only — keep
      release locked down).

### iOS

- [ ] **Classic AppDelegate** as shown above — this is a functional
      requirement, not a style preference.
- [ ] `ios/Runner/GoogleService-Info.plist` present.
- [ ] Push Notifications capability + `aps-environment` entitlement.
- [ ] APNs key uploaded in the Firebase console.
- [ ] `UIBackgroundModes` includes `remote-notification` in `Info.plist`.
- [ ] ATS note: raw IP addresses (e.g. `http://192.168.1.6` for a local
      notify-hub) are exempt from ATS, so no `Info.plist` exception is needed
      for LAN testing.

## API surface

### Tokens

```dart
final token = await NotifyKit.getToken();      // null on failure, never throws.
                                               // On iOS, waits for the APNS
                                               // token first (polls ~5s).
NotifyKit.onTokenRefresh.listen(syncToBackend); // fires on every rotation
```

### Permission

```dart
final granted = await NotifyKit.requestPermission(); // idempotent
```

`init()` already requests permission when `requestPermissionOnInit` is true
(the default).

### Raw FCM topics

For backends that broadcast straight through FCM (`all_users`,
platform topics, …). iOS APNS wait is built in.

```dart
await NotifyKit.subscribeToFcmTopics(['all_users', 'promotions']);
await NotifyKit.unsubscribeFromFcmTopics(['promotions']);
```

Failures are logged (`debugPrint`), never thrown. Keep the topic NAMES in the
app — they are a backend contract, not plumbing.

### Local notifications

```dart
await NotifyKit.showLocal(
  id: 7,
  title: 'Arrived',
  body: 'You have reached your destination',
  payload: {'route': '/proof'},   // round-trips through onTap(source: local)
);
await NotifyKit.cancelLocal(7);
await NotifyKit.cancelAllLocal();
```

### Background (data-only) pushes

FCM requires the handler to be a **top-level** function; the kit ships one:

```dart
NotifyKit.registerBackgroundHandler(notifyKitBackgroundHandler);
```

`notifyKitBackgroundHandler` displays *data-only* messages (extracting
title/body via `extractTitleBody`) on the default channel and carries the FCM
`data` through the payload, so tapping it routes via `onTap` and reports the
campaign open. Messages with a `notification` block are rendered by the OS in
background/terminated states and are deliberately left alone (no duplicates).

Need custom background processing? Register your own
`@pragma('vm:entry-point')` top-level function instead.

### notify-hub backend (optional)

When `NotifyConfig.backend` is set, the kit:

- registers the device (`POST /api/v1/devices`) on init and on every token
  refresh — **after** message listeners are wired, never blocking them;
- reports campaign opens automatically when a tapped push (remote **or**
  local) carries the `nh_notification_id` data key
  (`POST /api/v1/events/opened`);
- exposes notify-hub topic slugs:

```dart
final topics = await NotifyKit.fetchTopics();        // throws NotifyBackendException on failure
await NotifyKit.subscribeToTopics(['city-cairo']);   // notify-hub slugs — NOT FCM topics
await NotifyKit.unsubscribeFromTopics(['promos']);
await NotifyKit.registerDevice(user: NotifyUserProfile(id: 'customer-42'));
await NotifyKit.unregisterDevice();                  // on logout
```

Every backend call has a 10-second timeout, and every write is
fire-and-forget: failures are logged via `debugPrint`
(`notify_kit: POST … failed: …`), never thrown. **Notifications work fully
without a backend** — omit `backend:` and everything else keeps working.

### Crash reporting

Errors thrown by your handlers are caught so they never kill a subscription.
Wire `onError` to your crash reporter:

```dart
onError: (context, error, stack) => FirebaseCrashlytics.instance
    .recordError(error, stack, reason: 'notify_kit: $context'),
```

`context` names the failing handler (`onTap(local)`, `onForegroundMessage`,
`onToken`, …). A throwing `onError` handler is swallowed too.

## Troubleshooting

`init()` prints breadcrumbs to the console so a hang or failure is
attributable to an exact phase:

```
notify_kit: init: local notifications…
notify_kit: init: FCM…
notify_kit: init: requesting permission…
notify_kit: init: permission granted=true
notify_kit: init: checking initial message…
notify_kit: init: done
```

| Symptom | Likely cause |
|---|---|
| Background pushes arrive, foreground is dead (no `onMessage`) | Implicit-engine AppDelegate — switch to classic registration (see the delegate trap above) |
| Breadcrumbs stop at `requesting permission…` | The iOS permission dialog is pending (first run) — it resolves when answered |
| `getToken()` returns null on iOS | No APNS token (Simulator without push support, missing entitlement, or `registerForRemoteNotifications` never called) |
| `notify_kit: POST …/devices failed: Connection refused` | notify-hub isn't running / wrong host or port (Sail publishes port **80** by default, not 8080) |
| `Invalid API key.` (401) from notify-hub | Wrong `apiKey` — the kit sends it in the `X-Api-Key` header |
| Opens not counted in notify-hub | The push data lacks `nh_notification_id` (only campaign pushes sent through notify-hub carry it) |
| Permission dialog appears twice | Something else (e.g. flutter_local_notifications) is also requesting permission — it must not (the kit initializes it with all permission requests disabled) |

## What the package deliberately does NOT do

- **Foreground UI**: `onForegroundMessage` / `foregroundMessages` give you the
  message; showing a toast/dialog is app policy (and the only reliable way on
  iOS — see above).
- **Payload → route mapping and topic names**: backend contracts belong to
  the app (see `lib/core/services/notification/samnan_notification_navigation.dart`).
- Scheduled notifications, multiple Android channels, action buttons — out of
  scope until a real consumer needs them.
- The in-app notification-center screen (REST history) — domain logic.
