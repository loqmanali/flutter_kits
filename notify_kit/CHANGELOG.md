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
