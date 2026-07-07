import 'package:flutter/material.dart';

/// Lottie Animation Widget
///
/// A widget that displays Lottie animations.
/// Note: Requires the lottie package to be added to pubspec.yaml.
///
/// ## Examples
///
/// ```dart
/// LottieAnimationWidget(
///   asset: 'assets/animations/loading.json',
///   width: 200,
///   height: 200,
///   repeat: true,
/// )
/// ```
class LottieAnimationWidget extends StatefulWidget {
  /// Path to the Lottie JSON asset
  final String asset;

  /// Width of the animation
  final double? width;

  /// Height of the animation
  final double? height;

  /// Whether to repeat the animation
  final bool repeat;

  /// Whether to play animation in reverse
  final bool reverse;

  /// Whether to auto-play the animation
  final bool autoPlay;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  /// Animation fit
  final BoxFit fit;

  /// Creates a Lottie animation widget
  const LottieAnimationWidget({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.repeat = false,
    this.reverse = false,
    this.autoPlay = true,
    this.onComplete,
    this.fit = BoxFit.contain,
  });

  @override
  State<LottieAnimationWidget> createState() => _LottieAnimationWidgetState();
}

class _LottieAnimationWidgetState extends State<LottieAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    if (widget.autoPlay) {
      _controller.forward();
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
        if (widget.repeat) {
          _controller.reset();
          _controller.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Plays the animation
  void play() {
    _controller.forward();
  }

  /// Pauses the animation
  void pause() {
    _controller.stop();
  }

  /// Resets the animation
  void reset() {
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    // Note: This is a placeholder implementation.
    // For actual Lottie support, add the lottie package and use:
    // return Lottie.asset(
    //   widget.asset,
    //   controller: _controller,
    //   width: widget.width,
    //   height: widget.height,
    //   fit: widget.fit,
    //   repeat: widget.repeat,
    //   reverse: widget.reverse,
    // );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: const Center(
        child: Text(
          'Lottie Animation\n(Add lottie package)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
