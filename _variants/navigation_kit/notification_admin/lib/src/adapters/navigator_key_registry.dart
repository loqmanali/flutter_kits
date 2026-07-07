import 'package:flutter/material.dart';

/// Owns the global navigator keys used by the kit's shells and route helpers.
///
/// Host apps can register named keys to control which navigator a route opens
/// in (root vs. shell vs. branch), or just let the kit auto-create the
/// defaults.
///
/// Usage:
/// ```dart
/// // Default behaviour — kit creates its own root/shell keys.
/// final rootKey = NavigatorKeyRegistry.instance.rootKey;
///
/// // Custom keys.
/// NavigatorKeyRegistry.instance
///   ..registerRootKey(myRootKey)
///   ..registerBranch('home', myHomeBranchKey);
/// ```
class NavigatorKeyRegistry {
  NavigatorKeyRegistry._();
  static final NavigatorKeyRegistry instance = NavigatorKeyRegistry._();

  GlobalKey<NavigatorState>? _rootKey;
  GlobalKey<NavigatorState>? _shellKey;
  final Map<String, GlobalKey<NavigatorState>> _branches = {};

  /// Root navigator key. Auto-created on first access if not registered.
  GlobalKey<NavigatorState> get rootKey => _rootKey ??=
      GlobalKey<NavigatorState>(debugLabel: 'navKitRootNavigator');

  /// Shell navigator key (single-shell layouts). Auto-created on first access.
  GlobalKey<NavigatorState> get shellKey => _shellKey ??=
      GlobalKey<NavigatorState>(debugLabel: 'navKitShellNavigator');

  /// Register a custom root navigator key.
  void registerRootKey(GlobalKey<NavigatorState> key) => _rootKey = key;

  /// Register a custom shell navigator key.
  void registerShellKey(GlobalKey<NavigatorState> key) => _shellKey = key;

  /// Register / look up a branch key by name (e.g. `'home'`, `'profile'`).
  /// Auto-creates the key on first access if not registered.
  GlobalKey<NavigatorState> branch(String name) {
    return _branches.putIfAbsent(
      name,
      () => GlobalKey<NavigatorState>(debugLabel: 'navKitBranch:$name'),
    );
  }

  /// Register a branch key explicitly.
  void registerBranch(String name, GlobalKey<NavigatorState> key) {
    _branches[name] = key;
  }

  /// Reset everything (test hook).
  void reset() {
    _rootKey = null;
    _shellKey = null;
    _branches.clear();
  }

  // ----- convenience operations --------------------------------------------

  /// Pop the root navigator if it can pop.
  void popRoot() => _rootKey?.currentState?.maybePop();

  bool canPopRoot() => _rootKey?.currentState?.canPop() ?? false;
}
