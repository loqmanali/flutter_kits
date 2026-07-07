import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'animated_svg_widget_entries.dart';

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
        _paintFragmentAssemble(canvas, size, scale, viewBoxWidth, viewBoxHeight);
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

  void _paintStrokeToFill(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
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
        _drawFill(canvas, info.path, color, fillProgress, viewBoxWidth, viewBoxHeight);
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

  void _paintFadeIn(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final opacity = entranceCurve.transform(_t).clamp(0.0, 1.0);

    canvas
      ..save()
      ..translate(
        (size.width - viewBoxWidth * scale) / 2,
        (size.height - viewBoxHeight * scale) / 2,
      )
      ..scale(scale, scale);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info).withValues(alpha: opacity);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintScaleIn(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final scaleValue = scaleFrom + (scaleTo - scaleFrom) * curvedT;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scaleValue * scale, scaleValue * scale);
    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintScaleInBounce(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final curvedT = Curves.elasticOut.transform(_t);
    final scaleValue = scaleFrom + (scaleTo - scaleFrom) * curvedT;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scaleValue * scale, scaleValue * scale);
    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintSlideIn(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    double offsetX = 0;
    double offsetY = 0;

    switch (slideDirection) {
      case AnimatedSvgSlideDirection.fromLeft:
        offsetX = -size.width * (1 - curvedT);
      case AnimatedSvgSlideDirection.fromRight:
        offsetX = size.width * (1 - curvedT);
      case AnimatedSvgSlideDirection.fromTop:
        offsetY = -size.height * (1 - curvedT);
      case AnimatedSvgSlideDirection.fromBottom:
        offsetY = size.height * (1 - curvedT);
    }

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.translate(
      (size.width - viewBoxWidth * scale) / 2,
      (size.height - viewBoxHeight * scale) / 2,
    );
    canvas.scale(scale, scale);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintTypewriter(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    canvas
      ..save()
      ..translate(
        (size.width - viewBoxWidth * scale) / 2,
        (size.height - viewBoxHeight * scale) / 2,
      )
      ..scale(scale, scale);

    final pathCount = vector.paths.length;
    for (int i = 0; i < pathCount; i++) {
      final pathStartTime = i * staggerDelay;
      final pathEndTime = pathStartTime + (1 - staggerDelay * (pathCount - 1));
      final pathProgress = ((_t - pathStartTime) / (pathEndTime - pathStartTime)).clamp(0.0, 1.0);

      if (pathProgress > 0) {
        final info = vector.paths[i];
        final color = _effectiveFillColor(info);
        _drawStroke(canvas, info.path, color, pathProgress);
      }
    }

    canvas.restore();
  }

  void _paintPulse(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final pulseValue = 1.0 + 0.1 * math.sin(_t * 2 * math.pi);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(pulseValue * scale, pulseValue * scale);
    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintShimmer(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    canvas
      ..save()
      ..translate(
        (size.width - viewBoxWidth * scale) / 2,
        (size.height - viewBoxHeight * scale) / 2,
      )
      ..scale(scale, scale);

    for (final info in vector.paths) {
      final baseColor = _effectiveFillColor(info);
      final effectiveShimmerColor = shimmerColor ?? Colors.white;

      final shimmerPosition = _t * 2 - 0.5;
      final gradient = ui.Gradient.linear(
        Offset(viewBoxWidth * shimmerPosition, 0),
        Offset(viewBoxWidth * (shimmerPosition + 0.5), viewBoxHeight),
        [baseColor, Color.lerp(baseColor, effectiveShimmerColor, 0.5)!, baseColor],
        [0.0, 0.5, 1.0],
      );

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = gradient;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintMorphIn(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final morphScale = curvedT;
    final opacity = curvedT;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(morphScale * scale, morphScale * scale);
    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info).withValues(alpha: opacity);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintStaggeredPaths(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    canvas
      ..save()
      ..translate(
        (size.width - viewBoxWidth * scale) / 2,
        (size.height - viewBoxHeight * scale) / 2,
      )
      ..scale(scale, scale);

    final pathCount = vector.paths.length;
    for (int i = 0; i < pathCount; i++) {
      final pathDelay = i * staggerDelay;
      final pathProgress = ((_t - pathDelay) / (1 - pathDelay)).clamp(0.0, 1.0);
      final curvedProgress = entranceCurve.transform(pathProgress);

      if (curvedProgress > 0) {
        final info = vector.paths[i];
        final color = _effectiveFillColor(info).withValues(alpha: curvedProgress);
        final paint = Paint()
          ..style = PaintingStyle.fill
          ..color = color;

        canvas.save();
        final bounds = info.path.getBounds();
        final centerX = bounds.center.dx;
        final centerY = bounds.center.dy;
        canvas.translate(centerX, centerY);
        canvas.scale(curvedProgress, curvedProgress);
        canvas.translate(-centerX, -centerY);
        canvas.drawPath(info.path, paint);
        canvas.restore();
      }
    }

    canvas.restore();
  }

  void _paintGlowPulse(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final glowIntensity = 0.5 + 0.5 * math.sin(_t * 2 * math.pi);
    final effectiveGlowColor = glowColor ?? Colors.white;

    canvas
      ..save()
      ..translate(
        (size.width - viewBoxWidth * scale) / 2,
        (size.height - viewBoxHeight * scale) / 2,
      )
      ..scale(scale, scale);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info);

      final glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = effectiveGlowColor.withValues(alpha: glowIntensity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius * glowIntensity);
      canvas.drawPath(info.path, glowPaint);

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintElasticScale(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final elasticT = _elasticOut(_t, elasticity);
    final scaleValue = scaleFrom + (scaleTo - scaleFrom) * elasticT;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scaleValue * scale, scaleValue * scale);
    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  double _elasticOut(double t, double elasticity) {
    if (t == 0 || t == 1) return t;
    final p = 0.3 + elasticity * 0.4;
    final s = p / 4;
    return math.pow(2, -10 * t) * math.sin((t - s) * (2 * math.pi) / p) + 1;
  }

  void _paintRotateIn(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final rotation = rotationAngle * (1 - curvedT);
    final opacity = curvedT;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.scale(scale, scale);
    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info).withValues(alpha: opacity);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintFlipIn(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final flipAngle = math.pi * (1 - curvedT);
    final scaleX = flipAxis == Axis.horizontal ? math.cos(flipAngle).abs() : 1.0;
    final scaleY = flipAxis == Axis.vertical ? math.cos(flipAngle).abs() : 1.0;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scaleX * scale, scaleY * scale);
    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintWaveIn(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    canvas
      ..save()
      ..translate(
        (size.width - viewBoxWidth * scale) / 2,
        (size.height - viewBoxHeight * scale) / 2,
      )
      ..scale(scale, scale);

    final pathCount = vector.paths.length;
    for (int i = 0; i < pathCount; i++) {
      final waveOffset = math.sin((_t * waveFrequency * math.pi) + (i * 0.5)) * waveAmplitude * (1 - _t);
      final pathProgress = entranceCurve.transform(
        ((_t - i * staggerDelay) / (1 - staggerDelay * (pathCount - 1))).clamp(0.0, 1.0),
      );

      if (pathProgress > 0) {
        final info = vector.paths[i];
        final color = _effectiveFillColor(info).withValues(alpha: pathProgress);
        final paint = Paint()
          ..style = PaintingStyle.fill
          ..color = color;

        canvas.save();
        canvas.translate(0, waveOffset);
        canvas.drawPath(info.path, paint);
        canvas.restore();
      }
    }

    canvas.restore();
  }

  void _paintLogoReveal(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    canvas
      ..save()
      ..translate(
        (size.width - viewBoxWidth * scale) / 2,
        (size.height - viewBoxHeight * scale) / 2,
      )
      ..scale(scale, scale);

    const phase1End = 0.3;
    const phase2End = 0.7;
    const phase3End = 1.0;

    final pathCount = vector.paths.length;
    for (int i = 0; i < pathCount; i++) {
      final info = vector.paths[i];
      final baseColor = _effectiveFillColor(info);
      final bounds = info.path.getBounds();
      final centerX = bounds.center.dx;
      final centerY = bounds.center.dy;

      double opacity = 0.0;
      double offsetX = 0.0;
      double offsetY = 0.0;
      double pathScale = 1.0;

      if (_t < phase1End) {
        final phaseProgress = (_t / phase1End).clamp(0.0, 1.0);
        final curvedProgress = Curves.easeOut.transform(phaseProgress);
        opacity = curvedProgress * 0.6;
        offsetX = (i.isEven ? -30 : 30) * (1 - curvedProgress);
        offsetY = (i.isOdd ? -20 : 20) * (1 - curvedProgress);
        pathScale = 0.8 + 0.2 * curvedProgress;
      } else if (_t < phase2End) {
        final phaseProgress = ((_t - phase1End) / (phase2End - phase1End)).clamp(0.0, 1.0);
        final curvedProgress = Curves.easeInOut.transform(phaseProgress);
        opacity = 0.6 + 0.4 * curvedProgress;
        offsetX = 0;
        offsetY = 0;
        pathScale = 1.0;
      } else {
        final phaseProgress = ((_t - phase2End) / (phase3End - phase2End)).clamp(0.0, 1.0);
        opacity = 1.0;
        offsetX = 0;
        offsetY = 0;
        pathScale = 1.0 + 0.02 * math.sin(phaseProgress * math.pi);
      }

      final color = baseColor.withValues(alpha: opacity);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;

      canvas.save();
      canvas.translate(centerX + offsetX, centerY + offsetY);
      canvas.scale(pathScale, pathScale);
      canvas.translate(-centerX, -centerY);
      canvas.drawPath(info.path, paint);
      canvas.restore();
    }

    canvas.restore();
  }

  void _paintGlitchReveal(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    canvas
      ..save()
      ..translate(
        (size.width - viewBoxWidth * scale) / 2,
        (size.height - viewBoxHeight * scale) / 2,
      )
      ..scale(scale, scale);

    final random = math.Random(42);
    final glitchIntensity = _t < 0.7 ? (0.7 - _t) / 0.7 : 0.0;
    final opacity = Curves.easeOut.transform(_t.clamp(0.0, 1.0));

    for (final info in vector.paths) {
      final baseColor = _effectiveFillColor(info);

      if (glitchIntensity > 0 && random.nextDouble() < glitchIntensity * 0.5) {
        for (int j = 0; j < 3; j++) {
          final glitchOffsetX = (random.nextDouble() - 0.5) * 20 * glitchIntensity;
          final glitchOffsetY = (random.nextDouble() - 0.5) * 10 * glitchIntensity;
          final glitchColor = j == 0
              ? const Color(0xFFFF0000)
              : j == 1
                  ? const Color(0xFF00FF00)
                  : const Color(0xFF0000FF);

          final paint = Paint()
            ..style = PaintingStyle.fill
            ..color = glitchColor.withValues(alpha: glitchIntensity * 0.3)
            ..blendMode = BlendMode.screen;

          canvas.save();
          canvas.translate(glitchOffsetX, glitchOffsetY);
          canvas.drawPath(info.path, paint);
          canvas.restore();
        }
      }

      final color = baseColor.withValues(alpha: opacity);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintFragmentAssemble(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    canvas
      ..save()
      ..translate(
        (size.width - viewBoxWidth * scale) / 2,
        (size.height - viewBoxHeight * scale) / 2,
      )
      ..scale(scale, scale);

    final pathCount = vector.paths.length;
    final random = math.Random(123);

    for (int i = 0; i < pathCount; i++) {
      final info = vector.paths[i];
      final baseColor = _effectiveFillColor(info);
      final bounds = info.path.getBounds();
      final centerX = bounds.center.dx;
      final centerY = bounds.center.dy;

      final startAngle = random.nextDouble() * 2 * math.pi;
      final startDistance = 50 + random.nextDouble() * 100;
      final startRotation = (random.nextDouble() - 0.5) * math.pi;

      final pathDelay = i * 0.1;
      final pathProgress = ((_t - pathDelay) / (1 - pathDelay)).clamp(0.0, 1.0);
      final curvedProgress = Curves.easeOutBack.transform(pathProgress);

      final currentDistance = startDistance * (1 - curvedProgress);
      final currentRotation = startRotation * (1 - curvedProgress);
      final offsetX = math.cos(startAngle) * currentDistance;
      final offsetY = math.sin(startAngle) * currentDistance;
      final opacity = curvedProgress;

      final color = baseColor.withValues(alpha: opacity);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;

      canvas.save();
      canvas.translate(centerX + offsetX, centerY + offsetY);
      canvas.rotate(currentRotation);
      canvas.scale(curvedProgress.clamp(0.5, 1.0), curvedProgress.clamp(0.5, 1.0));
      canvas.translate(-centerX, -centerY);
      canvas.drawPath(info.path, paint);
      canvas.restore();
    }

    canvas.restore();
  }

  void _paintSplitMerge(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    canvas
      ..save()
      ..translate(
        (size.width - viewBoxWidth * scale) / 2,
        (size.height - viewBoxHeight * scale) / 2,
      )
      ..scale(scale, scale);

    final centerViewX = viewBoxWidth / 2;

    for (final info in vector.paths) {
      final baseColor = _effectiveFillColor(info);
      final bounds = info.path.getBounds();
      final isLeftSide = bounds.center.dx < centerViewX;

      final splitOffset = 80 * (1 - Curves.easeOutCubic.transform(_t));
      final offsetX = isLeftSide ? -splitOffset : splitOffset;

      final fadeProgress = Curves.easeOut.transform(_t);
      final scaleProgress = 0.8 + 0.2 * Curves.easeOutBack.transform(_t);

      final color = baseColor.withValues(alpha: fadeProgress);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;

      canvas.save();
      canvas.translate(bounds.center.dx, bounds.center.dy);
      canvas.translate(offsetX, 0);
      canvas.scale(scaleProgress, scaleProgress);
      canvas.translate(-bounds.center.dx, -bounds.center.dy);
      canvas.drawPath(info.path, paint);
      canvas.restore();
    }

    canvas.restore();
  }

  void _paintRotate3D(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final rotX = rotationX * curvedT;
    final rotY = rotationY * curvedT;
    final rotZ = rotationZ * curvedT;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    if (enable3DPerspective) {
      final perspective = perspective3DDistance;
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, -1 / perspective)
        ..rotateX(rotX)
        ..rotateY(rotY)
        ..rotateZ(rotZ)
        ..translateByDouble(translateX * curvedT, translateY * curvedT, translateZ * curvedT, 1)
        ..scaleByDouble(scale3D * scale, scale3D * scale, 1, 1);

      canvas.transform(matrix.storage);
    } else {
      canvas.rotate(rotZ);
      canvas.scale(scale3D * scale, scale3D * scale);
    }

    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintFlip3D(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final flipAngle = math.pi * curvedT;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    if (enable3DPerspective) {
      final perspective = perspective3DDistance;
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, -1 / perspective)
        ..rotateX(flipAxis == Axis.horizontal ? 0 : flipAngle)
        ..rotateY(flipAxis == Axis.horizontal ? flipAngle : 0)
        ..scaleByDouble(scale3D * scale, scale3D * scale, 1, 1);

      canvas.transform(matrix.storage);
    } else {
      final scaleX = flipAxis == Axis.horizontal ? math.cos(flipAngle).abs() : 1.0;
      final scaleY = flipAxis == Axis.vertical ? math.cos(flipAngle).abs() : 1.0;
      canvas.scale(scaleX * scale, scaleY * scale);
    }

    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintPerspective3D(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final perspective = perspective3DDistance * (1 - curvedT * 0.8);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, -1 / perspective)
      ..rotateX(rotationX * curvedT)
      ..rotateY(rotationY * curvedT)
      ..rotateZ(rotationZ * curvedT)
      ..translateByDouble(translateX * curvedT, translateY * curvedT, translateZ * curvedT, 1)
      ..scaleByDouble(scale3D * scale * (0.5 + 0.5 * curvedT), scale3D * scale * (0.5 + 0.5 * curvedT), 1, 1);

    canvas.transform(matrix.storage);
    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info).withValues(alpha: curvedT);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintCubeRotate(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final rotation = curvedT * math.pi * 2;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    if (enable3DPerspective) {
      final perspective = perspective3DDistance;
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, -1 / perspective)
        ..rotateY(rotation)
        ..rotateX(rotation * 0.3)
        ..scaleByDouble(scale3D * scale, scale3D * scale, 1, 1);

      canvas.transform(matrix.storage);
    } else {
      canvas.rotate(rotation);
      canvas.scale(scale3D * scale, scale3D * scale);
    }

    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintCardFlip(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final flipAngle = math.pi * curvedT;
    final opacity = math.cos(flipAngle).abs();

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    if (enable3DPerspective) {
      final perspective = perspective3DDistance;
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, -1 / perspective)
        ..rotateY(flipAngle)
        ..scaleByDouble(scale3D * scale, scale3D * scale, 1, 1);

      canvas.transform(matrix.storage);
    } else {
      final scaleX = math.cos(flipAngle).abs();
      canvas.scale(scaleX * scale, scale);
    }

    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info).withValues(alpha: opacity);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintSwing3D(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final swingAngle = math.sin(curvedT * math.pi * 2) * 0.3;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    if (enable3DPerspective) {
      final perspective = perspective3DDistance;
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, -1 / perspective)
        ..rotateX(swingAngle)
        ..rotateY(swingAngle * 0.5)
        ..scaleByDouble(scale3D * scale, scale3D * scale, 1, 1);

      canvas.transform(matrix.storage);
    } else {
      canvas.rotate(swingAngle);
      canvas.scale(scale3D * scale, scale3D * scale);
    }

    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintTumble3D(Canvas canvas, Size size, double scale, double viewBoxWidth, double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final tumbleX = math.sin(curvedT * math.pi * 2) * 0.5;
    final tumbleY = math.cos(curvedT * math.pi * 2) * 0.5;
    final tumbleZ = math.sin(curvedT * math.pi * 4) * 0.3;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    if (enable3DPerspective) {
      final perspective = perspective3DDistance;
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, -1 / perspective)
        ..rotateX(tumbleX)
        ..rotateY(tumbleY)
        ..rotateZ(tumbleZ)
        ..scaleByDouble(scale3D * scale, scale3D * scale, 1, 1);

      canvas.transform(matrix.storage);
    } else {
      canvas.rotate(tumbleZ);
      canvas.scale(scale3D * scale, scale3D * scale);
    }

    canvas.translate(-viewBoxWidth / 2, -viewBoxHeight / 2);

    for (final info in vector.paths) {
      final color = _effectiveFillColor(info);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
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
    return info.fillColor == Colors.transparent ? const Color(0xFF000000) : info.fillColor;
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

    final normalized = ((_t - fillStartFraction) / (1 - fillStartFraction)).clamp(0.0, 1.0);
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
    final totalLength = metrics.fold<double>(0, (sum, metric) => sum + metric.length);
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

  void _drawFill(Canvas canvas, Path path, Color color, double progress, double viewBoxWidth, double viewBoxHeight) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    canvas.save();
    canvas.clipRect(_clipRectForProgress(progress, viewBoxWidth, viewBoxHeight));
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  Rect _clipRectForProgress(double progress, double viewBoxWidth, double viewBoxHeight) {
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
