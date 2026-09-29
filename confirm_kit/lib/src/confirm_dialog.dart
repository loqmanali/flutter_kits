import 'dart:async';

import 'package:flutter/material.dart';

import 'confirm_action.dart';
import 'confirm_action_button.dart';
import 'confirm_enums.dart';
import 'confirm_kit_theme.dart';
import 'confirm_strings.dart';

/// A confirmation with an icon, a title, a message and 1..N actions.
///
/// Works as a plain widget (`showDialog(builder: (_) => ConfirmDialog(...))`)
/// or through `.show(context)` from `show_confirm.dart`, which picks the right
/// presentation for [surface].
///
/// ```dart
/// final confirmed = await const ConfirmDialog(
///   title: 'Delete account?',
///   message: 'This removes your orders and addresses permanently.',
///   intent: ConfirmIntent.destructive,
/// ).show(context);
/// ```
///
/// [T] is what the confirmation pops. Leave it inferred for the yes/no case —
/// the built-in confirm/cancel actions pop `true` / `false` — or set it
/// explicitly and pass your own [actions] for a multi-way choice.
class ConfirmDialog<T> extends StatefulWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.intent = ConfirmIntent.primary,
    this.actions,
    this.confirmText,
    this.cancelText,
    this.showCancel = true,
    this.confirmFirst = false,
    this.confirmResult,
    this.cancelResult,
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.showIcon = true,
    this.iconBackground,
    this.actionsLayout = ConfirmActionsLayout.auto,
    this.surface = ConfirmSurface.dialog,
    this.alignment = ConfirmAlignment.center,
    this.dismissible = true,
    this.strings,
    this.backgroundColor,
    this.borderRadius,
    this.contentPadding,
    this.maxWidth,
    this.titleStyle,
    this.messageStyle,
  });

  /// Headline. Required — a confirmation without one is a toast.
  final String title;

  /// Supporting text under the title.
  final String? message;

  /// Arbitrary widget under the message: a checkbox ("don't ask again"), a
  /// text field ("type DELETE to confirm"), a summary list…
  final Widget? content;

  /// Drives the accent color, the default icon and the default confirm label.
  final ConfirmIntent intent;

  /// Full control over the buttons. When null, a confirm (+ cancel) pair is
  /// built from [confirmText] / [cancelText] / [showCancel].
  final List<ConfirmAction<T>>? actions;

  /// Label of the generated confirm action. Defaults to `strings.delete` for a
  /// destructive intent, `strings.ok` when [showCancel] is false, and
  /// `strings.confirm` otherwise.
  final String? confirmText;

  /// Label of the generated cancel action. Defaults to `strings.cancel`.
  final String? cancelText;

  /// `false` drops the cancel action — an acknowledge-only alert.
  final bool showCancel;

  /// `true` puts confirm before cancel. Default is the Material order
  /// (dismiss first, affirm last).
  final bool confirmFirst;

  /// Value popped by the generated confirm action. Defaults to `true` when [T]
  /// admits a `bool`.
  final T? confirmResult;

  /// Value popped by the generated cancel action. Defaults to `false` when [T]
  /// admits a `bool`.
  final T? cancelResult;

  /// Work run by the generated confirm action. Return a `Future` to get an
  /// in-button spinner and a locked dialog until it settles.
  final FutureOr<void> Function()? onConfirm;

  /// Work run by the generated cancel action.
  final FutureOr<void> Function()? onCancel;

  /// Replaces the intent's default icon — an `SvgPicture.asset`, an `Image`,
  /// any widget. Keep `flutter_svg` in your app, not in this kit.
  final Widget? icon;

  /// `false` hides the icon block entirely.
  final bool showIcon;

  /// Whether the icon sits in a tinted circle. Defaults to the theme.
  final bool? iconBackground;

  final ConfirmActionsLayout actionsLayout;
  final ConfirmSurface surface;
  final ConfirmAlignment alignment;

  /// `false` blocks the barrier, the drag and the system back button, so the
  /// user must pick an action. A running async action blocks them too, on its
  /// own, until it settles.
  final bool dismissible;

  /// Localized default labels for this confirmation only. Prefer setting them
  /// once on `ConfirmKitTheme`.
  final ConfirmStrings? strings;

  // ---- Per-instance style overrides (all fall back to ConfirmKitTheme) ----
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final double? maxWidth;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;

  T? get _defaultConfirmResult =>
      confirmResult ?? (true is T ? true as T : null);
  T? get _defaultCancelResult =>
      cancelResult ?? (false is T ? false as T : null);

  @override
  State<ConfirmDialog<T>> createState() => _ConfirmDialogState<T>();
}

class _ConfirmDialogState<T> extends State<ConfirmDialog<T>> {
  /// Index of the action whose async callback is still running, if any.
  int? _busyIndex;

  bool get _busy => _busyIndex != null;

  List<ConfirmAction<T>> _resolveActions(ConfirmStrings strings) {
    final custom = widget.actions;
    if (custom != null && custom.isNotEmpty) return custom;

    final confirmLabel = widget.confirmText ??
        switch ((widget.showCancel, widget.intent)) {
          (false, _) => strings.ok,
          (_, ConfirmIntent.destructive) => strings.delete,
          _ => strings.confirm,
        };

    final confirm = ConfirmAction<T>(
      label: confirmLabel,
      result: widget._defaultConfirmResult,
      onPressed: widget.onConfirm,
      intent: widget.intent == ConfirmIntent.neutral
          ? ConfirmIntent.primary
          : widget.intent,
    );

    if (!widget.showCancel) return [confirm];

    final cancel = ConfirmAction<T>.cancel(
      label: widget.cancelText ?? strings.cancel,
      result: widget._defaultCancelResult,
      onPressed: widget.onCancel,
    );

    return widget.confirmFirst ? [confirm, cancel] : [cancel, confirm];
  }

  Future<void> _handle(int index, ConfirmAction<T> action) async {
    if (_busy || !action.enabled) return;

    final callback = action.onPressed;
    if (callback == null) {
      _pop(action.result);
      return;
    }

    final outcome = callback();
    if (outcome is Future<void>) {
      setState(() => _busyIndex = index);
      try {
        await outcome;
      } finally {
        if (mounted) setState(() => _busyIndex = null);
      }
    }

    if (!mounted || !action.autoPop) return;
    _pop(action.result);
  }

  /// Closes the confirmation. No-op in [ConfirmSurface.bare], where the widget
  /// is embedded in a page and popping would dismiss that page instead.
  void _pop(T? result) {
    if (widget.surface == ConfirmSurface.bare) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final kit = ConfirmKitTheme.of(context);
    final strings = widget.strings ?? kit.strings ?? ConfirmStrings.fallback;
    final accent = kit.colorFor(widget.intent, scheme);
    final actions = _resolveActions(strings);

    final background = widget.backgroundColor ??
        kit.backgroundColor ??
        theme.dialogTheme.backgroundColor ??
        scheme.surface;
    final radius = widget.borderRadius ?? kit.borderRadius!;
    final padding = widget.contentPadding ?? kit.contentPadding!;

    final body = _buildBody(context, theme, scheme, kit, accent, actions);

    final surface = switch (widget.surface) {
      ConfirmSurface.bare => Padding(padding: padding, child: body),
      ConfirmSurface.sheet =>
        _buildSheet(context, scheme, background, radius, padding, body),
      ConfirmSurface.dialog => Dialog(
          insetPadding: kit.insetPadding!,
          backgroundColor: background,
          elevation: kit.elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: widget.maxWidth ?? kit.maxWidth!),
            child: Padding(padding: padding, child: body),
          ),
        ),
    };

    if (widget.surface == ConfirmSurface.bare) return surface;

    return PopScope(
      canPop: widget.dismissible && !_busy,
      child: surface,
    );
  }

  Widget _buildSheet(
    BuildContext context,
    ColorScheme scheme,
    Color background,
    double radius,
    EdgeInsetsGeometry padding,
    Widget body,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      ),
      // Keeps a text field in [content] above the software keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.dismissible)
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Flexible(child: Padding(padding: padding, child: body)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    ConfirmKitTheme kit,
    Color accent,
    List<ConfirmAction<T>> actions,
  ) {
    final centered = widget.alignment == ConfirmAlignment.center;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    final icon = _buildIcon(kit, accent);
    final header = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[icon, const SizedBox(height: 16)],
        Text(
          widget.title,
          textAlign: textAlign,
          style: widget.titleStyle ??
              kit.titleStyle ??
              theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.message!,
            textAlign: textAlign,
            style: widget.messageStyle ??
                kit.messageStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
        ],
        if (widget.content != null) ...[
          const SizedBox(height: 16),
          widget.content!,
        ],
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A bare confirmation may be laid out with unbounded height (inside a
        // scroll view of the host page), where Flexible is illegal.
        if (widget.surface == ConfirmSurface.bare)
          header
        else
          Flexible(child: SingleChildScrollView(child: header)),
        const SizedBox(height: 20),
        _buildActions(kit, scheme, accent, actions),
      ],
    );
  }

  Widget? _buildIcon(ConfirmKitTheme kit, Color accent) {
    if (!widget.showIcon) return null;

    final size = kit.iconSize!;
    Widget? child = widget.icon;
    if (child == null) {
      final data = widget.intent.defaultIcon;
      if (data == null) return null;
      child = Icon(data, size: size, color: accent);
    }

    final boxed = widget.iconBackground ?? kit.iconBackground!;
    if (!boxed) return child;

    return Container(
      height: size * 2,
      width: size * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: kit.iconBackgroundOpacity!),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }

  Widget _buildActions(
    ConfirmKitTheme kit,
    ColorScheme scheme,
    Color accent,
    List<ConfirmAction<T>> actions,
  ) {
    final spacing = kit.actionSpacing!;
    final stacked = switch (widget.actionsLayout) {
      ConfirmActionsLayout.column => true,
      ConfirmActionsLayout.row => false,
      ConfirmActionsLayout.auto => actions.length > 2,
    };

    final buttons = <Widget>[
      for (var i = 0; i < actions.length; i++)
        ConfirmActionButton<T>(
          action: actions[i],
          color: actions[i].intent == null
              ? accent
              : kit.colorFor(actions[i].intent!, scheme),
          height: kit.actionHeight!,
          borderRadius: kit.actionBorderRadius!,
          busy: _busyIndex == i,
          enabled: actions[i].enabled && (!_busy || _busyIndex == i),
          onPressed: () => _handle(i, actions[i]),
        ),
    ];

    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) SizedBox(height: spacing),
            buttons[i],
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: buttons[i]),
        ],
      ],
    );
  }
}
