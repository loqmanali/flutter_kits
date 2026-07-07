import 'package:flutter/material.dart';

/// Transition Type
///
/// Defines the direction and type of transition animations.
/// Used with slide and scale transition widgets to control animation direction.
///
/// ## Examples
///
/// ```dart
/// // Slide transition from left to right
/// SlideTransitionWidget(
///   type: AnimationType.slide,
///   transitionType: TransitionType.slideRight,
///   duration: Duration(milliseconds: 300),
/// )
///
/// // Fade in transition
/// FadeTransitionWidget(
///   type: AnimationType.fade,
///   transitionType: TransitionType.fadeIn,
///   duration: Duration(milliseconds: 500),
/// )
/// ```
///
/// ## Transition Categories
///
/// - **Slide Transitions**: slideLeft, slideRight, slideUp, slideDown
/// - **Fade Transitions**: fadeIn, fadeOut
/// - **Scale Transitions**: scaleIn, scaleOut
/// - **Rotation Transitions**: rotationIn, rotationOut
enum TransitionType {
  /// Slide from left to right
  ///
  /// Widget enters from the left side of the screen.
  ///
  /// Example:
  /// ```dart
  /// SlideTransitionWidget(
  ///   transitionType: TransitionType.slideRight,
  ///   duration: Duration(milliseconds: 300),
  /// )
  /// ```
  slideLeft,

  /// Slide from right to left
  ///
  /// Widget enters from the right side of the screen.
  ///
  /// Example:
  /// ```dart
  /// SlideTransitionWidget(
  ///   transitionType: TransitionType.slideLeft,
  ///   duration: Duration(milliseconds: 300),
  /// )
  /// ```
  slideRight,

  /// Slide from bottom to top
  ///
  /// Widget enters from the bottom of the screen.
  ///
  /// Example:
  /// ```dart
  /// SlideTransitionWidget(
  ///   transitionType: TransitionType.slideUp,
  ///   duration: Duration(milliseconds: 300),
  /// )
  /// ```
  slideUp,

  /// Slide from top to bottom
  ///
  /// Widget enters from the top of the screen.
  ///
  /// Example:
  /// ```dart
  /// SlideTransitionWidget(
  ///   transitionType: TransitionType.slideDown,
  ///   duration: Duration(milliseconds: 300),
  /// )
  /// ```
  slideDown,

  /// Fade in - opacity from 0 to 1
  ///
  /// Widget fades in from transparent to visible.
  ///
  /// Example:
  /// ```dart
  /// FadeTransitionWidget(
  ///   transitionType: TransitionType.fadeIn,
  ///   duration: Duration(milliseconds: 500),
  /// )
  /// ```
  fadeIn,

  /// Fade out - opacity from 1 to 0
  ///
  /// Widget fades out from visible to transparent.
  ///
  /// Example:
  /// ```dart
  /// FadeTransitionWidget(
  ///   transitionType: TransitionType.fadeOut,
  ///   duration: Duration(milliseconds: 500),
  /// )
  /// ```
  fadeOut,

  /// Scale in - size from smaller to normal
  ///
  /// Widget scales up from a smaller size to normal size.
  ///
  /// Example:
  /// ```dart
  /// ScaleTransitionWidget(
  ///   transitionType: TransitionType.scaleIn,
  ///   beginScale: 0.5,
  ///   duration: Duration(milliseconds: 400),
  /// )
  /// ```
  scaleIn,

  /// Scale out - size from normal to smaller
  ///
  /// Widget scales down from normal size to a smaller size.
  ///
  /// Example:
  /// ```dart
  /// ScaleTransitionWidget(
  ///   transitionType: TransitionType.scaleOut,
  ///   endScale: 0.5,
  ///   duration: Duration(milliseconds: 400),
  /// )
  /// ```
  scaleOut,

  /// Rotation in - rotate into view
  ///
  /// Widget rotates into view from a starting angle.
  ///
  /// Example:
  /// ```dart
  /// RotationTransitionWidget(
  ///   transitionType: TransitionType.rotationIn,
  ///   beginAngle: -0.5, // radians
  ///   duration: Duration(milliseconds: 500),
  /// )
  /// ```
  rotationIn,

  /// Rotation out - rotate out of view
  ///
  /// Widget rotates out of view to an ending angle.
  ///
  /// Example:
  /// ```dart
  /// RotationTransitionWidget(
  ///   transitionType: TransitionType.rotationOut,
  ///   endAngle: 0.5, // radians
  ///   duration: Duration(milliseconds: 500),
  /// )
  /// ```
  rotationOut,

  /// No transition - instant appearance
  ///
  /// Widget appears instantly without any animation.
  ///
  /// Example:
  /// ```dart
  /// FadeTransitionWidget(
  ///   transitionType: TransitionType.none,
  /// )
  /// ```
  none,
}

/// Extension methods for [TransitionType]
extension TransitionTypeExtension on TransitionType {
  /// Returns the offset for slide transitions
  ///
  /// Returns the starting offset based on the transition type.
  /// Used internally by slide transition widgets.
  Offset get beginOffset {
    switch (this) {
      case TransitionType.slideLeft:
        return const Offset(-1.0, 0.0);
      case TransitionType.slideRight:
        return const Offset(1.0, 0.0);
      case TransitionType.slideUp:
        return const Offset(0.0, 1.0);
      case TransitionType.slideDown:
        return const Offset(0.0, -1.0);
      case TransitionType.fadeIn:
      case TransitionType.fadeOut:
      case TransitionType.scaleIn:
      case TransitionType.scaleOut:
      case TransitionType.rotationIn:
      case TransitionType.rotationOut:
      case TransitionType.none:
        return Offset.zero;
    }
  }

  /// Returns the offset for slide transitions (end position)
  Offset get endOffset {
    switch (this) {
      case TransitionType.slideLeft:
      case TransitionType.slideRight:
      case TransitionType.slideUp:
      case TransitionType.slideDown:
        return Offset.zero;
      case TransitionType.fadeIn:
      case TransitionType.fadeOut:
      case TransitionType.scaleIn:
      case TransitionType.scaleOut:
      case TransitionType.rotationIn:
      case TransitionType.rotationOut:
      case TransitionType.none:
        return Offset.zero;
    }
  }

  /// Returns the begin scale for scale transitions
  double get beginScale {
    switch (this) {
      case TransitionType.scaleIn:
        return 0.5;
      case TransitionType.scaleOut:
        return 1.0;
      case TransitionType.slideLeft:
      case TransitionType.slideRight:
      case TransitionType.slideUp:
      case TransitionType.slideDown:
      case TransitionType.fadeIn:
      case TransitionType.fadeOut:
      case TransitionType.rotationIn:
      case TransitionType.rotationOut:
      case TransitionType.none:
        return 1.0;
    }
  }

  /// Returns the end scale for scale transitions
  double get endScale {
    switch (this) {
      case TransitionType.scaleIn:
        return 1.0;
      case TransitionType.scaleOut:
        return 0.5;
      case TransitionType.slideLeft:
      case TransitionType.slideRight:
      case TransitionType.slideUp:
      case TransitionType.slideDown:
      case TransitionType.fadeIn:
      case TransitionType.fadeOut:
      case TransitionType.rotationIn:
      case TransitionType.rotationOut:
      case TransitionType.none:
        return 1.0;
    }
  }

  /// Returns the begin opacity for fade transitions
  double get beginOpacity {
    switch (this) {
      case TransitionType.fadeIn:
        return 0.0;
      case TransitionType.fadeOut:
        return 1.0;
      case TransitionType.slideLeft:
      case TransitionType.slideRight:
      case TransitionType.slideUp:
      case TransitionType.slideDown:
      case TransitionType.scaleIn:
      case TransitionType.scaleOut:
      case TransitionType.rotationIn:
      case TransitionType.rotationOut:
      case TransitionType.none:
        return 1.0;
    }
  }

  /// Returns the end opacity for fade transitions
  double get endOpacity {
    switch (this) {
      case TransitionType.fadeIn:
        return 1.0;
      case TransitionType.fadeOut:
        return 0.0;
      case TransitionType.slideLeft:
      case TransitionType.slideRight:
      case TransitionType.slideUp:
      case TransitionType.slideDown:
      case TransitionType.scaleIn:
      case TransitionType.scaleOut:
      case TransitionType.rotationIn:
      case TransitionType.rotationOut:
      case TransitionType.none:
        return 1.0;
    }
  }

  /// Returns true if this is a slide transition
  bool get isSlide {
    switch (this) {
      case TransitionType.slideLeft:
      case TransitionType.slideRight:
      case TransitionType.slideUp:
      case TransitionType.slideDown:
        return true;
      case TransitionType.fadeIn:
      case TransitionType.fadeOut:
      case TransitionType.scaleIn:
      case TransitionType.scaleOut:
      case TransitionType.rotationIn:
      case TransitionType.rotationOut:
      case TransitionType.none:
        return false;
    }
  }

  /// Returns true if this is a fade transition
  bool get isFade {
    switch (this) {
      case TransitionType.fadeIn:
      case TransitionType.fadeOut:
        return true;
      case TransitionType.slideLeft:
      case TransitionType.slideRight:
      case TransitionType.slideUp:
      case TransitionType.slideDown:
      case TransitionType.scaleIn:
      case TransitionType.scaleOut:
      case TransitionType.rotationIn:
      case TransitionType.rotationOut:
      case TransitionType.none:
        return false;
    }
  }

  /// Returns true if this is a scale transition
  bool get isScale {
    switch (this) {
      case TransitionType.scaleIn:
      case TransitionType.scaleOut:
        return true;
      case TransitionType.slideLeft:
      case TransitionType.slideRight:
      case TransitionType.slideUp:
      case TransitionType.slideDown:
      case TransitionType.fadeIn:
      case TransitionType.fadeOut:
      case TransitionType.rotationIn:
      case TransitionType.rotationOut:
      case TransitionType.none:
        return false;
    }
  }

  /// Returns true if this is a rotation transition
  bool get isRotation {
    switch (this) {
      case TransitionType.rotationIn:
      case TransitionType.rotationOut:
        return true;
      case TransitionType.slideLeft:
      case TransitionType.slideRight:
      case TransitionType.slideUp:
      case TransitionType.slideDown:
      case TransitionType.fadeIn:
      case TransitionType.fadeOut:
      case TransitionType.scaleIn:
      case TransitionType.scaleOut:
      case TransitionType.none:
        return false;
    }
  }

  /// Returns a human-readable name for the transition type
  String get displayName {
    switch (this) {
      case TransitionType.slideLeft:
        return 'Slide Left';
      case TransitionType.slideRight:
        return 'Slide Right';
      case TransitionType.slideUp:
        return 'Slide Up';
      case TransitionType.slideDown:
        return 'Slide Down';
      case TransitionType.fadeIn:
        return 'Fade In';
      case TransitionType.fadeOut:
        return 'Fade Out';
      case TransitionType.scaleIn:
        return 'Scale In';
      case TransitionType.scaleOut:
        return 'Scale Out';
      case TransitionType.rotationIn:
        return 'Rotation In';
      case TransitionType.rotationOut:
        return 'Rotation Out';
      case TransitionType.none:
        return 'None';
    }
  }

  /// Returns the opposite transition type
  ///
  /// Useful for reversing transitions.
  TransitionType get reverse {
    switch (this) {
      case TransitionType.slideLeft:
        return TransitionType.slideRight;
      case TransitionType.slideRight:
        return TransitionType.slideLeft;
      case TransitionType.slideUp:
        return TransitionType.slideDown;
      case TransitionType.slideDown:
        return TransitionType.slideUp;
      case TransitionType.fadeIn:
        return TransitionType.fadeOut;
      case TransitionType.fadeOut:
        return TransitionType.fadeIn;
      case TransitionType.scaleIn:
        return TransitionType.scaleOut;
      case TransitionType.scaleOut:
        return TransitionType.scaleIn;
      case TransitionType.rotationIn:
        return TransitionType.rotationOut;
      case TransitionType.rotationOut:
        return TransitionType.rotationIn;
      case TransitionType.none:
        return TransitionType.none;
    }
  }
}
