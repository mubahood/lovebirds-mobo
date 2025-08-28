import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import '../../services/onboarding_service.dart';
import '../../utils/CustomTheme.dart';
import '../dating/OrbitalSwipeScreen.dart';

/// Interactive Onboarding Screen with Step-by-Step Tutorials
class InteractiveOnboardingScreen extends StatefulWidget {
  const InteractiveOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<InteractiveOnboardingScreen> createState() =>
      _InteractiveOnboardingScreenState();
}

class _InteractiveOnboardingScreenState
    extends State<InteractiveOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _slideController;

  int _currentStep = 0;
  final int _totalSteps = 6;

  final OnboardingService _onboardingService = OnboardingService();

  // Onboarding steps data
  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: "Welcome to Lovebirds! 💕",
      description:
          "Find meaningful connections in Canada with our smart matching system.",
      icon: "💕",
      gradient: [Color(0xFFE91E63), Color(0xFFFF6B9D)],
      features: [
        "Smart compatibility matching",
        "Verified Canadian profiles",
        "Safe dating environment",
      ],
    ),
    OnboardingStep(
      title: "Discover Your Match 🔍",
      description:
          "Swipe through profiles and find people who share your interests and values.",
      icon: "🔍",
      gradient: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
      features: [
        "Location-based discovery",
        "Advanced compatibility scoring",
        "Detailed profile insights",
      ],
    ),
    OnboardingStep(
      title: "Connect & Chat 💬",
      description:
          "Start meaningful conversations with your matches and plan amazing dates.",
      icon: "💬",
      gradient: [Color(0xFF673AB7), Color(0xFF9575CD)],
      features: [
        "Real-time messaging",
        "Date planning tools",
        "Safety features built-in",
      ],
    ),
    OnboardingStep(
      title: "Premium Experience ✨",
      description:
          "Unlock unlimited features and get priority access to the best matches.",
      icon: "✨",
      gradient: [Color(0xFF3F51B5), Color(0xFF7986CB)],
      features: [
        "Unlimited swipes & super likes",
        "See who liked you",
        "Advanced search filters",
      ],
    ),
    OnboardingStep(
      title: "Safety First 🛡️",
      description:
          "Date with confidence using our comprehensive safety and verification system.",
      icon: "🛡️",
      gradient: [Color(0xFF2196F3), Color(0xFF64B5F6)],
      features: [
        "Photo & identity verification",
        "Safety check-ins for dates",
        "24/7 support team",
      ],
    ),
    OnboardingStep(
      title: "Ready to Find Love? 💖",
      description:
          "Your journey to meaningful connections starts now. Let's create your profile!",
      icon: "💖",
      gradient: [Color(0xFF4CAF50), Color(0xFF81C784)],
      features: [
        "Complete your profile",
        "Upload your best photos",
        "Start swiping and matching",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressController.forward();
      HapticFeedback.lightImpact();
    } else {
      _completeOnboarding();
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

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await _onboardingService.completeOnboarding();

    // Celebration haptic feedback
    HapticFeedback.mediumImpact();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OrbitalSwipeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress and skip
            _buildHeader(),

            // Main content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingStep(_steps[index]);
                },
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CustomTheme.primary,
                      CustomTheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('💕', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 8),
              FxText.titleMedium(
                'Lovebirds',
                color: Colors.white,
                fontWeight: 600,
              ),
            ],
          ),

          // Skip button
          GestureDetector(
            onTap: _skipOnboarding,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FxText.bodyMedium('Skip', color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingStep(OnboardingStep step) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutBack,
            ),
          ),
          child: FadeTransition(
            opacity: _slideController,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Progress indicator
                  _buildProgressIndicator(),

                  const SizedBox(height: 60),

                  // Icon with gradient background
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: step.gradient),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: step.gradient[0].withValues(alpha: 0.3),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        step.icon,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  FxText.headlineMedium(
                    step.title,
                    color: Colors.white,
                    fontWeight: 700,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  FxText.bodyLarge(
                    step.description,
                    color: Colors.white70,
                    textAlign: TextAlign.center,
                    height: 1.5,
                  ),

                  const SizedBox(height: 40),

                  // Features list
                  ...step.features.map((feature) => _buildFeatureItem(feature)),

                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalSteps, (index) {
        final isActive = index <= _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? CustomTheme.primary : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: CustomTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(child: FxText.bodyMedium(feature, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back button
          if (_currentStep > 0)
            Expanded(
              child: GestureDetector(
                onTap: _previousStep,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: FxText.bodyLarge(
                      'Back',
                      color: Colors.white,
                      fontWeight: 600,
                    ),
                  ),
                ),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 16),

          // Next/Complete button
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: GestureDetector(
              onTap: _nextStep,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CustomTheme.primary,
                      CustomTheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: CustomTheme.primary.withValues(alpha: 0.3),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FxText.bodyLarge(
                        _currentStep == _totalSteps - 1
                            ? 'Get Started'
                            : 'Continue',
                        color: Colors.white,
                        fontWeight: 700,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentStep == _totalSteps - 1
                            ? Icons.favorite
                            : Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Onboarding Step Data Model
class OnboardingStep {
  final String title;
  final String description;
  final String icon;
  final List<Color> gradient;
  final List<String> features;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.features,
  });
}
