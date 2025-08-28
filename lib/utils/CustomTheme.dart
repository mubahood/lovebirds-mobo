import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

import '../core/styles.dart';

/// A centralized theme configuration for the app.
/// Main background is black, primary is red, and secondary accent is yellow.
class CustomTheme {
  // Core color palette
  static const Color background = Colors.black;
  static const Color primary = Colors.red;
  static const Color card = Color(0xFF1E1E1E);
  static const Color primaryDark = Colors.redAccent;
  static const Color accent = Colors.yellow;
  static const Color secondary = Colors.yellow;
  static const Color cardDark  = Color(0xFF2A2A2A);
  static const Color secondaryPurple = Color(0xFF9C27B0);

  // New semantic colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color accentGold   = Color(0xFFFFD700);
  static const Color errorRed     = Color(0xFFF44336);
  static const Color colorSecondary = secondaryPurple;
  static const Color colorLight     = Color(0xFFEEEEEE);



  // Text & border grays
  static Color color = Colors.grey.shade300;
  static Color color2 = Colors.grey.shade500;
  static Color color3 = Colors.grey.shade600;
  static Color color4 = Colors.grey.shade700;

  final Color border;
  final Color borderDark;
  final Color disabledColor;
  final Color onDisabled;
  final Color colorInfo;
  final Color colorWarning;
  final Color colorSuccess;
  final Color colorError;
  final Color shadowColor;
  final Color onInfo;
  final Color onWarning;
  final Color onSuccess;
  final Color onError;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;

  CustomTheme({
    this.border = const Color(0xFF3A3A3A),
    this.borderDark = const Color(0xFF4A4A4A),
    this.disabledColor = const Color(0xFF555555),
    this.onDisabled = const Color(0xFF888888),
    this.colorInfo = const Color(0xFF2196F3),
    this.colorWarning = const Color(0xFFFFC107),
    this.colorSuccess = const Color(0xFF4CAF50),
    this.colorError = const Color(0xFFF44336),
    this.onInfo = const Color(0xFFFFFFFF),
    this.onWarning = const Color(0xFF000000),
    this.onSuccess = const Color(0xFFFFFFFF),
    this.onError = const Color(0xFFFFFFFF),
    this.shadowColor = const Color(0xFF000000),
    this.shimmerBaseColor = const Color(0xFF2A2A2A),
    this.shimmerHighlightColor = const Color(0xFF3A3A3A),
  });

  /// Default input decoration with red primary and yellow accent
  static InputDecoration inputDecoration({
    String labelText = "",
    IconData icon = Icons.edit,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: primary),
      filled: true,
      fillColor: background.withValues(alpha: 0.1),
      labelText: labelText,
      labelStyle: TextStyle(color: accent),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primary),
        borderRadius: BorderRadius.circular(5),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryDark),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
 
  /// Dark theme instance
  static final CustomTheme dark = CustomTheme(

    border: Color(0xFF3A3A3A),
    borderDark: Color(0xFF4A4A4A),
    disabledColor: Color(0xFF555555),
    onDisabled: Color(0xFF888888),
    colorInfo: Color(0xFF2196F3),
    colorWarning: Color(0xFFFFC107),
    colorSuccess: Color(0xFF4CAF50),
    colorError: Color(0xFFF44336),
    onInfo: Colors.white,
    onWarning: Colors.black,
    onSuccess: Colors.white,
    onError: Colors.white,
    shadowColor: Colors.black54,
    shimmerBaseColor: Color(0xFF1E1E1E),
    shimmerHighlightColor: Color(0xFF2A2A2A),
  );

  static InputDecoration input_decoration(
      {String labelText = "",
        IconData icon = Icons.edit,
        bool isDense = false,
        double label_font_size = 16,
        EdgeInsetsGeometry padding = const EdgeInsets.all(10)}) {
    return InputDecoration(
      label: FxText.bodyLarge(
        labelText,
        color: Colors.black,
        fontSize: label_font_size,
        fontWeight: 900,
      ),
      isDense: isDense,
      contentPadding: padding,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      filled: true,
      labelStyle: FxTextStyle.bodyMedium(color: CustomTheme.accent),
      fillColor: CustomTheme.primary.withAlpha(40),
    );
  }

  static const input_outline_border = OutlineInputBorder(
    borderSide: BorderSide(color: CustomTheme.primary),
    borderRadius: BorderRadius.all(Radius.circular(50.0)),
  );

  static const input_outline_focused_border = OutlineInputBorder(
    borderSide: BorderSide(color: CustomTheme.primary),
    gapPadding: 20,
    borderRadius: BorderRadius.all(Radius.circular(50.0)),
  );

  static InputDecoration in_4(
    String labelText,
    String hintText, {
    IconData icon = Icons.edit,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: AppStyles.googleFontMontserrat.copyWith(
        color: Colors.grey.shade300,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      hintText: hintText,
      hintStyle: AppStyles.googleFontMontserrat.copyWith(
        color: Colors.grey.shade300,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      filled: true,
      fillColor: Colors.grey.shade800.withValues(alpha: .5),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  static InputDecoration in_3({
    String label = "",
    String hintText = "",
    double label_font_size = 16,
  }) {
    return InputDecoration(
      filled: true,
      isDense: false,
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      labelStyle: FxTextStyle.bodyMedium(
        color: Colors.grey.shade800,
        fontSize: label_font_size,
      ),
      contentPadding: const EdgeInsets.only(
        left: 0,
        bottom: 0,
        right: 0,
        top: 0,
      ),
      label: Text(
        label,
        style: FxTextStyle.bodyMedium(
          color: Colors.grey.shade800,
          fontSize: label_font_size,
          fontWeight: 700,
        ),
      ),
      hintText: hintText,
      helperMaxLines: 2,
      hintStyle: const TextStyle(fontWeight: FontWeight.w300),
      fillColor: Colors.white,
    );
  }

  InputDecoration input_decoration_2({
    String labelText = "",
    String hintText = "",
    dynamic suffixIcon,
    double label_font_size = 18,
  }) {
    return InputDecoration(
      suffixIcon:
          (suffixIcon == null) ? const SizedBox() : Icon(suffixIcon, size: 30),
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      filled: true,
      border: InputBorder.none,
      labelStyle: FxTextStyle.bodyLarge(
        color: Colors.grey.shade700,
        fontSize: label_font_size,
      ),
      labelText: labelText,
      hintText: hintText,
      hintStyle: const TextStyle(fontWeight: FontWeight.w300),
      fillColor: Colors.white,
    );
  }

  static InputDecoration input_decoration_4({String labelText = ""}) {
    return InputDecoration(
      hintText: labelText,
      hintStyle: const TextStyle(),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide.none,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.all(0),
    );
  }


  static InputDecoration input_decoration2(
      {String labelText = "", IconData icon = Icons.edit}) {
    return InputDecoration(
      label: FxText.bodyLarge(
        labelText,
        color: Colors.black,
        fontWeight: 900,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      labelStyle: FxTextStyle.bodyMedium(color: CustomTheme.accent),
      fillColor: CustomTheme.primary.withAlpha(40),
    );
  }

  /*InputDecoration input_decoration(
      {String labelText = "", IconData icon = Icons.edit}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: CustomTheme.primary),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: CustomTheme.primary),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: CustomTheme.primary),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      filled: true,
      border: InputBorder.none,
      labelStyle: FxTextStyle.bodyLarge(color: CustomTheme.accent),
      labelText: labelText,
      fillColor: CustomTheme.primary.withAlpha(40),
    );
  }
*/
}
