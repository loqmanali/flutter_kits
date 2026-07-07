# notification_kit

Self-contained, plug-and-play Flutter notification module. Built around Firebase
Cloud Messaging, local notifications, Riverpod, and Clean Architecture — but
**zero coupling to any specific host app**.

Drop it into any Flutter project, wire three adapters, and you're done.

## What it gives you

- Firebase Cloud Messaging — foreground, background, terminated, with token management.
- Local + scheduled notifications via `flutter_local_notifications`.
- FCM HTTP v1 admin sender (service-account JWT signing) — ship in-app admin tooling.
- Riverpod providers and notifiers for state, settings, history, composer.
- Pre-built screens: `NotificationAdminPage`, `NotificationHistoryPage`, `NotificationSettingsPage`.
- Pre-built widgets: `InAppNotificationBanner`, `NotificationListTile`, `NotificationPermissionDialog`, `NotificationSettingsTile`.
- Deep-link routing on tap (via `go_router`).
- In-app toasts via `toastification`.
- Topic subscriptions, badges, custom sounds.

## Add to your project

In your app's `pubspec.yaml`:

```yaml
dependencies:
  notification_kit:
    path: ../packages/notification_kit  # adjust to where you copied it
```

Then `flutter pub get`.

## Integration (3 steps)

### 1) Configure the runtime — once, near the top of `main()`

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notification_kit/notification_kit.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // (Optional) background handler — must be registered before runApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ── notification_kit setup ─────────────────────────────────────────
  NotificationKitRuntime.use(
    navigator: NotificationNavigator(
      rootNavigatorKey: rootNavigatorKey,
      fallbackRoute: '/home', // tapped notifications without payload land here
    ),
    // storage: MyHiveAdapter(),   // optional — defaults to SharedPreferences
    // logger:  MyAppLogger(),     // optional — defaults to debugPrint
  );

  await NotificationInitializer.initialize();
  // ───────────────────────────────────────────────────────────────────

  runApp(ProviderScope(child: MyApp(navigatorKey: rootNavigatorKey)));
}
```

### 2) Hand your root navigator key to `MaterialApp` / `GoRouter`

```dart
MaterialApp(
  navigatorKey: rootNavigatorKey,
  // ...
);

// or with GoRouter:
GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: [...],
);
```

### 3) Wire the runtime handlers somewhere after `ProviderScope` mounts

```dart
class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationHandlerProvider).initialize();
    });
  }
  // ...
}
```

That's it. Foreground messages, taps, deep links, in-app banners, settings
persistence — all working.

## Host-app adapters

The kit is project-agnostic because it talks to your app through three small
adapters configured on `NotificationKitRuntime`. Override what you need; leave
the rest on defaults.

### Logger (optional)

```dart
class MyAppLogger implements NotificationLogger {
  @override
  void debug(String m, [Object? e, StackTrace? s]) => Logger.d(m, error: e);
  @override
  void info(String m, [Object? e, StackTrace? s])  => Logger.i(m, error: e);
  @override
  void warning(String m, [Object? e, StackTrace? s]) => Logger.w(m, error: e);
  @override
  void error(String m, [Object? e, StackTrace? s])   => Logger.e(m, error: e);
}
```

### Storage adapter (optional)

If you have a project-wide storage abstraction (Hive, secure-storage,
SharedPreferences wrapper, etc.), implement `NotificationStorageAdapter`:

```dart
class MyHiveAdapter implements NotificationStorageAdapter {
  // 7 simple methods — see NotificationStorageAdapter for the contract.
  // ...
}
```

Default: `SharedPreferencesAdapter` (uses `shared_preferences`).

### Navigator (required for in-app toasts & deep-link routing)

Pass the same key you use in your `MaterialApp`/`GoRouter`:

```dart
NotificationNavigator(
  rootNavigatorKey: rootNavigatorKey,
  fallbackRoute: '/home',
)
```

If `navigator` is left null, the kit still receives notifications — it just
won't show in-app toasts or auto-navigate on tap.

## Sending notifications (admin)

```dart
final admin = await FCMAdminServiceImpl.fromAssets(
  // pass path to your service-account JSON inside assets/
);

final result = await admin.sendNotification(NotificationRequest(
  title: 'Hello',
  body: 'World',
  targetType: NotificationTargetType.topic,
  topic: 'all_users',
));
```

Or jump straight into the pre-built admin screen:

```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const NotificationAdminPage(),
));
```

## Platform setup

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

<application>
  <meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />
</application>
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

And upload your APNs key in the Firebase Console.

## Public API

Everything is re-exported from `package:notification_kit/notification_kit.dart`:

- **Runtime / adapters** — `NotificationKitRuntime`, `NotificationNavigator`, `NotificationStorageAdapter`, `NotificationLogger`
- **Entry point** — `NotificationInitializer`
- **Entities / failures** — `NotificationEntity`, `NotificationRequest`, `NotificationPayload`, `NotificationSchedule`, `NotificationSettings`, `NotificationFailure`, `FCMFailure`, …
- **Services** — `NotificationService`, `FCMService`, `FCMAdminService`, `ToastNotificationService`, `DeepLinkNotificationService`, …
- **Providers** — `notificationProvider`, `notificationSettingsProvider`, `notificationComposerProvider`, plus all DataSource/Repository providers
- **Pages** — `NotificationAdminPage`, `NotificationHistoryPage`, `NotificationSettingsPage`
- **Widgets** — `InAppNotificationBanner`, `NotificationListTile`, `NotificationPermissionDialog`, `NotificationSettingsTile`

See `example/` for a minimal working app, and `lib/src/README.md` for the
extended reference (entities, configuration, troubleshooting).

## Notes

- The kit assumes `ProviderScope` is mounted at the app root.
- `ScreenUtil` is used by some widgets — initialize `flutter_screenutil` in
  your host app (e.g. wrap with `ScreenUtilInit`).
- The default `SharedPreferencesAdapter` is fully async-safe; you don't need to
  pre-initialize it.
