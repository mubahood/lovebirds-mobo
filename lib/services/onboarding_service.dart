import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/CustomTheme.dart';

/// Interactive Onboarding Service with Tutorial Management
class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  // Onboarding state management
  bool _hasCompletedOnboarding = false;
  bool _hasSeenSwipeTutorial = false;
  bool _hasSeenMatchTutorial = false;
  bool _hasSeenChatTutorial = false;
  bool _hasSeenProfileTutorial = false;
  bool _hasSeenMarketplaceTutorial = false;

  // Tutorial preferences
  bool _showTooltips = true;
  bool _enableHapticInTutorials = true;
  int _tutorialSpeed = 2; // 1=slow, 2=normal, 3=fast

  // Getters
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get hasSeenSwipeTutorial => _hasSeenSwipeTutorial;
  bool get hasSeenMatchTutorial => _hasSeenMatchTutorial;
  bool get hasSeenChatTutorial => _hasSeenChatTutorial;
  bool get hasSeenProfileTutorial => _hasSeenProfileTutorial;
  bool get hasSeenMarketplaceTutorial => _hasSeenMarketplaceTutorial;
  bool get showTooltips => _showTooltips;
  bool get enableHapticInTutorials => _enableHapticInTutorials;
  int get tutorialSpeed => _tutorialSpeed;

  /// Initialize onboarding service and load preferences
  Future<void> initialize() async {
    await _loadOnboardingPreferences();
  }

  /// Check if user needs onboarding
  bool shouldShowOnboarding() {
    return !_hasCompletedOnboarding;
  }

  /// Check if specific tutorial should be shown
  bool shouldShowTutorial(String tutorialType) {
    if (!_showTooltips) return false;

    switch (tutorialType) {
      case 'swipe':
        return !_hasSeenSwipeTutorial;
      case 'match':
        return !_hasSeenMatchTutorial;
      case 'chat':
        return !_hasSeenChatTutorial;
      case 'profile':
        return !_hasSeenProfileTutorial;
      case 'marketplace':
        return !_hasSeenMarketplaceTutorial;
      default:
        return false;
    }
  }

  /// Mark tutorial as completed
  Future<void> completeTutorial(String tutorialType) async {
    switch (tutorialType) {
      case 'swipe':
        _hasSeenSwipeTutorial = true;
        break;
      case 'match':
        _hasSeenMatchTutorial = true;
        break;
      case 'chat':
        _hasSeenChatTutorial = true;
        break;
      case 'profile':
        _hasSeenProfileTutorial = true;
        break;
      case 'marketplace':
        _hasSeenMarketplaceTutorial = true;
        break;
    }

    await _saveOnboardingPreferences();

    // Trigger haptic feedback for tutorial completion
    if (_enableHapticInTutorials) {
      HapticFeedback.lightImpact();
    }
  }

  /// Complete main onboarding flow
  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _saveOnboardingPreferences();

    // Celebration haptic feedback
    if (_enableHapticInTutorials) {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.lightImpact();
    }
  }

  /// Reset onboarding for testing or user request
  Future<void> resetOnboarding() async {
    _hasCompletedOnboarding = false;
    _hasSeenSwipeTutorial = false;
    _hasSeenMatchTutorial = false;
    _hasSeenChatTutorial = false;
    _hasSeenProfileTutorial = false;
    _hasSeenMarketplaceTutorial = false;

    await _saveOnboardingPreferences();
  }

  /// Update tutorial preferences
  Future<void> setTooltips(bool enabled) async {
    _showTooltips = enabled;
    await _saveOnboardingPreferences();
  }

  Future<void> setHapticInTutorials(bool enabled) async {
    _enableHapticInTutorials = enabled;
    await _saveOnboardingPreferences();
  }

  Future<void> setTutorialSpeed(int speed) async {
    _tutorialSpeed = speed.clamp(1, 3);
    await _saveOnboardingPreferences();
  }

  /// Get tutorial animation duration based on speed
  Duration getTutorialDuration() {
    switch (_tutorialSpeed) {
      case 1:
        return const Duration(milliseconds: 800); // Slow
      case 2:
        return const Duration(milliseconds: 500); // Normal
      case 3:
        return const Duration(milliseconds: 300); // Fast
      default:
        return const Duration(milliseconds: 500);
    }
  }

  /// Get tutorial delay between steps
  Duration getTutorialDelay() {
    switch (_tutorialSpeed) {
      case 1:
        return const Duration(milliseconds: 1500); // Slow
      case 2:
        return const Duration(milliseconds: 1000); // Normal
      case 3:
        return const Duration(milliseconds: 600); // Fast
      default:
        return const Duration(milliseconds: 1000);
    }
  }

  /// Show contextual tooltip
  void showTooltip(
    BuildContext context, {
    required String message,
    required GlobalKey targetKey,
    String? title,
    VoidCallback? onTap,
  }) {
    if (!_showTooltips) return;

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => TooltipOverlay(
            position: position,
            targetSize: size,
            title: title,
            message: message,
            onDismiss: () {
              overlayEntry.remove();
              onTap?.call();
            },
            animationDuration: getTutorialDuration(),
          ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss tooltip
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });

    // Haptic feedback for tooltip
    if (_enableHapticInTutorials) {
      HapticFeedback.selectionClick();
    }
  }

  /// Load preferences from storage
  Future<void> _loadOnboardingPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
      _hasSeenSwipeTutorial = prefs.getBool('tutorial_swipe_seen') ?? false;
      _hasSeenMatchTutorial = prefs.getBool('tutorial_match_seen') ?? false;
      _hasSeenChatTutorial = prefs.getBool('tutorial_chat_seen') ?? false;
      _hasSeenProfileTutorial = prefs.getBool('tutorial_profile_seen') ?? false;
      _hasSeenMarketplaceTutorial =
          prefs.getBool('tutorial_marketplace_seen') ?? false;

      _showTooltips = prefs.getBool('tutorial_tooltips_enabled') ?? true;
      _enableHapticInTutorials =
          prefs.getBool('tutorial_haptic_enabled') ?? true;
      _tutorialSpeed = prefs.getInt('tutorial_speed') ?? 2;
    } catch (e) {
      debugPrint('Error loading onboarding preferences: $e');
    }
  }

  /// Save preferences to storage
  Future<void> _saveOnboardingPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('onboarding_completed', _hasCompletedOnboarding);
      await prefs.setBool('tutorial_swipe_seen', _hasSeenSwipeTutorial);
      await prefs.setBool('tutorial_match_seen', _hasSeenMatchTutorial);
      await prefs.setBool('tutorial_chat_seen', _hasSeenChatTutorial);
      await prefs.setBool('tutorial_profile_seen', _hasSeenProfileTutorial);
      await prefs.setBool(
        'tutorial_marketplace_seen',
        _hasSeenMarketplaceTutorial,
      );

      await prefs.setBool('tutorial_tooltips_enabled', _showTooltips);
      await prefs.setBool('tutorial_haptic_enabled', _enableHapticInTutorials);
      await prefs.setInt('tutorial_speed', _tutorialSpeed);
    } catch (e) {
      debugPrint('Error saving onboarding preferences: $e');
    }
  }

  /// Get onboarding progress percentage
  double getOnboardingProgress() {
    if (_hasCompletedOnboarding) return 1.0;

    int completedTutorials = 0;
    int totalTutorials = 5; // swipe, match, chat, profile, marketplace

    if (_hasSeenSwipeTutorial) completedTutorials++;
    if (_hasSeenMatchTutorial) completedTutorials++;
    if (_hasSeenChatTutorial) completedTutorials++;
    if (_hasSeenProfileTutorial) completedTutorials++;
    if (_hasSeenMarketplaceTutorial) completedTutorials++;

    return completedTutorials / totalTutorials;
  }

  /// Get tutorial completion status
  Map<String, bool> getTutorialStatus() {
    return {
      'onboarding': _hasCompletedOnboarding,
      'swipe': _hasSeenSwipeTutorial,
      'match': _hasSeenMatchTutorial,
      'chat': _hasSeenChatTutorial,
      'profile': _hasSeenProfileTutorial,
      'marketplace': _hasSeenMarketplaceTutorial,
    };
  }

  /// Get tutorial settings
  Map<String, dynamic> getTutorialSettings() {
    return {
      'tooltips': _showTooltips,
      'haptic': _enableHapticInTutorials,
      'speed': _tutorialSpeed,
      'speedLabel': ['', 'Slow', 'Normal', 'Fast'][_tutorialSpeed],
    };
  }
}

/// Animated Tooltip Overlay Widget
class TooltipOverlay extends StatefulWidget {
  final Offset position;
  final Size targetSize;
  final String? title;
  final String message;
  final VoidCallback onDismiss;
  final Duration animationDuration;

  const TooltipOverlay({
    Key? key,
    required this.position,
    required this.targetSize,
    this.title,
    required this.message,
    required this.onDismiss,
    required this.animationDuration,
  }) : super(key: key);

  @override
  State<TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<TooltipOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Calculate tooltip position (above or below target)
    final showAbove = widget.position.dy > screenSize.height / 2;
    final tooltipTop =
        showAbove
            ? widget.position.dy - 80
            : widget.position.dy + widget.targetSize.height + 10;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Semi-transparent overlay
            GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                width: screenSize.width,
                height: screenSize.height,
                color: Colors.black.withValues(alpha: 0.3 * _opacityAnimation.value),
              ),
            ),

            // Target highlight
            Positioned(
              left: widget.position.dx - 8,
              top: widget.position.dy - 8,
              child: Container(
                width: widget.targetSize.width + 16,
                height: widget.targetSize.height + 16,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CustomTheme.primary.withOpacity(
                      _opacityAnimation.value,
                    ),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Tooltip content
            Positioned(
              left: 20,
              right: 20,
              top: tooltipTop,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    color: CustomTheme.cardDark,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            CustomTheme.primary.withValues(alpha: 0.1),
                            CustomTheme.cardDark,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title != null) ...[
                            Text(
                              widget.title!,
                              style: TextStyle(
                                color: CustomTheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: widget.onDismiss,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: CustomTheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Got it!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
