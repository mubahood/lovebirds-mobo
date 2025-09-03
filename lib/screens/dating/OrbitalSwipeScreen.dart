import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';

import '../../models/RespondModel.dart';
import '../../models/UserModel.dart';
import '../../controllers/MainController.dart';
import '../../services/swipe_service.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/Utilities.dart';
import '../../widgets/dating/swipe_shimmer.dart';
import '../shop/screens/shop/chat/chat_screen.dart';
import '../dating/ProfileViewScreen.dart';
import '../dating/AnalyticsScreen.dart';
import '../subscription/subscription_selection_screen.dart';

class OrbitalSwipeScreen extends StatefulWidget {
  const OrbitalSwipeScreen({Key? key}) : super(key: key);

  @override
  _OrbitalSwipeScreenState createState() => _OrbitalSwipeScreenState();
}

class _OrbitalSwipeScreenState extends State<OrbitalSwipeScreen>
    with TickerProviderStateMixin {
  // Core data
  List<UserModel> users = [];
  int selectedUserIndex = 0;
  bool isLoading = true;
  String errorMessage = '';

  // Controllers
  final MainController _mainC = Get.find<MainController>();

  // Animation controllers
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _actionController;

  // Animations
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Orbital positioning
  double _currentAngle = 0.0;
  final double _orbitRadius = 140.0;
  final double _centerRadius = 80.0;
  final double _satelliteRadius = 35.0;

  // Gesture tracking
  bool _isDragging = false;
  Offset _lastPanPosition = Offset.zero;
  bool _isAnimating = false;

  // User interface state
  bool _showUserDetails = false;
  UserModel? _selectedUser;

  // Stats and premium features
  int likesRemaining = 10; // Updated to 10 for free users
  int messagesRemaining = 10; // New: message limits for free users
  bool hasPremium = false;

  // Analytics data
  Map<String, dynamic>? _analyticsData;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUsers();
    _loadStats();
  }

  void _setupAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _actionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Initialize with first user if available
    if (users.isNotEmpty) {
      _selectedUser = users[selectedUserIndex];
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final userList = await SwipeService.getBatchSwipeUsers(
        count: 6,
      ); // FIXED: Reduce to 6 users for cleaner orbital UI

      if (userList.isEmpty) {
        setState(() {
          errorMessage = 'No users found. Please try again later.';
          isLoading = false;
        });
        return;
      }

      setState(() {
        users = userList;
        isLoading = false;
        if (users.isNotEmpty) {
          selectedUserIndex = 0;
          _selectedUser = users[selectedUserIndex];
        }
      });

      if (users.isNotEmpty) {
        _fadeController.forward();
      }
    } catch (e) {
      print('Error in _loadUsers: $e');
      setState(() {
        errorMessage =
            'Error loading users. Please check your internet connection and try again.';
        isLoading = false;
      });

      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load users: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadUsers,
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      // Load user stats and analytics in parallel
      await Future.wait([_loadUserStats(), _loadAnalyticsData()]);

      setState(() {
        likesRemaining = 10; // Updated: Will be updated from user stats
        messagesRemaining = 10; // New: Will be updated from user stats
        _updatePremiumStatus();
      });
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<Map<String, dynamic>> _loadUserStats() async {
    try {
      // You can implement API call to get user stats
      final response = await Utils.http_get('user-stats', {});
      final resp = RespondModel(response);

      if (resp.code == 1) {
        final data = resp.data ?? {};
        setState(() {
          likesRemaining =
              int.tryParse(data['likes_remaining']?.toString() ?? '10') ??
              10; // Updated default
          messagesRemaining =
              int.tryParse(data['messages_remaining']?.toString() ?? '10') ??
              10; // New: message limits
        });
        return data;
      }
      return {};
    } catch (e) {
      print('Error loading user stats: $e');
      return {};
    }
  }

  Future<void> _loadAnalyticsData() async {
    try {
      final response = await SwipeService.getSwipeStats();
      if (response != null) {
        setState(() {
          _analyticsData = {
            'profile_views':
                0, // Not available in SwipeStats, would need separate API
            'likes_received': response.likesReceived,
            'matches_count': response.matches,
            'likes_given': response.likesGiven,
            'super_likes_given': response.superLikesGiven,
            'passes_given': response.passesGiven,
          };
        });
      } else {
        setState(() {
          _analyticsData = {
            'profile_views': 0,
            'likes_received': 0,
            'matches_count': 0,
            'likes_given': 0,
            'super_likes_given': 0,
            'passes_given': 0,
          };
        });
      }
    } catch (e) {
      print('Error loading analytics data: $e');
      setState(() {
        _analyticsData = {
          'profile_views': 0,
          'likes_received': 0,
          'matches_count': 0,
          'likes_given': 0,
          'super_likes_given': 0,
          'passes_given': 0,
        };
      });
    }
  }

  void _updatePremiumStatus() {
    final currentUser = _mainC.userModel;
    final subscriptionTier = currentUser.subscription_tier.toLowerCase();
    setState(() {
      hasPremium =
          subscriptionTier.contains('premium') ||
          subscriptionTier.contains('plus');
    });
  }

  // Direct click handlers with no conflicts
  void _handleOrbitalUserTap(int index) {
    if (_isAnimating) return;

    HapticFeedback.lightImpact();
    print('Orbital user tapped: ${users[index].name} (index: $index)');

    if (index != selectedUserIndex) {
      // Bring this user to center
      _bringUserToCenter(index);
    }
  }

  void _handleCenterUserTap() {
    if (_selectedUser == null) return;

    HapticFeedback.lightImpact();
    print('Center user tapped: ${_selectedUser!.name}');

    Utils.toast("Opening ${_selectedUser!.name}'s profile");
    _openUserProfile(_selectedUser!);
  }

  void _bringUserToCenter(int index) {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      selectedUserIndex = index;
      _selectedUser = users[index];
      _showUserDetails = false;
    });

    // Calculate rotation needed
    final targetAngle = -(index * (math.pi * 2 / users.length));

    _rotationController
        .animateTo(
          targetAngle / (math.pi * 2),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        )
        .then((_) {
          setState(() {
            _isAnimating = false;
          });
        });

    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    HapticFeedback.lightImpact();
  }

  void _onOrbitDrag(DragUpdateDetails details) {
    if (!_isDragging) return;

    final currentPos = details.localPosition;
    final deltaAngle = (currentPos.dx - _lastPanPosition.dx) / _orbitRadius;

    setState(() {
      _currentAngle += deltaAngle;
      _lastPanPosition = currentPos;
    });
  }

  void _onOrbitDragEnd() {
    _isDragging = false;

    // Snap to nearest user
    final userCount = users.length;
    if (userCount > 0 && !_isAnimating) {
      final anglePerUser = (math.pi * 2) / userCount;
      final normalizedAngle = _currentAngle % (math.pi * 2);
      final nearestUserIndex =
          ((normalizedAngle / anglePerUser).round()) % userCount;

      if (nearestUserIndex != selectedUserIndex) {
        _bringUserToCenter(nearestUserIndex);
      }
    }
  }

  Future<void> _performAction(String action) async {
    if (_selectedUser == null || _isAnimating) return;

    _actionController.forward().then((_) {
      _actionController.reverse();
    });

    try {
      final result = await SwipeService.performSwipe(
        targetUserId: _selectedUser!.id,
        action: action,
      );

      if (result.success) {
        // Update like limits for non-premium users when liking
        if (!hasPremium && action == 'like') {
          setState(() {
            likesRemaining = math.max(0, likesRemaining - 1);
          });
        }

        // Remove current user
        setState(() {
          users.removeAt(selectedUserIndex);

          // Adjust selected index
          if (selectedUserIndex >= users.length) {
            selectedUserIndex = 0;
          }

          _selectedUser = users.isNotEmpty ? users[selectedUserIndex] : null;
        });

        // Show match celebration if it was a mutual like
        if (result.isMatch) {
          _showMatchCelebration();
        }

        // Load more users if running low
        if (users.length < 3) {
          _loadUsers();
        }
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showMatchCelebration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "It's a Match! 🎉",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You and ${_selectedUser?.getFirstName() ?? "this person"} liked each other!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Keep Swiping',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Navigate to chat
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.primary,
                      ),
                      child: const Text(
                        'Say Hello',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildModernAppBar(),
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
              : users.isEmpty
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
                  ],
                ),
              )
              : Column(
                children: [
                  // Key features section instead of stats
                  _buildKeyFeaturesSection(),

                  // Main orbital area
                  Expanded(flex: 3, child: _buildOrbitalSwipeArea()),

                  // User details section
                  if (_showUserDetails && _selectedUser != null)
                    Expanded(flex: 2, child: _buildUserDetailsSection()),

                  // Improved action buttons
                  _buildImprovedActionButtons(),
                ],
              ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 12, // Reduced spacing
      title: Row(
        children: [
          // App title with gradient - made more compact
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomTheme.primary, CustomTheme.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6), // Smaller radius
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ), // Reduced padding
            child: Text(
              'Lovebirds',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16, // Slightly smaller
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Limit indicators for free users - more compact
          if (!hasPremium) ...[
            SizedBox(width: 12), // Fixed width instead of Spacer
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FeatherIcons.heart,
                    color: Colors.red,
                    size: 10,
                  ), // Smaller icons
                  SizedBox(width: 2), // Reduced spacing
                  Text(
                    '$likesRemaining',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10, // Smaller text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6), // Reduced spacing
                  Icon(
                    FeatherIcons.messageCircle,
                    color: CustomTheme.accent,
                    size: 10,
                  ),
                  SizedBox(width: 2),
                  Text(
                    '$messagesRemaining',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Analytics button - more compact
        IconButton(
          onPressed: _showAnalyticsScreen,
          icon: Container(
            padding: EdgeInsets.all(6), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.5),
                  Colors.blue.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8), // Smaller radius
              border: Border.all(
                color: Colors.purple.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Icon(
              FeatherIcons.barChart,
              color: Colors.white,
              size: 16,
            ), // Smaller icon
          ),
        ),

        // Premium subscription button - more compact
        Container(
          margin: EdgeInsets.only(right: 8, left: 4), // Reduced margins
          child: ElevatedButton.icon(
            onPressed: _showPremiumDialog,
            icon: Icon(
              hasPremium ? FeatherIcons.award : FeatherIcons.star,
              size: 14, // Smaller icon
              color: hasPremium ? CustomTheme.accent : Colors.white,
            ),
            label: Text(
              hasPremium ? 'PRO' : 'PRO', // Shorter text
              style: TextStyle(
                color: hasPremium ? Colors.black : Colors.white,
                fontSize: 11, // Smaller font
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  hasPremium
                      ? CustomTheme.accent
                      : CustomTheme.primary.withOpacity(0.8),
              foregroundColor: hasPremium ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Smaller radius
                side: BorderSide(
                  color: hasPremium ? CustomTheme.accent : CustomTheme.primary,
                  width: 1,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ), // Reduced padding
              minimumSize: Size(0, 28), // Smaller minimum size
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyFeaturesSection() {
    if (_selectedUser == null) return SizedBox.shrink();

    final user = _selectedUser!;
    List<Map<String, dynamic>> features = [];

    // Extract key features with their corresponding icons
    final age = int.tryParse(user.age) ?? 0;
    if (age > 0) {
      features.add({
        'text': '$age years old',
        'icon': FeatherIcons.calendar,
        'type': 'age',
      });
    }

    if (user.city.isNotEmpty && user.city.trim() != '') {
      features.add({
        'text': user.city.trim(),
        'icon': FeatherIcons.mapPin,
        'type': 'location',
      });
    }

    if (user.occupation.isNotEmpty && user.occupation.trim() != '') {
      features.add({
        'text': user.occupation.trim(),
        'icon': FeatherIcons.briefcase,
        'type': 'work',
      });
    }

    // Add education if available
    if (user.education_level.isNotEmpty && user.education_level.trim() != '') {
      features.add({
        'text': user.education_level.trim(),
        'icon': FeatherIcons.book,
        'type': 'education',
      });
    }

    // Add interests with appropriate icons
    if (user.interests.isNotEmpty && user.interests.trim() != '') {
      final interests =
          user.interests
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty && e != '')
              .take(3)
              .toList();

      for (String interest in interests) {
        features.add({
          'text': interest,
          'icon': _getInterestIcon(interest),
          'type': 'interest',
        });
      }
    }

    // Add height if available
    if (user.height_cm.isNotEmpty && user.height_cm.trim() != '') {
      final height = int.tryParse(user.height_cm) ?? 0;
      if (height > 0) {
        features.add({
          'text': '${height}cm',
          'icon': FeatherIcons.trendingUp,
          'type': 'height',
        });
      }
    }

    // If no features to show, return empty widget
    if (features.isEmpty) return SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              features
                  .take(6)
                  .map((featureData) => _buildFeatureChip(featureData))
                  .toList(),
        ),
      ),
    );
  }

  // Helper method to build individual feature chips with icons
  Widget _buildFeatureChip(Map<String, dynamic> featureData) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomTheme.primary.withOpacity(0.3),
            CustomTheme.accent.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          width: 1.5,
          color: CustomTheme.primary.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            featureData['icon'],
            size: 14,
            color: Colors.white.withOpacity(0.9),
          ),
          SizedBox(width: 6),
          Text(
            featureData['text'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get appropriate icons for interests
  IconData _getInterestIcon(String interest) {
    final lowerInterest = interest.toLowerCase();

    // Sports & Fitness
    if (lowerInterest.contains('gym') ||
        lowerInterest.contains('fitness') ||
        lowerInterest.contains('workout')) {
      return FeatherIcons.activity;
    }
    if (lowerInterest.contains('running') ||
        lowerInterest.contains('jogging') ||
        lowerInterest.contains('marathon')) {
      return FeatherIcons.zap;
    }
    if (lowerInterest.contains('swimming') ||
        lowerInterest.contains('diving')) {
      return FeatherIcons.droplet;
    }
    if (lowerInterest.contains('football') ||
        lowerInterest.contains('soccer') ||
        lowerInterest.contains('basketball') ||
        lowerInterest.contains('tennis') ||
        lowerInterest.contains('sport')) {
      return FeatherIcons.target;
    }

    // Arts & Creativity
    if (lowerInterest.contains('music') ||
        lowerInterest.contains('singing') ||
        lowerInterest.contains('guitar') ||
        lowerInterest.contains('piano')) {
      return FeatherIcons.music;
    }
    if (lowerInterest.contains('painting') ||
        lowerInterest.contains('drawing') ||
        lowerInterest.contains('art')) {
      return FeatherIcons.edit3;
    }
    if (lowerInterest.contains('photography') ||
        lowerInterest.contains('photo')) {
      return FeatherIcons.camera;
    }
    if (lowerInterest.contains('dancing') || lowerInterest.contains('dance')) {
      return FeatherIcons.headphones;
    }

    // Food & Drink
    if (lowerInterest.contains('cooking') ||
        lowerInterest.contains('baking') ||
        lowerInterest.contains('chef')) {
      return FeatherIcons.users;
    }
    if (lowerInterest.contains('coffee') || lowerInterest.contains('tea')) {
      return FeatherIcons.coffee;
    }
    if (lowerInterest.contains('wine') ||
        lowerInterest.contains('beer') ||
        lowerInterest.contains('cocktail')) {
      return FeatherIcons.moreHorizontal;
    }

    // Travel & Adventure
    if (lowerInterest.contains('travel') ||
        lowerInterest.contains('adventure') ||
        lowerInterest.contains('explore')) {
      return FeatherIcons.compass;
    }
    if (lowerInterest.contains('hiking') ||
        lowerInterest.contains('climbing') ||
        lowerInterest.contains('mountain')) {
      return FeatherIcons.triangle;
    }
    if (lowerInterest.contains('beach') ||
        lowerInterest.contains('ocean') ||
        lowerInterest.contains('surfing')) {
      return FeatherIcons.sun;
    }

    // Technology & Games
    if (lowerInterest.contains('gaming') ||
        lowerInterest.contains('games') ||
        lowerInterest.contains('video game')) {
      return FeatherIcons.play;
    }
    if (lowerInterest.contains('tech') ||
        lowerInterest.contains('computer') ||
        lowerInterest.contains('coding')) {
      return FeatherIcons.monitor;
    }

    // Reading & Learning
    if (lowerInterest.contains('reading') ||
        lowerInterest.contains('books') ||
        lowerInterest.contains('literature')) {
      return FeatherIcons.bookOpen;
    }
    if (lowerInterest.contains('writing') ||
        lowerInterest.contains('blogging') ||
        lowerInterest.contains('poetry')) {
      return FeatherIcons.penTool;
    }

    // Movies & Entertainment
    if (lowerInterest.contains('movie') ||
        lowerInterest.contains('cinema') ||
        lowerInterest.contains('film')) {
      return FeatherIcons.film;
    }
    if (lowerInterest.contains('tv') ||
        lowerInterest.contains('series') ||
        lowerInterest.contains('netflix')) {
      return FeatherIcons.tv;
    }

    // Nature & Animals
    if (lowerInterest.contains('pet') ||
        lowerInterest.contains('dog') ||
        lowerInterest.contains('cat') ||
        lowerInterest.contains('animal')) {
      return FeatherIcons.heart;
    }
    if (lowerInterest.contains('garden') ||
        lowerInterest.contains('plant') ||
        lowerInterest.contains('flower')) {
      return FeatherIcons.feather;
    }

    // Default icon for unmatched interests
    return FeatherIcons.star;
  }

  Widget _buildOrbitalSwipeArea() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return GestureDetector(
          onPanStart: (details) {
            _isDragging = true;
            _lastPanPosition = details.localPosition;
          },
          onPanUpdate: _onOrbitDrag,
          onPanEnd: (_) => _onOrbitDragEnd(),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final centerX = constraints.maxWidth / 2;
                final centerY = constraints.maxHeight * 0.4;

                return Stack(
                  children: [
                    // Orbital track - perfect circle positioned at center
                    Positioned(
                      left: centerX - _orbitRadius,
                      top: centerY - _orbitRadius,
                      child: Container(
                        width: _orbitRadius * 2,
                        height: _orbitRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    // Orbital users positioned in perfect circle around the track
                    ...List.generate(users.length, (index) {
                      final angle =
                          _currentAngle +
                          (index * (math.pi * 2 / users.length));
                      final isSelected = index == selectedUserIndex;

                      // Calculate perfect circular positioning relative to center
                      final posX =
                          centerX +
                          (math.cos(angle) * _orbitRadius) -
                          _satelliteRadius;
                      final posY =
                          centerY +
                          (math.sin(angle) * _orbitRadius) -
                          _satelliteRadius;

                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        left: posX,
                        top: posY,
                        child: GestureDetector(
                          onTap: () => _handleOrbitalUserTap(index),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 300),
                            scale: isSelected ? 0.3 : 1.0,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: isSelected ? 0.3 : 1.0,
                              child: _buildUserAvatar(
                                users[index],
                                _satelliteRadius,
                                false,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    // Center user (selected) - perfectly centered and clickable
                    if (_selectedUser != null)
                      Positioned(
                        left: centerX - _centerRadius,
                        top: centerY - _centerRadius,
                        child: AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: GestureDetector(
                                onTap: _handleCenterUserTap,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: CustomTheme.primary.withOpacity(
                                          0.5,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: _buildUserAvatar(
                                    _selectedUser!,
                                    _centerRadius,
                                    true,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Connection lines
                    if (_selectedUser != null)
                      CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: ConnectionLinesPainter(
                          users: users,
                          selectedIndex: selectedUserIndex,
                          currentAngle: _currentAngle,
                          orbitRadius: _orbitRadius,
                          centerX: centerX,
                          centerY: centerY,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(UserModel user, double radius, bool isCenter) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isCenter
                  ? [CustomTheme.primary, CustomTheme.accent]
                  : [
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.6),
                  ],
        ),
        boxShadow: [
          BoxShadow(
            color:
                isCenter
                    ? CustomTheme.primary.withOpacity(0.3)
                    : Colors.black.withOpacity(0.3),
            blurRadius: isCenter ? 20 : 10,
            spreadRadius: isCenter ? 5 : 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: user.getPrimaryPhotoUrl(),
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  color: Colors.grey[800],
                  child: Icon(
                    FeatherIcons.user,
                    color: Colors.white.withOpacity(0.5),
                    size: radius * 0.6,
                  ),
                ),
            errorWidget:
                (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: Icon(
                    FeatherIcons.user,
                    color: Colors.white.withOpacity(0.5),
                    size: radius * 0.6,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetailsSection() {
    if (_selectedUser == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User name and age
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedUser!.getFirstName()}, ${_selectedUser!.age}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_selectedUser!.city.isNotEmpty ||
                            _selectedUser!.occupation.isNotEmpty)
                          const SizedBox(height: 4),
                        Text(
                          [
                            if (_selectedUser!.occupation.isNotEmpty)
                              _selectedUser!.occupation,
                            if (_selectedUser!.city.isNotEmpty)
                              _selectedUser!.city,
                          ].join(' • '),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Online status
                  if (_selectedUser!.isOnline)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Online',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // User bio
              if (_selectedUser!.bio.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _selectedUser!.bio,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),

              // Interest chips
              if (_selectedUser!.interests.isNotEmpty)
                const SizedBox(height: 16),
              if (_selectedUser!.interests.isNotEmpty) _buildInterestChips(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInterestChips() {
    final interests =
        _selectedUser!.interests
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .take(4)
            .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          interests.map((interest) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: CustomTheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CustomTheme.primary.withOpacity(0.3)),
              ),
              child: Text(
                interest,
                style: TextStyle(
                  color: CustomTheme.primary.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildImprovedActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass button
          _buildModernActionButtonWithText(
            icon: FeatherIcons.x,
            color: Colors.grey[600]!,
            size: 50, // Reduced size to fit 4 buttons
            label: 'Pass',
            onPressed: () => _performAction('pass'),
          ),

          // Like button
          _buildModernActionButtonWithText(
            icon: FeatherIcons.heart,
            color: Colors.red[400]!,
            size: 60, // Slightly reduced size
            label: 'Like',
            onPressed:
                likesRemaining > 0
                    ? () => _performAction('like')
                    : () => _showUpgradeDialog('likes'),
            badge: likesRemaining > 0 ? null : '0',
          ),

          // View Profile button (replaces Boost)
          _buildModernActionButtonWithText(
            icon: FeatherIcons.user,
            color: CustomTheme.primary,
            size: 50,
            label: 'View Profile',
            onPressed:
                _selectedUser != null
                    ? () => _openUserProfile(_selectedUser!)
                    : null,
            badge: null,
          ),

          // Message/Chat button
          _buildModernActionButtonWithText(
            icon: FeatherIcons.messageCircle,
            color: CustomTheme.accent,
            size: 50, // Reduced size to fit 4 buttons
            label: 'Message',
            onPressed:
                hasPremium || messagesRemaining > 0
                    ? () => _showMessageDialog()
                    : () => _showUpgradeDialog('messages'),
            badge: messagesRemaining > 0 || hasPremium ? null : '0',
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButtonWithText({
    required IconData icon,
    required Color color,
    required double size,
    required String label,
    required VoidCallback? onPressed,
    String? badge,
  }) {
    return AnimatedBuilder(
      animation: _actionController,
      builder: (context, child) {
        final scale = 1.0 - (_actionController.value * 0.1);
        return Transform.scale(
          scale: scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onPressed,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                    ),
                    border: Border.all(color: color.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(child: Icon(icon, color: color, size: size * 0.4)),
                      if (badge != null)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Premium dialog
  void _showPremiumDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF1A1A2E), const Color(0xFF0F0F1A)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CustomTheme.primary.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FeatherIcons.star, color: CustomTheme.accent, size: 48),
                const SizedBox(height: 16),
                Text(
                  '✨ Unlock Premium ✨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Get unlimited likes, super likes, and premium features!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Maybe Later',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Get.to(() => const SubscriptionSelectionScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.primary,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Upgrade Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Message dialog with enhanced features
  void _showMessageDialog() {
    if (_selectedUser == null) return;

    final TextEditingController messageController = TextEditingController();
    bool isSending = false;

    // Check message limits for non-premium users
    final hasMessagesLeft = hasPremium || messagesRemaining > 0;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) => Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A1A2E),
                        const Color(0xFF0F0F1A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: CustomTheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User avatar and name
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CustomTheme.primary,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: _selectedUser!.getPrimaryPhotoUrl(),
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Container(
                                      color: Colors.grey[800],
                                      child: Icon(
                                        FeatherIcons.user,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Container(
                                      color: Colors.grey[800],
                                      child: Icon(
                                        FeatherIcons.user,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Send message to',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _selectedUser!.getFirstName(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!hasMessagesLeft)
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Premium required',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(FeatherIcons.x, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Message limit indicator for free users
                      if (!hasPremium) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                messagesRemaining > 0
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  messagesRemaining > 0
                                      ? Colors.blue.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                messagesRemaining > 0
                                    ? FeatherIcons.messageCircle
                                    : FeatherIcons.alertTriangle,
                                color:
                                    messagesRemaining > 0
                                        ? Colors.blue
                                        : Colors.red,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  messagesRemaining > 0
                                      ? '$messagesRemaining messages remaining today'
                                      : 'Daily message limit reached (0/10)',
                                  style: TextStyle(
                                    color:
                                        messagesRemaining > 0
                                            ? Colors.blue
                                            : Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Message suggestions (quick starters)
                      if (hasMessagesLeft) ...[
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick starters:',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildQuickMessage(
                                    messageController,
                                    setDialogState,
                                    "Hi there! 👋",
                                  ),
                                  _buildQuickMessage(
                                    messageController,
                                    setDialogState,
                                    "Love your profile! ✨",
                                  ),
                                  _buildQuickMessage(
                                    messageController,
                                    setDialogState,
                                    "How's your day going? 😊",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Message input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CustomTheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: TextField(
                          controller: messageController,
                          maxLines: 4,
                          style: TextStyle(color: Colors.white),
                          enabled: hasMessagesLeft && !isSending,
                          decoration: InputDecoration(
                            hintText:
                                hasMessagesLeft
                                    ? 'Write your message...'
                                    : 'Upgrade to Premium to send messages',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed:
                                  isSending
                                      ? null
                                      : () => Navigator.of(context).pop(),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color:
                                      isSending
                                          ? Colors.grey[600]
                                          : Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  (!hasMessagesLeft || isSending)
                                      ? null
                                      : () async {
                                        final message =
                                            messageController.text.trim();
                                        if (message.isNotEmpty) {
                                          setDialogState(
                                            () => isSending = true,
                                          );
                                          _sendMessage(message);
                                          Navigator.of(context).pop();
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    hasMessagesLeft
                                        ? CustomTheme.primary
                                        : Colors.grey[700],
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child:
                                  isSending
                                      ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        hasMessagesLeft
                                            ? 'Send Message'
                                            : 'Get Premium',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),

                      // Premium upgrade message
                      if (!hasMessagesLeft) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                FeatherIcons.star,
                                color: Colors.orange,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Upgrade to Premium for unlimited messaging and more features!',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }

  // Helper method to build quick message chips
  Widget _buildQuickMessage(
    TextEditingController controller,
    StateSetter setDialogState,
    String message,
  ) {
    return InkWell(
      onTap: () {
        controller.text = message;
        setDialogState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: CustomTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: CustomTheme.primary.withOpacity(0.3)),
        ),
        child: Text(
          message,
          style: TextStyle(color: CustomTheme.primary, fontSize: 12),
        ),
      ),
    );
  }

  // Open user profile
  void _openUserProfile(UserModel user) {
    try {
      // Navigate to the correct profile viewing screen with user data
      Get.to(() => ProfileViewScreen(user));
    } catch (e) {
      // Handle any navigation errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Profile navigation error: $e');
    }
  }

  // Send message using the same logic as ChatScreen
  void _sendMessage(String message) async {
    if (_selectedUser == null) return;

    // Check message limits for non-premium users
    if (!hasPremium && messagesRemaining <= 0) {
      _showUpgradeDialog('messages');
      return;
    }

    // Show loading state
    Utils.toast('Sending message...', color: Colors.blue);

    try {
      // Use the same endpoint and parameters as the main chat system
      final response = await Utils.http_post('chat-send', {
        'receiver_id': _selectedUser!.id,
        'content': message,
        'message_type': 'text',
        // Note: chat_head_id is optional - API will create new chat if needed
      });

      final resp = RespondModel(response);
      if (resp.code == 1) {
        // Success - message sent and chat head created/found
        Utils.toast('Message sent successfully! 💖', color: Colors.green);

        // Update message limits for non-premium users
        if (!hasPremium) {
          setState(() {
            messagesRemaining = math.max(0, messagesRemaining - 1);
          });
        }

        // Optional: Navigate to chat screen for continued conversation
        _navigateToChat();
      } else {
        // Handle API errors
        Utils.toast(resp.message, color: Colors.red);
        print('Chat send error: ${resp.message}');
      }
    } catch (e) {
      // Handle network or other errors
      Utils.toast(
        'Failed to send message. Please check your connection.',
        color: Colors.red,
      );
      print('Error in _sendMessage: $e');
    }
  }

  // Navigate to chat screen for continued conversation
  void _navigateToChat() async {
    if (_selectedUser == null) return;

    try {
      // Navigate with proper parameters using direct import
      Get.to(
        () => ChatScreen({
          'receiver_id': _selectedUser!.id,
          'sender_id':
              _selectedUser!.id, // Will be determined by API from auth token
          'task': 'dating', // Indicate this is a dating chat
        }),
      );
    } catch (e) {
      // If navigation fails, show a helpful message
      Utils.toast(
        'Message sent! Check your chat list to continue the conversation.',
        color: Colors.green,
      );
      print('Chat navigation error: $e');
    }
  }

  void _showUpgradeDialog(String feature) {
    // Customize message based on feature
    String title = 'Upgrade to Premium';
    String content = '';

    switch (feature) {
      case 'likes':
        content =
            'You\'ve used all your daily likes (10/day)! Upgrade to Premium for unlimited likes and more features.';
        break;
      case 'messages':
        content =
            'You\'ve used all your daily messages (10/day)! Upgrade to Premium for unlimited messaging and more features.';
        break;
      case 'boost':
        content =
            'Boost your profile for 3x more visibility! Upgrade to Premium for boosts and more features.';
        break;
      default:
        content =
            'Upgrade to Premium for unlimited likes, messages, boosts and more features.';
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              content,
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
                  Get.to(() => const SubscriptionSelectionScreen());
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

  // Analytics Screen Navigation
  void _showAnalyticsScreen() async {
    try {
      HapticFeedback.lightImpact();
      await Get.to(() => const AnalyticsScreen());
      // Refresh data when returning
      await _loadAnalyticsData();
    } catch (e) {
      Utils.toast('Analytics feature coming soon!', color: Colors.blue);
      _showAnalyticsDialog();
    }
  }

  // Analytics dialog for when AnalyticsScreen is not available
  void _showAnalyticsDialog() {
    final analytics = _analyticsData ?? {};

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF1A1A2E), const Color(0xFF0F0F1A)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.withOpacity(0.6),
                              Colors.blue.withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          FeatherIcons.barChart,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '📊 Dating Analysis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(FeatherIcons.x, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Analytics stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnalyticsCard(
                          '❤️ Likes Received',
                          '${analytics['likes_received'] ?? 0}',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildAnalyticsCard(
                          '🔥 Matches',
                          '${analytics['matches_count'] ?? 0}',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnalyticsCard(
                          '👍 Likes Given',
                          '${analytics['likes_given'] ?? 0}',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildAnalyticsCard(
                          '⭐ Super Likes',
                          '${analytics['super_likes_given'] ?? 0}',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Upgrade prompt
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🔥 Unlock Advanced Analytics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Get detailed insights, success rates, and profile optimization tips!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Get.to(() => const SubscriptionSelectionScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Upgrade Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: CustomTheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Custom painter for orbital connection lines
class ConnectionLinesPainter extends CustomPainter {
  final List<UserModel> users;
  final int selectedIndex;
  final double currentAngle;
  final double orbitRadius;
  final double centerX;
  final double centerY;

  ConnectionLinesPainter({
    required this.users,
    required this.selectedIndex,
    required this.currentAngle,
    required this.orbitRadius,
    required this.centerX,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    final center = Offset(centerX, centerY);

    // Draw lines from center to selected orbital user
    if (selectedIndex >= 0 && selectedIndex < users.length) {
      final angle =
          currentAngle + (selectedIndex * (math.pi * 2 / users.length));
      final orbitalPosition =
          center +
          Offset(math.cos(angle) * orbitRadius, math.sin(angle) * orbitRadius);

      canvas.drawLine(center, orbitalPosition, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
