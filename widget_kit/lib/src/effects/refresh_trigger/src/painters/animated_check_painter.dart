import 'package:flutter/widgets.dart';

/// Draws a checkmark that animates with [progress] 0..1.
class AnimatedCheckPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  AnimatedCheckPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = color;

    // Define a simple check ✔ path based on size.
    final start = Offset(size.width * 0.05, size.height * 0.55);
    final mid = Offset(size.width * 0.40, size.height * 0.90);
    final end = Offset(size.width * 0.95, size.height * 0.10);

    // Animate two segments: start->mid then mid->end
    const total = 1.0;
    const firstSegWeight = 0.5; // first half draws first segment
    if (progress <= firstSegWeight) {
      final t = (progress / firstSegWeight).clamp(0.0, 1.0);
      final p = Offset.lerp(start, mid, t)!;
      canvas.drawLine(start, p, paint);
    } else {
      // draw full first segment
      canvas.drawLine(start, mid, paint);
      // draw partial second segment
      final t = ((progress - firstSegWeight) / (total - firstSegWeight)).clamp(
        0.0,
        1.0,
      );
      final p = Offset.lerp(mid, end, t)!;
      canvas.drawLine(mid, p, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedCheckPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
