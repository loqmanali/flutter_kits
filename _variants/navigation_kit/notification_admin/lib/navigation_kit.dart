/// navigation_kit
///
/// Self-contained, project-agnostic navigation module for Flutter apps using
/// GoRouter.
///
/// - **Shells**: bottom nav (stateful & stateless), drawer, tab bar, mixed
/// - **Guards**: auth, guest mode, role-based access, feature flags
/// - **Routes**: helpers for fullscreen / modal / animated transitions
/// - **Utils**: logging & analytics observers, deep-link handler, context extensions
/// - **Pluggable**: bring your own logger and navigator keys
///
/// Quick start:
/// ```dart
/// import 'package:navigation_kit/navigation_kit.dart';
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   NavigationKitRuntime.use(
///     logger: AppNavigationLogger(),   // optional — wraps your AppLogger
///   );
///
///   final router = GoRouter(
///     navigatorKey: NavigationKitRuntime.rootKey,
///     redirect: AuthGuard.globalRedirect(
///       isAuthenticated: () => authService.isLoggedIn,
///       publicPaths: const ['/login', '/register'],
///       loginPath: '/login',
///     ),
///     observers: [LoggingNavigatorObserver()],
///     routes: [...],
///   );
///
///   runApp(MaterialApp.router(routerConfig: router));
/// }
/// ```
library;

// Runtime + adapters
export 'src/navigation_kit_runtime.dart';
export 'src/adapters/navigation_logger.dart';
export 'src/adapters/navigator_key_registry.dart';

// Config
export 'src/config/navigation_config.dart';

// Guards
export 'src/guards/auth_guard.dart';
export 'src/guards/guest_guard.dart';
export 'src/guards/role_guard.dart';
export 'src/guards/feature_flag_guard.dart';

// Routes
export 'src/routes/route_builder.dart';
export 'src/routes/modal_routes.dart';
export 'src/routes/transition_routes.dart';

// Shells
export 'src/shells/bottom_nav_shell.dart';
export 'src/shells/stateful_bottom_nav_shell.dart';
export 'src/shells/drawer_shell.dart';
export 'src/shells/tab_bar_shell.dart';
export 'src/shells/mixed_shell.dart';

// Utils
export 'src/utils/navigation_observer.dart';
export 'src/utils/navigation_extensions.dart';
export 'src/utils/deep_link_handler.dart';
