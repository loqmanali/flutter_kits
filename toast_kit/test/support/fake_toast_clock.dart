import 'package:toast_kit/toast_kit.dart';

/// A [ToastClock] a test drives by hand: [advance] runs every scheduled
/// callback whose due time has passed, in order, without any real `Timer`
/// or `Future` in play.
class FakeToastClock implements ToastClock {
  FakeToastClock([DateTime? start]) : _now = start ?? DateTime(2026);

  DateTime _now;
  final List<_Scheduled> _scheduled = [];

  @override
  DateTime now() => _now;

  @override
  ToastCancellable scheduleOnce(Duration duration, void Function() callback) {
    final entry = _Scheduled(_now.add(duration), callback);
    _scheduled.add(entry);
    return _FakeCancellable(entry);
  }

  /// Moves time forward by [duration], running (in due-time order) every
  /// callback whose time has come, without skipping any due to reentrancy.
  void advance(Duration duration) {
    _now = _now.add(duration);
    while (true) {
      final due = _scheduled
          .where((e) => !e.cancelled && !e.fired && !e.due.isAfter(_now))
          .toList()
        ..sort((a, b) => a.due.compareTo(b.due));
      if (due.isEmpty) break;
      for (final entry in due) {
        entry.fired = true;
      }
      for (final entry in due) {
        entry.callback();
      }
    }
  }
}

class _Scheduled {
  _Scheduled(this.due, this.callback);
  final DateTime due;
  final void Function() callback;
  bool cancelled = false;
  bool fired = false;
}

class _FakeCancellable implements ToastCancellable {
  _FakeCancellable(this._entry);
  final _Scheduled _entry;

  @override
  void cancel() => _entry.cancelled = true;
}
