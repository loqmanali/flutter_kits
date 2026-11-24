import 'package:flutter/foundation.dart';

import '../models/refresh_trigger_stage.dart';
import '../widgets/refresh_trigger.dart';

/// Drives a [RefreshTrigger] programmatically and reports its state.
///
/// The controller holds no state of its own — every getter reads through to the
/// attached [RefreshTriggerState], so the widget stays the single source of
/// truth and the two can never disagree.
///
/// ```dart
/// final controller = RefreshTriggerController();
/// RefreshTrigger(controller: controller, onRefresh: load, child: list);
///
/// controller.requestRefresh();
/// controller.addListener(() => print(controller.isRefreshing));
/// ```
class RefreshTriggerController extends ChangeNotifier {
  RefreshTriggerState? _state;
  bool _disposed = false;

  /// Whether a [RefreshTrigger] is currently using this controller.
  bool get isAttached => _state != null;

  /// Current stage of the refresh operation.
  TriggerStage get refreshStage => _state?.refreshStage ?? TriggerStage.idle;

  /// Current stage of the load-more operation.
  TriggerStage get loadMoreStage => _state?.loadMoreStage ?? TriggerStage.idle;

  bool get isRefreshing => refreshStage == TriggerStage.refreshing;

  bool get isLoadingMore => loadMoreStage == TriggerStage.refreshing;

  /// Whether the attached trigger has been told there is nothing left to load.
  bool get noMoreData => _state?.noMoreData ?? false;

  /// Runs [RefreshTrigger.onRefresh] as if the user had pulled.
  Future<void> requestRefresh() async {
    if (_state != null && !isRefreshing) await _state!.refresh();
  }

  /// Runs [RefreshTrigger.onLoadMore] as if the user had pulled from the end.
  Future<void> requestLoadMore() async {
    if (_state != null && !isLoadingMore) await _state!.loadMore();
  }

  /// Ends the running refresh yourself instead of waiting for its future.
  void finishRefresh({bool success = true}) =>
      _state?.finishRefresh(success, resetNoMoreData: success);

  /// Ends the running load-more. Pass `noMoreData: true` to stop further loads
  /// until the next successful refresh.
  void finishLoadMore({bool success = true, bool noMoreData = false}) =>
      _state?.finishLoadMore(success, noMoreData);

  /// Called by [RefreshTriggerState] when it mounts. Not for app code.
  void attach(RefreshTriggerState state) => _state = state;

  /// Called by [RefreshTriggerState] when it unmounts. Not for app code.
  void detach(RefreshTriggerState state) {
    if (identical(_state, state)) _state = null;
  }

  /// Called by [RefreshTriggerState] after every stage change. Not for app code.
  void notifyStageChanged() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _state = null;
    super.dispose();
  }
}
