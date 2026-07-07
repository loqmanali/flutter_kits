import 'package:flutter/material.dart';

/// Animation Curve
///
/// Defines various animation curves available in Animation Kit.
/// Each curve represents a different easing function for animations.
///
/// ## Examples
///
/// ```dart
/// // Using animation curve with configuration
/// final config = AnimationConfig(
///   type: AnimationType.fade,
///   duration: Duration(milliseconds: 300),
///   curve: AnimationCurve.easeInOut,
/// );
/// ```
///
/// ## Curve Categories
///
/// - **Basic Curves**: linear, easeIn, easeOut, easeInOut
/// - **Bounce Curves**: bounceIn, bounceOut, bounceInOut
/// - **Elastic Curves**: elasticIn, elasticOut, elasticInOut
/// - **Material Curves**: fastOutSlowIn, material design curves
enum AnimationCurve {
  /// Linear - constant speed throughout
  ///
  /// Animation progresses at constant speed from start to finish.
  /// No acceleration or deceleration.
  ///
  /// Example:
  /// ```dart
  /// FadeTransitionWidget(
  ///   curve: AnimationCurve.linear,
  ///   duration: Duration(milliseconds: 500),
  /// )
  /// ```
  linear,

  /// Ease In - starts slow, accelerates
  ///
  /// Animation starts slowly and accelerates towards the end.
  /// Good for elements entering the screen.
  ///
  /// Example:
  /// ```dart
  /// FadeTransitionWidget(
  ///   curve: AnimationCurve.easeIn,
  ///   duration: Duration(milliseconds: 500),
  /// )
  /// ```
  easeIn,

  /// Ease Out - starts fast, decelerates
  ///
  /// Animation starts quickly and decelerates towards the end.
  /// Good for elements leaving the screen.
  ///
  /// Example:
  /// ```dart
  /// FadeTransitionWidget(
  ///   curve: AnimationCurve.easeOut,
  ///   duration: Duration(milliseconds: 500),
  /// )
  /// ```
  easeOut,

  /// Ease In Out - slow start and end, fast middle
  ///
  /// Animation starts slowly, accelerates, then decelerates at the end.
  /// Most commonly used curve for smooth animations.
  ///
  /// Example:
  /// ```dart
  /// FadeTransitionWidget(
  ///   curve: AnimationCurve.easeInOut,
  ///   duration: Duration(milliseconds: 500),
  /// )
  /// ```
  easeInOut,

  /// Fast Out Slow In - starts fast, ends slow
  ///
  /// Material design standard curve.
  /// Starts quickly and decelerates significantly at the end.
  ///
  /// Example:
  /// ```dart
  /// FadeTransitionWidget(
  ///   curve: AnimationCurve.fastOutSlowIn,
  ///   duration: Duration(milliseconds: 500),
  /// )
  /// ```
  fastOutSlowIn,

  /// Bounce In - bouncy entrance
  ///
  /// Animation overshoots the target and bounces back.
  /// Creates a playful, bouncy entrance effect.
  ///
  /// Example:
  /// ```dart
  /// ScaleTransitionWidget(
  ///   curve: AnimationCurve.bounceIn,
  ///   duration: Duration(milliseconds: 600),
  /// )
  /// ```
  bounceIn,

  /// Bounce Out - bouncy exit
  ///
  /// Animation overshoots the target and bounces back.
  /// Creates a playful, bouncy exit effect.
  ///
  /// Example:
  /// ```dart
  /// ScaleTransitionWidget(
  ///   curve: AnimationCurve.bounceOut,
  ///   duration: Duration(milliseconds: 600),
  /// )
  /// ```
  bounceOut,

  /// Elastic In - elastic entrance
  ///
  /// Animation stretches beyond the target and snaps back.
  /// Creates an elastic, spring-like entrance effect.
  ///
  /// Example:
  /// ```dart
  /// ScaleTransitionWidget(
  ///   curve: AnimationCurve.elasticIn,
  ///   duration: Duration(milliseconds: 800),
  /// )
  /// ```
  elasticIn,

  /// Elastic Out - elastic exit
  ///
  /// Animation stretches beyond the target and snaps back.
  /// Creates an elastic, spring-like exit effect.
  ///
  /// Example:
  /// ```dart
  /// ScaleTransitionWidget(
  ///   curve: AnimationCurve.elasticOut,
  ///   duration: Duration(milliseconds: 800),
  /// )
  /// ```
  elasticOut,

  /// Decelerate - starts fast, slows down
  ///
  /// Animation starts quickly and gradually slows down.
  /// Similar to easeOut but with different timing.
  ///
  /// Example:
  /// ```dart
  /// FadeTransitionWidget(
  ///   curve: AnimationCurve.decelerate,
  ///   duration: Duration(milliseconds: 500),
  /// )
  /// ```
  decelerate,

  /// Accelerate - starts slow, speeds up
  ///
  /// Animation starts slowly and gradually speeds up.
  /// Similar to easeIn but with different timing.
  ///
  /// Example:
  /// ```dart
  /// FadeTransitionWidget(
  ///   curve: AnimationCurve.accelerate,
  ///   duration: Duration(milliseconds: 500),
  /// )
  /// ```
  accelerate,
}

/// Extension methods for [AnimationCurve]
extension AnimationCurveExtension on AnimationCurve {
  /// Converts to Flutter [Curve]
  ///
  /// Returns the corresponding Flutter [Curve] for use with
  /// Flutter's animation system.
  Curve toFlutterCurve() {
    switch (this) {
      case AnimationCurve.linear:
        return Curves.linear;
      case AnimationCurve.easeIn:
        return Curves.easeIn;
      case AnimationCurve.easeOut:
        return Curves.easeOut;
      case AnimationCurve.easeInOut:
        return Curves.easeInOut;
      case AnimationCurve.fastOutSlowIn:
        return Curves.fastOutSlowIn;
      case AnimationCurve.bounceIn:
        return Curves.bounceIn;
      case AnimationCurve.bounceOut:
        return Curves.bounceOut;
      case AnimationCurve.elasticIn:
        return Curves.elasticIn;
      case AnimationCurve.elasticOut:
        return Curves.elasticOut;
      case AnimationCurve.decelerate:
        return Curves.decelerate;
      case AnimationCurve.accelerate:
        return Curves.easeIn;
    }
  }

  /// Returns true if this is a basic curve
  ///
  /// Basic curves include linear, easeIn, easeOut, easeInOut.
  bool get isBasic {
    switch (this) {
      case AnimationCurve.linear:
      case AnimationCurve.easeIn:
      case AnimationCurve.easeOut:
      case AnimationCurve.easeInOut:
        return true;
      case AnimationCurve.fastOutSlowIn:
      case AnimationCurve.bounceIn:
      case AnimationCurve.bounceOut:
      case AnimationCurve.elasticIn:
      case AnimationCurve.elasticOut:
      case AnimationCurve.decelerate:
      case AnimationCurve.accelerate:
        return false;
    }
  }

  /// Returns true if this is a bounce curve
  ///
  /// Bounce curves include bounceIn and bounceOut.
  bool get isBounce {
    switch (this) {
      case AnimationCurve.bounceIn:
      case AnimationCurve.bounceOut:
        return true;
      case AnimationCurve.linear:
      case AnimationCurve.easeIn:
      case AnimationCurve.easeOut:
      case AnimationCurve.easeInOut:
      case AnimationCurve.fastOutSlowIn:
      case AnimationCurve.elasticIn:
      case AnimationCurve.elasticOut:
      case AnimationCurve.decelerate:
      case AnimationCurve.accelerate:
        return false;
    }
  }

  /// Returns true if this is an elastic curve
  ///
  /// Elastic curves include elasticIn and elasticOut.
  bool get isElastic {
    switch (this) {
      case AnimationCurve.elasticIn:
      case AnimationCurve.elasticOut:
        return true;
      case AnimationCurve.linear:
      case AnimationCurve.easeIn:
      case AnimationCurve.easeOut:
      case AnimationCurve.easeInOut:
      case AnimationCurve.fastOutSlowIn:
      case AnimationCurve.bounceIn:
      case AnimationCurve.bounceOut:
      case AnimationCurve.decelerate:
      case AnimationCurve.accelerate:
        return false;
    }
  }

  /// Returns a human-readable name for the animation curve
  String get displayName {
    switch (this) {
      case AnimationCurve.linear:
        return 'Linear';
      case AnimationCurve.easeIn:
        return 'Ease In';
      case AnimationCurve.easeOut:
        return 'Ease Out';
      case AnimationCurve.easeInOut:
        return 'Ease In Out';
      case AnimationCurve.fastOutSlowIn:
        return 'Fast Out Slow In';
      case AnimationCurve.bounceIn:
        return 'Bounce In';
      case AnimationCurve.bounceOut:
        return 'Bounce Out';
      case AnimationCurve.elasticIn:
        return 'Elastic In';
      case AnimationCurve.elasticOut:
        return 'Elastic Out';
      case AnimationCurve.decelerate:
        return 'Decelerate';
      case AnimationCurve.accelerate:
        return 'Accelerate';
    }
  }

  /// Returns a description of the animation curve
  String get description {
    switch (this) {
      case AnimationCurve.linear:
        return 'Constant speed throughout animation';
      case AnimationCurve.easeIn:
        return 'Starts slow, accelerates towards end';
      case AnimationCurve.easeOut:
        return 'Starts fast, decelerates towards end';
      case AnimationCurve.easeInOut:
        return 'Slow start and end, fast middle';
      case AnimationCurve.fastOutSlowIn:
        return 'Material design standard curve';
      case AnimationCurve.bounceIn:
        return 'Overshoots target and bounces back (entrance)';
      case AnimationCurve.bounceOut:
        return 'Overshoots target and bounces back (exit)';
      case AnimationCurve.elasticIn:
        return 'Stretches beyond target and snaps back (entrance)';
      case AnimationCurve.elasticOut:
        return 'Stretches beyond target and snaps back (exit)';
      case AnimationCurve.decelerate:
        return 'Starts fast, gradually slows down';
      case AnimationCurve.accelerate:
        return 'Starts slow, gradually speeds up';
    }
  }
}
