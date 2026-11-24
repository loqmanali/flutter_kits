## 1.0.0

**BREAKING.** Flutter 3.50 / Dart 3.14 migration (monorepo release 2.1.0).

- Migrated from the deprecated `package:flutter/material.dart` / `cupertino.dart` to `package:material_ui` / `package:cupertino_ui`. Requires Flutter >= 3.47 / Dart >= 3.13; extensions and themes are now material_ui `ThemeData` types.
- Dependencies: `firebase_core ^5.2.0`, `firebase_messaging ^17.1.0`, `flutter_local_notifications ^23.0.4`, `timezone ^0.11.2`.
- flutter_local_notifications 20+ named parameters (`initialize`, `show`, `zonedSchedule`, `cancel`) and the removed `uiLocalNotificationDateInterpretation`.
- `getToken()` / `onTokenRefresh` still emit the FCM token via firebase_messaging's deprecated members (`register()`/`onRegistered` emit the Firebase Installation ID instead), with a scoped `ignore: deprecated_member_use`. Public API unchanged.

## 0.1.1

### Fixed

- `NotifyKit.init()` used to set its `_initialized` latch **before** awaiting
  the fallible `_local.init()` / `_fcm.init()` calls. If either threw (a
  platform-channel failure, a bad config), the flag was already set, so every
  later `init()` call — including the retry that `registerDevice()`'s own
  doc comment tells callers to make after login — hit the "already called"
  no-op branch forever, with no subscriptions ever created and no error
  surfaced. The flag is now only set once init has genuinely completed.
- A second `init()` call made while a first is still in flight now awaits
  that same attempt instead of starting a concurrent second one, which
  would have double-run the local/FCM init and created duplicate
  subscriptions.

## 0.1.0

- Initial release.
