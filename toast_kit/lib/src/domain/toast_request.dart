import 'toast_action.dart';
import 'toast_close_button_policy.dart';
import 'toast_placement.dart';
import 'toast_tone.dart';

/// Everything needed to show one toast, before the application layer
/// assigns it an id and a lifecycle.
final class ToastRequest {
  const ToastRequest({
    required this.title,
    this.message,
    this.tone = ToastTone.neutral,
    this.duration = const Duration(seconds: 4),
    this.placement,
    this.layoutKey,
    this.action,
    this.showCloseButton = ToastCloseButtonPolicy.whenSticky,
    this.dismissible = true,
    this.dedupeKey,
    this.semanticsLabel,
  });

  final String title;
  final String? message;
  final ToastTone tone;

  /// How long the toast stays visible once shown. `null` means sticky: it
  /// stays until dismissed (swipe, close button, action or
  /// [ToastHandle.dismiss]).
  final Duration? duration;

  /// `null` defers to the host's/theme's default placement.
  final ToastPlacement? placement;

  /// `null` defers to the host's/theme's default layout.
  final String? layoutKey;

  final ToastAction? action;
  final ToastCloseButtonPolicy showCloseButton;

  /// Whether swipe/tap can dismiss this toast at all.
  final bool dismissible;

  /// Explicit dedupe key. When `null`, [ToastController] dedupes on
  /// `tone|title|message` instead (see [ToastPolicy.dedupeWindow]).
  final String? dedupeKey;

  /// Overrides the label a screen reader announces; defaults to
  /// `title` + `message`.
  final String? semanticsLabel;

  /// The key [ToastPolicy] dedupes on when [dedupeKey] is not set.
  String get defaultDedupeKey => '${tone.name}|$title|${message ?? ''}';
}
