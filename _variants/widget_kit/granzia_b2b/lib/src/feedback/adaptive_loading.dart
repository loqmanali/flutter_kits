import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// {@template loading_indicator}
/// A highly customizable, platform-aware loading indicator that supports multiple animation styles.
///
/// This widget provides a unified interface for displaying loading states across your application,
/// with support for both platform-specific indicators and custom animations.
///
/// Features:
/// * Platform adaptation for iOS and Android
/// * 30+ animation styles from SpinKit
/// * Customizable colors and dimensions
/// * Automatic theme integration
///
/// Example usage:
/// ```dart
/// LoadingIndicator(
///   type: LoadingIndicatorType.adaptive,
///   color: Colors.blue,
///   size: 24.0,
/// )
/// ```
/// {@endtemplate}
class LoadingIndicator extends StatelessWidget {
  /// {@template loading_indicator_constructor}
  /// Creates a loading indicator with the specified configuration.
  ///
  /// Parameters:
  /// * [type] - The style of loading animation to display
  /// * [color] - The color of the indicator (defaults to theme's primary color)
  /// * [size] - The size of the indicator (defaults to 20.0)
  /// * [strokeWidth] - The thickness of the indicator where applicable (defaults to 4.0)
  /// {@endtemplate}
  const LoadingIndicator({
    super.key,
    this.type = LoadingIndicatorType.fadingCircle,
    this.color,
    this.size,
    this.strokeWidth,
  });

  /// The type of loading indicator to display
  final LoadingIndicatorType type;

  /// The color of the loading indicator
  final Color? color;

  /// The size of the loading indicator
  final double? size;

  /// The stroke width/thickness of the loading indicator
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingIndicatorBuilder(
        type: type,
        color: color,
        size: size,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

/// Defines the available types of loading indicators
enum LoadingIndicatorType {
  /// Standard circular progress indicator
  circular,

  /// Standard linear progress indicator
  linear,

  /// Platform-adaptive indicator
  /// Shows CupertinoActivityIndicator on iOS and CircularProgressIndicator on other platforms
  adaptive,

  /// A rotating plain animation
  rotatingPlain,

  /// A double bouncing animation
  doubleBounce,

  /// A wave animation
  wave,

  /// Wandering cubes animation
  wanderingCubes,

  /// Four fading dots animation
  fadingFour,

  /// A fading cube animation
  fadingCube,

  /// A pulsing dot animation
  pulse,

  /// Chasing dots animation
  chasingDots,

  /// Three bouncing dots animation
  threeBounce,

  /// Circular dots animation
  circle,

  /// Grid of cubes animation
  cubeGrid,

  /// Fading circle animation
  fadingCircle,

  /// Rotating circle animation
  rotatingCircle,

  /// Folding cube animation
  foldingCube,

  /// Pumping heart animation
  pumpingHeart,

  /// Hour glass animation
  hourGlass,

  /// Pouring hour glass animation
  pouringHourGlass,

  /// Refined pouring hour glass animation
  pouringHourGlassRefined,

  /// Fading grid animation
  fadingGrid,

  /// Ring animation
  ring,

  /// Ripple animation
  ripple,

  /// Spinning circle animation
  spinningCircle,

  /// Spinning lines animation
  spinningLines,

  /// Square circle animation
  squareCircle,

  /// Dual ring animation
  dualRing,

  /// Piano wave animation
  pianoWave,

  /// Dancing square animation
  dancingSquare,

  /// Three in-out animation
  threeInOut,

  /// Wave spinner animation
  waveSpinner,

  /// Pulsing grid animation
  pulsingGrid,
}

/// A builder widget that constructs the appropriate loading indicator
/// based on the specified type and configuration.
class LoadingIndicatorBuilder extends StatelessWidget {
  /// Creates a loading indicator builder.
  const LoadingIndicatorBuilder({
    super.key,
    required this.type,
    this.color,
    this.size,
    this.strokeWidth,
  });

  /// The type of loading indicator to display
  final LoadingIndicatorType type;

  /// The color of the loading indicator
  final Color? color;

  /// The size of the loading indicator
  final double? size;

  /// The stroke width/thickness of the loading indicator
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = color ?? theme.colorScheme.primary;
    final defaultSize = size ?? 30.0;

    return _buildIndicator(
      context,
      defaultColor,
      defaultSize,
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    Color color,
    double size,
  ) {
    switch (type) {
      case LoadingIndicatorType.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: color,
            strokeWidth: strokeWidth ?? 4.0,
          ),
        );

      case LoadingIndicatorType.linear:
        return SizedBox(
          width: size,
          child: LinearProgressIndicator(
            color: color,
            minHeight: strokeWidth ?? 4.0,
          ),
        );

      case LoadingIndicatorType.adaptive:
        return Theme.of(context).platform == TargetPlatform.iOS
            ? CupertinoActivityIndicator(
                color: color,
                radius: size / 2,
              )
            : SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  color: color,
                  strokeWidth: strokeWidth ?? 4.0,
                ),
              );

      case LoadingIndicatorType.rotatingPlain:
        return SpinKitRotatingPlain(color: color, size: size);
      case LoadingIndicatorType.doubleBounce:
        return SpinKitDoubleBounce(color: color, size: size);
      case LoadingIndicatorType.wave:
        return SpinKitWave(color: color, size: size);
      case LoadingIndicatorType.wanderingCubes:
        return SpinKitWanderingCubes(color: color, size: size);
      case LoadingIndicatorType.fadingFour:
        return SpinKitFadingFour(color: color, size: size);
      case LoadingIndicatorType.fadingCube:
        return SpinKitFadingCube(color: color, size: size);
      case LoadingIndicatorType.pulse:
        return SpinKitPulse(color: color, size: size);
      case LoadingIndicatorType.chasingDots:
        return SpinKitChasingDots(color: color, size: size);
      case LoadingIndicatorType.threeBounce:
        return SpinKitThreeBounce(color: color, size: size);
      case LoadingIndicatorType.circle:
        return SpinKitCircle(color: color, size: size);
      case LoadingIndicatorType.cubeGrid:
        return SpinKitCubeGrid(color: color, size: size);
      case LoadingIndicatorType.fadingCircle:
        return SpinKitFadingCircle(color: color, size: size);
      case LoadingIndicatorType.rotatingCircle:
        return SpinKitRotatingCircle(color: color, size: size);
      case LoadingIndicatorType.foldingCube:
        return SpinKitFoldingCube(color: color, size: size);
      case LoadingIndicatorType.pumpingHeart:
        return SpinKitPumpingHeart(color: color, size: size);
      case LoadingIndicatorType.hourGlass:
        return SpinKitHourGlass(color: color, size: size);
      case LoadingIndicatorType.pouringHourGlass:
        return SpinKitPouringHourGlass(color: color, size: size);
      case LoadingIndicatorType.pouringHourGlassRefined:
        return SpinKitPouringHourGlassRefined(color: color, size: size);
      case LoadingIndicatorType.fadingGrid:
        return SpinKitFadingGrid(color: color, size: size);
      case LoadingIndicatorType.ring:
        return SpinKitRing(color: color, size: size);
      case LoadingIndicatorType.ripple:
        return SpinKitRipple(color: color, size: size);
      case LoadingIndicatorType.spinningCircle:
        return SpinKitSpinningCircle(color: color, size: size);
      case LoadingIndicatorType.spinningLines:
        return SpinKitSpinningLines(color: color, size: size);
      case LoadingIndicatorType.squareCircle:
        return SpinKitSquareCircle(color: color, size: size);
      case LoadingIndicatorType.dualRing:
        return SpinKitDualRing(color: color, size: size);
      case LoadingIndicatorType.pianoWave:
        return SpinKitPianoWave(color: color, size: size);
      case LoadingIndicatorType.dancingSquare:
        return SpinKitDancingSquare(color: color, size: size);
      case LoadingIndicatorType.threeInOut:
        return SpinKitThreeInOut(color: color, size: size);
      case LoadingIndicatorType.waveSpinner:
        return SpinKitWaveSpinner(color: color, size: size);
      case LoadingIndicatorType.pulsingGrid:
        return SpinKitPulsingGrid(color: color, size: size);
    }
  }
}
