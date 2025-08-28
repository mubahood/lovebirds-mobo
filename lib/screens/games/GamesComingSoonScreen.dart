// lib/screens/games/GamesComingSoonScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';

import '../../utils/CustomTheme.dart';

class GamesComingSoonScreen extends StatelessWidget {
  const GamesComingSoonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: FxText.titleLarge(
          'Games',
          color: CustomTheme.accent,
          fontWeight: 700,
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Subtle gradient circle behind icon
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      CustomTheme.primary.withValues(alpha: 0.2),
                      CustomTheme.primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Icon(
                  FeatherIcons.play,
                  size: 72,
                  color: CustomTheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              FxText.headlineSmall(
                'Online Games Coming Soon',
                color: CustomTheme.color,
                fontWeight: 800,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FxText.bodyLarge(
                'We’re hard at work building a collection of fun and engaging online games just for you. Stay tuned!',
                color: CustomTheme.color2,
                textAlign: TextAlign.center,
                fontWeight: 500,
              ),
              const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }
}