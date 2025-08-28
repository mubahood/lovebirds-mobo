import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/CustomTheme.dart';
import '../../models/UserModel.dart';
import 'package:flutx/flutx.dart';

/// Enhanced match celebration widget with confetti, fireworks, and animations
class MatchCelebrationWidget extends StatefulWidget {
  final UserModel matchedUser;
  final VoidCallback onKeepSwiping;
  final VoidCallback onSayHello;

  const MatchCelebrationWidget({
    Key? key,
    required this.matchedUser,
    required this.onKeepSwiping,
    required this.onSayHello,
  }) : super(key: key);

  @override
  _MatchCelebrationWidgetState createState() => _MatchCelebrationWidgetState();
}

class _MatchCelebrationWidgetState extends State<MatchCelebrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _dialogController;
  late AnimationController _heartsController;

  late Animation<double> _confettiAnimation;
  late Animation<double> _dialogScaleAnimation;
  late Animation<double> _dialogOpacityAnimation;
  late Animation<double> _heartsAnimation;

  List<ConfettiParticle> _confettiParticles = [];
  List<HeartParticle> _heartParticles = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateParticles();
    _startCelebration();
  }

  void _setupAnimations() {
    // Confetti animation (2 seconds)
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _confettiController, curve: Curves.easeOut),
    );

    // Dialog animation (800ms)
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _dialogScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dialogController, curve: Curves.elasticOut),
    );

    _dialogOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dialogController,
        curve: Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Hearts animation (1.5 seconds)
    _heartsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _heartsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heartsController, curve: Curves.easeOut),
    );
  }

  void _generateParticles() {
    final random = Random();

    // Generate confetti particles
    _confettiParticles = List.generate(50, (index) {
      return ConfettiParticle(
        x: random.nextDouble(),
        y: -0.1, // Start above screen
        size: random.nextDouble() * 8 + 4,
        color: _getRandomColor(random),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 0.3,
          random.nextDouble() * 0.4 + 0.2,
        ),
        rotation: random.nextDouble() * 2 * pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.2,
      );
    });

    // Generate floating hearts
    _heartParticles = List.generate(15, (index) {
      return HeartParticle(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.5 + 0.25, // Middle area
        size: random.nextDouble() * 6 + 8,
        color: Colors.pink.withValues(alpha: random.nextDouble() * 0.7 + 0.3),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 0.1,
          -(random.nextDouble() * 0.2 + 0.1), // Float upward
        ),
        pulsePhase: random.nextDouble() * 2 * pi,
      );
    });
  }

  Color _getRandomColor(Random random) {
    final colors = [
      Colors.pink,
      Colors.red,
      Colors.purple,
      Colors.deepPurple,
      Colors.blue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.yellow,
      Colors.orange,
    ];
    return colors[random.nextInt(colors.length)];
  }

  void _startCelebration() async {
    // Add haptic feedback
    HapticFeedback.heavyImpact();

    // Start all animations with slight delays for effect
    _confettiController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _heartsController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _dialogController.forward();

    // Add another haptic after dialog appears
    await Future.delayed(const Duration(milliseconds: 300));
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _dialogController.dispose();
    _heartsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          // Confetti layer
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _confettiAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(
                    particles: _confettiParticles,
                    animation: _confettiAnimation,
                  ),
                );
              },
            ),
          ),

          // Hearts layer
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _heartsAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: HeartsPainter(
                    particles: _heartParticles,
                    animation: _heartsAnimation,
                  ),
                );
              },
            ),
          ),

          // Match dialog
          Center(
            child: AnimatedBuilder(
              animation: _dialogController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _dialogScaleAnimation.value,
                  child: Opacity(
                    opacity: _dialogOpacityAnimation.value,
                    child: _buildMatchDialog(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchDialog() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomTheme.primary,
            CustomTheme.primary.withValues(alpha: 0.8),
            Colors.pink.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing hearts icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.2),
            duration: const Duration(milliseconds: 1000),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 100,
                    ),
                    const Icon(Icons.favorite, color: Colors.white, size: 80),
                  ],
                ),
              );
            },
            onEnd: () {
              if (mounted) {
                setState(() {}); // Restart the pulsing animation
              }
            },
          ),

          const SizedBox(height: 25),

          // Match text with typewriter effect
          FxText.titleLarge(
            'It\'s a Match!',
            color: Colors.white,
            fontWeight: 700,
            fontSize: 28,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15),

          // User info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage:
                    widget.matchedUser.avatar.isNotEmpty
                        ? NetworkImage(widget.matchedUser.avatar)
                        : null,
                child:
                    widget.matchedUser.avatar.isEmpty
                        ? Icon(Icons.person, color: Colors.grey[400])
                        : null,
              ),
              const SizedBox(width: 15),
              const Icon(Icons.favorite, color: Colors.white, size: 20),
              const SizedBox(width: 15),
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 15),

          FxText.bodyLarge(
            'You and ${widget.matchedUser.name} liked each other',
            color: Colors.white.withValues(alpha: 0.9),
            textAlign: TextAlign.center,
            fontSize: 16,
          ),

          const SizedBox(height: 35),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  text: 'Keep Swiping',
                  isPrimary: false,
                  onPressed: widget.onKeepSwiping,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionButton(
                  text: 'Say Hello',
                  isPrimary: true,
                  onPressed: widget.onSayHello,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(25),
        border:
            isPrimary ? null : Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(25),
          child: Center(
            child: FxText.bodyLarge(
              text,
              color: isPrimary ? CustomTheme.primary : Colors.white,
              fontWeight: isPrimary ? 600 : 400,
            ),
          ),
        ),
      ),
    );
  }
}

// Confetti particle class
class ConfettiParticle {
  double x;
  double y;
  final double size;
  final Color color;
  final Offset velocity;
  double rotation;
  final double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
  });

  void update(double dt) {
    x += velocity.dx * dt;
    y += velocity.dy * dt;
    rotation += rotationSpeed * dt;
  }
}

// Heart particle class
class HeartParticle {
  double x;
  double y;
  final double size;
  final Color color;
  final Offset velocity;
  final double pulsePhase;

  HeartParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.velocity,
    required this.pulsePhase,
  });

  void update(double dt) {
    x += velocity.dx * dt;
    y += velocity.dy * dt;
  }
}

// Confetti painter
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final Animation<double> animation;

  ConfettiPainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(animation.value);

      // Skip particles that fell off screen
      if (particle.y > 1.2) continue;

      final paint =
          Paint()
            ..color = particle.color.withOpacity(
              (1 - animation.value * 0.7).clamp(0.0, 1.0),
            )
            ..style = PaintingStyle.fill;

      final position = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(particle.rotation);

      // Draw confetti piece (rectangle)
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        Radius.circular(particle.size * 0.1),
      );
      canvas.drawRRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Hearts painter
class HeartsPainter extends CustomPainter {
  final List<HeartParticle> particles;
  final Animation<double> animation;

  HeartsPainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(animation.value);

      // Calculate pulsing scale
      final pulseScale =
          1.0 + 0.3 * sin(animation.value * 4 * pi + particle.pulsePhase);

      final paint =
          Paint()
            ..color = particle.color.withOpacity(
              (1 - animation.value * 0.5).clamp(0.0, 1.0),
            )
            ..style = PaintingStyle.fill;

      final position = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.scale(pulseScale);

      _drawHeart(canvas, Offset.zero, particle.size, paint);

      canvas.restore();
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    // Heart shape
    final heartSize = size;
    path.moveTo(center.dx, center.dy + heartSize * 0.3);

    // Left curve
    path.cubicTo(
      center.dx - heartSize * 0.5,
      center.dy - heartSize * 0.1,
      center.dx - heartSize * 0.5,
      center.dy - heartSize * 0.4,
      center.dx,
      center.dy - heartSize * 0.2,
    );

    // Right curve
    path.cubicTo(
      center.dx + heartSize * 0.5,
      center.dy - heartSize * 0.4,
      center.dx + heartSize * 0.5,
      center.dy - heartSize * 0.1,
      center.dx,
      center.dy + heartSize * 0.3,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
