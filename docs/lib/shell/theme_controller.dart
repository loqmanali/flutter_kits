import 'package:flutter/material.dart';

/// Hosts the light/dark mode preference for the docs app.
///
/// We keep it dead simple: an [InheritedWidget] carrying the current
/// [ThemeMode], toggled by the top bar. No persistence beyond the session —
/// mirroring how the widget_kit gallery behaves, and fine for a docs site.
class ThemeModeController extends StatefulWidget {
  const ThemeModeController({super.key, required this.child});

  final Widget child;

  /// Reads the current [ThemeMode].
  static ThemeMode of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<_ThemeModeData>();
    return w?.mode ?? ThemeMode.system;
  }

  /// Toggles between light and dark. No-op for system (resolved at build).
  static void toggle(BuildContext context) {
    final state = context.findAncestorStateOfType<_ThemeModeControllerState>();
    state?._toggle();
  }

  @override
  State<ThemeModeController> createState() => _ThemeModeControllerState();
}

class _ThemeModeControllerState extends State<ThemeModeController> {
  ThemeMode _mode = ThemeMode.light;

  void _toggle() {
    setState(() {
      _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ThemeModeData(mode: _mode, child: widget.child);
  }
}

class _ThemeModeData extends InheritedWidget {
  const _ThemeModeData({required this.mode, required super.child});

  final ThemeMode mode;

  @override
  bool updateShouldNotify(_ThemeModeData oldWidget) => oldWidget.mode != mode;
}
