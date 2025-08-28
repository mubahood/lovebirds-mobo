/*
* File : Dating Theme
* Version : 1.0.0
* Description : Lovebirds Dating App romantic color theme
*/

import 'package:flutter/material.dart';

class DatingTheme {
  // Primary Dating Colors - Romantic Palette
  static const Color primaryPink = Color(0xFFE91E63); // Material Pink
  static const Color primaryRose = Color(0xFFFF4081); // Pink Accent
  static const Color secondaryPurple = Color(0xFF9C27B0); // Deep Purple
  static const Color accentGold = Color(0xFFFFD700); // Gold accent
  static const Color accent = Color(0xFF9C27B0); // Alias for secondaryPurple

  // Gradient Colors for romantic effects
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPink, primaryRose],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heartGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF8A9B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient loveGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFC44569)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background Colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color background = Color(0xFFF8F9FA); // Light background alias
  static const Color cardBackground = Color(0xFF2D2D2D);
  static const Color surfaceColor = Color(0xFF363636);

  // Text Colors
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Color(0xFFB0B0B0);
  static const Color disabledText = Color(0xFF666666);

  // Success/Error Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningOrange = Color(0xFFFF9800);

  // Special Dating UI Colors
  static const Color likeGreen = Color(0xFF4CAF50);
  static const Color passRed = Color(0xFFF44336);
  static const Color superLikePurple = Color(0xFF673AB7);
  static const Color matchGold = Color(0xFFFFD700);

  // Premium Feature Colors
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color premiumPlatinum = Color(0xFFE5E4E2);

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [premiumGold, Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dating Action Button Colors
  static BoxDecoration getActionButtonDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration getGradientButtonDecoration(LinearGradient gradient) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: gradient.colors.first.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Swipe Card Decoration
  static BoxDecoration getSwipeCardDecoration() {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Match Card Decoration with romantic glow
  static BoxDecoration getMatchCardDecoration() {
    return BoxDecoration(
      gradient: heartGradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: primaryPink.withValues(alpha: 0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Premium Badge Decoration
  static BoxDecoration getPremiumBadgeDecoration() {
    return BoxDecoration(
      gradient: premiumGradient,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: premiumGold.withValues(alpha: 0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
