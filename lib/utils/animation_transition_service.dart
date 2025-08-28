/**
 * Animation & Transition Polish Service - UI-1 Implementation
 * 
 * This file provides comprehensive animation and transition utilities for
 * smooth screen transitions, enhanced swipe animations, loading shimmer effects,
 * haptic feedback, and optimized 60fps performance.
 */

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced page transition animations
class CustomPageTransitions {
  /// Slide transition from right to left
  static PageRouteBuilder<T> slideFromRight<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Slide transition from bottom to top
  static PageRouteBuilder<T> slideFromBottom<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Fade transition with scale
  static PageRouteBuilder<T> fadeWithScale<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));
        final scaleAnimation = Tween(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
    );
  }

  /// Custom swipe animation with physics
  static PageRouteBuilder<T> swipeTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 350),
    SwipeDirection direction = SwipeDirection.left,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: _getSwipeOffset(direction, animation),
          child: child,
        );
      },
    );
  }

  static Animation<Offset> _getSwipeOffset(
    SwipeDirection direction,
    Animation<double> animation,
  ) {
    late Offset begin;
    switch (direction) {
      case SwipeDirection.left:
        begin = const Offset(1.0, 0.0);
        break;
      case SwipeDirection.right:
        begin = const Offset(-1.0, 0.0);
        break;
      case SwipeDirection.up:
        begin = const Offset(0.0, 1.0);
        break;
      case SwipeDirection.down:
        begin = const Offset(0.0, -1.0);
        break;
    }

    const end = Offset.zero;
    final tween = Tween(
      begin: begin,
      end: end,
    ).chain(CurveTween(curve: Curves.fastOutSlowIn));
    return animation.drive(tween);
  }
}

enum SwipeDirection { left, right, up, down }

/// Enhanced swipe animation controller for dating cards
class EnhancedSwipeController extends ChangeNotifier {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _positionAnimation;

  Offset _cardPosition = Offset.zero;
  double _cardRotation = 0.0;
  bool _isDragging = false;

  EnhancedSwipeController({required TickerProvider vsync}) {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _animationController.addListener(() {
      _cardPosition = _positionAnimation.value;
      _cardRotation = _rotationAnimation.value;
      notifyListeners();
    });
  }

  Offset get cardPosition => _cardPosition;
  double get cardRotation => _cardRotation;
  bool get isDragging => _isDragging;

  /// Start dragging the card
  void startDrag(Offset position) {
    _isDragging = true;
    _animationController.stop();
    notifyListeners();
  }

  /// Update card position during drag
  void updateDrag(Offset position, Size screenSize) {
    _cardPosition = position;

    // Calculate rotation based on horizontal position
    final normalizedX = position.dx / screenSize.width;
    _cardRotation = normalizedX * 0.3; // Max 0.3 radians (about 17 degrees)

    notifyListeners();
  }

  /// End drag and animate to final position
  void endDrag(
    Offset velocity,
    Size screenSize, {
    required VoidCallback onSwipeLeft,
    required VoidCallback onSwipeRight,
    required VoidCallback onSwipeUp,
  }) {
    _isDragging = false;

    final threshold = screenSize.width * 0.3;
    final velocityThreshold = 1000.0;

    // Determine swipe direction
    if (_cardPosition.dx > threshold || velocity.dx > velocityThreshold) {
      _animateSwipeRight(screenSize, onSwipeRight);
    } else if (_cardPosition.dx < -threshold ||
        velocity.dx < -velocityThreshold) {
      _animateSwipeLeft(screenSize, onSwipeLeft);
    } else if (_cardPosition.dy < -threshold ||
        velocity.dy < -velocityThreshold) {
      _animateSwipeUp(screenSize, onSwipeUp);
    } else {
      _animateReturn();
    }
  }

  /// Animate swipe right (like)
  void _animateSwipeRight(Size screenSize, VoidCallback onComplete) {
    _positionAnimation = Tween<Offset>(
      begin: _cardPosition,
      end: Offset(screenSize.width, _cardPosition.dy),
    ).animate(_animationController);

    _rotationAnimation = Tween<double>(
      begin: _cardRotation,
      end: 0.5,
    ).animate(_animationController);

    _animationController.forward().then((_) {
      _resetCard();
      onComplete();
    });
  }

  /// Animate swipe left (pass)
  void _animateSwipeLeft(Size screenSize, VoidCallback onComplete) {
    _positionAnimation = Tween<Offset>(
      begin: _cardPosition,
      end: Offset(-screenSize.width, _cardPosition.dy),
    ).animate(_animationController);

    _rotationAnimation = Tween<double>(
      begin: _cardRotation,
      end: -0.5,
    ).animate(_animationController);

    _animationController.forward().then((_) {
      _resetCard();
      onComplete();
    });
  }

  /// Animate swipe up (super like)
  void _animateSwipeUp(Size screenSize, VoidCallback onComplete) {
    _positionAnimation = Tween<Offset>(
      begin: _cardPosition,
      end: Offset(_cardPosition.dx, -screenSize.height),
    ).animate(_animationController);

    _rotationAnimation = Tween<double>(
      begin: _cardRotation,
      end: 0.0,
    ).animate(_animationController);

    _animationController.forward().then((_) {
      _resetCard();
      onComplete();
    });
  }

  /// Animate return to center
  void _animateReturn() {
    _positionAnimation = Tween<Offset>(
      begin: _cardPosition,
      end: Offset.zero,
    ).animate(_animationController);

    _rotationAnimation = Tween<double>(
      begin: _cardRotation,
      end: 0.0,
    ).animate(_animationController);

    _animationController.forward();
  }

  /// Reset card to initial position
  void _resetCard() {
    _cardPosition = Offset.zero;
    _cardRotation = 0.0;
    _animationController.reset();
    notifyListeners();
  }

  /// Programmatically swipe right
  void swipeRight(Size screenSize, VoidCallback onComplete) {
    _animateSwipeRight(screenSize, onComplete);
  }

  /// Programmatically swipe left
  void swipeLeft(Size screenSize, VoidCallback onComplete) {
    _animateSwipeLeft(screenSize, onComplete);
  }

  /// Programmatically swipe up
  void swipeUp(Size screenSize, VoidCallback onComplete) {
    _animateSwipeUp(screenSize, onComplete);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// Shimmer loading effect widget
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_animation.value * math.pi),
            ).createShader(rect);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Haptic feedback service
class HapticFeedbackService {
  /// Light impact feedback for button taps
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact feedback for swipe actions
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact feedback for important actions
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click feedback
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate feedback for notifications
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  /// Custom pattern vibration (platform dependent)
  static Future<void> customPattern(List<int> pattern) async {
    // This would be implemented with platform-specific code
    // For now, use heavy impact as fallback
    await heavyImpact();
  }

  /// Success feedback pattern
  static Future<void> successFeedback() async {
    await lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await lightImpact();
  }

  /// Error feedback pattern
  static Future<void> errorFeedback() async {
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await heavyImpact();
  }

  /// Match feedback pattern
  static Future<void> matchFeedback() async {
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await lightImpact();
  }
}

/// Performance-optimized animation manager
class AnimationPerformanceManager {
  static const int _targetFPS = 60;
  static const Duration _frameDuration = Duration(
    microseconds: 16667,
  ); // 1/60 second

  static final Map<String, AnimationController> _controllers = {};
  static final Map<String, Stopwatch> _performanceTimers = {};

  /// Register an animation controller for performance monitoring
  static void registerController(String name, AnimationController controller) {
    _controllers[name] = controller;
    _performanceTimers[name] = Stopwatch();
  }

  /// Unregister an animation controller
  static void unregisterController(String name) {
    _controllers.remove(name);
    _performanceTimers.remove(name);
  }

  /// Start performance monitoring for an animation
  static void startMonitoring(String name) {
    _performanceTimers[name]?.start();
  }

  /// Stop performance monitoring and get results
  static Map<String, dynamic> stopMonitoring(String name) {
    final timer = _performanceTimers[name];
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsed;
      final fps = 1000000 / duration.inMicroseconds; // Calculate FPS
      timer.reset();

      return {
        'duration_ms': duration.inMilliseconds,
        'fps': fps.toStringAsFixed(2),
        'target_fps': _targetFPS,
        'performance_rating': fps >= _targetFPS ? 'Good' : 'Needs Optimization',
      };
    }
    return {};
  }

  /// Get performance statistics for all animations
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'registered_controllers': _controllers.length,
      'target_fps': _targetFPS,
      'frame_duration_us': _frameDuration.inMicroseconds,
      'monitoring_active':
          _performanceTimers.values.where((t) => t.isRunning).length,
    };
  }

  /// Optimize animation performance
  static void optimizePerformance() {
    // Clear completed animations
    _controllers.removeWhere((name, controller) => !controller.isAnimating);

    // Stop monitoring for inactive animations
    _performanceTimers.removeWhere((name, timer) => !timer.isRunning);
  }
}

/// Staggered animation helper
class StaggeredAnimationHelper {
  /// Create staggered list animation
  static List<Animation<double>> createStaggeredList({
    required AnimationController controller,
    required int itemCount,
    double interval = 0.1,
    Curve curve = Curves.easeOut,
  }) {
    final animations = <Animation<double>>[];

    for (int i = 0; i < itemCount; i++) {
      final start = (i * interval).clamp(0.0, 1.0);
      final end = (start + interval).clamp(0.0, 1.0);

      animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, end, curve: curve),
          ),
        ),
      );
    }

    return animations;
  }

  /// Create staggered fade-in animation
  static List<Animation<double>> createStaggeredFadeIn({
    required AnimationController controller,
    required int itemCount,
    double interval = 0.15,
  }) {
    return createStaggeredList(
      controller: controller,
      itemCount: itemCount,
      interval: interval,
      curve: Curves.easeInOut,
    );
  }

  /// Create staggered slide-up animation
  static List<Animation<Offset>> createStaggeredSlideUp({
    required AnimationController controller,
    required int itemCount,
    double interval = 0.1,
  }) {
    final animations = <Animation<Offset>>[];

    for (int i = 0; i < itemCount; i++) {
      final start = (i * interval).clamp(0.0, 1.0);
      final end = (start + interval).clamp(0.0, 1.0);

      animations.add(
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );
    }

    return animations;
  }
}

/// Custom loading animations
class LoadingAnimations {
  /// Pulsing heart animation for like actions
  static Widget pulsingHeart({
    Color color = Colors.red,
    double size = 24.0,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.8, end: 1.2),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Icon(Icons.favorite, color: color, size: size),
        );
      },
    );
  }

  /// Rotating loading spinner
  static Widget rotatingSpinner({
    Color color = Colors.blue,
    double size = 24.0,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 2 * math.pi),
      builder: (context, rotation, child) {
        return Transform.rotate(
          angle: rotation,
          child: Icon(Icons.sync, color: color, size: size),
        );
      },
    );
  }

  /// Bouncing dots loading animation
  static Widget bouncingDots({
    Color color = Colors.grey,
    double size = 8.0,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          duration: duration,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            final animationDelay = index * 0.2;
            final bounceValue = math.sin(
              (value + animationDelay) * 2 * math.pi,
            );

            return Transform.translate(
              offset: Offset(0, bounceValue * 5),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: size,
                height: size,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            );
          },
        );
      }),
    );
  }
}
