import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../models/UserModel.dart';
import '../../services/swipe_service.dart';
import '../../utils/CustomTheme.dart';
import '../../widgets/dating/swipe_shimmer.dart';

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

  // Stats
  int likesRemaining = 50;
  int superLikesRemaining = 3;

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

      final userList = await SwipeService.getBatchSwipeUsers();



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
      setState(() {
        errorMessage = 'Error loading users: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadStats() async {
    // Load user stats
    setState(() {
      likesRemaining = 50;
      superLikesRemaining = 3;
    });
  }

  void _onUserTap(int index) {
    if (index == selectedUserIndex) {
      // Tapped on center user - show details
      setState(() {
        _showUserDetails = !_showUserDetails;
      });
    } else {
      // Tapped on orbital user - bring to center
      _bringUserToCenter(index);
    }
  }

  void _bringUserToCenter(int index) {
    if (_isAnimating) return;

    setState(() {
      selectedUserIndex = index;
      _selectedUser = users[index];
      _showUserDetails = false;
    });

    // Calculate rotation needed
    final targetAngle = -(index * (math.pi * 2 / users.length));

    _rotationController.animateTo(
      targetAngle / (math.pi * 2),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );

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
    if (userCount > 0) {
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
      backgroundColor: const Color(0xFF0A0A0A),
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
                  // Stats header
                  _buildStatsHeader(),

                  // Main orbital area
                  Expanded(flex: 3, child: _buildOrbitalSwipeArea()),

                  // User details section
                  if (_showUserDetails && _selectedUser != null)
                    Expanded(flex: 2, child: _buildUserDetailsSection()),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildActionButtons(),
                  ),
                ],
              ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            label: 'Available',
            value: '${users.length}',
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Orbital track
                Container(
                  width: _orbitRadius * 2,
                  height: _orbitRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                ),

                // Orbital users
                ...List.generate(users.length, (index) {
                  final angle =
                      _currentAngle + (index * (math.pi * 2 / users.length));
                  final isSelected = index == selectedUserIndex;

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    left:
                        MediaQuery.of(context).size.width / 2 +
                        math.cos(angle) * _orbitRadius -
                        _satelliteRadius,
                    top:
                        MediaQuery.of(context).size.height * 0.4 +
                        math.sin(angle) * _orbitRadius -
                        _satelliteRadius,
                    child: GestureDetector(
                      onTap: () => _onUserTap(index),
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

                // Center user (selected)
                if (_selectedUser != null)
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: GestureDetector(
                          onTap: () => _onUserTap(selectedUserIndex),
                          child: _buildUserAvatar(
                            _selectedUser!,
                            _centerRadius,
                            true,
                          ),
                        ),
                      );
                    },
                  ),

                // Connection lines
                if (_selectedUser != null)
                  CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 600),
                    painter: ConnectionLinesPainter(
                      users: users,
                      selectedIndex: selectedUserIndex,
                      currentAngle: _currentAngle,
                      orbitRadius: _orbitRadius,
                    ),
                  ),
              ],
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pass button
        _buildActionButton(
          icon: FeatherIcons.x,
          color: Colors.grey[600]!,
          size: 56,
          onPressed: () => _performAction('pass'),
        ),

        // Like button
        _buildActionButton(
          icon: FeatherIcons.heart,
          color: Colors.red[400]!,
          size: 68,
          onPressed:
              likesRemaining > 0
                  ? () => _performAction('like')
                  : () => _showUpgradeDialog('likes'),
          badge: likesRemaining > 0 ? null : '0',
        ),

        // Super like button
        _buildActionButton(
          icon: FeatherIcons.star,
          color: Colors.blue[400]!,
          size: 56,
          onPressed:
              superLikesRemaining > 0
                  ? () => _performAction('super_like')
                  : () => _showUpgradeDialog('super_likes'),
          badge: superLikesRemaining > 0 ? null : '0',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback? onPressed,
    String? badge,
  }) {
    return AnimatedBuilder(
      animation: _actionController,
      builder: (context, child) {
        final scale = 1.0 - (_actionController.value * 0.1);
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(child: Icon(icon, color: color, size: size * 0.4)),
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
          ),
        );
      },
    );
  }

  void _showUpgradeDialog(String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
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

// Custom painter for orbital connection lines
class ConnectionLinesPainter extends CustomPainter {
  final List<UserModel> users;
  final int selectedIndex;
  final double currentAngle;
  final double orbitRadius;

  ConnectionLinesPainter({
    required this.users,
    required this.selectedIndex,
    required this.currentAngle,
    required this.orbitRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height * 0.4);

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
