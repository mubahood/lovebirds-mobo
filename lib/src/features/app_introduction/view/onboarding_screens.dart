import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/features/moderation/screens/force_consent_screen.dart';
import 'package:lovebirds_app/models/LoggedInUserModel.dart';
import 'package:lovebirds_app/screens/auth/login_screen.dart';
import 'package:lovebirds_app/screens/dating/ProfileSetupWizardScreen.dart';
import 'package:lovebirds_app/utils/Utilities.dart';
import 'package:lovebirds_app/utils/consent_manager.dart';
import 'package:lovebirds_app/utils/lovebirds_theme.dart';

import '../../../../screens/shop/screens/shop/full_app/full_app.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;

  // Message Animation
  String _currentMessage = "";
  Timer? _messageTimer;
  int _currentMessageIndex = 0;

  // Beautiful romantic and motivational messages for Lovebirds
  final List<String> _loadingMessages = [
    "Finding your perfect match... 💕",
    "Love is in the air... ✨",
    "Connecting hearts worldwide... 💖",
    "Your soulmate is waiting... 🌟",
    "Creating meaningful connections... 💝",
    "Spreading love everywhere... 🦋",
    "Building lasting relationships... 🌸",
    "Love knows no boundaries... 🌍",
    "Every love story is beautiful... 📖",
    "Your journey to love begins now... 🚀",
    "Matching hearts and souls... 💫",
    "Love is the greatest adventure... 🗺️",
    "Finding your happily ever after... 🏰",
    "Where true love meets... 🌹",
    "Your perfect match awaits... ⭐",
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startMessageAnimation();
    myInit();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    // Fade animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Pulse animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Heart animation - removed unused controller

    // Floating animation
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Start animations with delays
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
        _floatingController.repeat(reverse: true);
      }
    });
  }

  void _startMessageAnimation() {
    _currentMessage = _loadingMessages[0];
    _messageTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _loadingMessages.length;
          _currentMessage = _loadingMessages[_currentMessageIndex];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              LovebirdsTheme.primary,
              LovebirdsTheme.primary.withValues(alpha: 0.8),
              const Color(0xFFFF6B9D),
              LovebirdsTheme.background,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating hearts background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _floatingController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: FloatingHeartsPainter(_floatingAnimation.value),
                    size: Size.infinite,
                  );
                },
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(minHeight: Get.height - 100),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(height: isSmallScreen ? 0 : 10),

                      // Animated Logo with enhanced effects
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Transform.rotate(
                              angle: _logoRotation.value,
                              child: Container(
                                width: isSmallScreen ? 80 : 80,
                                height: isSmallScreen ? 80 : 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pinkAccent.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value * 0.8,
                                      child: Icon(
                                        Icons.favorite,
                                        size: isSmallScreen ? 50 : 60,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: isSmallScreen ? 10 : 20),

                      // Animated Welcome Text
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textOpacity.value,
                            child: Column(
                              children: [
                                Text(
                                  'Welcome to Lovebirds',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 28 : 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10.0,
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
                                        offset: const Offset(0.0, 2.0),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: isSmallScreen ? 15 : 15),

                      // Animated loading message
                      AnimatedBuilder(
                        animation: _fadeController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 800),
                                child: Text(
                                  _currentMessage,
                                  key: ValueKey(_currentMessage),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: isSmallScreen ? 15 : 15),

                      // Enhanced Features Preview with animations
                      AnimatedBuilder(
                        animation: _fadeController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildAnimatedFeatureItem(
                                    Icons.verified_user,
                                    'Verified Profiles',
                                    'Meet real people with photos',
                                    0,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildAnimatedFeatureItem(
                                    Icons.psychology,
                                    'Smart Matching',
                                    'AI-powered matching',
                                    1,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildAnimatedFeatureItem(
                                    Icons.security,
                                    'Safe & Secure',
                                    'Private messaging with',
                                    2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: isSmallScreen ? 15 : 15),

                      // Animated floating emojis with message
                      AnimatedBuilder(
                        animation: _fadeController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value * 0.8,
                            child: Column(
                              children: [

                                Text(
                                  'Your love story begins here... ❤️',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: isSmallScreen ? 15 : 16,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: isSmallScreen ? 30 : 40),

                      // Loading indicator
                      AnimatedBuilder(
                        animation: _fadeController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value * 0.9,
                                  child: Container(
                                    width: isSmallScreen ? 60 : 70,
                                    height: isSmallScreen ? 60 : 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.yellowAccent.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 4,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.yellowAccent,
                                      ),
                                      backgroundColor: Color(0x33FFEB3B),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedFeatureItem(
    IconData icon,
    String title,
    String description,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1.0 - _fadeAnimation.value) * 50.0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale =
                        1.0 +
                        (sin(
                              _pulseController.value * pi * 2 +
                                  index * pi * 0.5,
                            ) *
                            0.1);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 28),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isProfileComplete(LoggedInUserModel user) {
    debugPrint('🔍 Checking profile completeness for user: ${user.name}');

    List<String> missingFields = [];

    if (user.first_name.isEmpty || user.first_name == "null")
      missingFields.add('First Name');

    if (user.bio.isEmpty || user.bio == "null") missingFields.add('Bio');

    if (user.dob.isEmpty || user.dob == "null")
      missingFields.add('Date of Birth');

    if (user.city.isEmpty || user.city == "null") missingFields.add('City');

    if (user.sexual_orientation.isEmpty || user.sexual_orientation == "null")
      missingFields.add('Sexual Orientation');

    if (missingFields.isNotEmpty) {
      debugPrint('❌ Profile incomplete. Missing: ${missingFields.join(', ')}');
      return false;
    }

    debugPrint('✅ Profile is complete');
    return true;
  }

  LoggedInUserModel u = LoggedInUserModel();

  void myInit() async {
    u = await LoggedInUserModel.getLoggedInUser();

    // Enhanced delay with animations (minimum 10 seconds)
    await Future.delayed(const Duration(seconds: 5));

    if (u.id < 1) {
      debugPrint('👤 No user logged in, redirecting to login');
      Get.off(() => const LoginScreen());
      return;
    }

    Utils.initOneSignal(u);
    Utils.toast("Welcome ${u.name}!");

    // Check if profile is complete
    if (!_isProfileComplete(u)) {
      debugPrint('📝 Profile incomplete, redirecting to profile setup');

      // Show motivational message
      final encouragementMessages = [
        'Complete your profile to find your perfect match! 💕',
        'A complete profile gets 5x more matches! ✨',
        'Tell your story and find someone special! 🌟',
        'Your soulmate is waiting - complete your profile! 💖',
        'Stand out with a complete profile! 🚀',
      ];

      final randomMessage =
          encouragementMessages[Random().nextInt(encouragementMessages.length)];

      Utils.toast(randomMessage, color: Colors.amber.shade600);

      Get.off(() => ProfileSetupWizardScreen(user: u, isEditing: true));
      return;
    }

    // Check legal compliance before proceeding to main app
    Utils.log("Checking legal compliance for user: ${u.name}");

    // Check if user has given legal consent
    bool hasConsent = await ConsentManager.hasLocalConsent();

    // If no local consent, check server and show force consent if needed
    if (!hasConsent) {
      hasConsent = await ConsentManager.checkAndUpdateConsentStatus();
    }

    if (!hasConsent) {
      Utils.log("Legal consent required - showing force consent screen");
      Get.off(() => const ForceConsentScreen());
      return;
    }

    Utils.log("Legal consent verified - proceeding to main app");
    debugPrint('🎉 Everything complete, redirecting to main app');
    Get.off(() => const HomeScreen());
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _logoController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }
}

// Custom painter for floating hearts background
class FloatingHeartsPainter extends CustomPainter {
  final double animation;

  FloatingHeartsPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.06)
          ..style = PaintingStyle.fill;

    const heartSize = 15.0;
    const spacing = 100.0;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final scale =
            0.5 + (sin(animation * pi * 2 + x * 0.01 + y * 0.01) * 0.3);
        final offsetY = sin(animation * pi * 2 + x * 0.02) * 10;
        _drawHeart(canvas, paint, x, y + offsetY, heartSize * scale);
      }
    }
  }

  void _drawHeart(Canvas canvas, Paint paint, double x, double y, double size) {
    final path = Path();
    path.moveTo(x, y + size * 0.3);

    path.cubicTo(
      x,
      y + size * 0.1,
      x - size * 0.5,
      y - size * 0.1,
      x - size * 0.5,
      y + size * 0.3,
    );

    path.cubicTo(
      x - size * 0.5,
      y + size * 0.5,
      x,
      y + size * 0.7,
      x,
      y + size,
    );

    path.cubicTo(
      x,
      y + size * 0.7,
      x + size * 0.5,
      y + size * 0.5,
      x + size * 0.5,
      y + size * 0.3,
    );

    path.cubicTo(
      x + size * 0.5,
      y - size * 0.1,
      x,
      y + size * 0.1,
      x,
      y + size * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(FloatingHeartsPainter oldDelegate) =>
      animation != oldDelegate.animation;
}
