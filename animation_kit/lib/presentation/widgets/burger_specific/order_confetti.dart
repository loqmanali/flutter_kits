import 'dart:math';

import 'package:flutter/material.dart';

/// Order Confetti Animation
///
/// Displays confetti animation for order celebrations.
class OrderConfetti extends StatefulWidget {
  /// Number of confetti particles
  final int particleCount;

  /// Duration of the confetti animation
  final Duration duration;

  /// Colors for confetti particles
  final List<Color> colors;

  /// Whether to auto-play the animation
  final bool autoPlay;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  const OrderConfetti({
    super.key,
    this.particleCount = 50,
    this.duration = const Duration(seconds: 2),
    this.colors = const [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ],
    this.autoPlay = true,
    this.onComplete,
  });

  @override
  State<OrderConfetti> createState() => _OrderConfettiState();
}

class _OrderConfettiState extends State<OrderConfetti>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _particles = List.generate(widget.particleCount, (index) {
      return _ConfettiParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.3,
        color: widget.colors[_random.nextInt(widget.colors.length)],
        size: _random.nextDouble() * 10 + 5,
        velocity: _random.nextDouble() * 0.5 + 0.5,
        rotation: _random.nextDouble() * 2 * pi,
      );
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.autoPlay) {
      _controller.forward();
    }
  }

  void play() => _controller.forward(from: 0);
  void reset() => _controller.reset();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double velocity;
  final double rotation;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.velocity,
    required this.rotation,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = (particle.y + progress * particle.velocity) * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + progress * 2 * pi);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
