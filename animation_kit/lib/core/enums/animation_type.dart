/// Animation Type
///
/// Defines the various types of animations available in the Animation Kit.
/// Each type represents a different animation behavior that can be applied to widgets.
///
/// ## Examples
///
/// ```dart
/// // Using animation type with configuration
/// final config = AnimationConfig(
///   type: AnimationType.fade,
///   duration: Duration(milliseconds: 300),
///   curve: AnimationCurve.easeInOut,
/// );
/// ```
///
/// ## Animation Types
///
/// - **fade**: Opacity transition from 0 to 1 or vice versa
/// - **slide**: Position transition (left, right, up, down)
/// - **scale**: Size transition from one scale to another
/// - **rotation**: Rotation angle transition
/// - **pulse**: Continuous scale up and down
/// - **shake**: Horizontal shaking motion
/// - **bounce**: Bouncing effect
/// - **heartbeat**: Heartbeat-like pulsing
/// - **lottie**: Lottie JSON animation
/// - **custom**: User-defined custom animation
enum AnimationType {
  /// Fade animation - opacity transition
  ///
  /// Transitions the widget's opacity from 0 to 1 (in) or 1 to 0 (out).
  ///
  /// Example:
  /// ```dart
  /// FadeTransitionWidget(
  ///   type: AnimationType.fade,
  ///   duration: Duration(milliseconds: 300),
  /// )
  /// ```
  fade,

  /// Slide animation - position transition
  ///
  /// Moves the widget from one position to another.
  /// Direction is controlled by [TransitionType].
  ///
  /// Example:
  /// ```dart
  /// SlideTransitionWidget(
  ///   type: AnimationType.slide,
  ///   direction: TransitionType.slideRight,
  ///   duration: Duration(milliseconds: 300),
  /// )
  /// ```
  slide,

  /// Scale animation - size transition
  ///
  /// Scales the widget from one size to another.
  ///
  /// Example:
  /// ```dart
  /// ScaleTransitionWidget(
  ///   type: AnimationType.scale,
  ///   beginScale: 0.5,
  ///   endScale: 1.0,
  ///   duration: Duration(milliseconds: 400),
  /// )
  /// ```
  scale,

  /// Rotation animation - angle transition
  ///
  /// Rotates the widget from one angle to another.
  ///
  /// Example:
  /// ```dart
  /// RotationTransitionWidget(
  ///   type: AnimationType.rotation,
  ///   beginAngle: 0,
  ///   endAngle: 360,
  ///   duration: Duration(seconds: 1),
  /// )
  /// ```
  rotation,

  /// Pulse animation - continuous scale effect
  ///
  /// Continuously scales the widget up and down.
  /// Useful for attention-grabbing elements like notifications or favorite icons.
  ///
  /// Example:
  /// ```dart
  /// PulseWidget(
  ///   child: Icon(Icons.notifications),
  ///   duration: Duration(seconds: 1),
  ///   minScale: 0.9,
  ///   maxScale: 1.1,
  /// )
  /// ```
  pulse,

  /// Shake animation - horizontal shaking motion
  ///
  /// Shakes the widget horizontally.
  /// Commonly used for error states or validation feedback.
  ///
  /// Example:
  /// ```dart
  /// ShakeWidget(
  ///   child: TextField(...),
  ///   trigger: hasError,
  ///   duration: Duration(milliseconds: 500),
  /// )
  /// ```
  shake,

  /// Bounce animation - bouncing effect
  ///
  /// Creates a bouncing effect on the widget.
  /// Useful for buttons and interactive elements.
  ///
  /// Example:
  /// ```dart
  /// BounceWidget(
  ///   child: ElevatedButton(...),
  ///   onTap: () {},
  /// )
  /// ```
  bounce,

  /// Heartbeat animation - heart-like pulsing
  ///
  /// Creates a heartbeat-like pulsing effect.
  /// Perfect for favorite icons or like buttons.
  ///
  /// Example:
  /// ```dart
  /// HeartbeatWidget(
  ///   child: Icon(Icons.favorite),
  ///   duration: Duration(milliseconds: 800),
  /// )
  /// ```
  heartbeat,

  /// Lottie animation - JSON-based animation
  ///
  /// Plays Lottie JSON animations.
  /// Supports complex, frame-by-frame animations from Lottie files.
  ///
  /// Example:
  /// ```dart
  /// LottieAnimationWidget(
  ///   asset: 'assets/animations/success.json',
  ///   width: 200,
  ///   height: 200,
  ///   repeat: false,
  /// )
  /// ```
  lottie,

  /// Custom animation - user-defined
  ///
  /// Allows for custom animation implementations.
  /// Use this when none of the built-in types fit your needs.
  ///
  /// Example:
  /// ```dart
  /// CustomAnimationWidget(
  ///   builder: (context, animation) {
  ///     return Transform.rotate(
  ///       angle: animation.value * 2 * pi,
  ///       child: child,
  ///     );
  ///   },
  /// )
  /// ```
  custom,
}

/// Extension methods for [AnimationType]
extension AnimationTypeExtension on AnimationType {
  /// Returns true if this is a transition animation
  ///
  /// Transition animations are used for page transitions and entering/leaving widgets.
  bool get isTransition {
    switch (this) {
      case AnimationType.fade:
      case AnimationType.slide:
      case AnimationType.scale:
      case AnimationType.rotation:
        return true;
      case AnimationType.pulse:
      case AnimationType.shake:
      case AnimationType.bounce:
      case AnimationType.heartbeat:
      case AnimationType.lottie:
      case AnimationType.custom:
        return false;
    }
  }

  /// Returns true if this is a micro animation
  ///
  /// Micro animations are small, attention-grabbing effects.
  bool get isMicroAnimation {
    switch (this) {
      case AnimationType.pulse:
      case AnimationType.shake:
      case AnimationType.bounce:
      case AnimationType.heartbeat:
        return true;
      case AnimationType.fade:
      case AnimationType.slide:
      case AnimationType.scale:
      case AnimationType.rotation:
      case AnimationType.lottie:
      case AnimationType.custom:
        return false;
    }
  }

  /// Returns true if this animation supports repetition
  ///
  /// Some animations like pulse and heartbeat are designed to repeat.
  bool get supportsRepetition {
    switch (this) {
      case AnimationType.pulse:
      case AnimationType.heartbeat:
        return true;
      case AnimationType.fade:
      case AnimationType.slide:
      case AnimationType.scale:
      case AnimationType.rotation:
      case AnimationType.shake:
      case AnimationType.bounce:
      case AnimationType.lottie:
      case AnimationType.custom:
        return false;
    }
  }

  /// Returns a human-readable name for the animation type
  String get displayName {
    switch (this) {
      case AnimationType.fade:
        return 'Fade';
      case AnimationType.slide:
        return 'Slide';
      case AnimationType.scale:
        return 'Scale';
      case AnimationType.rotation:
        return 'Rotation';
      case AnimationType.pulse:
        return 'Pulse';
      case AnimationType.shake:
        return 'Shake';
      case AnimationType.bounce:
        return 'Bounce';
      case AnimationType.heartbeat:
        return 'Heartbeat';
      case AnimationType.lottie:
        return 'Lottie';
      case AnimationType.custom:
        return 'Custom';
    }
  }

  /// Returns a description of the animation type
  String get description {
    switch (this) {
      case AnimationType.fade:
        return 'Opacity transition from 0 to 1 or vice versa';
      case AnimationType.slide:
        return 'Position transition in any direction';
      case AnimationType.scale:
        return 'Size transition from one scale to another';
      case AnimationType.rotation:
        return 'Rotation angle transition';
      case AnimationType.pulse:
        return 'Continuous scale up and down effect';
      case AnimationType.shake:
        return 'Horizontal shaking motion';
      case AnimationType.bounce:
        return 'Bouncing effect';
      case AnimationType.heartbeat:
        return 'Heartbeat-like pulsing effect';
      case AnimationType.lottie:
        return 'JSON-based Lottie animation';
      case AnimationType.custom:
        return 'User-defined custom animation';
    }
  }
}
