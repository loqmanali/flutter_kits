import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../application/toast_controller.dart';
import '../application/toast_entry.dart';
import '../application/toast_lifecycle_state.dart';
import '../domain/toast_close_button_policy.dart';
import '../domain/toast_dismiss_reason.dart';
import 'toast_kit_theme.dart';
import 'toast_layout.dart';
import 'toast_strings.dart';

/// Renders one live [ToastEntry]: resolves its [ToastLayout], drives its
/// enter/exit animation and progress bar, and turns gestures into
/// [ToastController] calls.
///
/// Reports [ToastController.markShown] from a post-frame callback — the
/// first opportunity to know the toast actually painted — never from
/// [initState] or `build`, which can both run while frames are being
/// dropped (a native modal occluding the app).
class ToastItemWidget extends StatefulWidget {
  const ToastItemWidget(
      {super.key, required this.entry, required this.controller});

  final ToastEntry entry;
  final ToastController controller;

  @override
  State<ToastItemWidget> createState() => _ToastItemWidgetState();
}

class _ToastItemWidgetState extends State<ToastItemWidget>
    with TickerProviderStateMixin {
  late final AnimationController _visibility;
  late final AnimationController _progress;
  ToastLifecycleState? _lastState;
  bool _reportedShown = false;
  bool _themeApplied = false;
  double _dragExtent = 0;

  static const double _dragDismissThreshold = 80;

  @override
  void initState() {
    super.initState();
    _visibility = AnimationController(vsync: this, value: 0);
    final remaining = widget.entry.remaining;
    _progress = AnimationController(
      vsync: this,
      value: 1,
      duration: remaining ?? Duration.zero,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportShown());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_themeApplied) {
      _themeApplied = true;
      final theme = ToastKitTheme.of(context);
      _visibility.duration = theme.enterDuration;
      _visibility.reverseDuration = theme.exitDuration;
      if (MediaQuery.disableAnimationsOf(context)) {
        _visibility.value = 1;
      } else {
        _visibility.forward();
      }
    }
  }

  void _reportShown() {
    if (_reportedShown || !mounted) return;
    _reportedShown = true;
    final suppressTimer = MediaQuery.accessibleNavigationOf(context);
    widget.controller.markShown(widget.entry.id, suppressTimer: suppressTimer);
    if (!suppressTimer && !MediaQuery.disableAnimationsOf(context)) {
      _progress.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant ToastItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = widget.entry.state;
    if (current is ToastLeaving && _lastState is! ToastLeaving) {
      _playExit();
    }
    _lastState = current;
  }

  void _playExit() {
    if (MediaQuery.disableAnimationsOf(context)) {
      // Deferred to a post-frame callback: this runs from didUpdateWidget,
      // itself mid-build, and acknowledgeRemoved's notification would
      // otherwise call setState on the host while the framework is still
      // building this frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.acknowledgeRemoved(widget.entry.id);
      });
      return;
    }
    _visibility.reverse().whenCompleteOrCancel(() {
      if (mounted) widget.controller.acknowledgeRemoved(widget.entry.id);
    });
  }

  void _pause() => widget.controller.pause(widget.entry.id);

  void _resume() {
    widget.controller.resume(widget.entry.id);
    if (!MediaQuery.disableAnimationsOf(context)) _progress.reverse();
  }

  void _dismiss(ToastDismissReason reason) =>
      widget.controller.dismiss(widget.entry.id, reason);

  @override
  void dispose() {
    _visibility.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final entry = widget.entry;
    properties
      ..add(IntProperty('id', entry.id))
      ..add(EnumProperty<ToastCloseButtonPolicy>(
        'closeButtonPolicy',
        entry.request.showCloseButton,
      ))
      ..add(DiagnosticsProperty<Duration?>('duration', entry.request.duration))
      ..add(DiagnosticsProperty<Duration?>('remaining', entry.remaining))
      ..add(StringProperty('lifecycle', entry.state.toString()));
  }

  bool _closeButtonVisible(ToastKitTheme theme) {
    final policy = widget.entry.request.showCloseButton;
    return switch (policy) {
      ToastCloseButtonPolicy.always => true,
      ToastCloseButtonPolicy.never => false,
      ToastCloseButtonPolicy.whenSticky =>
        widget.entry.request.duration == null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = ToastKitTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final request = widget.entry.request;
    final layoutKey = request.layoutKey ?? theme.defaultLayoutKey ?? 'flat';
    final layout = theme.layoutFor(layoutKey);
    final dismissible = request.dismissible;

    final view = ToastView(
      request: request,
      tone: request.tone,
      backgroundColor: theme.backgroundFor(request.tone, scheme),
      foregroundColor: theme.foregroundFor(request.tone, scheme),
      borderColor: theme.accentFor(request.tone, scheme),
      iconColor: theme.accentFor(request.tone, scheme),
      titleStyle:
          theme.titleTextStyle ?? Theme.of(context).textTheme.titleSmall!,
      messageStyle:
          theme.messageTextStyle ?? Theme.of(context).textTheme.bodySmall!,
      progress: _progress,
      showCloseButton: _closeButtonVisible(theme),
      maxTitleLines: theme.maxTitleLines ?? 5,
      maxMessageLines: theme.maxMessageLines ?? 3,
      strings: theme.strings ?? ToastStrings.fallback,
      onClose:
          dismissible ? () => _dismiss(ToastDismissReason.closeButton) : null,
      onAction: request.action == null
          ? null
          : () {
              request.action!.onPressed();
              _dismiss(ToastDismissReason.action);
            },
    );

    Widget content = layout.build(context, view);

    if (dismissible) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _dismiss(ToastDismissReason.tap),
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        onHorizontalDragUpdate: (details) {
          setState(() => _dragExtent += details.delta.dx);
        },
        onHorizontalDragEnd: (details) {
          if (_dragExtent.abs() >= _dragDismissThreshold) {
            _dismiss(ToastDismissReason.swipe);
          } else {
            setState(() => _dragExtent = 0);
          }
        },
        child: Transform.translate(
          offset: Offset(_dragExtent, 0),
          child: Opacity(
            opacity: (1 - (_dragExtent.abs() / (_dragDismissThreshold * 3)))
                .clamp(0.2, 1.0),
            child: content,
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _visibility,
      child: SizeTransition(
        sizeFactor: _visibility,
        // Without this, SizeTransition's un-animated (horizontal) axis
        // takes the full width its parent offers and centers the child in
        // it — silently overriding whatever start/center/end alignment the
        // placement chose. `1` makes it hug the child's own width instead.
        fixedCrossAxisSizeFactor: 1,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 0),
          child: content,
        ),
      ),
    );
  }
}
