part of '../animated_svg_widget_renderer.dart';

/// Multi-phase reveals: logo reveal, glitch, fragment assemble, split/merge.
extension _RevealPaints on AnimatedSvgPainter {
  void _paintLogoReveal(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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
        final phaseProgress =
            ((_t - phase1End) / (phase2End - phase1End)).clamp(0.0, 1.0);
        final curvedProgress = Curves.easeInOut.transform(phaseProgress);
        opacity = 0.6 + 0.4 * curvedProgress;
        offsetX = 0;
        offsetY = 0;
        pathScale = 1.0;
      } else {
        final phaseProgress =
            ((_t - phase2End) / (phase3End - phase2End)).clamp(0.0, 1.0);
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

  void _paintGlitchReveal(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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
          final glitchOffsetX =
              (random.nextDouble() - 0.5) * 20 * glitchIntensity;
          final glitchOffsetY =
              (random.nextDouble() - 0.5) * 10 * glitchIntensity;
          // RGB channel split — this IS the glitch effect, not a theme
          // color, so it stays literal.
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

  void _paintFragmentAssemble(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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
      canvas.scale(
          curvedProgress.clamp(0.5, 1.0), curvedProgress.clamp(0.5, 1.0));
      canvas.translate(-centerX, -centerY);
      canvas.drawPath(info.path, paint);
      canvas.restore();
    }

    canvas.restore();
  }

  void _paintSplitMerge(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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
}
