import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/screens/auth/login_screen.dart';


/// Modern Onboarding Screen with Smooth Animations
class ModernOnboardingScreen extends StatefulWidget {
  const ModernOnboardingScreen({Key? key}) : super(key: key);

  @override
  _ModernOnboardingScreenState createState() => _ModernOnboardingScreenState();
}

class _ModernOnboardingScreenState extends State<ModernOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _slideController;
  late AnimationController _buttonController;

  final RxInt _currentPage = 0.obs;
  final int _totalPages = 4;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Find Your\nPerfect Match",
      subtitle:
          "Discover meaningful connections with people who share your interests and values",
      icon: FeatherIcons.heart,
      image: "assets/images/onboarding_1.png",
      gradient: [Color(0xFFFF6B9D), Color(0xFFE91E63)],
      features: [
        "Smart compatibility matching",
        "Verified Canadian profiles",
        "Advanced search filters",
      ],
    ),
    OnboardingPage(
      title: "Connect &\nChat Safely",
      subtitle:
          "Start meaningful conversations in a safe and secure environment",
      icon: FeatherIcons.messageCircle,
      image: "assets/images/onboarding_2.png",
      gradient: [Color(0xFF9C27B0), Color(0xFF673AB7)],
      features: [
        "Real-time messaging",
        "Photo and video sharing",
        "Safety features built-in",
      ],
    ),
    OnboardingPage(
      title: "Plan Amazing\nDates",
      subtitle:
          "Discover local events and activities perfect for your first date",
      icon: FeatherIcons.map,
      image: "assets/images/onboarding_3.png",
      gradient: [Color(0xFF3F51B5), Color(0xFF2196F3)],
      features: [
        "Local event discovery",
        "Date planning tools",
        "Restaurant recommendations",
      ],
    ),
    OnboardingPage(
      title: "Premium\nExperience",
      subtitle:
          "Unlock exclusive features and get priority access to the best matches",
      icon: FeatherIcons.star,
      image: "assets/images/onboarding_4.png",
      gradient: [Color(0xFFFF9800), Color(0xFFF57C00)],
      features: [
        "Unlimited swipes & likes",
        "See who liked you",
        "Boost your profile",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startInitialAnimations();
  }

  void _initializeControllers() {
    _pageController = PageController();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  void _startInitialAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _slideController.forward();
        _buttonController.forward();
      }
    });
  }

  void _nextPage() {
    if (_currentPage.value < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToAuth();
    }
  }

  void _previousPage() {
    if (_currentPage.value > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _navigateToAuth() {
    // Add haptic feedback
    HapticFeedback.mediumImpact();

    // Navigate to login screen with custom transition
    Get.offAll(
      () => const LoginScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 600),
    );
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    _navigateToAuth();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background with current page gradient
          _buildAnimatedBackground(),

          // Main content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              _currentPage.value = page;
              HapticFeedback.selectionClick();
            },
            itemCount: _totalPages,
            itemBuilder:
                (context, index) => _buildOnboardingPage(_pages[index]),
          ),

          // Top navigation
          _buildTopNavigation(),

          // Bottom navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _pages[_currentPage.value].gradient,
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            Obx(
              () => AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _currentPage.value > 0 ? 1.0 : 0.0,
                child: GestureDetector(
                  onTap: _currentPage.value > 0 ? _previousPage : null,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      FeatherIcons.chevronLeft,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            // Skip button
            GestureDetector(
              onTap: _skipOnboarding,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 120),

                  // Main illustration area
                  Expanded(flex: 3, child: _buildIllustration(page)),

                  // Content area
                  Expanded(flex: 2, child: _buildContent(page)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIllustration(OnboardingPage page) {
    return Container(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
          ),

          // Inner circle
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(page.icon, size: 80, color: Colors.white),
          ),

          // Floating elements
          ...List.generate(6, (index) {
            final angle = (index * 60) * (3.14159 / 180);
            final radius = 140.0;
            return Positioned(
              left: 140 + radius * cos(angle),
              top: 140 + radius * sin(angle),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContent(OnboardingPage page) {
    return Column(
      children: [
        // Title
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 16),

        // Subtitle
        Text(
          page.subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 32),

        // Features list
        Column(
          children:
              page.features
                  .map((feature) => _buildFeatureItem(feature))
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            feature,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Page indicators
              _buildPageIndicators(),

              const SizedBox(height: 32),

              // Action button
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (index) {
        return Obx(
          () => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage.value == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  _currentPage.value == index
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton() {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _buttonController.value),
          child: Opacity(
            opacity: _buttonController.value,
            child: GestureDetector(
              onTap: _nextPage,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => Text(
                        _currentPage.value < _totalPages - 1
                            ? 'Continue'
                            : 'Get Started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _pages[_currentPage.value].gradient[0],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => Icon(
                        _currentPage.value < _totalPages - 1
                            ? FeatherIcons.arrowRight
                            : FeatherIcons.heart,
                        color: _pages[_currentPage.value].gradient[0],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final String image;
  final List<Color> gradient;
  final List<String> features;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.image,
    required this.gradient,
    required this.features,
  });
}
