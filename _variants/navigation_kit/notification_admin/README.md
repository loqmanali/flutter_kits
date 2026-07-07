# navigation_kit

A self-contained, project-agnostic navigation module for Flutter apps built on
[GoRouter](https://pub.dev/packages/go_router). Drop it into any project and
you get:

- **Shells** — stateful & stateless bottom nav, drawer, tab bar, mixed (drawer+bottom-nav)
- **Guards** — auth, guest mode, role-based access (RBAC), feature flags
- **Route helpers** — fullscreen / modal / animated transitions, nested route builders
- **Observers** — logging, analytics, screen-time tracking
- **Deep links** — pattern matching with parameter extraction
- **Extensions** — `context.goTo / pushTo / goBack` for tighter call sites
- **Pluggable** — bring your own logger and navigator keys

---

## 1. Setup

`pubspec.yaml`:

```yaml
dependencies:
  navigation_kit:
    path: packages/navigation_kit
```

Configure once at startup:

```dart
import 'package:navigation_kit/navigation_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NavigationKitRuntime.use(
    logger: AppNavigationLogger(),   // optional — wraps your AppLogger
    // Or pass your own keys:
    // rootKey: myRootNavigatorKey,
    // branchKeys: {'home': homeKey, 'profile': profileKey},
  );

  runApp(MyApp());
}
```

### Wiring your existing logger

```dart
class AppNavigationLogger implements NavigationLogger {
  @override
  void debug(String m, [Object? e, StackTrace? st]) => AppLogger.debug(m, e, st);
  @override
  void info(String m, [Object? e, StackTrace? st]) => AppLogger.info(m, e, st);
  @override
  void warning(String m, [Object? e, StackTrace? st]) => AppLogger.warning(m, e, st);
  @override
  void error(String m, [Object? e, StackTrace? st]) => AppLogger.error(m, e, st);
}
```

---

## 2. Guards

```dart
final router = GoRouter(
  navigatorKey: NavigationKitRuntime.rootKey,
  redirect: AuthGuard.combine([
    AuthGuard.globalRedirect(
      isAuthenticated: () => authService.isLoggedIn,
      publicPaths: const ['/login', '/register', '/forgot-password'],
      loginPath: '/login',
      homePath: '/home',
    ),
    FeatureFlagGuard.requireFeature(
      isFeatureEnabled: () => flags.isOn('new_checkout'),
      fallbackPath: '/checkout',
    ),
  ]),
  routes: [...],
);
```

Role-based:

```dart
GoRoute(
  path: '/admin',
  redirect: RoleGuard.requireRole(
    getCurrentUserRole: () => authService.currentUser?.role,
    allowedRoles: const ['admin', 'super_admin'],
    unauthorizedPath: '/unauthorized',
  ),
  builder: (_, __) => const AdminScreen(),
);
```

Guest mode:

```dart
GoRouter(
  redirect: GuestGuard.combinedAuthAndGuestRedirect(
    isAuthenticated: () => authService.isLoggedIn,
    isGuest: () => authService.isGuestMode,
    publicPaths: const ['/login', '/register'],
    guestAllowedPaths: const ['/home', '/products', '/products/:id'],
    loginPath: '/login',
    homePath: '/home',
  ),
);
```

---

## 3. Shells

Stateful bottom navigation (recommended — preserves tab state):

```dart
final router = GoRouter(
  navigatorKey: NavigationKitRuntime.rootKey,
  initialLocation: '/home',
  routes: [
    StatefulBottomNavShellBuilder.build(
      branches: [
        BranchConfig(
          destination: const NavigationDestinationConfig(
            path: '/home', label: 'Home', icon: Icons.home,
          ),
          routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())],
          navigatorKey: NavigationKitRuntime.keys.branch('home'),
        ),
        BranchConfig(
          destination: const NavigationDestinationConfig(
            path: '/profile', label: 'Profile', icon: Icons.person,
          ),
          routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())],
          navigatorKey: NavigationKitRuntime.keys.branch('profile'),
        ),
      ],
    ),
  ],
);
```

Other shells follow the same shape: `BottomNavShellBuilder`, `DrawerShellBuilder`,
`TabBarShellBuilder`, `MixedShellBuilder`.

---

## 4. Route helpers

```dart
RouteBuilder.fullScreen(
  path: '/checkout',
  builder: (_, __) => const CheckoutScreen(),   // hides bottom nav
);

ModalRoutes.bottomSheet(
  path: '/filters',
  builder: (_, __) => const FiltersSheet(),
);

TransitionRoutes.fade(
  path: '/promo',
  builder: (_, __) => const PromoScreen(),
);
```

---

## 5. Observers

```dart
GoRouter(
  observers: [
    LoggingNavigatorObserver(),                   // → uses NavigationKitRuntime.logger
    AnalyticsNavigatorObserver(
      onScreenView: (name, params) => analytics.logScreenView(name, params),
    ),
    ScreenTimeObserver(
      onScreenExit: (name, duration) =>
          analytics.logEvent('screen_time', {'screen': name, 'ms': duration.inMilliseconds}),
    ),
  ],
);
```

---

## 6. Deep links

```dart
final handler = DeepLinkHandler(
  hosts: const ['example.com'],
  patterns: [
    DeepLinkPattern(pattern: 'product/:id', routePath: '/home/product/:id'),
    DeepLinkPattern(pattern: 'offer/:code', routePath: '/promo/:code'),
  ],
);

final route = handler.processDeepLink(uri);
if (route != null) router.go(route);
```

---

## 7. Context extensions

```dart
context.goTo('/home');
context.pushTo('/details/123');
context.goBack();
final result = await context.pushForResult<bool>('/confirm');
```

---

## 8. What's pluggable

| Surface              | Plug via                                              |
|----------------------|-------------------------------------------------------|
| Logger               | `NavigationLogger` + `NavigationKitRuntime.use(logger:)` |
| Root navigator key   | `NavigationKitRuntime.use(rootKey:)`                  |
| Shell navigator key  | `NavigationKitRuntime.use(shellKey:)`                 |
| Branch keys          | `NavigationKitRuntime.use(branchKeys: {...})` or `keys.branch('name')` |
| Route paths          | Define your own `RoutePaths` class in the host app — the kit doesn't ship one |

Reset everything (test hook): `NavigationKitRuntime.reset()`.
