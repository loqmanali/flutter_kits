import 'notification_logger.dart';
import 'notification_navigator.dart';
import 'notification_storage_adapter.dart';

/// Process-wide runtime configuration for notification_kit.
///
/// Configure once, near the top of `main()`, before calling
/// `NotificationInitializer.initialize(...)`. All internal services read
/// from this singleton, so callers don't need to thread adapters through
/// constructors.
///
/// Example:
/// ```dart
/// NotificationKitRuntime.use(
///   navigator: NotificationNavigator(rootNavigatorKey: appRootKey, fallbackRoute: '/home'),
///   storage: MyHiveAdapter(),     // optional — defaults to SharedPreferences
///   logger: MyAppLogger(),        // optional — defaults to debugPrint
/// );
/// ```
class NotificationKitRuntime {
  NotificationKitRuntime._();

  static NotificationLogger _logger = const DeveloperLogLogger();
  static NotificationStorageAdapter _storage = SharedPreferencesAdapter();
  static NotificationNavigator? _navigator;

  /// Configure the runtime. Pass only the adapters you want to override —
  /// others keep their previous (or default) values.
  static void use({
    NotificationLogger? logger,
    NotificationStorageAdapter? storage,
    NotificationNavigator? navigator,
  }) {
    if (logger != null) _logger = logger;
    if (storage != null) _storage = storage;
    if (navigator != null) _navigator = navigator;
  }

  static NotificationLogger get logger => _logger;
  static NotificationStorageAdapter get storage => _storage;

  /// Root navigator. May be null if the host app didn't supply one — in that
  /// case features that depend on it (in-app toasts, deep-link navigation)
  /// will silently no-op.
  static NotificationNavigator? get navigator => _navigator;
}
