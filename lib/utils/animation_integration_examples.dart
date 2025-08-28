/**
 * Animation & Transition Integration Guide - UI-1 Implementation
 * 
 * This file shows how to integrate animation and transition enhancements
 * into existing screens and components for better user experience.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'animation_transition_service.dart';

// Example 1: Enhanced Navigation with Custom Transitions
// Replace standard Navigator.push with custom animated transitions

class NavigationEnhancements {
  /// Navigate with slide from right animation
  static Future<T?> slideToPage<T>(BuildContext context, Widget page) {
    return Navigator.of(
      context,
    ).push<T>(CustomPageTransitions.slideFromRight<T>(page));
  }

  /// Navigate with slide from bottom animation (for modals)
  static Future<T?> slideFromBottomModal<T>(BuildContext context, Widget page) {
    return Navigator.of(
      context,
    ).push<T>(CustomPageTransitions.slideFromBottom<T>(page));
  }

  /// Navigate with fade and scale animation
  static Future<T?> fadeScaleToPage<T>(BuildContext context, Widget page) {
    return Navigator.of(
      context,
    ).push<T>(CustomPageTransitions.fadeWithScale<T>(page));
  }

  /// Navigate with custom swipe transition
  static Future<T?> swipeToPage<T>(
    BuildContext context,
    Widget page,
    SwipeDirection direction,
  ) {
    return Navigator.of(context).push<T>(
      CustomPageTransitions.swipeTransition<T>(page, direction: direction),
    );
  }
}

// Example 2: Enhanced SwipeCard with Improved Physics
// Replace existing SwipeCard with enhanced version

class EnhancedSwipeCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeUp;
  final bool enableSwipe;

  const EnhancedSwipeCard({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
    this.enableSwipe = true,
  });

  @override
  State<EnhancedSwipeCard> createState() => _EnhancedSwipeCardState();
}

class _EnhancedSwipeCardState extends State<EnhancedSwipeCard>
    with TickerProviderStateMixin {
  late EnhancedSwipeController _swipeController;

  @override
  void initState() {
    super.initState();
    _swipeController = EnhancedSwipeController(vsync: this);
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanStart:
              widget.enableSwipe
                  ? (details) {
                    _swipeController.startDrag(details.localPosition);
                  }
                  : null,
          onPanUpdate:
              widget.enableSwipe
                  ? (details) {
                    _swipeController.updateDrag(
                      details.localPosition,
                      screenSize,
                    );
                  }
                  : null,
          onPanEnd:
              widget.enableSwipe
                  ? (details) {
                    _swipeController.endDrag(
                      details.velocity.pixelsPerSecond,
                      screenSize,
                      onSwipeLeft: () {
                        HapticFeedbackService.mediumImpact();
                        widget.onSwipeLeft();
                      },
                      onSwipeRight: () {
                        HapticFeedbackService.mediumImpact();
                        widget.onSwipeRight();
                      },
                      onSwipeUp: () {
                        HapticFeedbackService.heavyImpact();
                        widget.onSwipeUp();
                      },
                    );
                  }
                  : null,
          child: AnimatedBuilder(
            animation: _swipeController,
            builder: (context, child) {
              return Transform.translate(
                offset: _swipeController.cardPosition,
                child: Transform.rotate(
                  angle: _swipeController.cardRotation,
                  child: widget.child,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Example 3: Loading States with Shimmer Effects
// Replace basic loading indicators with shimmer effects

class ShimmerLoadingExamples {
  /// Profile card shimmer placeholder
  static Widget profileCardShimmer() {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Image placeholder
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
            // Text placeholders
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 20,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(height: 16, width: 200, color: Colors.grey[300]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// List item shimmer placeholder
  static Widget listItemShimmer() {
    return ShimmerLoading(
      isLoading: true,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        title: Container(height: 16, color: Colors.grey[300]),
        subtitle: Container(height: 14, width: 150, color: Colors.grey[300]),
      ),
    );
  }

  /// Chat message shimmer placeholder
  static Widget chatMessageShimmer() {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 200, color: Colors.grey[300]),
                  const SizedBox(height: 4),
                  Container(height: 12, width: 100, color: Colors.grey[300]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example 4: Staggered List Animations
// Enhance list views with staggered animations

class StaggeredListView extends StatefulWidget {
  final List<Widget> children;
  final Duration animationDuration;
  final double staggerInterval;

  const StaggeredListView({
    super.key,
    required this.children,
    this.animationDuration = const Duration(milliseconds: 600),
    this.staggerInterval = 0.1,
  });

  @override
  State<StaggeredListView> createState() => _StaggeredListViewState();
}

class _StaggeredListViewState extends State<StaggeredListView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimations = StaggeredAnimationHelper.createStaggeredFadeIn(
      controller: _animationController,
      itemCount: widget.children.length,
      interval: widget.staggerInterval,
    );

    _slideAnimations = StaggeredAnimationHelper.createStaggeredSlideUp(
      controller: _animationController,
      itemCount: widget.children.length,
      interval: widget.staggerInterval,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimations[index],
              child: SlideTransition(
                position: _slideAnimations[index],
                child: widget.children[index],
              ),
            );
          },
        );
      },
    );
  }
}

// Example 5: Enhanced Button Interactions with Haptic Feedback
// Replace standard buttons with haptic feedback

class HapticButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final HapticFeedbackType feedbackType;
  final Color? backgroundColor;
  final EdgeInsets padding;

  const HapticButton({
    super.key,
    required this.child,
    this.onPressed,
    this.feedbackType = HapticFeedbackType.light,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  State<HapticButton> createState() => _HapticButtonState();
}

class _HapticButtonState extends State<HapticButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.onPressed != null) {
      // Animate button press
      await _animationController.forward();
      await _animationController.reverse();

      // Provide haptic feedback
      switch (widget.feedbackType) {
        case HapticFeedbackType.light:
          await HapticFeedbackService.lightImpact();
          break;
        case HapticFeedbackType.medium:
          await HapticFeedbackService.mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          await HapticFeedbackService.heavyImpact();
          break;
        case HapticFeedbackType.selection:
          await HapticFeedbackService.selectionClick();
          break;
      }

      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

enum HapticFeedbackType { light, medium, heavy, selection }

// Example 6: Like/Pass/Super Like Buttons with Animation
// Enhanced swipe action buttons with animations and feedback

class SwipeActionButtons extends StatelessWidget {
  final VoidCallback onLike;
  final VoidCallback onPass;
  final VoidCallback onSuperLike;
  final bool enabled;

  const SwipeActionButtons({
    super.key,
    required this.onLike,
    required this.onPass,
    required this.onSuperLike,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pass button
        HapticButton(
          onPressed:
              enabled
                  ? () {
                    HapticFeedbackService.lightImpact();
                    onPass();
                  }
                  : null,
          feedbackType: HapticFeedbackType.light,
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.close, color: Colors.grey, size: 30),
        ),

        // Super Like button
        HapticButton(
          onPressed:
              enabled
                  ? () {
                    HapticFeedbackService.heavyImpact();
                    onSuperLike();
                  }
                  : null,
          feedbackType: HapticFeedbackType.heavy,
          backgroundColor: Colors.blue[100],
          child: const Icon(Icons.star, color: Colors.blue, size: 30),
        ),

        // Like button
        HapticButton(
          onPressed:
              enabled
                  ? () {
                    HapticFeedbackService.mediumImpact();
                    onLike();
                  }
                  : null,
          feedbackType: HapticFeedbackType.medium,
          backgroundColor: Colors.pink[100],
          child: LoadingAnimations.pulsingHeart(color: Colors.pink, size: 30),
        ),
      ],
    );
  }
}

// Example 7: Match Animation Screen
// Enhanced match celebration with animations

class MatchCelebrationScreen extends StatefulWidget {
  final String userImageUrl;
  final String matchImageUrl;
  final VoidCallback onContinue;

  const MatchCelebrationScreen({
    super.key,
    required this.userImageUrl,
    required this.matchImageUrl,
    required this.onContinue,
  });

  @override
  State<MatchCelebrationScreen> createState() => _MatchCelebrationScreenState();
}

class _MatchCelebrationScreenState extends State<MatchCelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _slideController;
  late Animation<double> _heartAnimation;
  late Animation<Offset> _leftImageAnimation;
  late Animation<Offset> _rightImageAnimation;

  @override
  void initState() {
    super.initState();

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );

    _leftImageAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(-0.3, 0.0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _rightImageAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.3, 0.0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _startAnimation();
  }

  void _startAnimation() async {
    // Provide match haptic feedback
    await HapticFeedbackService.matchFeedback();

    // Start slide animations
    await _slideController.forward();

    // Start heart animation
    await _heartController.forward();

    // Auto-continue after delay
    Timer(const Duration(seconds: 3), widget.onContinue);
  }

  @override
  void dispose() {
    _heartController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background hearts
            ...List.generate(10, (index) {
              return Positioned(
                top: 100 + (index * 50.0),
                left: 50 + (index * 30.0),
                child: AnimatedBuilder(
                  animation: _heartController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _heartAnimation.value * 0.3,
                      child: Transform.scale(
                        scale: _heartAnimation.value,
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.pink,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            // User images
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left image (user)
                SlideTransition(
                  position: _leftImageAnimation,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(widget.userImageUrl),
                  ),
                ),

                // Center heart
                AnimatedBuilder(
                  animation: _heartAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _heartAnimation.value,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.pink,
                        size: 60,
                      ),
                    );
                  },
                ),

                // Right image (match)
                SlideTransition(
                  position: _rightImageAnimation,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(widget.matchImageUrl),
                  ),
                ),
              ],
            ),

            // Match text
            Positioned(
              bottom: 200,
              child: AnimatedBuilder(
                animation: _heartAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _heartAnimation.value,
                    child: const Text(
                      "It's a Match!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Continue button
            Positioned(
              bottom: 100,
              child: HapticButton(
                onPressed: widget.onContinue,
                feedbackType: HapticFeedbackType.medium,
                backgroundColor: Colors.pink,
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Integration Checklist:
// 1. ✅ Replace Navigator.push with CustomPageTransitions for smooth screen transitions
// 2. ✅ Enhance SwipeCard with EnhancedSwipeController for better physics and haptic feedback
// 3. ✅ Replace loading indicators with ShimmerLoading effects for better perceived performance
// 4. ✅ Add StaggeredListView for animated list entries
// 5. ✅ Replace standard buttons with HapticButton for tactile feedback
// 6. ✅ Implement SwipeActionButtons with enhanced animations
// 7. ✅ Create MatchCelebrationScreen with complex animations and haptic patterns
// 8. ✅ Add LoadingAnimations for custom loading states (hearts, spinners, dots)
// 9. ✅ Monitor animation performance with AnimationPerformanceManager
// 10. ✅ Use StaggeredAnimationHelper for coordinated multi-element animations
