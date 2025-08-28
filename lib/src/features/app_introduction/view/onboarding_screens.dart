import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/features/moderation/screens/force_consent_screen.dart';
import 'package:lovebirds_app/models/LoggedInUserModel.dart';
import 'package:lovebirds_app/screens/auth/login_screen.dart';
import 'package:lovebirds_app/utils/Utilities.dart';
import 'package:lovebirds_app/utils/consent_manager.dart';
import 'package:lovebirds_app/utils/lovebirds_theme.dart';

import '../../../../screens/shop/screens/shop/full_app/full_app.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LovebirdsTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              LovebirdsTheme.primary,
              LovebirdsTheme.primary.withOpacity(0.8),
              LovebirdsTheme.background,
            ],
          ),
        ),
        child: SafeArea(child: newScreen()),
      ),
    );
  }

  newScreen() {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(minHeight: Get.height),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Spacer for top
            const SizedBox(height: 60),

            // Logo and Heart Animation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(Icons.favorite, size: 80, color: Colors.white),
            ),

            const SizedBox(height: 40),

            // Welcome Text
            Text(
              'Welcome to Lovebirds',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'Find meaningful connections\nand authentic relationships',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 18,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Features Preview
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildFeatureItem(
                    Icons.verified_user,
                    'Verified Profiles',
                    'Meet real people with verified photos',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    Icons.psychology,
                    'Smart Matching',
                    'AI-powered compatibility matching',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    Icons.security,
                    'Safe & Secure',
                    'Private messaging with safety features',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Simple footer text - no buttons
            Text(
              'Swipe right to continue exploring Lovebirds ❤️',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  LoggedInUserModel u = LoggedInUserModel();

  void myInit() async {
    u = await LoggedInUserModel.getLoggedInUser();
    await Future.delayed(const Duration(seconds: 5));

    if (u.id < 1) {
      Get.off(() => const LoginScreen());
      return;
    }

    Utils.initOneSignal(u);
    Utils.toast("Welcome ${u.name}!");

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
    Get.off(() => const HomeScreen());
  }
}
