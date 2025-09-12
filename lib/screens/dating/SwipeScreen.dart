import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../models/UserModel.dart';
import '../../services/swipe_service.dart';
import '../../utils/CustomTheme.dart';
import '../../widgets/dating/match_celebration_widget.dart';
import '../../widgets/dating/swipe_card.dart';
import '../../widgets/dating/swipe_shimmer.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({Key? key}) : super(key: key);

  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with TickerProviderStateMixin {
  // Core data
  List<UserModel> users = [];
  List<UserModel> upcomingUsers = [];
  int currentIndex = 0;
  bool isLoading = true;
  String errorMessage = '';

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _cardController;

  // Card positioning
  late ValueNotifier<Offset> _cardPosition;
  late ValueNotifier<double> _cardRotation;
  bool _isAnimating = false;

  // Stats
  int likesRemaining = 50;
  int superLikesRemaining = 3;
  bool canUndo = false;

  // Undo functionality
  UserModel? lastSwipedUser;
  String? lastSwipeAction;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUsers();
    _loadStats();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cardPosition = ValueNotifier(Offset.zero);
    _cardRotation = ValueNotifier(0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardController.dispose();
    _cardPosition.dispose();
    _cardRotation.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final userList = await SwipeService.getBatchSwipeUsers();
      setState(() {
        users = userList;
        currentIndex = 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading users: $e';
        isLoading = false;
      });
    }
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
      // Use default values if loading fails
      setState(() {
        likesRemaining = 50;
        superLikesRemaining = 3;
      });
    }
  }

  // Reset card position and rotation
  void _resetCard() {
    if (_isAnimating) return;

    _cardPosition.value = Offset.zero;
    _cardRotation.value = 0.0;
  }

  // Handle pan start
  void _onPanStart(DragStartDetails details) {
    if (_isAnimating || currentIndex >= users.length) return;
  }

  // Handle pan update
  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating || currentIndex >= users.length) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final newOffset = details.delta;

    _cardPosition.value += newOffset;

    // Calculate rotation based on horizontal position
    final rotationFactor = (_cardPosition.value.dx / screenWidth).clamp(
      -1.0,
      1.0,
    );
    _cardRotation.value = rotationFactor * 0.3; // Max 0.3 radians rotation

    // Provide feedback for like/pass thresholds
    if (_cardPosition.value.dx > 80) {
      HapticFeedback.selectionClick();
    } else if (_cardPosition.value.dx < -80) {
      HapticFeedback.selectionClick();
    } else if (_cardPosition.value.dy < -80) {
      HapticFeedback.mediumImpact();
    }
  }

  // Handle pan end
  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating || currentIndex >= users.length) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    // Determine swipe action based on position
    if (_cardPosition.value.dx > threshold ||
        details.velocity.pixelsPerSecond.dx > 500) {
      _performSwipe('like');
    } else if (_cardPosition.value.dx < -threshold ||
        details.velocity.pixelsPerSecond.dx < -500) {
      _performSwipe('pass');
    } else if (_cardPosition.value.dy < -threshold ||
        details.velocity.pixelsPerSecond.dy < -500) {
      _performSwipe('super_like');
    } else {
      // Snap back to center
      _resetCardPosition();
    }
  }

  // Animate card back to center
  void _resetCardPosition() {
    _isAnimating = true;

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
    });
  }

  // Perform swipe action
  Future<void> _performSwipe(String action) async {
    if (currentIndex >= users.length || _isAnimating) return;

    final user = users[currentIndex];
    _isAnimating = true;

    // Store for undo functionality
    lastSwipedUser = user;
    lastSwipeAction = action;

    // Update local counters optimistically
    setState(() {
      if (action == 'like' && likesRemaining > 0) {
        likesRemaining--;
      } else if (action == 'super_like' && superLikesRemaining > 0) {
        superLikesRemaining--;
      }
    });

    try {
      final result = await SwipeService.performSwipe(
        targetUserId: user.id,
        action: action,
      );

      if (result.success) {
        // Move to next user
        setState(() {
          currentIndex++;
          canUndo = true;
        });

        // Show match celebration if applicable
        if (result.isMatch) {
          _showMatchCelebration(user);
        }

        // Load more users if needed
        if (currentIndex >= users.length - 2) {
          _loadUsers();
        }
      } else {
        // Revert optimistic update on failure
        setState(() {
          if (action == 'like') {
            likesRemaining++;
          } else if (action == 'super_like') {
            superLikesRemaining++;
          }
        });

        _showErrorMessage(result.message);
      }
    } catch (e) {
      // Revert optimistic update on error
      setState(() {
        if (action == 'like') {
          likesRemaining++;
        } else if (action == 'super_like') {
          superLikesRemaining++;
        }
      });

      _showErrorMessage('Error performing swipe: $e');
    }

    _isAnimating = false;
    _resetCard();
  }

  void _showMatchCelebration(UserModel matchedUser) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => MatchCelebrationWidget(
            matchedUser: matchedUser,
            onKeepSwiping: () => Navigator.of(context).pop(),
            onSayHello: () {
              Navigator.of(context).pop();
              // Navigate to chat
            },
          ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Discover',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(FeatherIcons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const SwipeCardShimmer()
              : errorMessage.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FeatherIcons.alertTriangle,
                      color: Colors.red.withOpacity(0.7),
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadUsers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.primary,
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
              : currentIndex >= users.length
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FeatherIcons.heart,
                      color: CustomTheme.primary.withOpacity(0.7),
                      size: 80,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No more users to discover!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Check back later for new matches',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadUsers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.primary,
                      ),
                      child: const Text(
                        'Refresh',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Stats header
                  _buildStatsHeader(),

                  // Card stack
                  Expanded(child: _buildCardStack()),

                  // Action buttons
                  _buildActionButtons(),
                ],
              ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: FeatherIcons.heart,
            label: 'Likes',
            value: '$likesRemaining',
            color: Colors.red[400]!,
          ),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
          _buildStatItem(
            icon: FeatherIcons.star,
            label: 'Super Likes',
            value: '$superLikesRemaining',
            color: Colors.blue[400]!,
          ),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
          _buildStatItem(
            icon: FeatherIcons.users,
            label: 'Remaining',
            value: '${users.length - currentIndex}',
            color: Colors.green[400]!,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCardStack() {
    return Stack(
      children: [
        // Background cards (next 2 users) - optimized for performance
        for (int i = math.min(2, users.length - currentIndex - 1); i > 0; i--)
          if (currentIndex + i < users.length)
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, i * 4.0),
                child: Transform.scale(
                  scale: 1.0 - (i * 0.02),
                  child: SwipeCard(
                    user: users[currentIndex + i],
                    isBackground: true, // Optimize for background rendering
                    enableAnimations:
                        false, // Disable animations for performance
                    onTap: () {
                      // Navigate to profile view
                    },
                  ),
                ),
              ),
            ),

        // Active card - full features and animations enabled
        if (currentIndex < users.length)
          Positioned.fill(
            child: ValueListenableBuilder<Offset>(
              valueListenable: _cardPosition,
              builder: (context, position, child) {
                return ValueListenableBuilder<double>(
                  valueListenable: _cardRotation,
                  builder: (context, rotation, child) {
                    return Transform.translate(
                      offset: position,
                      child: Transform.rotate(
                        angle: rotation,
                        child: GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: SwipeCard(
                            user: users[currentIndex],
                            isBackground:
                                false, // Active card gets full features
                            enableAnimations:
                                true, // Full animations for active card
                            onTap: () {
                              // Navigate to profile view
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Undo button
          _buildActionButton(
            icon: FeatherIcons.rotateCcw,
            color: Colors.grey[600]!,
            size: 48,
            onPressed: canUndo ? () => _undoLastSwipe() : null,
          ),

          // Pass button
          _buildActionButton(
            icon: FeatherIcons.x,
            color: Colors.red[600]!,
            size: 56,
            onPressed: () => _performSwipe('pass'),
          ),

          // Super like button
          _buildActionButton(
            icon: FeatherIcons.star,
            color: Colors.blue[400]!,
            size: 52,
            onPressed:
                superLikesRemaining > 0
                    ? () => _performSwipe('super_like')
                    : () => _showUpgradeDialog('super_likes'),
            badge: superLikesRemaining > 0 ? null : '0',
          ),

          // Like button
          _buildActionButton(
            icon: FeatherIcons.heart,
            color: Colors.green[400]!,
            size: 64,
            onPressed:
                likesRemaining > 0
                    ? () => _performSwipe('like')
                    : () => _showUpgradeDialog('likes'),
            badge: likesRemaining > 0 ? null : '0',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback? onPressed,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(onPressed != null ? 0.1 : 0.05),
          border: Border.all(
            color: color.withOpacity(onPressed != null ? 0.3 : 0.1),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: onPressed != null ? color : color.withOpacity(0.3),
                size: size * 0.4,
              ),
            ),
            if (badge != null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _undoLastSwipe() {
    if (!canUndo || lastSwipedUser == null) return;

    setState(() {
      users.insert(currentIndex, lastSwipedUser!);
      canUndo = false;

      // Restore counters
      if (lastSwipeAction == 'like') {
        likesRemaining++;
      } else if (lastSwipeAction == 'super_like') {
        superLikesRemaining++;
      }
    });

    HapticFeedback.lightImpact();
  }

  void _showUpgradeDialog(String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: CustomTheme.cardDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Upgrade to Premium',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              feature == 'likes'
                  ? 'You\'ve used all your daily likes! Upgrade to Premium for unlimited likes.'
                  : 'You\'ve used all your super likes! Upgrade to Premium for unlimited super likes.',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Maybe Later',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to subscription screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primary,
                ),
                child: const Text(
                  'Upgrade',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
