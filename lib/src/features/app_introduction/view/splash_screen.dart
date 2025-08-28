import 'dart:async';

import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:lovebirds_app/utils/AppConfig.dart';

import '../../../../controllers/MainController.dart';
import '../../../../screens/shop/screens/shop/full_app/full_app.dart';
import '../../../../utils/Utilities.dart';
import 'onboarding_screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final MainController mainController = Get.put(MainController());

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    Utils.init_theme();
    await mainController.getLoggedInUser();
    Utils.system_boot();

    // Auto-redirect after 5 seconds as requested
    await Future.delayed(const Duration(seconds: 5));

    if (mainController.loggedInUser.id < 1) {
      Get.to(() => const OnBoardingScreen());
      return;
    }

    // await Utils.initOneSignal(mainController.loggedInUser);
    Get.offAll(() => const HomeScreen());
    return;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFF0d1117), // Dark background
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with glow effect
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellowAccent.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AppConfig.logo_1,
                      width: isSmallScreen ? 100 : 120,
                      height: isSmallScreen ? 100 : 120,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 30),

                  // App Name with gradient
                  ShaderMask(
                    shaderCallback:
                        (bounds) => const LinearGradient(
                          colors: [Colors.yellowAccent, Colors.amber],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                    child: Text(
                      AppConfig.APP_NAME,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 30 : 50),

                  // Beautiful loader
                  Container(
                    width: isSmallScreen ? 50 : 60,
                    height: isSmallScreen ? 50 : 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.yellowAccent,
                      ),
                      backgroundColor: Colors.yellowAccent.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Loading text
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
