import 'package:flutter/material.dart';

import 'adapters/navigation_logger.dart';
import 'adapters/navigator_key_registry.dart';

/// Global injection point for navigation_kit.
///
/// Call `NavigationKitRuntime.use(...)` once at startup, before constructing
/// your `GoRouter`, to plug in:
///   * a custom [NavigationLogger] (defaults to [DeveloperNavigationLogger])
///   * custom root / shell navigator keys (otherwise the kit auto-creates
///     them on first access)
class NavigationKitRuntime {
  NavigationKitRuntime._();

  static NavigationLogger _logger = const DeveloperNavigationLogger();

  static NavigationLogger get logger => _logger;
  static NavigatorKeyRegistry get keys => NavigatorKeyRegistry.instance;

  /// Convenience accessors so call sites read cleanly.
  static GlobalKey<NavigatorState> get rootKey => keys.rootKey;
  static GlobalKey<NavigatorState> get shellKey => keys.shellKey;

  static void use({
    NavigationLogger? logger,
    GlobalKey<NavigatorState>? rootKey,
    GlobalKey<NavigatorState>? shellKey,
    Map<String, GlobalKey<NavigatorState>>? branchKeys,
  }) {
    if (logger != null) _logger = logger;
    if (rootKey != null) keys.registerRootKey(rootKey);
    if (shellKey != null) keys.registerShellKey(shellKey);
    if (branchKeys != null) {
      branchKeys.forEach(keys.registerBranch);
    }
  }

  /// Reset everything (test hook).
  static void reset() {
    _logger = const DeveloperNavigationLogger();
    keys.reset();
  }
}
