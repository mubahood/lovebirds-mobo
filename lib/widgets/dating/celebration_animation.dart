import 'dart:math';
import 'package:flutter/material.dart';

/// Celebration animation widget for super likes and matches
class CelebrationAnimation extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final Color color;
  final Duration duration;

  const CelebrationAnimation({
    Key? key,
    required this.child,
    required this.trigger,
    this.color = Colors.blue,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  _CelebrationAnimationState createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _generateParticles();
  }

  @override
  void didUpdateWidget(CelebrationAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startCelebration();
    }
  }

  void _generateParticles() {
    _particles = List.generate(20, (index) {
      final random = Random();
      return Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 6 + 4,
        color: widget.color.withValues(alpha: random.nextDouble()),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 4,
          (random.nextDouble() - 0.5) * 4,
        ),
      );
    });
  }

  void _startCelebration() {
    _generateParticles();
    _controller.forward().then((_) {
      _controller.reset();
    });
  }

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
        return Stack(
          children: [
            Transform.scale(scale: _scaleAnimation.value, child: widget.child),
            if (_controller.isAnimating)
              Positioned.fill(
                child: CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    animation: _controller,
                    opacity: _opacityAnimation.value,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  final double size;
  final Color color;
  final Offset velocity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.velocity,
  });

  void update(double dt) {
    x += velocity.dx * dt;
    y += velocity.dy * dt;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Animation<double> animation;
  final double opacity;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Update particle position
      particle.update(animation.value);

      final paint =
          Paint()
            ..color = particle.color.withOpacity(
              opacity * (1 - animation.value),
            )
            ..style = PaintingStyle.fill;

      final position = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      // Draw star shape for super like celebration
      _drawStar(canvas, position, particle.size, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final outerRadius = size;
    final innerRadius = size * 0.4;
    const spikes = 5;

    for (int i = 0; i < spikes * 2; i++) {
      final angle = (i * pi) / spikes;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * cos(angle - pi / 2);
      final y = center.dy + radius * sin(angle - pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
