/// Design System Constants for Lovebirds Dating App
/// This file contains standardized typography, spacing, and design tokens
/// to ensure consistency across all screens.

import 'package:flutter/material.dart';

class LovebirdsDesignSystem {
  // TYPOGRAPHY SCALE
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // SPACING SCALE (using 8px base unit)
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;
  static const double space80 = 80.0;
  static const double space96 = 96.0;

  // PADDING PRESETS
  static const EdgeInsets paddingNone = EdgeInsets.zero;
  static const EdgeInsets paddingXS = EdgeInsets.all(space4);
  static const EdgeInsets paddingS = EdgeInsets.all(space8);
  static const EdgeInsets paddingM = EdgeInsets.all(space16);
  static const EdgeInsets paddingL = EdgeInsets.all(space24);
  static const EdgeInsets paddingXL = EdgeInsets.all(space32);

  static const EdgeInsets paddingHorizontalS = EdgeInsets.symmetric(
    horizontal: space8,
  );
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(
    horizontal: space16,
  );
  static const EdgeInsets paddingHorizontalL = EdgeInsets.symmetric(
    horizontal: space24,
  );
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(
    horizontal: space32,
  );

  static const EdgeInsets paddingVerticalS = EdgeInsets.symmetric(
    vertical: space8,
  );
  static const EdgeInsets paddingVerticalM = EdgeInsets.symmetric(
    vertical: space16,
  );
  static const EdgeInsets paddingVerticalL = EdgeInsets.symmetric(
    vertical: space24,
  );
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(
    vertical: space32,
  );

  // SIZED BOX PRESETS for consistent spacing
  static const SizedBox spaceV4 = SizedBox(height: space4);
  static const SizedBox spaceV8 = SizedBox(height: space8);
  static const SizedBox spaceV12 = SizedBox(height: space12);
  static const SizedBox spaceV16 = SizedBox(height: space16);
  static const SizedBox spaceV20 = SizedBox(height: space20);
  static const SizedBox spaceV24 = SizedBox(height: space24);
  static const SizedBox spaceV32 = SizedBox(height: space32);
  static const SizedBox spaceV40 = SizedBox(height: space40);
  static const SizedBox spaceV48 = SizedBox(height: space48);
  static const SizedBox spaceV56 = SizedBox(height: space56);
  static const SizedBox spaceV64 = SizedBox(height: space64);

  static const SizedBox spaceH4 = SizedBox(width: space4);
  static const SizedBox spaceH8 = SizedBox(width: space8);
  static const SizedBox spaceH12 = SizedBox(width: space12);
  static const SizedBox spaceH16 = SizedBox(width: space16);
  static const SizedBox spaceH20 = SizedBox(width: space20);
  static const SizedBox spaceH24 = SizedBox(width: space24);
  static const SizedBox spaceH32 = SizedBox(width: space32);

  // BORDER RADIUS
  static const Radius radiusS = Radius.circular(4);
  static const Radius radiusM = Radius.circular(8);
  static const Radius radiusL = Radius.circular(12);
  static const Radius radiusXL = Radius.circular(16);
  static const Radius radiusXXL = Radius.circular(24);
  static const Radius radiusRound = Radius.circular(999);

  static const BorderRadius borderRadiusS = BorderRadius.all(radiusS);
  static const BorderRadius borderRadiusM = BorderRadius.all(radiusM);
  static const BorderRadius borderRadiusL = BorderRadius.all(radiusL);
  static const BorderRadius borderRadiusXL = BorderRadius.all(radiusXL);
  static const BorderRadius borderRadiusXXL = BorderRadius.all(radiusXXL);
  static const BorderRadius borderRadiusRound = BorderRadius.all(radiusRound);

  // ELEVATION SCALE
  static const List<BoxShadow> elevationLow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> elevationMedium = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> elevationHigh = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 8)),
  ];

  // BUTTON HEIGHTS
  static const double buttonHeightS = 40;
  static const double buttonHeightM = 48;
  static const double buttonHeightL = 56;
  static const double buttonHeightXL = 64;

  // COMMON GRADIENTS
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
  );

  // ICON SIZES
  static const double iconSizeS = 16;
  static const double iconSizeM = 20;
  static const double iconSizeL = 24;
  static const double iconSizeXL = 32;
  static const double iconSizeXXL = 48;

  // COMMON DURATIONS
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);

  // OPACITY VALUES
  static const double opacityDisabled = 0.5;
  static const double opacityMuted = 0.7;
  static const double opacitySubtle = 0.8;

  /// Helper method to get text style with custom color
  static TextStyle getTextStyle(TextStyle baseStyle, Color color) {
    return baseStyle.copyWith(color: color);
  }

  /// Helper method to get text style with custom color and opacity
  static TextStyle getTextStyleWithOpacity(
    TextStyle baseStyle,
    Color color,
    double opacity,
  ) {
    return baseStyle.copyWith(color: color.withValues(alpha: opacity));
  }
}

/// Extension on TextStyle for easy color application
extension TextStyleExtension on TextStyle {
  TextStyle colored(Color color) => copyWith(color: color);
  TextStyle withOpacity(double opacity) =>
      copyWith(color: color?.withValues(alpha: opacity));
}

/// Extension on EdgeInsets for custom padding
extension EdgeInsetsExtension on EdgeInsets {
  static EdgeInsets symmetric({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal ?? 0,
      vertical: vertical ?? 0,
    );
  }

  static EdgeInsets only({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left ?? 0,
      top: top ?? 0,
      right: right ?? 0,
      bottom: bottom ?? 0,
    );
  }
}
