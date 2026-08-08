// template: async-button
// description: A button that shows a spinner for the duration of an async call.
// kits: widget_kit
// output: lib/widgets/async_button.dart
//
// These files are real, analyzed source — `flutter analyze` on the docs app is
// what keeps the snippets the CLI ships from going stale. The header above is
// metadata for tool/sync_snippets.dart and is stripped before emitting.
import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

/// A button that runs [onPressed] and stays in its loading state until the
/// future completes.
///
/// AppButton ignores taps while `isLoading` is true, so there is no need to
/// null out the callback or guard against double submission yourself.
class AsyncButton extends StatefulWidget {
  const AsyncButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loadingLabel,
    this.style = AppButtonStyleType.filled,
    this.widthMode,
    this.icon,
  });

  final String label;

  /// Shown while the future is in flight. Falls back to [label].
  final String? loadingLabel;

  /// The work to run. Errors are rethrown after the loading state is cleared.
  final Future<void> Function() onPressed;

  final AppButtonStyleType style;
  final AppButtonWidthMode? widthMode;
  final Widget? icon;

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed();
    } finally {
      // The widget can be disposed mid-flight — navigating away during a save
      // is the common case — so never setState without checking.
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: _busy ? (widget.loadingLabel ?? widget.label) : widget.label,
      icon: _busy ? null : widget.icon,
      style: widget.style,
      widthMode: widget.widthMode,
      isLoading: _busy,
      onPressed: _run,
    );
  }
}
