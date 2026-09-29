import 'dart:async';

/// A cancellable unit of scheduled work, returned by [ToastClock.scheduleOnce].
abstract interface class ToastCancellable {
  void cancel();
}

/// The kit's only source of "now" and "later", so tests can fake time
/// instead of racing real `Timer`s (mirrors how the framework isolates
/// `Timer`-driven state behind an abstraction for testability).
abstract interface class ToastClock {
  DateTime now();

  /// Runs [callback] once, after [duration]. Cancelling the returned
  /// [ToastCancellable] before it fires prevents the call.
  ToastCancellable scheduleOnce(Duration duration, void Function() callback);
}

/// The real clock, backed by `dart:async`'s [Timer].
final class SystemToastClock implements ToastClock {
  const SystemToastClock();

  @override
  DateTime now() => DateTime.now();

  @override
  ToastCancellable scheduleOnce(Duration duration, void Function() callback) {
    final timer = Timer(duration, callback);
    return _TimerCancellable(timer);
  }
}

final class _TimerCancellable implements ToastCancellable {
  _TimerCancellable(this._timer);
  final Timer _timer;

  @override
  void cancel() => _timer.cancel();
}
