import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern, Professional Splash Screen with Enhanced Animations
class ModernSplashScreen extends StatefulWidget {
  const ModernSplashScreen({Key? key}) : super(key: key);

  @override
  _ModernSplashScreenState createState() => _ModernSplashScreenState();
}

class _ModernSplashScreenState extends State<ModernSplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _progressController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textFade;
  late Animation<double> _textSlide;
  late Animation<double> _particleAnimation;
  late Animation<double> _progressAnimation;

  // Loading progress
  double _loadingProgress = 0.0;
  String _loadingText = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _simulateLoading();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _textSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Particle effects
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() {
    // Start logo animation
    _logoController.forward();

    // Start text animation after delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _textController.forward();
    });

    // Start particle animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _particleController.repeat();
    });

    // Start progress animation
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _progressController.forward();
    });
  }

  void _simulateLoading() async {
    final loadingSteps = [
      "Initializing app...",
      "Loading user preferences...",
      "Connecting to servers...",
      "Preparing your experience...",
      "Almost ready...",
    ];

    for (int i = 0; i < loadingSteps.length; i++) {
      await Future.delayed(Duration(milliseconds: 800 + (i * 200)));
      if (mounted) {
        setState(() {
          _loadingText = loadingSteps[i];
          _loadingProgress = (i + 1) / loadingSteps.length;
        });
      }
    }

    // Complete loading
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _loadingProgress = 1.0;
        _loadingText = "Welcome to Lovebirds!";
      });

      // Navigate to next screen after animation completes
      Future.delayed(const Duration(milliseconds: 800), () {
        // Add navigation logic here
        // Get.offAll(() => OnBoardingScreen());
      });
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _progressController.dispose();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6B9D),
              const Color(0xFFE91E63),
              const Color(0xFFAD1457),
              const Color(0xFF880E4F),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated Background Particles
            _buildAnimatedBackground(),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  _buildAnimatedLogo(),

                  const SizedBox(height: 40),

                  // App Name and Tagline
                  _buildAppTitle(),

                  const SizedBox(height: 80),

                  // Loading Progress
                  _buildLoadingSection(),
                ],
              ),
            ),

            // Bottom branding
            _buildBottomBranding(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating hearts
            ...List.generate(8, (index) {
              final offset = _particleAnimation.value * 360 + (index * 45);
              return Positioned(
                left: 50 + (index * 40) + (30 * _particleAnimation.value),
                top: 100 + (index * 80) + (50 * _particleAnimation.value),
                child: Transform.rotate(
                  angle: offset * 0.017453292519943295, // Convert to radians
                  child: Opacity(
                    opacity: 0.1 + (0.3 * _particleAnimation.value),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 20 + (index % 3) * 10,
                    ),
                  ),
                ),
              );
            }),

            // Subtle sparkles
            ...List.generate(12, (index) {
              return Positioned(
                left: (index * 30) + (100 * _particleAnimation.value),
                top: (index * 50) + (80 * _particleAnimation.value),
                child: Opacity(
                  opacity: 0.05 + (0.2 * _particleAnimation.value),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoScale, _logoRotation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Transform.rotate(
            angle: _logoRotation.value,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFFFF0F5),
                    Color(0xFFFFE4E1),
                  ],
                ),
                borderRadius: BorderRadius.circular(70),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Inner glow
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.pink.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),

                  // Heart icon
                  const Icon(
                    Icons.favorite,
                    color: Color(0xFFE91E63),
                    size: 70,
                  ),

                  // Pulse effect
                  AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, child) {
                      return Container(
                        width: 140 + (20 * _particleAnimation.value),
                        height: 140 + (20 * _particleAnimation.value),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.3 * (1 - _particleAnimation.value),
                            ),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            70 + (10 * _particleAnimation.value),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppTitle() {
    return AnimatedBuilder(
      animation: Listenable.merge([_textFade, _textSlide]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlide.value),
          child: Opacity(
            opacity: _textFade.value,
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback:
                      (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFFFF8DC), Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                  child: const Text(
                    'Lovebirds',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 3,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Find Your Perfect Match',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white,
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        // Loading text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _loadingText,
            key: ValueKey(_loadingText),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Modern progress indicator
        Container(
          width: 240,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            children: [
              // Progress fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 240 * _loadingProgress,
                height: 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFFFF8DC)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              // Shimmer effect
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Positioned(
                    left: -20 + (260 * _progressAnimation.value),
                    child: Container(
                      width: 40,
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Progress percentage
        Text(
          '${(_loadingProgress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBranding() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _textFade,
        builder: (context, child) {
          return Opacity(
            opacity: _textFade.value * 0.7,
            child: Column(
              children: [
                Text(
                  'Made with ❤️ in Canada',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
