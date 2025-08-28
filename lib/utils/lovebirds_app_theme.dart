/*
* File : Lovebirds Dating App Theme
* Version : 1.0.0
* Description : Complete theme system for Lovebirds Dating App
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dating_theme.dart';

class LovebirdsAppTheme {
  /// Primary Dating App Theme - Dark with romantic pink accents
  static final ThemeData datingTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: DatingTheme.primaryPink,
    scaffoldBackgroundColor: DatingTheme.darkBackground,
    canvasColor: Colors.transparent,

    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: DatingTheme.primaryPink,
      secondary: DatingTheme.primaryRose,
      surface: DatingTheme.cardBackground,
      background: DatingTheme.darkBackground,
      error: DatingTheme.errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: DatingTheme.primaryText,
      onBackground: DatingTheme.primaryText,
      onError: Colors.white,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: DatingTheme.darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF1A1A1A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),



    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DatingTheme.primaryPink,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DatingTheme.primaryPink,
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DatingTheme.primaryPink,
        side: const BorderSide(color: DatingTheme.primaryPink),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DatingTheme.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: DatingTheme.surfaceColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: DatingTheme.primaryPink, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: DatingTheme.errorRed),
      ),
      labelStyle: GoogleFonts.poppins(
        color: DatingTheme.secondaryText,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.poppins(
        color: DatingTheme.disabledText,
        fontSize: 14,
      ),
    ),

    // Text Theme
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          color: DatingTheme.primaryText,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: DatingTheme.primaryText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: DatingTheme.primaryText,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: DatingTheme.primaryText,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: DatingTheme.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: DatingTheme.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          color: DatingTheme.primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: DatingTheme.primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: DatingTheme.secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: DatingTheme.primaryText,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: DatingTheme.primaryText,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: DatingTheme.secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: DatingTheme.primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: DatingTheme.secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: DatingTheme.disabledText,
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: DatingTheme.cardBackground,
      selectedItemColor: DatingTheme.primaryPink,
      unselectedItemColor: DatingTheme.secondaryText,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w400,
      ),
    ),


    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: DatingTheme.primaryPink,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: DatingTheme.primaryText, size: 24),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: DatingTheme.surfaceColor,
      selectedColor: DatingTheme.primaryPink,
      labelStyle: GoogleFonts.poppins(
        color: DatingTheme.primaryText,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return DatingTheme.primaryPink;
        }
        return DatingTheme.secondaryText;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return DatingTheme.primaryPink.withValues(alpha: 0.5);
        }
        return DatingTheme.surfaceColor;
      }),
    ),


  );

  /// Gradient Decorations for Special UI Elements
  static BoxDecoration get primaryGradientDecoration => BoxDecoration(
    gradient: DatingTheme.primaryGradient,
    borderRadius: BorderRadius.circular(30),
  );

  static BoxDecoration get heartGradientDecoration => BoxDecoration(
    gradient: DatingTheme.heartGradient,
    borderRadius: BorderRadius.circular(20),
  );

  static BoxDecoration get loveGradientDecoration => BoxDecoration(
    gradient: DatingTheme.loveGradient,
    borderRadius: BorderRadius.circular(25),
  );

  /// Method to initialize the theme
  static void init() {
    // Initialize any theme-related services
    print('🎨 Lovebirds Dating Theme Initialized');
  }
}
