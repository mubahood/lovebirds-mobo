import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../models/UserModel.dart';
import '../../services/swipe_service.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/SubscriptionManager.dart';
import '../../widgets/dating/user_card_widget.dart';
import '../../widgets/common/upgrade_prompt_dialog.dart';

class WhoLikedMeScreen extends StatefulWidget {
  @override
  _WhoLikedMeScreenState createState() => _WhoLikedMeScreenState();
}

class _WhoLikedMeScreenState extends State<WhoLikedMeScreen> {
  List<UserModel> _likedUsers = [];
  bool _isLoading = true;
  bool _hasSubscription = false;
  int _currentPage = 1;
  bool _hasMorePages = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkSubscription();
    _loadWhoLikedMe();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkSubscription() async {
    _hasSubscription = await SubscriptionManager.hasActiveSubscription();
    setState(() {});
  }

  void _loadWhoLikedMe() async {
    try {
      final users = await SwipeService.getWhoLikedMe(page: _currentPage);
      setState(() {
        if (_currentPage == 1) {
          _likedUsers = users;
        } else {
          _likedUsers.addAll(users);
        }
        _isLoading = false;
        _hasMorePages = users.length >= 20; // Assuming 20 per page
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load who liked you: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _hasMorePages &&
        !_isLoading) {
      _currentPage++;
      _isLoading = true;
      _loadWhoLikedMe();
    }
  }

  Future<void> _likeBack(UserModel user) async {
    if (!_hasSubscription) {
      _showUpgradePrompt(
        'Like Back Feature',
        'Upgrade to premium to like users back and create instant matches!',
      );
      return;
    }

    try {
      final result = await SwipeService.performSwipe(
        targetUserId: user.id,
        action: 'like',
      );

      if (result.success) {
        _showSuccessSnackBar('Liked ${user.name} back!');

        // Check if it's a match
        if (result.isMatch) {
          _showMatchDialog(user);
        }

        // Remove from liked users list
        setState(() {
          _likedUsers.removeWhere((u) => u.id == user.id);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to like back: $e');
    }
  }

  Future<void> _pass(UserModel user) async {
    try {
      await SwipeService.performSwipe(targetUserId: user.id, action: 'pass');

      setState(() {
        _likedUsers.removeWhere((u) => u.id == user.id);
      });

      _showSuccessSnackBar('Passed on ${user.name}');
    } catch (e) {
      _showErrorSnackBar('Failed to pass: $e');
    }
  }

  void _showUpgradePrompt(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => UpgradePromptDialog(
            title: title,
            message: message,
            features: [
              'See everyone who liked you',
              'Like back for instant matches',
              'Unlimited daily swipes',
              'Super likes and profile boosts',
            ],
          ),
    );
  }

  void _showMatchDialog(UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [CustomTheme.primary, CustomTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: 60),
                  SizedBox(height: 16),
                  FxText.titleLarge(
                    'It\'s a Match!',
                    color: Colors.white,
                    fontWeight: 700,
                  ),
                  SizedBox(height: 8),
                  FxText.bodyMedium(
                    'You and ${user.name} liked each other',
                    color: Colors.white.withValues(alpha: 0.9),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: FxText.bodyMedium(
                            'Keep Swiping',
                            color: Colors.white,
                            fontWeight: 600,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: FxText.bodyMedium(
                            'Say Hello',
                            color: CustomTheme.primary,
                            fontWeight: 600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showSuccessSnackBar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        elevation: 0,
        title: FxText.titleLarge(
          'Who Liked You',
          fontWeight: 700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (!_hasSubscription)
            IconButton(
              icon: Icon(Icons.star, color: CustomTheme.primary),
              onPressed:
                  () => _showUpgradePrompt(
                    'Premium Features',
                    'Unlock all premium features to get the most out of your dating experience!',
                  ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _currentPage == 1) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
            ),
            SizedBox(height: 16),
            FxText.bodyMedium(
              'Loading who liked you...',
              color: Colors.white70,
            ),
          ],
        ),
      );
    }

    if (_likedUsers.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Header stats
        _buildHeaderStats(),

        // Users grid
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _likedUsers.length + (_hasMorePages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _likedUsers.length) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CustomTheme.primary,
                    ),
                  ),
                );
              }

              final user = _likedUsers[index];
              return _buildUserCard(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomTheme.primary.withValues(alpha: 0.2),
            CustomTheme.primaryDark.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite, color: CustomTheme.primary, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyMedium(
                  '${_likedUsers.length} people liked you',
                  color: Colors.white,
                  fontWeight: 600,
                ),
                FxText.bodySmall(
                  _hasSubscription
                      ? 'Like them back to create a match!'
                      : 'Upgrade to see who they are',
                  color: Colors.white70,
                ),
              ],
            ),
          ),
          if (!_hasSubscription)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CustomTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FxText.bodySmall(
                'Premium',
                color: Colors.white,
                fontWeight: 600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          SizedBox(height: 24),
          FxText.titleMedium(
            'No likes yet',
            color: Colors.white,
            fontWeight: 600,
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: FxText.bodyMedium(
              'Keep swiping to find people who are interested in you!',
              color: Colors.white70,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.swipe, color: Colors.white),
            label: FxText.bodyMedium(
              'Start Swiping',
              color: Colors.white,
              fontWeight: 600,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.primary,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Stack(
      children: [
        // Blur effect for non-subscribers
        if (!_hasSubscription)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: UserCardWidget(user: user),
            ),
          )
        else
          UserCardWidget(user: user),

        // Overlay for non-subscribers
        if (!_hasSubscription)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.black.withValues(alpha: 0.7),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, color: CustomTheme.primary, size: 32),
                  SizedBox(height: 8),
                  FxText.bodySmall(
                    'Premium\nRequired',
                    color: Colors.white,
                    textAlign: TextAlign.center,
                    fontWeight: 600,
                  ),
                ],
              ),
            ),
          ),

        // Action buttons for subscribers
        if (_hasSubscription)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _pass(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(8),
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _likeBack(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.primary,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(8),
                    ),
                    child: Icon(Icons.favorite, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
