import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../models/UserModel.dart';
import '../../services/swipe_service.dart';
import '../../utils/CustomTheme.dart';
import '../../widgets/dating/user_card_widget.dart';
import '../../widgets/dating/match_celebration_widget.dart';
import 'ProfileViewScreen.dart';

class WhoLikedMeScreen extends StatefulWidget {
  const WhoLikedMeScreen({Key? key}) : super(key: key);

  @override
  _WhoLikedMeScreenState createState() => _WhoLikedMeScreenState();
}

class _WhoLikedMeScreenState extends State<WhoLikedMeScreen>
    with TickerProviderStateMixin {
  List<UserModel> users = [];
  bool isLoading = true;
  String errorMessage = '';
  int currentPage = 1;
  bool hasMore = true;

  // Animation controllers for enhanced UX
  late AnimationController _cardAnimationController;
  Map<int, AnimationController> _buttonAnimationControllers = {};

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUsers();
  }

  void _setupAnimations() {
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    for (var controller in _buttonAnimationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

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

  Future<void> _loadUsers({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        hasMore = true;
        users.clear();
      });
    }

    try {
      final newUsers = await SwipeService.getWhoLikedMe(page: currentPage);

      setState(() {
        if (newUsers.isNotEmpty) {
          users.addAll(newUsers);
          currentPage++;
          hasMore = newUsers.length >= 20; // Assuming 20 per page
        } else {
          hasMore = false;
        }
        isLoading = false;
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load users who liked you';
      });
    }
  }

  Future<void> _handleLikeBack(UserModel user) async {
    // Trigger haptic feedback immediately
    _triggerHapticFeedback('medium');

    // Create animation controller for this specific card
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonAnimationControllers[user.id] = animationController;

    // Start button press animation
    animationController.forward();

    try {
      // Optimistic UI update - remove card immediately for better UX
      setState(() {
        users.removeWhere((u) => u.id == user.id);
      });

      final result = await SwipeService.performSwipe(
        targetUserId: user.id,
        action: 'like',
      );

      if (result.success) {
        if (result.isMatch) {
          // Trigger celebration haptic feedback
          _triggerHapticFeedback('heavy');
          _showEnhancedMatchDialog(user);
        } else {
          // Success feedback
          _triggerHapticFeedback('light');
          _showSuccessSnackbar('You liked ${user.name}! 💕');
        }
      } else {
        // Handle failure - restore the user to the list
        setState(() {
          users.insert(0, user);
        });
        _showErrorSnackbar('Failed to send like. Please try again.');
      }
    } catch (e) {
      // Handle error - restore the user to the list
      setState(() {
        users.insert(0, user);
      });
      _showErrorSnackbar('Network error. Please check your connection.');
    } finally {
      // Clean up animation controller
      _buttonAnimationControllers.remove(user.id);
      animationController.dispose();
    }
  }

  Future<void> _handlePass(UserModel user) async {
    // Trigger haptic feedback
    _triggerHapticFeedback('light');

    try {
      // Optimistic UI update
      setState(() {
        users.removeWhere((u) => u.id == user.id);
      });

      final result = await SwipeService.performSwipe(
        targetUserId: user.id,
        action: 'pass',
      );

      if (!result.success) {
        // Handle failure - restore the user to the list
        setState(() {
          users.insert(0, user);
        });
        _showErrorSnackbar('Failed to pass. Please try again.');
      }
    } catch (e) {
      // Handle error - restore the user to the list
      setState(() {
        users.insert(0, user);
      });
      _showErrorSnackbar('Network error. Please check your connection.');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            _loadUsers(refresh: true);
          },
        ),
      ),
    );
  }

  void _showEnhancedMatchDialog(UserModel matchedUser) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => MatchCelebrationWidget(
            matchedUser: matchedUser,
            onKeepSwiping: () {
              Navigator.pop(context);
            },
            onSayHello: () {
              Navigator.pop(context);
              // Navigate to chat screen
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(user: matchedUser)));
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.card,
        elevation: 0,
        title: FxText.titleMedium(
          'Who Liked Me',
          color: Colors.white,
          fontWeight: 700,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          isLoading && users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : users.isEmpty
              ? _buildEmptyWidget()
              : _buildUsersList(),
    );
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
            onPressed: () => _loadUsers(refresh: true),
            backgroundColor: CustomTheme.primary,
            child: FxText.bodyMedium('Retry', color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 80, color: CustomTheme.color2),
          const SizedBox(height: 20),
          FxText.titleMedium('No likes yet', color: CustomTheme.color),
          const SizedBox(height: 10),
          FxText.bodyMedium(
            'When someone likes you, they\'ll appear here',
            color: CustomTheme.color2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return RefreshIndicator(
      onRefresh: () => _loadUsers(refresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoading &&
              hasMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadUsers();
          }
          return false;
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: users.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == users.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = users[index];
            return _buildUserCard(user);
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // User image and info
            GestureDetector(
              onTap: () => Get.to(() => ProfileViewScreen(user)),
              child: UserCardWidget(user: user),
            ),

            // Action buttons
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.close,
                      color: Colors.grey[300]!,
                      iconColor: Colors.grey[600]!,
                      onPressed: () => _handlePass(user),
                      userId: user.id,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.favorite,
                      color: CustomTheme.primary,
                      iconColor: Colors.white,
                      onPressed: () => _handleLikeBack(user),
                      userId: user.id,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
    int? userId,
  }) {
    return AnimatedBuilder(
      animation:
          _buttonAnimationControllers[userId] ?? _cardAnimationController,
      builder: (context, child) {
        final controller =
            _buttonAnimationControllers[userId] ?? _cardAnimationController;
        final scale = 1.0 - (controller.value * 0.1); // Subtle press effect

        return Transform.scale(
          scale: scale,
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(17.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Add haptic feedback for button press
                  _triggerHapticFeedback('selection');
                  onPressed();
                },
                borderRadius: BorderRadius.circular(17.5),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
          ),
        );
      },
    );
  }
}
