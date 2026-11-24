import 'package:flutter/widgets.dart';

import '../domain/toast_action.dart';
import '../domain/toast_request.dart';
import '../domain/toast_tone.dart';
import 'toast_strings.dart';

/// Everything a [ToastLayout] needs to paint one toast: the resolved
/// request, colors already picked for its tone, a remaining-time animation
/// and the callbacks its chrome should invoke.
@immutable
final class ToastView {
  const ToastView({
    required this.request,
    required this.tone,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.titleStyle,
    required this.messageStyle,
    required this.progress,
    required this.showCloseButton,
    required this.maxTitleLines,
    required this.maxMessageLines,
    required this.strings,
    this.onClose,
    this.onAction,
  });

  final ToastRequest request;
  final ToastTone tone;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final Color iconColor;
  final TextStyle titleStyle;
  final TextStyle messageStyle;

  /// `1.0` at show time, `0.0` at timeout. Static (`kAlwaysCompleteAnimation`
  /// or similar) for a sticky toast, previews, and anywhere no host is
  /// running the real countdown.
  final Animation<double> progress;

  final bool showCloseButton;
  final int maxTitleLines;
  final int maxMessageLines;
  final ToastStrings strings;

  final VoidCallback? onClose;
  final VoidCallback? onAction;

  ToastAction? get action => request.action;
}

/// One drawing of a toast. Built-ins are `flat`, `filled`, `outlined`,
/// `minimal` and `banner`; register a custom one on
/// `ToastKitTheme.layouts`.
abstract interface class ToastLayout {
  Widget build(BuildContext context, ToastView view);
}
