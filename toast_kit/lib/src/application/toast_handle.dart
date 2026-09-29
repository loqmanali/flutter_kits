import 'dart:async';

import '../domain/toast_dismiss_reason.dart';
import 'toast_controller.dart';

/// What [ToastController.show] returns — mirrors the framework's
/// `ScaffoldFeatureController` (`closed` future, `close()`/here `dismiss()`).
final class ToastHandle {
  ToastHandle({
    required int id,
    required ToastController controller,
    required Completer<ToastDismissReason> completer,
  })  : _id = id,
        _controller = controller,
        _completer = completer;

  final int _id;
  final ToastController _controller;
  final Completer<ToastDismissReason> _completer;

  /// Completes once the toast is gone, with why.
  Future<ToastDismissReason> get closed => _completer.future;

  /// Dismisses the toast (or, if it is still queued, removes it before it
  /// is ever shown).
  void dismiss() => _controller.dismiss(_id);
}
