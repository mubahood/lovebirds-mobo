import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Accessibility Service for Enhanced App Inclusivity
class AccessibilityService {
  static final AccessibilityService _instance =
      AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  // Accessibility settings
  bool _screenReaderEnabled = false;
  bool _highContrastEnabled = false;
  bool _largeTextEnabled = false;
  bool _reducedMotionEnabled = false;
  bool _voiceAnnouncementsEnabled = true;
  double _textScaleFactor = 1.0;
  double _buttonSizeMultiplier = 1.0;

  // Getters
  bool get screenReaderEnabled => _screenReaderEnabled;
  bool get highContrastEnabled => _highContrastEnabled;
  bool get largeTextEnabled => _largeTextEnabled;
  bool get reducedMotionEnabled => _reducedMotionEnabled;
  bool get voiceAnnouncementsEnabled => _voiceAnnouncementsEnabled;
  double get textScaleFactor => _textScaleFactor;
  double get buttonSizeMultiplier => _buttonSizeMultiplier;

  /// Initialize accessibility service
  Future<void> initialize() async {
    await _loadAccessibilitySettings();
    _detectSystemAccessibilitySettings();
  }

  /// Detect system accessibility settings
  void _detectSystemAccessibilitySettings() {
    // Check if system screen reader is enabled
    _screenReaderEnabled =
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .accessibleNavigation;

    // Check if high contrast is enabled
    _highContrastEnabled =
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .highContrast;

    // Check if large text is enabled
    _largeTextEnabled =
        WidgetsBinding.instance.platformDispatcher.textScaleFactor > 1.3;

    // Check if reduced motion is enabled
    _reducedMotionEnabled =
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .reduceMotion;

    // Auto-adjust text scale factor based on system settings
    if (_largeTextEnabled) {
      _textScaleFactor = WidgetsBinding
          .instance
          .platformDispatcher
          .textScaleFactor
          .clamp(1.0, 2.0);
    }
  }

  /// Update accessibility settings
  Future<void> setScreenReader(bool enabled) async {
    _screenReaderEnabled = enabled;
    await _saveAccessibilitySettings();

    if (enabled) {
      _announceToScreenReader('Screen reader support enabled');
    }
  }

  Future<void> setHighContrast(bool enabled) async {
    _highContrastEnabled = enabled;
    await _saveAccessibilitySettings();

    if (_screenReaderEnabled) {
      _announceToScreenReader(
        enabled ? 'High contrast enabled' : 'High contrast disabled',
      );
    }
  }

  Future<void> setLargeText(bool enabled) async {
    _largeTextEnabled = enabled;
    _textScaleFactor = enabled ? 1.3 : 1.0;
    await _saveAccessibilitySettings();

    if (_screenReaderEnabled) {
      _announceToScreenReader(
        enabled ? 'Large text enabled' : 'Large text disabled',
      );
    }
  }

  Future<void> setReducedMotion(bool enabled) async {
    _reducedMotionEnabled = enabled;
    await _saveAccessibilitySettings();

    if (_screenReaderEnabled) {
      _announceToScreenReader(
        enabled ? 'Reduced motion enabled' : 'Reduced motion disabled',
      );
    }
  }

  Future<void> setVoiceAnnouncements(bool enabled) async {
    _voiceAnnouncementsEnabled = enabled;
    await _saveAccessibilitySettings();
  }

  Future<void> setTextScaleFactor(double factor) async {
    _textScaleFactor = factor.clamp(0.8, 2.0);
    await _saveAccessibilitySettings();

    if (_screenReaderEnabled) {
      _announceToScreenReader(
        'Text size adjusted to ${(_textScaleFactor * 100).round()}%',
      );
    }
  }

  Future<void> setButtonSizeMultiplier(double multiplier) async {
    _buttonSizeMultiplier = multiplier.clamp(1.0, 1.5);
    await _saveAccessibilitySettings();

    if (_screenReaderEnabled) {
      _announceToScreenReader(
        'Button size adjusted to ${(_buttonSizeMultiplier * 100).round()}%',
      );
    }
  }

  /// Screen reader announcements
  void _announceToScreenReader(String message) {
    if (_screenReaderEnabled && _voiceAnnouncementsEnabled) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }

  void announceScreenChange(String screenName) {
    _announceToScreenReader('Navigated to $screenName');
  }

  void announceAction(String action) {
    _announceToScreenReader(action);
  }

  void announceMatch(String matchName) {
    _announceToScreenReader(
      'New match with $matchName! You can now start chatting.',
    );
  }

  void announceSwipe(String action, String userName) {
    String message;
    switch (action) {
      case 'like':
        message = 'Liked $userName';
        break;
      case 'pass':
        message = 'Passed on $userName';
        break;
      case 'super_like':
        message = 'Super liked $userName';
        break;
      default:
        message = 'Swiped on $userName';
    }
    _announceToScreenReader(message);
  }

  /// Get accessibility-optimized duration
  Duration getAnimationDuration(Duration defaultDuration) {
    if (_reducedMotionEnabled) {
      return Duration(
        milliseconds: (defaultDuration.inMilliseconds * 0.3).round(),
      );
    }
    return defaultDuration;
  }

  /// Get accessibility-optimized colors
  Color getContrastColor(Color defaultColor, Color background) {
    if (!_highContrastEnabled) return defaultColor;

    // Calculate contrast ratio and adjust if needed
    final defaultLuminance = defaultColor.computeLuminance();
    final backgroundLuminance = background.computeLuminance();
    final contrastRatio =
        (defaultLuminance + 0.05) / (backgroundLuminance + 0.05);

    // If contrast is too low, return high contrast alternative
    if (contrastRatio < 4.5) {
      return backgroundLuminance > 0.5 ? Colors.black : Colors.white;
    }

    return defaultColor;
  }

  /// Get accessible text style
  TextStyle getAccessibleTextStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * _textScaleFactor,
      fontWeight: _highContrastEnabled ? FontWeight.bold : baseStyle.fontWeight,
    );
  }

  /// Get accessible button size
  Size getAccessibleButtonSize(Size baseSize) {
    return Size(
      baseSize.width * _buttonSizeMultiplier,
      baseSize.height * _buttonSizeMultiplier,
    );
  }

  /// Create semantic wrapper for complex widgets
  Widget wrapWithSemantics({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool isButton = false,
    bool isHeader = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton,
      header: isHeader,
      onTap: onTap,
      child: child,
    );
  }

  /// Create accessible swipe card
  Widget createAccessibleSwipeCard({
    required Widget child,
    required String userName,
    required String userAge,
    required String userBio,
    required VoidCallback onLike,
    required VoidCallback onPass,
    required VoidCallback onSuperLike,
  }) {
    final semanticLabel =
        'Dating profile for $userName, age $userAge. $userBio';

    return Semantics(
      label: semanticLabel,
      hint:
          'Swipe right to like, left to pass, or up for super like. Double tap for profile details.',
      child: ExcludeSemantics(excluding: !_screenReaderEnabled, child: child),
    );
  }

  /// Create accessible navigation hint
  String getNavigationHint(String currentTab, List<String> availableTabs) {
    final index = availableTabs.indexOf(currentTab);
    final total = availableTabs.length;

    return 'Tab $index of $total. Swipe left or right to navigate between tabs.';
  }

  /// Load accessibility settings
  Future<void> _loadAccessibilitySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _screenReaderEnabled =
          prefs.getBool('accessibility_screen_reader') ?? false;
      _highContrastEnabled =
          prefs.getBool('accessibility_high_contrast') ?? false;
      _largeTextEnabled = prefs.getBool('accessibility_large_text') ?? false;
      _reducedMotionEnabled =
          prefs.getBool('accessibility_reduced_motion') ?? false;
      _voiceAnnouncementsEnabled =
          prefs.getBool('accessibility_voice_announcements') ?? true;
      _textScaleFactor = prefs.getDouble('accessibility_text_scale') ?? 1.0;
      _buttonSizeMultiplier =
          prefs.getDouble('accessibility_button_size') ?? 1.0;
    } catch (e) {
      debugPrint('Error loading accessibility settings: $e');
    }
  }

  /// Save accessibility settings
  Future<void> _saveAccessibilitySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('accessibility_screen_reader', _screenReaderEnabled);
      await prefs.setBool('accessibility_high_contrast', _highContrastEnabled);
      await prefs.setBool('accessibility_large_text', _largeTextEnabled);
      await prefs.setBool(
        'accessibility_reduced_motion',
        _reducedMotionEnabled,
      );
      await prefs.setBool(
        'accessibility_voice_announcements',
        _voiceAnnouncementsEnabled,
      );
      await prefs.setDouble('accessibility_text_scale', _textScaleFactor);
      await prefs.setDouble('accessibility_button_size', _buttonSizeMultiplier);
    } catch (e) {
      debugPrint('Error saving accessibility settings: $e');
    }
  }

  /// Get accessibility settings summary
  Map<String, dynamic> getAccessibilitySettings() {
    return {
      'screenReader': _screenReaderEnabled,
      'highContrast': _highContrastEnabled,
      'largeText': _largeTextEnabled,
      'reducedMotion': _reducedMotionEnabled,
      'voiceAnnouncements': _voiceAnnouncementsEnabled,
      'textScale': _textScaleFactor,
      'buttonSize': _buttonSizeMultiplier,
    };
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    _screenReaderEnabled = false;
    _highContrastEnabled = false;
    _largeTextEnabled = false;
    _reducedMotionEnabled = false;
    _voiceAnnouncementsEnabled = true;
    _textScaleFactor = 1.0;
    _buttonSizeMultiplier = 1.0;

    await _saveAccessibilitySettings();
    _announceToScreenReader('Accessibility settings reset to defaults');
  }
}

/// Accessible Widget Extensions
extension AccessibleWidget on Widget {
  /// Add semantic label to any widget
  Widget withSemantics({
    required String label,
    String? hint,
    String? value,
    bool isButton = false,
    bool isHeader = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton,
      header: isHeader,
      onTap: onTap,
      child: this,
    );
  }

  /// Exclude from semantics tree
  Widget excludeSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Merge semantics with children
  Widget mergeSemantics() {
    return MergeSemantics(child: this);
  }
}

/// Accessible Button Widget
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? semanticHint;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AccessibleButton({
    Key? key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.semanticHint,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();

    return Semantics(
      label: semanticLabel,
      hint: semanticHint ?? 'Double tap to activate',
      button: true,
      onTap: onPressed,
      child: GestureDetector(
        onTap: () {
          if (onPressed != null) {
            accessibilityService.announceAction('$semanticLabel activated');
            onPressed!();
          }
        },
        child: Container(
          padding: padding ?? const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Accessible Text Field Widget
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String semanticLabel;
  final ValueChanged<String>? onChanged;
  final bool obscureText;

  const AccessibleTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    required this.semanticLabel,
    this.onChanged,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint:
          'Text input field. ${obscureText ? 'Text will be hidden for privacy.' : ''}',
      textField: true,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        decoration: InputDecoration(labelText: labelText, hintText: hintText),
      ),
    );
  }
}
