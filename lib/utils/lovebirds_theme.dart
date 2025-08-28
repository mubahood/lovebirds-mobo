import 'package:flutter/material.dart';
import './design_system.dart';

/// Enhanced Lovebirds Theme with Design System Integration
/// This extends the existing CustomTheme with standardized design tokens
class LovebirdsTheme {
  // CORE BRAND COLORS (keeping existing brand identity)
  static const Color background = Colors.black;
  static const Color primary = Colors.red;
  static const Color card = Color(0xFF1E1E1E);
  static const Color primaryDark = Colors.redAccent;
  static const Color accent = Colors.yellow;
  static const Color secondary = Colors.yellow;
  static const Color cardDark = Color(0xFF2A2A2A);

  // EXTENDED COLOR PALETTE FOR DATING FEATURES
  static const Color like = Color(0xFF4CAF50); // Green for likes
  static const Color pass = Color(0xFF757575); // Gray for pass
  static const Color superLike = Color(0xFF2196F3); // Blue for super like
  static const Color match = Color(0xFFFF6B6B); // Pink for matches
  static const Color online = Color(0xFF4CAF50); // Green for online status
  static const Color offline = Color(0xFF757575); // Gray for offline

  // TEXT COLORS WITH OPACITY VARIANTS
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textMuted = Color(0xFF808080);
  static const Color textDisabled = Color(0xFF555555);

  // SURFACE COLORS
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2A2A2A);
  static const Color surfaceContainer = Color(0xFF3A3A3A);

  // BORDER COLORS
  static const Color border = Color(0xFF3A3A3A);
  static const Color borderVariant = Color(0xFF4A4A4A);
  static const Color divider = Color(0xFF2A2A2A);

  // STATUS COLORS
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color success = Color(0xFF4CAF50);
  static const Color info = Color(0xFF2196F3);

  // SEMANTIC COLORS FOR DATING ACTIONS
  static const Color swipeRight = like;
  static const Color swipeLeft = pass;
  static const Color swipeUp = superLike;

  /// STANDARDIZED TEXT STYLES FOR DATING APP
  /// Using the design system typography scale

  // Headers for main screens (Discover, Matches, etc.)
  static TextStyle get screenTitle =>
      LovebirdsDesignSystem.headlineMedium.colored(textPrimary);

  // Profile names on cards
  static TextStyle get profileName =>
      LovebirdsDesignSystem.headlineSmall.colored(textPrimary);

  // Profile details (age, distance)
  static TextStyle get profileDetails =>
      LovebirdsDesignSystem.bodyMedium.colored(textSecondary);

  // Bio text
  static TextStyle get profileBio =>
      LovebirdsDesignSystem.bodyMedium.colored(textPrimary);

  // Button labels
  static TextStyle get buttonLabel =>
      LovebirdsDesignSystem.labelLarge.colored(textPrimary);

  // Small labels (like count, match count)
  static TextStyle get counterLabel =>
      LovebirdsDesignSystem.labelSmall.colored(textSecondary);

  // Chat messages
  static TextStyle get messageText =>
      LovebirdsDesignSystem.bodyMedium.colored(textPrimary);

  // Timestamps
  static TextStyle get timestampText =>
      LovebirdsDesignSystem.bodySmall.colored(textMuted);

  // Form field labels
  static TextStyle get fieldLabel =>
      LovebirdsDesignSystem.bodyMedium.colored(textSecondary);

  // Error messages
  static TextStyle get errorText =>
      LovebirdsDesignSystem.bodySmall.colored(error);

  /// COMPONENT STYLING PRESETS

  // Profile Card Styling
  static BoxDecoration get profileCardDecoration => BoxDecoration(
    color: card,
    borderRadius: LovebirdsDesignSystem.borderRadiusXL,
    boxShadow: LovebirdsDesignSystem.elevationMedium,
  );

  // Action Button (Like, Pass, Super Like)
  static BoxDecoration actionButtonDecoration(Color color) => BoxDecoration(
    color: color,
    shape: BoxShape.circle,
    boxShadow: LovebirdsDesignSystem.elevationLow,
  );

  // Chat Bubble Styling
  static BoxDecoration chatBubbleDecoration(bool isMe) => BoxDecoration(
    color: isMe ? primary : surface,
    borderRadius: BorderRadius.circular(18),
  );

  // Form Field Styling
  static InputDecoration get formFieldDecoration => InputDecoration(
    filled: true,
    fillColor: surface,
    border: OutlineInputBorder(
      borderRadius: LovebirdsDesignSystem.borderRadiusM,
      borderSide: BorderSide(color: border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: LovebirdsDesignSystem.borderRadiusM,
      borderSide: BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: LovebirdsDesignSystem.borderRadiusM,
      borderSide: BorderSide(color: primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: LovebirdsDesignSystem.borderRadiusM,
      borderSide: BorderSide(color: error),
    ),
    contentPadding: LovebirdsDesignSystem.paddingM,
    labelStyle: fieldLabel,
    hintStyle: fieldLabel.colored(textMuted),
  );

  /// STANDARDIZED SPACING FOR DATING LAYOUTS

  // Screen padding (edges of main content)
  static EdgeInsets get screenPadding => LovebirdsDesignSystem.paddingL;

  // Card padding (inside profile cards, chat bubbles)
  static EdgeInsets get cardPadding => LovebirdsDesignSystem.paddingM;

  // List item padding (between list items)
  static EdgeInsets get listItemPadding =>
      LovebirdsDesignSystem.paddingVerticalM;

  // Form field spacing
  static EdgeInsets get fieldSpacing => LovebirdsDesignSystem.paddingVerticalM;

  /// ANIMATION DURATIONS
  static Duration get cardSwipeAnimation =>
      LovebirdsDesignSystem.animationMedium;
  static Duration get matchAnimation => LovebirdsDesignSystem.animationSlow;
  static Duration get uiTransition => LovebirdsDesignSystem.animationFast;

  /// ICON SIZES FOR DATING ACTIONS
  static double get actionIconSize => LovebirdsDesignSystem.iconSizeXL;
  static double get navigationIconSize => LovebirdsDesignSystem.iconSizeL;
  static double get statusIconSize => LovebirdsDesignSystem.iconSizeM;

  /// BUTTON CONFIGURATIONS

  // Primary action button (Like, Match, Send Message)
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: textPrimary,
    minimumSize: Size(double.infinity, LovebirdsDesignSystem.buttonHeightL),
    shape: RoundedRectangleBorder(
      borderRadius: LovebirdsDesignSystem.borderRadiusXXL,
    ),
    textStyle: buttonLabel,
  );

  // Secondary action button (Pass, Cancel)
  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: surface,
    foregroundColor: textSecondary,
    minimumSize: Size(double.infinity, LovebirdsDesignSystem.buttonHeightL),
    shape: RoundedRectangleBorder(
      borderRadius: LovebirdsDesignSystem.borderRadiusXXL,
      side: BorderSide(color: border),
    ),
    textStyle: buttonLabel,
  );

  // Floating Action Button for Super Like
  static ButtonStyle get superLikeButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: superLike,
    foregroundColor: textPrimary,
    shape: const CircleBorder(),
    minimumSize: Size(
      LovebirdsDesignSystem.buttonHeightXL,
      LovebirdsDesignSystem.buttonHeightXL,
    ),
  );

  /// GRADIENTS FOR SPECIAL EFFECTS
  static LinearGradient get likeGradient =>
      const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)]);

  static LinearGradient get passGradient =>
      const LinearGradient(colors: [Color(0xFF757575), Color(0xFF9E9E9E)]);

  static LinearGradient get superLikeGradient =>
      const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF42A5F5)]);

  static LinearGradient get matchGradient =>
      const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8A80)]);

  /// STATUS INDICATOR COLORS
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return online;
      case 'offline':
        return offline;
      case 'away':
        return warning;
      default:
        return textMuted;
    }
  }

  /// UTILITY METHODS

  // Get text style with opacity
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withValues(alpha: opacity));
  }

  // Get color with opacity
  static Color colorWithOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  // Theme configuration for Material Theme
  static ThemeData get materialTheme => ThemeData.dark().copyWith(
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    cardColor: card,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      titleTextStyle: screenTitle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: LovebirdsDesignSystem.borderRadiusM,
        borderSide: BorderSide(color: border),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: LovebirdsDesignSystem.displayLarge.colored(textPrimary),
      displayMedium: LovebirdsDesignSystem.displayMedium.colored(textPrimary),
      displaySmall: LovebirdsDesignSystem.displaySmall.colored(textPrimary),
      headlineLarge: LovebirdsDesignSystem.headlineLarge.colored(textPrimary),
      headlineMedium: LovebirdsDesignSystem.headlineMedium.colored(textPrimary),
      headlineSmall: LovebirdsDesignSystem.headlineSmall.colored(textPrimary),
      titleLarge: LovebirdsDesignSystem.titleLarge.colored(textPrimary),
      titleMedium: LovebirdsDesignSystem.titleMedium.colored(textPrimary),
      titleSmall: LovebirdsDesignSystem.titleSmall.colored(textPrimary),
      bodyLarge: LovebirdsDesignSystem.bodyLarge.colored(textPrimary),
      bodyMedium: LovebirdsDesignSystem.bodyMedium.colored(textPrimary),
      bodySmall: LovebirdsDesignSystem.bodySmall.colored(textSecondary),
      labelLarge: LovebirdsDesignSystem.labelLarge.colored(textPrimary),
      labelMedium: LovebirdsDesignSystem.labelMedium.colored(textSecondary),
      labelSmall: LovebirdsDesignSystem.labelSmall.colored(textMuted),
    ),
  );
}
