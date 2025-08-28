import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced Theme Manager with Dynamic Switching and Advanced Customization
class DynamicThemeManager extends ChangeNotifier {
  static final DynamicThemeManager _instance = DynamicThemeManager._internal();
  factory DynamicThemeManager() => _instance;
  DynamicThemeManager._internal();

  // Theme states
  ThemeMode _themeMode = ThemeMode.dark;
  bool _useSystemTheme = false;
  bool _adaptiveColors = true;
  double _borderRadius = 20.0;
  double _cardElevation = 8.0;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get useSystemTheme => _useSystemTheme;
  bool get adaptiveColors => _adaptiveColors;
  double get borderRadius => _borderRadius;
  double get cardElevation => _cardElevation;

  /// Initialize theme from saved preferences
  Future<void> initializeTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeIndex = prefs.getInt('theme_mode') ?? 2; // Default to dark
      _themeMode = ThemeMode.values[themeIndex];

      _useSystemTheme = prefs.getBool('use_system_theme') ?? false;
      _adaptiveColors = prefs.getBool('adaptive_colors') ?? true;
      _borderRadius = prefs.getDouble('border_radius') ?? 20.0;
      _cardElevation = prefs.getDouble('card_elevation') ?? 8.0;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
    }
  }

  /// Set theme mode with smooth transition
  Future<void> setThemeMode(ThemeMode mode, {bool animate = true}) async {
    if (_themeMode == mode) return;

    if (animate) {
      await _animateThemeTransition();
    }

    _themeMode = mode;
    _useSystemTheme = false;

    await _saveThemePreferences();
    notifyListeners();

    // Update system UI overlay style
    _updateSystemUIOverlay();
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme({bool animate = true}) async {
    final newMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    await setThemeMode(newMode, animate: animate);

    // Haptic feedback for theme switching
    HapticFeedback.lightImpact();
  }

  /// Enable/disable system theme following
  Future<void> setSystemTheme(bool enabled) async {
    _useSystemTheme = enabled;
    if (enabled) {
      _themeMode = ThemeMode.system;
    }

    await _saveThemePreferences();
    notifyListeners();
  }

  /// Customize border radius
  Future<void> setBorderRadius(double radius) async {
    _borderRadius = radius.clamp(8.0, 40.0);
    await _saveThemePreferences();
    notifyListeners();
  }

  /// Customize card elevation
  Future<void> setCardElevation(double elevation) async {
    _cardElevation = elevation.clamp(0.0, 20.0);
    await _saveThemePreferences();
    notifyListeners();
  }

  /// Enable/disable adaptive colors
  Future<void> setAdaptiveColors(bool enabled) async {
    _adaptiveColors = enabled;
    await _saveThemePreferences();
    notifyListeners();
  }

  /// Animate theme transition with smooth effect
  Future<void> _animateThemeTransition() async {
    // Create a brief fade effect for smooth transition
    HapticFeedback.selectionClick();
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Update system UI overlay based on current theme
  void _updateSystemUIOverlay() {
    final isDark =
        _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            isDark ? const Color(0xFF121212) : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  /// Save theme preferences to persistent storage
  Future<void> _saveThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('theme_mode', _themeMode.index);
      await prefs.setBool('use_system_theme', _useSystemTheme);
      await prefs.setBool('adaptive_colors', _adaptiveColors);
      await prefs.setDouble('border_radius', _borderRadius);
      await prefs.setDouble('card_elevation', _cardElevation);
    } catch (e) {
      debugPrint('Error saving theme preferences: $e');
    }
  }

  /// Get current theme description for UI
  String get themeDescription {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light Theme';
      case ThemeMode.dark:
        return 'Dark Theme';
      case ThemeMode.system:
        return 'System Theme';
    }
  }

  /// Get theme customization summary
  Map<String, dynamic> getThemeSettings() {
    return {
      'themeMode': _themeMode.name,
      'useSystemTheme': _useSystemTheme,
      'adaptiveColors': _adaptiveColors,
      'borderRadius': _borderRadius,
      'cardElevation': _cardElevation,
    };
  }

  /// Reset to default theme settings
  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.dark;
    _useSystemTheme = false;
    _adaptiveColors = true;
    _borderRadius = 20.0;
    _cardElevation = 8.0;

    await _saveThemePreferences();
    notifyListeners();
    _updateSystemUIOverlay();
  }

  /// Check if current theme is dark
  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;

    // System theme
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }
}
