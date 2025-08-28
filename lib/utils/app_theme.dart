/*
* File : App Theme
* Version : 1.0.1
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lovebirds_app/utils/theme_type.dart';

import 'CustomTheme.dart';
import 'my_colors.dart';

class AppTheme {
  // switchable theme type
  static ThemeType themeType = ThemeType.dark;
  static TextDirection textDirection = TextDirection.ltr;

  static CustomTheme customTheme = getCustomTheme();
  static ThemeData theme = getTheme();

  /// Dark Theme: dark background, red primary, yellow secondary
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.redAccent,
    scaffoldBackgroundColor: CustomTheme.background,
    canvasColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: CustomTheme.background,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: CustomTheme.background,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: CustomTheme.background,
        systemNavigationBarIconBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
        statusBarBrightness: Brightness.light,
      ),
    ),
    cardTheme: const CardThemeData(color: Color(0xFF1E1E1E), elevation: 2),
    cardColor: const Color(0xFF1E1E1E),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white70),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.redAccent,
      foregroundColor: Colors.white,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: CustomTheme.background,
      elevation: 2,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) => Colors.redAccent),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => Colors.yellow.shade700.withValues(alpha: 0.5),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Colors.redAccent,
      inactiveTrackColor: Colors.redAccent.withValues(alpha: 0.3),
      thumbColor: Colors.redAccent,
      overlayColor: Colors.yellow.withValues(alpha: 0.2),
      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
    ),
    iconTheme: const IconThemeData(color: Colors.yellow),
    textTheme: TextTheme(
      titleLarge: GoogleFonts.lato(color: Colors.white),
      bodyLarge: GoogleFonts.lato(color: Colors.white70),
      bodyMedium: GoogleFonts.lato(color: Colors.white60),
      bodySmall: GoogleFonts.lato(color: Colors.white54),
    ),
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.redAccent,
      onPrimary: Colors.white,
      secondary: Colors.yellowAccent,
      onSecondary: Colors.black,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white70,
      error: Colors.orangeAccent,
      onError: Colors.black,
    ),
  );

  static ThemeData getTheme([ThemeType? t]) {
    return darkTheme;
  }

  static CustomTheme getCustomTheme([ThemeType? t]) {
    return CustomTheme.dark;
  }

  static init() {
    AppTheme.theme = getTheme();
    FlutX.changeTheme(theme);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:
            AppTheme.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
        statusBarIconBrightness:
            AppTheme
                .theme
                .appBarTheme
                .systemOverlayStyle!
                .statusBarIconBrightness,
        systemNavigationBarColor:
            AppTheme
                .theme
                .appBarTheme
                .systemOverlayStyle!
                .systemNavigationBarColor,
        systemNavigationBarIconBrightness:
            AppTheme
                .theme
                .appBarTheme
                .systemOverlayStyle!
                .systemNavigationBarIconBrightness,
        systemStatusBarContrastEnforced:
            AppTheme
                .theme
                .appBarTheme
                .systemOverlayStyle!
                .systemStatusBarContrastEnforced,
        systemNavigationBarContrastEnforced:
            AppTheme
                .theme
                .appBarTheme
                .systemOverlayStyle!
                .systemNavigationBarContrastEnforced,
        statusBarBrightness:
            AppTheme.theme.appBarTheme.systemOverlayStyle!.statusBarBrightness,
      ),
    );
  }

  static InputDecoration InputDecorationTheme1({
    bool isDense = true,
    String label = "",
    IconData iconData = Icons.edit,
    String hintText = "",
  }) {
    return InputDecoration(
      hintText: hintText.isEmpty ? null : hintText,
      isDense: isDense,
      label:
          (label.isEmpty)
              ? null
              : Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.grey.shade500,
                ),
              ),

      /*prefixIcon: Icon(
        iconData,
        color: Colors.grey.shade800,
      ),*/
      hintStyle: const TextStyle(fontSize: 15, color: Color(0xaa495057)),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(width: 1, color: MyColors.primary),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(width: 1, color: Colors.black54),
      ),
      disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(width: 1, color: Colors.black54),
      ),
      fillColor: Colors.grey.shade100,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(width: 1, color: Colors.black54),
      ),
    );
  }
}
