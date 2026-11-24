import 'package:flutter/rendering.dart';

import 'tour_theme.dart';

/// Paints the dimmed backdrop with a rounded cut-out over the target.
class HolePainter extends CustomPainter {
  const HolePainter(this.rect, this.theme);

  final Rect rect;
  final TourTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final backdrop = Paint()..color = theme.overlay;
    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect.inflate(theme.padding),
          Radius.circular(theme.radius),
        ),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, full, hole),
      backdrop,
    );
  }

  @override
  bool shouldRepaint(covariant HolePainter old) =>
      old.rect != rect || old.theme != theme;
}
