import 'package:flutter/material.dart';

class DatingTheme {
  // Primary Colors
  static const Color primaryPink = Color(0xFFE91E63);
  static const Color secondaryPurple = Color(0xFF9C27B0);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color accent = Color(0xFF9C27B0); // Alias for secondaryPurple

  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningOrange = Color(0xFFFF9800);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color background = Color(
    0xFFF8F9FA,
  ); // Alias for backgroundColor
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    letterSpacing: 0.4,
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(primaryPink.value, {
        50: primaryPink.withValues(alpha: 0.1),
        100: primaryPink.withValues(alpha: 0.2),
        200: primaryPink.withValues(alpha: 0.3),
        300: primaryPink.withValues(alpha: 0.4),
        400: primaryPink.withValues(alpha: 0.5),
        500: primaryPink,
        600: primaryPink.withValues(alpha: 0.7),
        700: primaryPink.withValues(alpha: 0.8),
        800: primaryPink.withValues(alpha: 0.9),
        900: primaryPink,
      }),
      primaryColor: primaryPink,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardBackground,
      textTheme: const TextTheme(
        displayLarge: headingStyle,
        displayMedium: titleStyle,
        bodyLarge: bodyStyle,
        bodySmall: captionStyle,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPink,
          side: const BorderSide(color: primaryPink),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
