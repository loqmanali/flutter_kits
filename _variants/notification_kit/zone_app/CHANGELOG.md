## 1.0.0

* Initial release as a standalone, project-agnostic package extracted from the
  original `lib/core/notification_module` of burger_republic.
* Added `NotificationKitRuntime` + three pluggable adapters
  (`NotificationLogger`, `NotificationStorageAdapter`, `NotificationNavigator`)
  so the kit can be dropped into any Flutter project without code changes.
* Default `SharedPreferencesAdapter` and `DebugPrintLogger` provided.
