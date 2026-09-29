import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../application/toast_controller.dart';
import '../application/toast_entry.dart';
import '../application/toast_handle.dart';
import '../domain/toast_placement.dart';
import '../domain/toast_request.dart';
import '../domain/toast_tone.dart';
import 'toast_item_widget.dart';
import 'toast_kit_theme.dart';

/// Hosts every toast for the app it wraps.
///
/// Place it in `MaterialApp.builder`, above the `Navigator`, so toasts
/// survive route pushes/pops and dialogs — the same reason
/// `ScaffoldMessenger` sits where it does:
///
/// ```dart
/// final toastKey = GlobalKey<ToastHostState>();
///
/// MaterialApp(
///   builder: (context, child) => ToastHost(key: toastKey, child: child!),
///   home: const HomeScreen(),
/// );
///
/// // From anywhere, without a BuildContext:
/// toastKey.currentState!.show(const ToastRequest(title: 'Saved'));
/// ```
///
/// Renders its own [Overlay] beside [child] (not [OverlayPortal]: there is
/// no single host element to anchor one to — a whole tree of independent,
/// self-removing toasts is exactly what `Overlay`/`OverlayEntry` are for,
/// the same primitive `Tooltip` and the legacy `Scaffold` snackbar used).
/// A plain `Stack` was tried first and rejected: `IconButton`'s built-in
/// `Tooltip` (used by the close button) asserts an `Overlay` ancestor, and
/// a `Stack` sibling of the app's `Navigator` is not one.
class ToastHost extends StatefulWidget {
  const ToastHost({super.key, required this.child});

  final Widget child;

  /// The nearest [ToastHostState], or throws if there is none.
  static ToastHostState of(BuildContext context) {
    final state = maybeOf(context);
    assert(state != null, 'No ToastHost found above this context.');
    return state!;
  }

  /// The nearest [ToastHostState], or `null` if there is none.
  static ToastHostState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<ToastHostState>();

  @override
  ToastHostState createState() => ToastHostState();
}

class ToastHostState extends State<ToastHost> {
  final ToastController _controller = ToastController();
  late final OverlayEntry _entry;

  static bool _extensionsRegistered = false;

  @override
  void initState() {
    super.initState();
    _entry = OverlayEntry(
      builder: (context) => _ToastOverlayLayer(controller: _controller),
    );
    _controller.addListener(_handleControllerChanged);
    _maybeRegisterServiceExtensions();
  }

  void _handleControllerChanged() {
    // The Diagnostics tree (debugFillProperties) is read off ToastHostState
    // itself, so it still needs a rebuild; the toasts' own re-paint is
    // driven by `_entry.markNeedsBuild()` alone.
    if (mounted) setState(() => _entry.markNeedsBuild());
  }

  /// Shows [request], resolving its placement against the theme's default
  /// when it does not set one.
  ToastHandle show(ToastRequest request) {
    final theme = ToastKitTheme.of(context);
    final placement =
        request.placement ?? theme.defaultPlacement ?? ToastPlacement.topCenter;
    return _controller.show(request, placement: placement);
  }

  /// Dismisses every active toast.
  void dismissAll() => _controller.dismissAll();

  /// The controller backing this host — for tests and DevTools only, never
  /// for an app to drive directly (use [show]/[dismissAll]).
  @visibleForTesting
  ToastController get debugController => _controller;

  @override
  void dispose() {
    // Not `_entry.dispose()` here: the child `Overlay` (still mounted at
    // this point) owns removing and disposing its own entries as it
    // unmounts; disposing one first throws ("must be removed from the
    // Overlay before dispose").
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: widget.child),
        Positioned.fill(child: Overlay(initialEntries: [_entry])),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    for (final placement in _controller.activePlacements) {
      properties.add(
        IterableProperty<String>(
          'visible[$placement]',
          _controller.visibleIn(placement).map(_describe),
        ),
      );
      properties.add(
        IterableProperty<String>(
          'pending[$placement]',
          _controller.pendingIn(placement).map(_describe),
        ),
      );
    }
  }

  static String _describe(ToastEntry entry) =>
      '#${entry.id} "${entry.request.title}" ${entry.state}';

  // ---- DevTools service extensions (debug/profile only) ----
  //
  // `BindingBase.registerServiceExtension` always prefixes with
  // `ext.flutter.`, which would register `ext.flutter.toast_kit.show`
  // rather than the `ext.toast_kit.show` this kit's brief asks for, so this
  // calls `dart:developer`'s `registerExtension` directly instead of that
  // (protected, `ext.flutter.`-prefixed) helper. Guarded by `kReleaseMode`
  // and a one-per-isolate latch, as `registerServiceExtension`'s own doc
  // recommends, so the tree shaker can drop it from release builds.
  void _maybeRegisterServiceExtensions() {
    if (kReleaseMode || _extensionsRegistered) return;
    _extensionsRegistered = true;

    developer.registerExtension('ext.toast_kit.show', (
      String method,
      Map<String, String> parameters,
    ) async {
      final tone = ToastTone.values.firstWhere(
        (t) => t.name == parameters['tone'],
        orElse: () => ToastTone.neutral,
      );
      final durationMs = int.tryParse(parameters['duration'] ?? '');
      show(
        ToastRequest(
          title: parameters['title'] ?? 'Toast',
          tone: tone,
          duration: durationMs == null
              ? const Duration(seconds: 4)
              : Duration(milliseconds: durationMs),
          layoutKey: parameters['layout'],
        ),
      );
      return developer.ServiceExtensionResponse.result(
        json.encode(<String, Object?>{'type': 'toast_kit', 'result': 'shown'}),
      );
    });

    developer.registerExtension('ext.toast_kit.dismissAll', (
      String method,
      Map<String, String> parameters,
    ) async {
      dismissAll();
      return developer.ServiceExtensionResponse.result(
        json.encode(<String, Object?>{'type': 'toast_kit', 'result': 'ok'}),
      );
    });

    developer.registerExtension('ext.toast_kit.state', (
      String method,
      Map<String, String> parameters,
    ) async {
      final state = <String, Object?>{
        for (final placement in _controller.activePlacements)
          placement.toString(): <String, Object?>{
            'visible': _controller.visibleIn(placement).map(_toJson).toList(),
            'pending': _controller.pendingIn(placement).map(_toJson).toList(),
          },
      };
      return developer.ServiceExtensionResponse.result(
        json.encode(<String, Object?>{'type': 'toast_kit', ...state}),
      );
    });
  }

  static Map<String, Object?> _toJson(ToastEntry entry) => <String, Object?>{
        'id': entry.id,
        'title': entry.request.title,
        'tone': entry.request.tone.name,
        'state': entry.state.toString(),
      };
}

/// The single [OverlayEntry]'s content: every active placement's stack,
/// read fresh from [controller] each time the entry is told to rebuild.
class _ToastOverlayLayer extends StatelessWidget {
  const _ToastOverlayLayer({required this.controller});

  final ToastController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          for (final placement in controller.activePlacements)
            _ToastPlacementPositioned(
              placement: placement,
              entries: controller.visibleIn(placement),
              controller: controller,
            ),
        ],
      ),
    );
  }
}

/// One placement's toast stack, positioned at its screen edge/anchor and
/// kept clear of the notch, status bar and (for a bottom placement) the
/// on-screen keyboard.
class _ToastPlacementPositioned extends StatelessWidget {
  const _ToastPlacementPositioned({
    required this.placement,
    required this.entries,
    required this.controller,
  });

  final ToastPlacement placement;
  final List<ToastEntry> entries;
  final ToastController controller;

  @override
  Widget build(BuildContext context) {
    final alignment = switch (placement.anchor) {
      ToastHorizontalAnchor.start => AlignmentDirectional.topStart,
      ToastHorizontalAnchor.center => AlignmentDirectional.topCenter,
      ToastHorizontalAnchor.end => AlignmentDirectional.topEnd,
    };
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final isBottom = placement.edge == ToastVerticalEdge.bottom;

    return PositionedDirectional(
      top: isBottom ? null : 0,
      bottom: isBottom ? 0 : null,
      start: 0,
      end: 0,
      child: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsetsDirectional.only(
              bottom: isBottom ? viewInsets.bottom : 0),
          child: Align(
            alignment:
                isBottom ? AlignmentDirectional(alignment.start, 1) : alignment,
            child: _ToastPlacementStack(
              placement: placement,
              entries: entries,
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }
}

/// The column of [ToastItemWidget]s for one placement, closest toast to the
/// edge last so a new toast at the bottom appears nearest the bottom edge.
class _ToastPlacementStack extends StatelessWidget {
  const _ToastPlacementStack({
    required this.placement,
    required this.entries,
    required this.controller,
  });

  final ToastPlacement placement;
  final List<ToastEntry> entries;
  final ToastController controller;

  @override
  Widget build(BuildContext context) {
    final theme = ToastKitTheme.of(context);
    final crossAxisAlignment = switch (placement.anchor) {
      ToastHorizontalAnchor.start => CrossAxisAlignment.start,
      ToastHorizontalAnchor.center => CrossAxisAlignment.center,
      ToastHorizontalAnchor.end => CrossAxisAlignment.end,
    };
    final ordered = placement.edge == ToastVerticalEdge.bottom
        ? entries.reversed.toList(growable: false)
        : entries;

    final children = <Widget>[];
    for (var i = 0; i < ordered.length; i++) {
      if (i > 0) children.add(SizedBox(height: theme.spacing ?? 8));
      children.add(
        ToastItemWidget(
          key: ValueKey<int>(ordered[i].id),
          entry: ordered[i],
          controller: controller,
        ),
      );
    }

    return Padding(
      padding: theme.margin ??
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }
}
