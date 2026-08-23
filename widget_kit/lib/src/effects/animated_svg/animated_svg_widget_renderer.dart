import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'animated_svg_widget_entries.dart';

// The painter is one class with ~27 independent animations. They live in
// `part` files grouped by family so no single file carries them all, while
// still sharing the class's private fields.
part 'painters/paints_basic.dart';
part 'painters/paints_reveal.dart';
part 'painters/paints_3d.dart';

class AnimatedSvgPainter extends CustomPainter {
  AnimatedSvgPainter({
    required this.progress,
    required this.vector,
    required this.strokeWidth,
    required this.style,
    required this.animateStrokeToFill,
    required this.fillStartFraction,
    required this.strokeCurve,
    required this.fillCurve,
    required this.fillDirection,
    required this.useSvgColors,
    required this.strokeColorOverride,
    required this.fillColorOverride,
    required this.animationType,
    required this.slideDirection,
    required this.staggerDelay,
    required this.shimmerColor,
    required this.glowColor,
    required this.glowRadius,
    required this.scaleFrom,
    required this.scaleTo,
    required this.rotationAngle,
    required this.flipAxis,
    required this.waveAmplitude,
    required this.waveFrequency,
    required this.elasticity,
    required this.entranceCurve,
    required this.perspective3DDistance,
    required this.rotationX,
    required this.rotationY,
    required this.rotationZ,
    required this.scale3D,
    required this.translateX,
    required this.translateY,
    required this.translateZ,
    required this.enable3DPerspective,
  }) : _t = progress % 1.0;

  final double progress;
  final double _t;
  final SvgVector vector;
  final double strokeWidth;
  final PaintingStyle style;
  final bool animateStrokeToFill;
  final double fillStartFraction;
  final Curve strokeCurve;
  final Curve fillCurve;
  final AnimatedSvgFillDirection fillDirection;
  final bool useSvgColors;
  final Color? strokeColorOverride;
  final Color? fillColorOverride;

  final AnimatedSvgAnimationType animationType;
  final AnimatedSvgSlideDirection slideDirection;
  final double staggerDelay;
  final Color? shimmerColor;
  final Color? glowColor;
  final double glowRadius;
  final double scaleFrom;
  final double scaleTo;
  final double rotationAngle;
  final Axis flipAxis;
  final double waveAmplitude;
  final double waveFrequency;
  final double elasticity;
  final Curve entranceCurve;

  final double perspective3DDistance;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final double scale3D;
  final double translateX;
  final double translateY;
  final double translateZ;
  final bool enable3DPerspective;

  @override
  void paint(Canvas canvas, Size size) {
    final viewBoxWidth = vector.viewBoxWidth;
    final viewBoxHeight = vector.viewBoxHeight;
    final scale = math.min(
      size.width / viewBoxWidth,
      size.height / viewBoxHeight,
    );

    switch (animationType) {
      case AnimatedSvgAnimationType.strokeToFill:
        _paintStrokeToFill(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.fadeIn:
        _paintFadeIn(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.scaleIn:
        _paintScaleIn(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.scaleInBounce:
        _paintScaleInBounce(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.slideIn:
        _paintSlideIn(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.typewriter:
        _paintTypewriter(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.pulse:
        _paintPulse(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.shimmer:
        _paintShimmer(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.morphIn:
        _paintMorphIn(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.staggeredPaths:
        _paintStaggeredPaths(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.glowPulse:
        _paintGlowPulse(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.elasticScale:
        _paintElasticScale(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.rotateIn:
        _paintRotateIn(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.flipIn:
        _paintFlipIn(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.waveIn:
        _paintWaveIn(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.logoReveal:
        _paintLogoReveal(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.glitchReveal:
        _paintGlitchReveal(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.fragmentAssemble:
        _paintFragmentAssemble(
            canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.splitMerge:
        _paintSplitMerge(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.rotate3D:
        _paintRotate3D(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.flip3D:
        _paintFlip3D(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.perspective3D:
        _paintPerspective3D(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.cubeRotate:
        _paintCubeRotate(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.cardFlip:
        _paintCardFlip(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.swing3D:
        _paintSwing3D(canvas, size, scale, viewBoxWidth, viewBoxHeight);
      case AnimatedSvgAnimationType.tumble3D:
        _paintTumble3D(canvas, size, scale, viewBoxWidth, viewBoxHeight);
    }
  }

  void _paintStrokeToFill(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
    canvas
      ..save()
      ..translate(
        (size.width - viewBoxWidth * scale) / 2,
        (size.height - viewBoxHeight * scale) / 2,
      )
      ..scale(scale, scale);

    final strokeProgress = _computeStrokeProgress();
    final fillProgress = _computeFillProgress();

    final shouldDrawStroke = style != PaintingStyle.fill || animateStrokeToFill;
    final shouldDrawFill = style == PaintingStyle.fill || animateStrokeToFill;

    if (shouldDrawFill && fillProgress > 0) {
      for (final info in vector.paths) {
        final color = _effectiveFillColor(info);
        if (color.a == 0) continue;
        _drawFill(canvas, info.path, color, fillProgress, viewBoxWidth,
            viewBoxHeight);
      }
    }

    if (shouldDrawStroke && strokeProgress > 0) {
      for (final info in vector.paths) {
        final color = _effectiveStrokeColor(info);
        if (color.a == 0) continue;
        _drawStroke(canvas, info.path, color, strokeProgress);
      }
    }

    canvas.restore();
  }

  Color _effectiveFillColor(SvgPath info) {
    if (!useSvgColors && fillColorOverride != null) {
      return fillColorOverride!;
    }
    if (useSvgColors && info.fillColor.a != 0) {
      return info.fillColor;
    }
    return fillColorOverride ?? info.fillColor;
  }

  Color _effectiveStrokeColor(SvgPath info) {
    if (strokeColorOverride != null) {
      return strokeColorOverride!;
    }
    if (useSvgColors && info.fillColor.a != 0) {
      return info.fillColor;
    }
    // The SVG spec's own default fill is black; an SVG that declares no
    // color gets it. Callers override with [strokeColorOverride].
    return info.fillColor == Colors.transparent
        ? const Color(0xFF000000)
        : info.fillColor;
  }

  double _computeStrokeProgress() {
    if (!animateStrokeToFill) {
      return strokeCurve.transform(_t);
    }

    if (_t <= fillStartFraction) {
      final normalized = (_t / fillStartFraction).clamp(0.0, 1.0);
      return strokeCurve.transform(normalized);
    }

    return 1.0;
  }

  double _computeFillProgress() {
    if (style == PaintingStyle.fill && !animateStrokeToFill) {
      return 1.0;
    }

    if (!animateStrokeToFill) {
      return 0.0;
    }

    final normalized =
        ((_t - fillStartFraction) / (1 - fillStartFraction)).clamp(0.0, 1.0);
    return fillCurve.transform(normalized);
  }

  void _drawStroke(Canvas canvas, Path path, Color color, double progress) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    final metrics = path.computeMetrics().toList(growable: false);
    final totalLength =
        metrics.fold<double>(0, (sum, metric) => sum + metric.length);
    final drawLength = totalLength * progress.clamp(0, 1);

    double remaining = drawLength;
    final extractPath = Path();

    for (final metric in metrics) {
      if (remaining <= 0) break;
      final segmentLength = math.min(metric.length, remaining);
      extractPath.addPath(metric.extractPath(0, segmentLength), Offset.zero);
      remaining -= segmentLength;
    }

    canvas.drawPath(extractPath, paint);
  }

  void _drawFill(Canvas canvas, Path path, Color color, double progress,
      double viewBoxWidth, double viewBoxHeight) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    canvas.save();
    canvas
        .clipRect(_clipRectForProgress(progress, viewBoxWidth, viewBoxHeight));
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  Rect _clipRectForProgress(
      double progress, double viewBoxWidth, double viewBoxHeight) {
    final clamped = progress.clamp(0.0, 1.0);
    switch (fillDirection) {
      case AnimatedSvgFillDirection.bottomToTop:
        final startY = viewBoxHeight * (1 - clamped);
        return Rect.fromLTWH(0, startY, viewBoxWidth, viewBoxHeight - startY);
      case AnimatedSvgFillDirection.topToBottom:
        final extentY = viewBoxHeight * clamped;
        return Rect.fromLTWH(0, 0, viewBoxWidth, extentY);
      case AnimatedSvgFillDirection.leftToRight:
        final extentX = viewBoxWidth * clamped;
        return Rect.fromLTWH(0, 0, extentX, viewBoxHeight);
      case AnimatedSvgFillDirection.rightToLeft:
        final startX = viewBoxWidth * (1 - clamped);
        return Rect.fromLTWH(startX, 0, viewBoxWidth - startX, viewBoxHeight);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedSvgPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.vector != vector ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.style != style ||
        oldDelegate.animateStrokeToFill != animateStrokeToFill ||
        oldDelegate.fillStartFraction != fillStartFraction ||
        oldDelegate.strokeCurve != strokeCurve ||
        oldDelegate.fillCurve != fillCurve ||
        oldDelegate.fillDirection != fillDirection ||
        oldDelegate.useSvgColors != useSvgColors ||
        oldDelegate.strokeColorOverride != strokeColorOverride ||
        oldDelegate.fillColorOverride != fillColorOverride ||
        oldDelegate.animationType != animationType ||
        oldDelegate.slideDirection != slideDirection ||
        oldDelegate.staggerDelay != staggerDelay ||
        oldDelegate.shimmerColor != shimmerColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.glowRadius != glowRadius ||
        oldDelegate.scaleFrom != scaleFrom ||
        oldDelegate.scaleTo != scaleTo ||
        oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.flipAxis != flipAxis ||
        oldDelegate.waveAmplitude != waveAmplitude ||
        oldDelegate.waveFrequency != waveFrequency ||
        oldDelegate.elasticity != elasticity ||
        oldDelegate.entranceCurve != entranceCurve ||
        oldDelegate.perspective3DDistance != perspective3DDistance ||
        oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY ||
        oldDelegate.rotationZ != rotationZ ||
        oldDelegate.scale3D != scale3D ||
        oldDelegate.translateX != translateX ||
        oldDelegate.translateY != translateY ||
        oldDelegate.translateZ != translateZ ||
        oldDelegate.enable3DPerspective != enable3DPerspective;
  }
}
