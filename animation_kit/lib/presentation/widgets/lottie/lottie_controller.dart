import 'package:flutter/material.dart';

/// Lottie Controller
///
/// A controller for managing Lottie animations.
/// Provides methods to play, pause, stop, and seek animations.
///
/// ## Examples
///
/// ```dart
/// final controller = LottieController();
///
/// // Play animation
/// controller.play();
///
/// // Pause animation
/// controller.pause();
///
/// // Seek to specific frame
/// controller.seekTo(0.5);
/// ```
class LottieController extends ChangeNotifier {
  /// The underlying animation controller
  AnimationController? _animationController;

  /// Whether the animation is currently playing
  bool _isPlaying = false;

  /// Current progress (0.0 to 1.0)
  double _progress = 0.0;

  /// Whether the animation is playing
  bool get isPlaying => _isPlaying;

  /// Current animation progress
  double get progress => _progress;

  /// Attaches an animation controller
  void attach(AnimationController controller) {
    _animationController = controller;
    _animationController?.addListener(_onAnimationUpdate);
  }

  /// Detaches the animation controller
  void detach() {
    _animationController?.removeListener(_onAnimationUpdate);
    _animationController = null;
  }

  void _onAnimationUpdate() {
    _progress = _animationController?.value ?? 0.0;
    notifyListeners();
  }

  /// Plays the animation
  void play() {
    _animationController?.forward();
    _isPlaying = true;
    notifyListeners();
  }

  /// Pauses the animation
  void pause() {
    _animationController?.stop();
    _isPlaying = false;
    notifyListeners();
  }

  /// Stops and resets the animation
  void stop() {
    _animationController?.stop();
    _animationController?.reset();
    _isPlaying = false;
    _progress = 0.0;
    notifyListeners();
  }

  /// Seeks to a specific progress value
  void seekTo(double value) {
    _animationController?.value = value.clamp(0.0, 1.0);
    _progress = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Reverses the animation
  void reverse() {
    _animationController?.reverse();
    _isPlaying = true;
    notifyListeners();
  }

  @override
  void dispose() {
    detach();
    super.dispose();
  }
}
