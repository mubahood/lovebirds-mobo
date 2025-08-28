/*
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:lovebirds_app/utils/AppConfig.dart';

import '../../config/debug_config.dart';
import '../../middleware/paywall_middleware.dart';
import '../../models/UserModel.dart';
import '../../services/BoostService.dart';
import '../../services/swipe_service.dart';
import '../../services/upgrade_prompt_service.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/SubscriptionManager.dart';
import '../../utils/Utilities.dart';
import '../../widgets/dating/boost_dialog.dart';
import '../../widgets/dating/celebration_animation.dart';
import '../../widgets/dating/match_celebration_widget.dart';
import '../../widgets/dating/super_like_dialog.dart';
import '../../widgets/dating/swipe_card.dart';
import '../../widgets/dating/swipe_shimmer.dart';
import 'AnalyticsScreen.dart';
import 'ProfileViewScreen.dart';

class SwipeScreenOld extends StatefulWidget {
  const SwipeScreenOld({Key? key}) : super(key: key);

  @override
  _SwipeScreenOldState createState() => _SwipeScreenOldState();
}

class _SwipeScreenOldState extends State<SwipeScreenOld>
    with SingleTickerProviderStateMixin {
  List<UserModel> users = [];
  int currentIndex = 0;
  bool isLoading = true;
  bool isLoadingMore = false; // New: Track when loading more users
  String errorMessage = '';

  // Single animation controller for smooth performance
  late AnimationController _animationController;

  // Gesture values - using ValueNotifier for performance
  ValueNotifier<Offset> _cardPosition = ValueNotifier(Offset.zero);
  ValueNotifier<double> _cardRotation = ValueNotifier(0.0);

  // Gesture state
  bool _isAnimating = false;

  // Like indicators
  String _currentIndicator = ''; // 'like', 'pass', 'super_like', or ''

  // Undo functionality
  bool canUndo = false;
  UserModel? lastSwipedUser;
  String? lastSwipeAction;

  // Daily stats
  int likesRemaining = 50;
  int superLikesRemaining = 3;

  // Haptic feedback helper
  void _triggerHapticFeedback(String type) {
    switch (type) {
      case 'light':
        HapticFeedback.lightImpact();
        break;
      case 'medium':
        HapticFeedback.mediumImpact();
        break;
      case 'heavy':
        HapticFeedback.heavyImpact();
        break;
      case 'selection':
        HapticFeedback.selectionClick();
        break;
    }
  }

  void _playSoundEffect(String type) async {
    // Check if sound effects are enabled (we'll use a simple approach for now)
    final soundEnabled = await _getSoundEffectSetting();
    if (!soundEnabled) return;

    switch (type) {
      case 'like':
        SystemSound.play(SystemSoundType.click);
        break;
      case 'pass':
        SystemSound.play(SystemSoundType.click);
        break;
      case 'super_like':
        SystemSound.play(SystemSoundType.click);
        break;
      case 'match':
        SystemSound.play(SystemSoundType.click);
        break;
      case 'boost':
        SystemSound.play(SystemSoundType.click);
        break;
      case 'undo':
        SystemSound.play(SystemSoundType.click);
        break;
    }
  }

  Future<bool> _getSoundEffectSetting() async {
    // For now, we'll default to true. In a full implementation,
    // this would read from user preferences/settings
    return true;
  }

  // Celebration states
  bool _triggerSuperLikeCelebration = false;

  // Boost state
  Map<String, dynamic>? _boostStatus;
  Map<String, dynamic>? _subscriptionStatus;
  bool _isLoadingBoost = false;

  @override
  void initState() {
    super.initState();
    _checkPaywallAndInitialize();
  }

  // Check subscription status and initialize app
  Future<void> _checkPaywallAndInitialize() async {
    try {
      // Enforce paywall - controlled by debug config for testing
      final hasAccess = await PaywallMiddleware.enforcePaywall(
        triggerReason: 'swipe_access',
        allowBypass: true, // Allow debug bypass from DebugConfig for testing
      );

      // Proceed if has access (either subscribed or debug bypass enabled)
      if (hasAccess) {
        _setupAnimations();
        await _loadUsers();
        await _loadStats();
        _loadBoostStatus();
        _initializeUpgradePrompts();
      }
    } catch (e) {
      // On error, show error state
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to initialize. Please try again.';
      });
    }
  }

  // Initialize upgrade prompt tracking
  void _initializeUpgradePrompts() async {
    // Reset daily counters if it's a new day
    await UpgradePromptService.resetDailyCounters();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300), // Reduced for smoother feel
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardPosition.dispose();
    _cardRotation.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      currentIndex = 0; // Reset index when reloading users
      users.clear(); // Clear existing users for fresh start
    });

    try {
      final user = await SwipeService.getSwipeUser();

      if (user != null) {
        setState(() {
          users.add(user);
          isLoading = false;
        });

        // Load more users in background for smoother experience
        _loadMoreUsers();
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No more profiles available';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Network error. Please try again.';
      });
    }
  }

  Future<void> _loadMoreUsers() async {
    if (isLoadingMore) return; // Prevent multiple simultaneous loads

    setState(() {
      isLoadingMore = true;
    });

    // Load 5 more users in background
    for (int i = 0; i < 5; i++) {
      try {
        final user = await SwipeService.getSwipeUser();
        if (user != null) {
          setState(() {
            if (!users.any((u) => u.id == user.id)) {
              users.add(user);
            }
          });
        }
      } catch (e) {
        // Ignore errors for background loading
        break;
      }
    }

    setState(() {
      isLoadingMore = false;
    });
  }

  Future<void> _loadStats() async {
    try {
      final stats = await SwipeService.getSwipeStats();

      if (stats != null) {
        setState(() {
          likesRemaining = stats.likesRemaining;
          superLikesRemaining = stats.superLikesRemaining;
        });
      }
    } catch (e) {
      // Use default values
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating) return;
    // Reset animation values when starting new gesture
    _cardPosition.value = Offset.zero;
    _cardRotation.value = 0.0;
    _currentIndicator = '';
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating || currentIndex >= users.length) return;

    // Get screen size for calculations
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDrag = screenWidth * 0.45; // Maximum drag distance for smooth feel

    // Update card position with clamping for stability
    final newOffset = Offset(
      details.delta.dx.clamp(-maxDrag, maxDrag),
      details.delta.dy.clamp(-maxDrag, maxDrag),
    );

    _cardPosition.value += newOffset;

    // Calculate rotation based on horizontal movement (reduced for stability)
    final rotationFactor = (_cardPosition.value.dx / screenWidth).clamp(
      -0.3,
      0.3,
    );
    _cardRotation.value =
        rotationFactor * 0.2; // Reduced rotation for smoother feel

    // Update indicator based on drag direction with larger thresholds for stability
    String newIndicator = '';
    if (_cardPosition.value.dx > 80) {
      newIndicator = 'like';
    } else if (_cardPosition.value.dx < -80) {
      newIndicator = 'pass';
    } else if (_cardPosition.value.dy < -80) {
      newIndicator = 'super_like';
    }

    if (_currentIndicator != newIndicator) {
      _currentIndicator = newIndicator;
      // Add haptic feedback when crossing into a swipe zone
      if (newIndicator.isNotEmpty) {
        _triggerHapticFeedback('light');
      }
      setState(() {}); // Only setState when indicator changes
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating || currentIndex >= users.length) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.25; // Threshold for swipe completion

    // Determine action based on position and velocity
    String? action;
    if (_cardPosition.value.dx > threshold ||
        details.velocity.pixelsPerSecond.dx > 500) {
      action = 'like';
    } else if (_cardPosition.value.dx < -threshold ||
        details.velocity.pixelsPerSecond.dx < -500) {
      action = 'pass';
    } else if (_cardPosition.value.dy < -threshold ||
        details.velocity.pixelsPerSecond.dy < -500) {
      action = 'super_like';
    }

    if (action != null) {
      // Add medium haptic feedback for successful swipe
      _triggerHapticFeedback('medium');
      _performSwipe(action);
    } else {
      // Reset card to center with smooth animation
      _resetCard();
    }
  }

  void _resetCard() {
    _isAnimating = true;

    // Create smooth return animation
    final resetAnimation = Tween<Offset>(
      begin: _cardPosition.value,
      end: Offset.zero,
    ).animate(_animationController);

    final resetRotation = Tween<double>(
      begin: _cardRotation.value,
      end: 0.0,
    ).animate(_animationController);

    resetAnimation.addListener(() {
      _cardPosition.value = resetAnimation.value;
    });

    resetRotation.addListener(() {
      _cardRotation.value = resetRotation.value;
    });

    _animationController.forward().then((_) {
      _animationController.reset();
      _isAnimating = false;
      _currentIndicator = '';
      setState(() {});
    });
  }

  void _performSwipe(String action) async {
    if (currentIndex >= users.length || _isAnimating) return;

    // Check daily limits before performing swipe
    if (action == 'like' && likesRemaining <= 0) {
      _showSmartUpgradePrompt('daily_limit', action);
      return;
    }

    if (action == 'super_like' && superLikesRemaining <= 0) {
      _showSmartUpgradePrompt('super_likes', action);
      return;
    }

    // Play sound effect for swipe action
    _playSoundEffect(action);

    _isAnimating = true;
    final user = users[currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate final position based on action
    Offset targetPosition;
    switch (action) {
      case 'like':
        targetPosition = Offset(screenWidth * 1.2, _cardPosition.value.dy);
        break;
      case 'pass':
        targetPosition = Offset(-screenWidth * 1.2, _cardPosition.value.dy);
        break;
      case 'super_like':
        targetPosition = Offset(_cardPosition.value.dx, -screenWidth);
        break;
      default:
        targetPosition = Offset(screenWidth * 1.2, _cardPosition.value.dy);
    }

    // Create smooth exit animation
    final exitAnimation = Tween<Offset>(
      begin: _cardPosition.value,
      end: targetPosition,
    ).animate(_animationController);

    final exitRotation = Tween<double>(
      begin: _cardRotation.value,
      end:
          action == 'like'
              ? 0.2
              : action == 'pass'
              ? -0.2
              : 0.0,
    ).animate(_animationController);

    exitAnimation.addListener(() {
      _cardPosition.value = exitAnimation.value;
    });

    exitRotation.addListener(() {
      _cardRotation.value = exitRotation.value;
    });

    // Animate card out
    await _animationController.forward();

    // Send swipe to backend
    _sendSwipeAction(user.id, action);

    // Track for undo functionality
    setState(() {
      lastSwipedUser = user;
      lastSwipeAction = action;
      canUndo = true;
    });

    // Move to next card
    setState(() {
      currentIndex++;
      _currentIndicator = '';
    });

    // Reset animation and position
    _animationController.reset();
    _cardPosition.value = Offset.zero;
    _cardRotation.value = 0.0;
    _isAnimating = false;

    // Load more users if running low (before reaching the end)
    if (users.length - currentIndex <= 2) {
      _loadMoreUsers();
    }
  }

  Future<void> _sendSwipeAction(int targetUserId, String action) async {
    try {
      final result = await SwipeService.performSwipe(
        targetUserId: targetUserId,
        action: action,
      );

      if (result.success) {
        // Track swipe action for smart prompting
        UpgradePromptService.trackSwipeAction();

        // Handle match notification
        if (result.isMatch) {
          // Track new match for smart prompting
          UpgradePromptService.trackNewMatch();
          _showMatchDialog(targetUserId);
        }

        // Update stats
        if (action == 'like' && likesRemaining > 0) {
          setState(() {
            likesRemaining--;
          });
        } else if (action == 'super_like' && superLikesRemaining > 0) {
          setState(() {
            superLikesRemaining--;
          });
        }

        // Check for active swiping session upgrade opportunity
        await UpgradePromptService.handleActiveSwipingSession(context);
      } else {
        Utils.toast(result.message);
      }
    } catch (e) {
      Utils.toast('Network error. Swipe not recorded.');
    }
  }

  void _showMatchDialog(int matchedUserId) {
    final matchedUser = users.firstWhere((u) => u.id == matchedUserId);

    // Play sound effect for match celebration
    _playSoundEffect('match');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => MatchCelebrationWidget(
            matchedUser: matchedUser,
            onKeepSwiping: () {
              Navigator.pop(context);
              // Show match potential upgrade prompt after match celebration
              _handleMatchSuccess();
            },
            onSayHello: () {
              Navigator.pop(context);
              // TODO: Navigate to chat with matched user
              Utils.toast('Opening chat with ${matchedUser.name}...');
              // Show match potential upgrade prompt
              _handleMatchSuccess();
            },
          ),
    );
  }

  // Handle match success and potential upgrade prompts
  void _handleMatchSuccess() async {
    // Calculate approximate total matches (simplified)
    final estimatedMatches = (50 - likesRemaining) ~/ 10; // Rough estimate
    await UpgradePromptService.handleMatchSuccess(context, estimatedMatches);
  }

  void _handleSuperLikePressed() async {
    if (currentIndex >= users.length) return;

    final currentUser = users[currentIndex];

    // Check if user can use super likes
    final canUseSuperLike = await SubscriptionManager.canUseSuperLike(
      superLikesRemaining,
    );

    if (!canUseSuperLike) {
      // Show upgrade dialog
      _showSuperLikeUpgradeDialog(currentUser);
      return;
    }

    // Show super like dialog with message input
    _showSuperLikeDialog(currentUser);
  }

  void _showSuperLikeDialog(UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => SuperLikeDialog(
            user: user,
            onSuperLike: () {
              // The dialog handles the API call, just provide feedback
              HapticFeedback.mediumImpact();
            },
            onCancel: () {
              HapticFeedback.lightImpact();
            },
          ),
    ).then((result) {
      if (result != null && result['action'] == 'super_like') {
        final message = result['message'] as String;
        _performSuperLikeWithMessage(message);
      }
    });
  }

  void _showSuperLikeUpgradeDialog(UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => SuperLikeDialog(
            user: user,
            showUpgrade: true,
            onCancel: () {
              HapticFeedback.lightImpact();
            },
          ),
    ).then((result) {
      if (result != null && result['action'] == 'upgrade') {
        // TODO: Navigate to subscription screen
        Utils.toast('Subscription feature coming soon!');
      }
    });
  }

  void _performSuperLikeWithMessage(String message) async {
    if (currentIndex >= users.length || _isAnimating) return;

    _isAnimating = true;
    final user = users[currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    // Create smooth exit animation for super like (upward)
    final exitAnimation = Tween<Offset>(
      begin: _cardPosition.value,
      end: Offset(_cardPosition.value.dx, -screenWidth),
    ).animate(_animationController);

    exitAnimation.addListener(() {
      _cardPosition.value = exitAnimation.value;
    });

    // Animate card out
    await _animationController.forward();

    // Send API request with message
    await _sendSuperLikeAction(user.id, message);

    // Reset for next card
    _animationController.reset();
    _cardPosition.value = Offset.zero;
    _cardRotation.value = 0.0;

    setState(() {
      currentIndex++;
      _isAnimating = false;
      _currentIndicator = '';
    });

    // Load more users if needed
    if (currentIndex >= users.length - 2) {
      _loadMoreUsers();
    }
  }

  Future<void> _sendSuperLikeAction(int targetUserId, String message) async {
    try {
      final result = await SwipeService.performSwipe(
        targetUserId: targetUserId,
        action: 'super_like',
        message: message,
      );

      if (result.success) {
        // Handle match notification
        if (result.isMatch) {
          _showMatchDialog(targetUserId);
        }

        // Update stats for super like
        setState(() {
          if (superLikesRemaining > 0) {
            superLikesRemaining--;
          }
        });

        // Show success message
        Utils.toast('Super like sent!', color: Colors.blue);

        // Trigger celebration animation
        setState(() {
          _triggerSuperLikeCelebration = true;
        });
      } else {
        Utils.toast(result.message);
      }
    } catch (e) {
      Utils.toast('Network error. Super like not sent.');
    }
  }

  // ======= BOOST FUNCTIONALITY =======

  Future<void> _loadBoostStatus() async {
    if (_isLoadingBoost) return;

    setState(() {
      _isLoadingBoost = true;
    });

    try {
      final result = await BoostService.getBoostStatus();
      if (result.code == 1 && result.data != null) {
        setState(() {
          _boostStatus = result.data;
        });
      }

      // Also load subscription status
      final isPremium = await SubscriptionManager.hasActiveSubscription();
      final tier = await SubscriptionManager.getSubscriptionTier();

      setState(() {
        _subscriptionStatus = {
          'is_premium': isPremium,
          'subscription_tier': tier,
          'boost_credits': 0, // TODO: Add boost credits to user model
        };
      });
    } catch (e) {
      // Error loading boost status - handle silently
    } finally {
      setState(() {
        _isLoadingBoost = false;
      });
    }
  }

  void _showBoostDialog() async {
    // Load latest boost status before showing dialog
    await _loadBoostStatus();

    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => BoostDialog(
            boostStatus: _boostStatus,
            subscriptionStatus: _subscriptionStatus,
            onBoostActivated: () {
              // Play sound effect for boost activation
              _playSoundEffect('boost');

              // Reload boost status after activation
              _loadBoostStatus();

              // Show success feedback
              Utils.toast(
                'Profile boosted! You\'ll get 3x more visibility!',
                color: Colors.green,
              );
            },
          ),
    );
  }

  Widget _buildBoostButton() {
    final isBoosted = _boostStatus?['is_boosted'] ?? false;
    final availableBoosts = _boostStatus?['available_boosts'] ?? {};
    final boostType = availableBoosts['type'] ?? 'credits';
    final boostCount = availableBoosts['count'] ?? 0;

    Color getIconColor() {
      if (isBoosted) return Colors.orange;
      if (boostType == 'unlimited' || boostCount > 0)
        return CustomTheme.primary;
      return CustomTheme.color3;
    }

    IconData getIcon() {
      return isBoosted ? Icons.rocket_launch : Icons.local_fire_department;
    }

    return Stack(
      children: [
        IconButton(
          onPressed: _showBoostDialog,
          icon: Icon(getIcon(), color: getIconColor()),
          tooltip: isBoosted ? 'Boost Active!' : 'Boost Profile',
        ),
        if (isBoosted)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: CustomTheme.card, width: 1),
              ),
            ),
          ),
        if (!isBoosted && boostType != 'unlimited' && boostCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: CustomTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: CustomTheme.card, width: 1),
              ),
              child: Text(
                boostCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Undo last swipe functionality
  void _undoLastSwipe() async {
    if (!canUndo || lastSwipedUser == null) {
      Utils.toast('No swipe to undo');
      return;
    }

    // Play sound effect for undo action
    _playSoundEffect('undo');

    try {
      Utils.toast('Undoing last swipe...');

      final result = await SwipeService.undoLastSwipe();

      if (result.success) {
        setState(() {
          // Move back to previous card
          currentIndex--;
          // Reset undo state
          canUndo = false;
          lastSwipedUser = null;
          lastSwipeAction = null;

          // Restore like counts if needed
          if (lastSwipeAction == 'like') {
            likesRemaining++;
          } else if (lastSwipeAction == 'super_like') {
            superLikesRemaining++;
          }
        });

        Utils.toast('Swipe undone successfully!');
      } else {
        Utils.toast(result.message);
      }
    } catch (e) {
      Utils.toast('Failed to undo swipe. Please try again.');
    }
  }

  // ======= END BOOST FUNCTIONALITY =======

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.card,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Icon(Icons.favorite, color: CustomTheme.primary),
            const SizedBox(width: 8),
            FxText.titleMedium(
              '${AppConfig.APP_NAME}',
              color: CustomTheme.primary,
              fontWeight: 700,
            ),
            // Debug mode indicator
            if (DebugConfig.bypassSubscription) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FxText.bodySmall(
                  'TEST',
                  color: Colors.white,
                  fontWeight: 600,
                ),
              ),
            ],
          ],
        ),
        actions: [
          _buildBoostButton(), // Add boost button
          IconButton(
            onPressed: () {
              _triggerHapticFeedback('selection');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
            icon: Icon(Icons.analytics, color: CustomTheme.primary),
            tooltip: 'View Analytics',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          isLoading
              ? const SwipeLoadingInterface() // Show shimmer during initial load
              : errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : users.isEmpty
              ? _buildNoMoreCardsWidget() // Show "no more" only when we have no users after loading
              : currentIndex >= users.length
              ? isLoadingMore
                  ? const SwipeLoadingInterface() // Show shimmer when loading more
                  : _buildNoMoreCardsWidget() // Show "no more" when we've gone through all loaded users
              : _buildSwipeInterface(),
          // Show swipe interface when we have users and haven't reached the end
          // Debug info overlay (only in debug mode)
          if (DebugConfig.showDebugOverlay) _buildDebugOverlay(),
        ],
      ),
    );
  }

  // Debug overlay to help understand app state
  Widget _buildDebugOverlay() {
    return Positioned(
      top: 100,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DEBUG INFO',
              style: TextStyle(
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              'isLoading: $isLoading',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'users.length: ${users.length}',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'currentIndex: $currentIndex',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'errorMessage: $errorMessage',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'isLoadingMore: $isLoadingMore',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Should show: ${_getShouldShowInfo()}',
              style: TextStyle(color: Colors.green, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _getShouldShowInfo() {
    if (isLoading) return 'Loading Interface';
    if (errorMessage.isNotEmpty) return 'Error Widget';
    if (users.isEmpty) return 'No More Cards';
    if (currentIndex >= users.length) {
      if (isLoadingMore) return 'Loading More';
      return 'No More Cards';
    }
    return 'Swipe Interface';
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: CustomTheme.color2),
          const SizedBox(height: 20),
          FxText.titleMedium(
            errorMessage,
            color: CustomTheme.color,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FxButton.medium(
            onPressed: _loadUsers,
            backgroundColor: CustomTheme.primary,
            child: FxText.bodyMedium('Retry', color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreCardsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 80, color: CustomTheme.color),
          const SizedBox(height: 20),
          FxText.titleMedium(
            'No more profiles nearby',
            color: CustomTheme.color,
          ),
          const SizedBox(height: 10),
          FxText.bodyMedium(
            'Try expanding your distance or check back later',
            color: CustomTheme.color2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FxButton.medium(
            onPressed: _loadUsers,
            backgroundColor: CustomTheme.primary,
            child: FxText.bodyMedium('Refresh', color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeInterface() {
    if (users.isEmpty || currentIndex >= users.length) {
      return const SwipeLoadingInterface();
    }

    final user = users[currentIndex];

    return Container(
      color: CustomTheme.background,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.999,
                  heightFactor: 0.99,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // 2 cards deep
                      if (currentIndex + 2 < users.length)
                        Positioned(
                          top: 32,
                          child: _buildBackgroundCard(
                            depth: 2,
                            user: users[currentIndex + 2],
                          ),
                        ),
                      if (currentIndex + 1 < users.length)
                        Positioned(
                          top: 16,
                          child: _buildBackgroundCard(
                            depth: 1,
                            user: users[currentIndex + 1],
                          ),
                        ),

                      // Main draggable card
                      Positioned.fill(
                        child: ValueListenableBuilder<Offset>(
                          valueListenable: _cardPosition,
                          builder: (context, pos, _) {
                            return ValueListenableBuilder<double>(
                              valueListenable: _cardRotation,
                              builder: (context, rot, _) {
                                return Transform.translate(
                                  offset: pos,
                                  child: Transform.rotate(
                                    angle: rot,
                                    child: _buildMainCard(user),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Swipe indicator
                      if (_currentIndicator.isNotEmpty)
                        Positioned.fill(
                          child: _buildSwipeIndicator(_currentIndicator),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCard({required int depth, required UserModel user}) {
    final scale = 1.0 - depth * 0.04;
    final opacity = 1.0 - depth * 0.1;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _buildCardContent(user, isBackground: true),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(UserModel user) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: () => _openProfileView(user),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildCardContent(user, isBackground: false),
        ),
      ),
    );
  }

  Widget _buildCardContent(UserModel user, {bool isBackground = false}) {
    return SwipeCard(
      user: user,
      rotation: 0.0,
      opacity: isBackground ? 0.8 : 1.0,
      onTap: () => _openProfileView(user),
      distance: _calculateDistance(user),
    );
  }

  // Helper method to calculate distance (placeholder for now)
  double? _calculateDistance(UserModel user) {
    // TODO: Implement actual distance calculation based on user location
    // For now, return a random distance for demo purposes
    if (user.city.isNotEmpty) {
      return (5.0 + (user.id % 50)).toDouble(); // Demo distance between 5-55 km
    }
    return null;
  }

  Widget _buildSwipeIndicator(String type) {
    IconData icon;
    Color color;
    String text;

    switch (type) {
      case 'like':
        icon = Icons.favorite;
        color = Colors.green;
        text = 'LIKE';
        break;
      case 'pass':
        icon = Icons.close;
        color = Colors.red;
        text = 'PASS';
        break;
      case 'super_like':
        icon = Icons.star;
        color = Colors.blue;
        text = 'SUPER LIKE';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProfileView(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileViewScreen(user)),
    );
  }

  // Smart upgrade prompt system
  void _showSmartUpgradePrompt(String trigger, [String? contextInfo]) async {
    // Track user actions for smart prompting
    if (trigger == 'daily_limit') {
      UpgradePromptService.trackSwipeAction();

      // Create SwipeStats for the prompt
      final stats = SwipeStats(
        likesGiven: 50 - likesRemaining,
        // Calculate likes used today
        superLikesGiven: 3 - superLikesRemaining,
        // Calculate super likes used
        passesGiven: 0,
        // We don't track passes in this context
        likesReceived: 0,
        // Not relevant for daily limit prompt
        matches: 0,
        // Not relevant for daily limit prompt
        likesRemaining: likesRemaining,
        superLikesRemaining: superLikesRemaining,
        resetTime: DateTime.now().add(Duration(hours: 24)).toIso8601String(),
      );

      await UpgradePromptService.handleDailyLimitReached(context, stats);
    } else if (trigger == 'super_likes') {
      await UpgradePromptService.handleSuperLikeLimit(context);
    }
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionButtonWithLabel(
            icon: FeatherIcons.rotateCcw,
            label: 'Undo',
            background: canUndo ? CustomTheme.color2 : CustomTheme.cardDark,
            iconColor: canUndo ? Colors.white : CustomTheme.colorSecondary,
            size: 48,
            onPressed: canUndo ? _undoLastSwipe : null,
          ),
          _actionButtonWithLabel(
            icon: FeatherIcons.x,
            label: 'Pass',
            background: CustomTheme.errorRed,
            iconColor: Colors.white,
            size: 56,
            onPressed: () => _performSwipe('pass'),
          ),
          _actionButtonWithLabel(
            icon: Icons.star,
            label: 'Super',
            background: CustomTheme.accentGold,
            iconColor: Colors.white,
            size: 52,
            onPressed: () => _handleSuperLikePressed(),
            celebration: _triggerSuperLikeCelebration,
          ),
          _actionButtonWithLabel(
            icon: Icons.favorite,
            label: 'Like',
            background: CustomTheme.successGreen,
            iconColor: Colors.white,
            size: 64,
            onPressed: likesRemaining > 0 ? () => _performSwipe('like') : null,
          ),
        ],
      ),
    );
  }

  Widget _actionButtonWithLabel({
    required IconData icon,
    required String label,
    required Color background,
    required Color iconColor,
    required double size,
    VoidCallback? onPressed,
    bool celebration = false,
  }) {
    final button =
        celebration
            ? CelebrationAnimation(
              trigger: _triggerSuperLikeCelebration,
              color: background,
              child: _buildActionButton(
                icon: icon,
                color: background,
                iconColor: iconColor,
                size: size,
                onPressed: onPressed,
              ),
            )
            : _buildActionButton(
              icon: icon,
              color: background,
              iconColor: iconColor,
              size: size,
              onPressed: onPressed,
            );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: onPressed != null ? Colors.white70 : Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required double size,
    VoidCallback? onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onPressed != null ? color : CustomTheme.cardDark,
        shape: BoxShape.circle,
        border:
            onPressed != null
                ? Border.all(color: Colors.white24, width: 1.5)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              onPressed != null
                  ? () {
                    _triggerHapticFeedback('selection');
                    onPressed();
                  }
                  : null,
          borderRadius: BorderRadius.circular(size / 2),
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Center(
            child: Icon(
              icon,
              color: onPressed != null ? iconColor : Colors.white38,
              size: size * 0.45,
            ),
          ),
        ),
      ),
    );
  }
}
*/
