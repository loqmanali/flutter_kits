part of '../animated_svg_widget_renderer.dart';

/// Entrance and emphasis animations: fade, scale, slide, typewriter, pulse,
/// shimmer, morph, stagger, glow, elastic, rotate, flip, wave.
extension _BasicPaints on AnimatedSvgPainter {
  void _paintFadeIn(Canvas canvas, Size size, double scale, double viewBoxWidth,
      double viewBoxHeight) {
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

  void _paintScaleIn(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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

  void _paintScaleInBounce(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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

  void _paintSlideIn(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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

  void _paintTypewriter(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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
      final pathProgress =
          ((_t - pathStartTime) / (pathEndTime - pathStartTime))
              .clamp(0.0, 1.0);

      if (pathProgress > 0) {
        final info = vector.paths[i];
        final color = _effectiveFillColor(info);
        _drawStroke(canvas, info.path, color, pathProgress);
      }
    }

    canvas.restore();
  }

  void _paintPulse(Canvas canvas, Size size, double scale, double viewBoxWidth,
      double viewBoxHeight) {
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

  void _paintShimmer(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
    canvas
      ..save()
      ..translate(
        (size.width - viewBoxWidth * scale) / 2,
        (size.height - viewBoxHeight * scale) / 2,
      )
      ..scale(scale, scale);

    for (final info in vector.paths) {
      final baseColor = _effectiveFillColor(info);
      final effectiveShimmerColor = shimmerColor ?? const Color(0xFFFFFFFF);

      final shimmerPosition = _t * 2 - 0.5;
      final gradient = ui.Gradient.linear(
        Offset(viewBoxWidth * shimmerPosition, 0),
        Offset(viewBoxWidth * (shimmerPosition + 0.5), viewBoxHeight),
        [
          baseColor,
          Color.lerp(baseColor, effectiveShimmerColor, 0.5)!,
          baseColor
        ],
        [0.0, 0.5, 1.0],
      );

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = gradient;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintMorphIn(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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

  void _paintStaggeredPaths(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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
        final color =
            _effectiveFillColor(info).withValues(alpha: curvedProgress);
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

  void _paintGlowPulse(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
    final glowIntensity = 0.5 + 0.5 * math.sin(_t * 2 * math.pi);
    final effectiveGlowColor = glowColor ?? const Color(0xFFFFFFFF);

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
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, glowRadius * glowIntensity);
      canvas.drawPath(info.path, glowPaint);

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(info.path, paint);
    }

    canvas.restore();
  }

  void _paintElasticScale(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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

  void _paintRotateIn(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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

  void _paintFlipIn(Canvas canvas, Size size, double scale, double viewBoxWidth,
      double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final flipAngle = math.pi * (1 - curvedT);
    final scaleX =
        this.flipAxis == Axis.horizontal ? math.cos(flipAngle).abs() : 1.0;
    final scaleY =
        this.flipAxis == Axis.vertical ? math.cos(flipAngle).abs() : 1.0;

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

  void _paintWaveIn(Canvas canvas, Size size, double scale, double viewBoxWidth,
      double viewBoxHeight) {
    canvas
      ..save()
      ..translate(
        (size.width - viewBoxWidth * scale) / 2,
        (size.height - viewBoxHeight * scale) / 2,
      )
      ..scale(scale, scale);

    final pathCount = vector.paths.length;
    for (int i = 0; i < pathCount; i++) {
      final waveOffset = math.sin((_t * waveFrequency * math.pi) + (i * 0.5)) *
          waveAmplitude *
          (1 - _t);
      final pathProgress = entranceCurve.transform(
        ((_t - i * staggerDelay) / (1 - staggerDelay * (pathCount - 1)))
            .clamp(0.0, 1.0),
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
}
