import 'package:flutter/foundation.dart';

/// English defaults for every user-facing string this kit draws. The kit
/// owns no translations — pass your app's localized strings once, via
/// `ToastKitTheme(strings: ...)`.
@immutable
class ToastStrings {
  const ToastStrings({
    this.closeButtonSemanticLabel = 'Dismiss notification',
    this.liveRegionPrefix = 'Notification',
  });

  /// Semantics label read for the close (X) button.
  final String closeButtonSemanticLabel;

  /// Prefix a screen reader hears before the toast's title, so a toast
  /// reads as "Notification: <title>" rather than just the title.
  final String liveRegionPrefix;

  static const ToastStrings fallback = ToastStrings();

  ToastStrings copyWith({
    String? closeButtonSemanticLabel,
    String? liveRegionPrefix,
  }) {
    return ToastStrings(
      closeButtonSemanticLabel:
          closeButtonSemanticLabel ?? this.closeButtonSemanticLabel,
      liveRegionPrefix: liveRegionPrefix ?? this.liveRegionPrefix,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToastStrings &&
          other.closeButtonSemanticLabel == closeButtonSemanticLabel &&
          other.liveRegionPrefix == liveRegionPrefix;

  @override
  int get hashCode => Object.hash(closeButtonSemanticLabel, liveRegionPrefix);
}
