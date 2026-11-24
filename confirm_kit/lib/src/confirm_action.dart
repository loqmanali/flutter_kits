import 'dart:async';

import 'package:flutter/widgets.dart';

import 'confirm_enums.dart';

/// One button in a confirmation.
///
/// [T] is what the confirmation pops when this action is pressed — `bool` for
/// the usual yes/no dialog, your own enum for a three-way choice:
///
/// ```dart
/// ConfirmDialog<SaveChoice>(
///   title: 'Unsaved changes',
///   actions: const [
///     ConfirmAction.cancel(label: 'Keep editing', result: SaveChoice.keep),
///     ConfirmAction(label: 'Discard', result: SaveChoice.discard,
///         intent: ConfirmIntent.destructive, style: ConfirmActionStyle.text),
///     ConfirmAction(label: 'Save', result: SaveChoice.save),
///   ],
/// );
/// ```
@immutable
class ConfirmAction<T> {
  const ConfirmAction({
    required this.label,
    this.result,
    this.onPressed,
    this.intent,
    this.style = ConfirmActionStyle.filled,
    this.icon,
    this.enabled = true,
    this.autoPop = true,
  });

  /// A dismissing action: outlined, neutral-colored, no callback by default.
  const ConfirmAction.cancel({
    required this.label,
    this.result,
    this.onPressed,
    this.intent = ConfirmIntent.neutral,
    this.style = ConfirmActionStyle.outlined,
    this.icon,
    this.enabled = true,
    this.autoPop = true,
  });

  /// A filled action in the destructive accent color.
  const ConfirmAction.destructive({
    required this.label,
    this.result,
    this.onPressed,
    this.intent = ConfirmIntent.destructive,
    this.style = ConfirmActionStyle.filled,
    this.icon,
    this.enabled = true,
    this.autoPop = true,
  });

  /// Button text.
  final String label;

  /// Value the confirmation pops when this action is pressed.
  final T? result;

  /// Work to run before popping. Return a `Future` and the button shows a
  /// spinner, the other actions are disabled, and the confirmation refuses to
  /// be dismissed until it settles.
  final FutureOr<void> Function()? onPressed;

  /// Accent color for this button. Defaults to the confirmation's own intent.
  final ConfirmIntent? intent;

  final ConfirmActionStyle style;

  /// Optional leading widget, e.g. `Icon(Icons.delete_outline, size: 18)`.
  final Widget? icon;

  /// `false` renders the button disabled.
  final bool enabled;

  /// Whether the confirmation pops itself once [onPressed] completes. Set
  /// `false` when the callback decides (e.g. validates a field first) — it is
  /// then responsible for closing the route.
  final bool autoPop;
}
