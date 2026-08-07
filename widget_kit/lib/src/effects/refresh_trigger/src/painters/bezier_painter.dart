import 'package:flutter/widgets.dart';

/// Fills a liquid-looking curve that stretches with [progress] 0..1.
class BezierPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isRefreshing;

  BezierPainter({
    required this.progress,
    required this.color,
    required this.isRefreshing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final height = size.height * progress;
    final controlHeight = height * 1.5;

    path.moveTo(0, 0);
    path.lineTo(0, height);
    path.quadraticBezierTo(size.width / 2, controlHeight, size.width, height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BezierPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isRefreshing != isRefreshing;
  }
}
