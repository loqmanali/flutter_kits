import 'dart:async';

import 'package:flutter/material.dart';

import 'showcase_step.dart';
import 'spotlight_navigator.dart';
import 'spotlight_widget.dart';
import 'tour_config.dart';

/// Drives the tour: holds the current step, owns the [OverlayEntry] showing the
/// spotlight, and the auto-play timer.
///
/// Created for you by `useShowcaseTour`; construct it directly only if you are
/// driving a tour outside a hook widget — in that case you must call [dispose].
class TourManager implements ISpotlightNavigator {
  TourManager(this.steps, this.overlay, this.config);

  final List<ShowcaseStep> steps;
  final OverlayState overlay;
  final TourConfig config;

  /// A target that never mounts must not spin a post-frame loop forever.
  /// ponytail: fixed frame budget, make it a config knob if a real screen
  /// takes longer than this to lay its target out.
  static const int _maxFramesWaitingForTarget = 60;

  int _index = 0;
  OverlayEntry? _entry;
  Timer? _timer;
  int _framesWaited = 0;

  /// Bumped on every close so a pending retry from a previous step cannot
  /// re-insert an overlay after the tour was ended or disposed.
  int _generation = 0;
  bool _disposed = false;

  /// Index of the step currently on screen.
  int get index => _index;

  /// Whether a spotlight is currently shown.
  bool get isRunning => _entry != null;

  /// Shows the first step. Safe to call again to restart a finished tour.
  void start() {
    if (_disposed || steps.isEmpty) return;
    _close();
    _index = 0;
    _show();
  }

  @override
  void next() {
    if (_index >= steps.length - 1) {
      _close();
      return;
    }
    _goto(_index + 1);
  }

  @override
  void prev() {
    if (_index == 0) return;
    _goto(_index - 1);
  }

  @override
  void skip() => _close();

  /// Ends the tour and releases the overlay entry and timer. Idempotent.
  void dispose() {
    _disposed = true;
    _close();
  }

  void _goto(int index) {
    _close();
    _index = index;
    _show();
  }

  void _close() {
    _generation++;
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
    _framesWaited = 0;
  }

  void _show() {
    if (_disposed) return;
    final generation = _generation;
    final context = steps[_index].key.currentContext;
    final box = context?.findRenderObject() as RenderBox?;

    if (box == null || !box.hasSize) {
      // The target is not laid out yet — a first frame, or a route still
      // animating in. Retry on the next frame, up to a bounded budget.
      if (_framesWaited++ >= _maxFramesWaitingForTarget) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (generation == _generation) _show();
      });
      return;
    }

    _framesWaited = 0;
    final entry = OverlayEntry(
      builder: (_) => SpotlightWidget(
        rect: box.localToGlobal(Offset.zero) & box.size,
        step: steps[_index],
        index: _index + 1,
        total: steps.length,
        navigator: this,
        config: config,
      ),
    );
    _entry = entry;
    overlay.insert(entry);

    if (config.auto) _timer = Timer(config.delay, next);
  }
}
