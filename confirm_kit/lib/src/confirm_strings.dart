import 'package:flutter/foundation.dart';

/// Default button labels used when the caller does not pass explicit text.
///
/// The kit ships English defaults and does **not** own translations: pass your
/// app's localized strings once, either per-dialog (`strings:`) or app-wide via
/// `ConfirmKitTheme(strings: ...)`.
///
/// ```dart
/// ConfirmKitTheme(
///   strings: ConfirmStrings(
///     confirm: context.l10n.confirm,
///     cancel: context.l10n.cancel,
///     delete: context.l10n.delete,
///     ok: context.l10n.ok,
///   ),
/// )
/// ```
@immutable
class ConfirmStrings {
  const ConfirmStrings({
    this.confirm = 'Confirm',
    this.cancel = 'Cancel',
    this.delete = 'Delete',
    this.ok = 'OK',
  });

  /// Default confirm label for every intent except `ConfirmIntent.destructive`.
  final String confirm;

  /// Default label of the dismissing action.
  final String cancel;

  /// Default confirm label for `ConfirmIntent.destructive`.
  final String delete;

  /// Default label of the single action in an acknowledge-only dialog
  /// (`showCancel: false`).
  final String ok;

  static const ConfirmStrings fallback = ConfirmStrings();

  ConfirmStrings copyWith({
    String? confirm,
    String? cancel,
    String? delete,
    String? ok,
  }) {
    return ConfirmStrings(
      confirm: confirm ?? this.confirm,
      cancel: cancel ?? this.cancel,
      delete: delete ?? this.delete,
      ok: ok ?? this.ok,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfirmStrings &&
          other.confirm == confirm &&
          other.cancel == cancel &&
          other.delete == delete &&
          other.ok == ok;

  @override
  int get hashCode => Object.hash(confirm, cancel, delete, ok);
}
