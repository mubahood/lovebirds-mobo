import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import '../services/onboarding_service.dart'; // TODO: Create this service
import '../../utils/CustomTheme.dart';

/// Tutorial Overlay Manager for Contextual Help
class TutorialOverlayManager {
  static final TutorialOverlayManager _instance =
      TutorialOverlayManager._internal();
  factory TutorialOverlayManager() => _instance;
  TutorialOverlayManager._internal();

  final OnboardingService _onboardingService = OnboardingService();
  OverlayEntry? _currentOverlay;

  /// Show swipe tutorial overlay
  void showSwipeTutorial(BuildContext context) {
    if (!_onboardingService.shouldShowTutorial('swipe')) return;

    _showTutorialOverlay(
      context: context,
      tutorialType: 'swipe',
      title: 'How to Swipe',
      steps: [
        TutorialStep(
          icon: '👆',
          title: 'Swipe Right to Like',
          description:
              'Swipe right or tap the heart to like someone you\'re interested in.',
          position: TutorialPosition.center,
        ),
        TutorialStep(
          icon: '👈',
          title: 'Swipe Left to Pass',
          description:
              'Swipe left or tap the X to pass on profiles that aren\'t a match.',
          position: TutorialPosition.center,
        ),
        TutorialStep(
          icon: '⭐',
          title: 'Swipe Up for Super Like',
          description:
              'Swipe up or tap the star to send a super like and get noticed!',
          position: TutorialPosition.center,
        ),
      ],
    );
  }

  /// Show match tutorial overlay
  void showMatchTutorial(BuildContext context) {
    if (!_onboardingService.shouldShowTutorial('match')) return;

    _showTutorialOverlay(
      context: context,
      tutorialType: 'match',
      title: 'You Got a Match! 💕',
      steps: [
        TutorialStep(
          icon: '🎉',
          title: 'Mutual Interest',
          description:
              'When someone likes you back, it\'s a match! You can now start chatting.',
          position: TutorialPosition.center,
        ),
        TutorialStep(
          icon: '💬',
          title: 'Start Chatting',
          description:
              'Tap "Send Message" to break the ice and start a conversation.',
          position: TutorialPosition.bottom,
        ),
      ],
    );
  }

  /// Show chat tutorial overlay
  void showChatTutorial(BuildContext context) {
    if (!_onboardingService.shouldShowTutorial('chat')) return;

    _showTutorialOverlay(
      context: context,
      tutorialType: 'chat',
      title: 'Chat Features',
      steps: [
        TutorialStep(
          icon: '💬',
          title: 'Send Messages',
          description:
              'Type your message and tap send to chat with your match.',
          position: TutorialPosition.bottom,
        ),
        TutorialStep(
          icon: '📅',
          title: 'Plan a Date',
          description:
              'Use the date planning feature to suggest restaurants and activities.',
          position: TutorialPosition.top,
        ),
        TutorialStep(
          icon: '🛡️',
          title: 'Stay Safe',
          description:
              'Use the safety features like check-ins and emergency alerts.',
          position: TutorialPosition.top,
        ),
      ],
    );
  }

  /// Show profile tutorial overlay
  void showProfileTutorial(BuildContext context) {
    if (!_onboardingService.shouldShowTutorial('profile')) return;

    _showTutorialOverlay(
      context: context,
      tutorialType: 'profile',
      title: 'Complete Your Profile',
      steps: [
        TutorialStep(
          icon: '📸',
          title: 'Add Photos',
          description:
              'Upload multiple photos to show your personality and increase matches.',
          position: TutorialPosition.center,
        ),
        TutorialStep(
          icon: '✏️',
          title: 'Write a Bio',
          description:
              'Add a compelling bio that tells your story and what you\'re looking for.',
          position: TutorialPosition.center,
        ),
        TutorialStep(
          icon: '✅',
          title: 'Get Verified',
          description:
              'Complete photo and identity verification to build trust.',
          position: TutorialPosition.center,
        ),
      ],
    );
  }

  /// Show marketplace tutorial overlay
  void showMarketplaceTutorial(BuildContext context) {
    if (!_onboardingService.shouldShowTutorial('marketplace')) return;

    _showTutorialOverlay(
      context: context,
      tutorialType: 'marketplace',
      title: 'Dating Marketplace',
      steps: [
        TutorialStep(
          icon: '🎁',
          title: 'Send Gifts',
          description:
              'Send thoughtful gifts to your matches to show you care.',
          position: TutorialPosition.center,
        ),
        TutorialStep(
          icon: '🍽️',
          title: 'Plan Dates',
          description:
              'Book restaurants and activities directly through the app.',
          position: TutorialPosition.center,
        ),
        TutorialStep(
          icon: '🛍️',
          title: 'Shop Together',
          description:
              'Browse and shop with your partner for special occasions.',
          position: TutorialPosition.center,
        ),
      ],
    );
  }

  /// Show generic tutorial overlay
  void _showTutorialOverlay({
    required BuildContext context,
    required String tutorialType,
    required String title,
    required List<TutorialStep> steps,
  }) {
    _dismissCurrentOverlay();

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _currentOverlay = OverlayEntry(
      builder:
          (context) => TutorialOverlay(
            title: title,
            steps: steps,
            onComplete: () async {
              await _onboardingService.completeTutorial(tutorialType);
              _dismissCurrentOverlay();
            },
            onSkip: () async {
              await _onboardingService.completeTutorial(tutorialType);
              _dismissCurrentOverlay();
            },
          ),
    );

    overlay.insert(_currentOverlay!);
  }

  /// Dismiss current overlay
  void _dismissCurrentOverlay() {
    if (_currentOverlay != null && _currentOverlay!.mounted) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }
  }

  /// Check if overlay is currently showing
  bool get isShowingOverlay => _currentOverlay != null;
}

/// Tutorial Overlay Widget
class TutorialOverlay extends StatefulWidget {
  final String title;
  final List<TutorialStep> steps;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const TutorialOverlay({
    Key? key,
    required this.title,
    required this.steps,
    required this.onComplete,
    required this.onSkip,
  }) : super(key: key);

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _stepController;
  late PageController _pageController;

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _stepController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pageController = PageController();

    _animationController.forward();
    _stepController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stepController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _stepController.reset();
      _stepController.forward();
      HapticFeedback.lightImpact();
    } else {
      widget.onComplete();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withValues(alpha: 0.8 * _animationController.value),
          child: SafeArea(
            child: Stack(
              children: [
                // Dismiss on tap outside
                GestureDetector(
                  onTap: widget.onSkip,
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),

                // Tutorial content
                Center(
                  child: GestureDetector(
                    onTap: () {}, // Prevent dismissal when tapping content
                    child: Transform.scale(
                      scale: _animationController.value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          color: CustomTheme.cardDark,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              spreadRadius: 2,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            _buildHeader(),

                            // Content
                            SizedBox(
                              height: 300,
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentStep = index;
                                  });
                                },
                                itemCount: widget.steps.length,
                                itemBuilder: (context, index) {
                                  return _buildStepContent(widget.steps[index]);
                                },
                              ),
                            ),

                            // Navigation
                            _buildNavigation(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.primary.withValues(alpha: 0.1), Colors.transparent],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                color: CustomTheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: widget.onSkip,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.close, color: Colors.white70, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(TutorialStep step) {
    return AnimatedBuilder(
      animation: _stepController,
      builder: (context, child) {
        return Opacity(
          opacity: _stepController.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _stepController.value)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CustomTheme.primary.withValues(alpha: 0.2),
                          CustomTheme.primary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Text(
                        step.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    step.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    step.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.steps.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _currentStep ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      index == _currentStep
                          ? CustomTheme.primary
                          : Colors.white30,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              // Previous button
              if (_currentStep > 0)
                Expanded(
                  child: GestureDetector(
                    onTap: _previousStep,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              if (_currentStep > 0) const SizedBox(width: 12),

              // Next/Complete button
              Expanded(
                flex: _currentStep > 0 ? 1 : 2,
                child: GestureDetector(
                  onTap: _nextStep,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CustomTheme.primary,
                          CustomTheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Center(
                      child: Text(
                        _currentStep == widget.steps.length - 1
                            ? 'Got it!'
                            : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tutorial Step Data Model
class TutorialStep {
  final String icon;
  final String title;
  final String description;
  final TutorialPosition position;

  TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
    this.position = TutorialPosition.center,
  });
}

/// Tutorial Position Enum
enum TutorialPosition { top, center, bottom }
