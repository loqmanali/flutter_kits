import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports whether the device currently has a network connection, as a stream
/// the sync engine listens to so it can flush the moment connectivity returns.
///
/// This is an interface so the engine never hard-depends on `connectivity_plus`:
/// tests use [ManualConnectivityMonitor], and an app that already tracks
/// connectivity elsewhere can adapt its own signal via [StreamConnectivityMonitor].
abstract interface class ConnectivityMonitor {
  /// `true` when online, `false` when offline. Should emit the current value on
  /// listen and then every change. Implementations should de-duplicate so it
  /// only emits on actual transitions.
  Stream<bool> get onlineChanges;

  /// A one-shot check of the current state.
  Future<bool> get isOnline;

  /// Releases any resources (platform subscriptions, controllers).
  Future<void> dispose();
}

/// Default [ConnectivityMonitor] backed by `connectivity_plus`.
///
/// "Online" means at least one active transport that isn't
/// [ConnectivityResult.none]. Note this reflects *transport* availability, not
/// reachability of your server — a captive portal or dead backend still reads as
/// online. The sync engine treats a failed push/pull as a retry, so this is the
/// right, cheap signal to *trigger* a sync attempt.
class ConnectivityPlusMonitor implements ConnectivityMonitor {
  ConnectivityPlusMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  Stream<bool> get onlineChanges =>
      _connectivity.onConnectivityChanged.map(_isOnline).distinct();

  @override
  Future<bool> get isOnline async =>
      _isOnline(await _connectivity.checkConnectivity());

  @override
  Future<void> dispose() async {}
}

/// A [ConnectivityMonitor] driven by an external `Stream<bool>` — for apps that
/// already compute connectivity (e.g. by pinging their own health endpoint) and
/// want the sync engine to use that instead.
class StreamConnectivityMonitor implements ConnectivityMonitor {
  StreamConnectivityMonitor(Stream<bool> source, {bool initial = false})
      : _initial = initial {
    _sub = source.listen((value) {
      _latest = value;
      _controller.add(value);
    });
  }

  final bool _initial;
  late final StreamSubscription<bool> _sub;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool? _latest;

  @override
  Stream<bool> get onlineChanges async* {
    yield _latest ?? _initial;
    yield* _controller.stream.distinct();
  }

  @override
  Future<bool> get isOnline async => _latest ?? _initial;

  @override
  Future<void> dispose() async {
    await _sub.cancel();
    await _controller.close();
  }
}

/// A test/manual [ConnectivityMonitor] you push values into. Lets tests simulate
/// going offline and back online deterministically.
class ManualConnectivityMonitor implements ConnectivityMonitor {
  ManualConnectivityMonitor({bool initial = true}) : _latest = initial {
    _controller.add(initial);
  }

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _latest;

  /// Simulate a connectivity transition.
  void set(bool online) {
    _latest = online;
    _controller.add(online);
  }

  @override
  Stream<bool> get onlineChanges async* {
    yield _latest;
    yield* _controller.stream.distinct();
  }

  @override
  Future<bool> get isOnline async => _latest;

  @override
  Future<void> dispose() async => _controller.close();
}
