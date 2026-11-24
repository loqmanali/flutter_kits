part of '../animated_svg_widget_renderer.dart';

/// Perspective animations: 3D rotate/flip, cube, card flip, swing, tumble.
extension _ThreeDPaints on AnimatedSvgPainter {
  void _paintRotate3D(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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
        ..translateByDouble(
            translateX * curvedT, translateY * curvedT, translateZ * curvedT, 1)
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

  void _paintFlip3D(Canvas canvas, Size size, double scale, double viewBoxWidth,
      double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final flipAngle = math.pi * curvedT;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    if (enable3DPerspective) {
      final perspective = perspective3DDistance;
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, -1 / perspective)
        ..rotateX(this.flipAxis == Axis.horizontal ? 0 : flipAngle)
        ..rotateY(this.flipAxis == Axis.horizontal ? flipAngle : 0)
        ..scaleByDouble(scale3D * scale, scale3D * scale, 1, 1);

      canvas.transform(matrix.storage);
    } else {
      final scaleX =
          this.flipAxis == Axis.horizontal ? math.cos(flipAngle).abs() : 1.0;
      final scaleY =
          this.flipAxis == Axis.vertical ? math.cos(flipAngle).abs() : 1.0;
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

  void _paintPerspective3D(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
    final curvedT = entranceCurve.transform(_t);
    final perspective = perspective3DDistance * (1 - curvedT * 0.8);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, -1 / perspective)
      ..rotateX(rotationX * curvedT)
      ..rotateY(rotationY * curvedT)
      ..rotateZ(rotationZ * curvedT)
      ..translateByDouble(
          translateX * curvedT, translateY * curvedT, translateZ * curvedT, 1)
      ..scaleByDouble(scale3D * scale * (0.5 + 0.5 * curvedT),
          scale3D * scale * (0.5 + 0.5 * curvedT), 1, 1);

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

  void _paintCubeRotate(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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

  void _paintCardFlip(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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

  void _paintSwing3D(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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

  void _paintTumble3D(Canvas canvas, Size size, double scale,
      double viewBoxWidth, double viewBoxHeight) {
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
}
