import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

import '../../models/UserModel.dart';
import '../../utils/CustomTheme.dart';
import 'multi_photo_gallery.dart';

class SwipeCard extends StatefulWidget {
  final UserModel user;
  final double rotation;
  final double opacity;
  final VoidCallback? onTap;
  final double? distance;

  const SwipeCard({
    Key? key,
    required this.user,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.onTap,
    this.distance,
  }) : super(key: key);

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> with TickerProviderStateMixin {
  late AnimationController _badgeAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _badgeScaleAnimation;
  late Animation<double> _badgeOpacityAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize badge animation controller
    _badgeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize pulse animation controller for verification badge
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create scale animation for badge entrance
    _badgeScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Create opacity animation for smooth fade-in
    _badgeOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Create pulse animation for verification badge
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations with staggered delays
    _startBadgeAnimations();
  }

  void _startBadgeAnimations() {
    // Start badge animation after a short delay for card entrance
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _badgeAnimationController.forward();
      }
    });

    // Start pulse animation for verification badge (if verified)
    if (_isUserVerified()) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _pulseAnimationController.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _badgeAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Transform.rotate(
        angle: widget.rotation,
        child: Opacity(
          opacity: widget.opacity,
          child: Container(
            width: double.infinity, // Add full width
            height: 600, // Fixed height to ensure visibility
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: CustomTheme.cardDark, // Fallback background color
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Multi-photo gallery
                  _buildMultiPhotoGallery(),

                  // Gradient overlay
                  _buildGradientOverlay(),

                  // User info at bottom
                  _buildUserInfo(),

                  // Enhanced top indicators
                  _buildTopIndicators(),

                  // Middle floating badges for important info
                  _buildMiddleInfoBadges(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  bool _isUserOnline() {
    return widget.user.isOnline;
  }

  bool _isUserVerified() {
    return widget.user.email_verified.toLowerCase() == 'yes' ||
        widget.user.phone_verified.toLowerCase() == 'yes';
  }

  int? _getUserAge() {
    if (widget.user.dob.isEmpty) return null;
    try {
      final dob = DateTime.parse(widget.user.dob);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  Widget _buildMultiPhotoGallery() {
    return Positioned.fill(
      child: Container(
        color: CustomTheme.cardDark, // Fallback background
        child: MultiPhotoGallery(
          user: widget.user,
          height: double.infinity,
          showIndicators: true,
          allowSwipe: true,
          onPhotoChanged: (index) {
            // Could add haptic feedback or analytics here
          },
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.1), // Subtle top shadow
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.15),
              Colors.black.withValues(alpha: 0.35),
              Colors.black.withValues(alpha: 0.55), // Reduced bottom darkness
            ],
            stops: const [0.0, 0.2, 0.5, 0.7, 0.85, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.4), // Reduced darkness
              Colors.black.withValues(alpha: 0.7), // Better text readability
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main name and age row
            Row(
              children: [
                Expanded(
                  child: FxText.titleLarge(
                    widget.user.name.isEmpty ? 'Unknown' : widget.user.name,
                    color: Colors.white,
                    fontWeight: 700,
                    fontSize: 28,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Enhanced age badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CustomTheme.primary,
                        CustomTheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CustomTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: FxText.bodyMedium(
                    '${_getUserAge() ?? '?'}',
                    color: Colors.white,
                    fontWeight: 700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bio section with better formatting
            if (widget.user.bio.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: CustomTheme.accent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FxText.bodyMedium(
                        widget.user.bio,
                        color: Colors.white,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        height: 1.4,
                        fontWeight: 500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Enhanced info chips
            _buildEnhancedUserTags(),

            const SizedBox(height: 8),

            // Quick stats row
            _buildQuickStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedUserTags() {
    List<Map<String, dynamic>> tags = [];

    // Add primary info with icons and enhanced styling
    if (widget.user.city.isNotEmpty) {
      tags.add({
        'text': widget.user.city,
        'icon': Icons.location_city,
        'color': Colors.teal,
        'gradient': true,
      });
    }

    if (widget.user.occupation.isNotEmpty) {
      tags.add({
        'text': widget.user.occupation,
        'icon': Icons.work,
        'color': Colors.deepPurple,
        'gradient': true,
      });
    }

    if (widget.user.education_level.isNotEmpty) {
      tags.add({
        'text': widget.user.education_level,
        'icon': Icons.school,
        'color': Colors.indigo,
        'gradient': true,
      });
    }

    // Add relationship goals if available
    if (widget.user.looking_for.isNotEmpty) {
      tags.add({
        'text': widget.user.looking_for,
        'icon': Icons.favorite,
        'color': Colors.pink,
        'gradient': true,
      });
    }

    // Add interests or hobbies if available
    if (widget.user.religion.isNotEmpty) {
      tags.add({
        'text': widget.user.religion,
        'icon': Icons.church,
        'color': Colors.amber,
        'gradient': true,
      });
    }

    if (tags.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          tags.take(4).map((tag) {
            // Show max 4 tags
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient:
                    tag['gradient'] == true
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            tag['color'].withValues(alpha: 0.9),
                            tag['color'].withValues(alpha: 0.7),
                          ],
                        )
                        : null,
                color:
                    tag['gradient'] != true
                        ? tag['color'].withValues(alpha: 0.8)
                        : null,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: tag['color'].withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tag['icon'], color: Colors.white, size: 15),
                  const SizedBox(width: 6),
                  FxText.bodySmall(
                    tag['text'],
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: 600,
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildQuickStats() {
    List<Map<String, dynamic>> stats = [];

    // Add verification status with priority
    if (_isUserVerified()) {
      stats.add({
        'icon': Icons.verified,
        'text': 'Verified',
        'color': Colors.blue,
        'highlight': true,
      });
    }

    // Add recently active status
    if (_isUserOnline()) {
      stats.add({
        'icon': Icons.circle,
        'text': 'Active now',
        'color': Colors.green,
        'highlight': true,
      });
    } else {
      stats.add({
        'icon': Icons.access_time,
        'text': 'Recently active',
        'color': Colors.orange,
        'highlight': false,
      });
    }

    // Add photo count if multiple photos
    if (widget.user.hasMultiplePhotos()) {
      final photoCount = widget.user.getPhotoCount();
      stats.add({
        'icon': Icons.photo_library,
        'text': '$photoCount photos',
        'color': CustomTheme.accent,
        'highlight': false,
      });
    }

    // Add interests count if available (assuming user has interests field)
    if (widget.user.religion.isNotEmpty || widget.user.looking_for.isNotEmpty) {
      stats.add({
        'icon': Icons.interests,
        'text': 'Has interests',
        'color': Colors.purple,
        'highlight': false,
      });
    }

    if (stats.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children:
          stats.take(3).map((stat) {
            // Limit to 3 for better layout
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color:
                    stat['highlight'] == true
                        ? stat['color'].withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: stat['color'].withOpacity(
                    stat['highlight'] == true ? 0.8 : 0.4,
                  ),
                  width: stat['highlight'] == true ? 1.5 : 1,
                ),
                boxShadow:
                    stat['highlight'] == true
                        ? [
                          BoxShadow(
                            color: stat['color'].withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    stat['icon'],
                    color: stat['color'],
                    size: stat['highlight'] == true ? 14 : 12,
                  ),
                  const SizedBox(width: 5),
                  FxText.bodySmall(
                    stat['text'],
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: stat['highlight'] == true ? 11 : 10,
                    fontWeight: stat['highlight'] == true ? 600 : 500,
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildMiddleInfoBadges() {
    List<Map<String, dynamic>> badges = [];

    // Add age prominently in middle if available
    final age = _getUserAge();
    if (age != null) {
      badges.add({
        'text': '$age years old',
        'icon': Icons.cake,
        'color': CustomTheme.primary,
        'position': 'center-right',
        'isVerified': false,
      });
    }

    // Add occupation badge in middle left
    if (widget.user.occupation.isNotEmpty) {
      badges.add({
        'text': widget.user.occupation,
        'icon': Icons.work,
        'color': Colors.purple,
        'position': 'center-left',
        'isVerified': false,
      });
    }

    // Add education if no occupation
    if (widget.user.occupation.isEmpty &&
        widget.user.education_level.isNotEmpty) {
      badges.add({
        'text': widget.user.education_level,
        'icon': Icons.school,
        'color': Colors.indigo,
        'position': 'center-left',
        'isVerified': false,
      });
    }

    // Add verification badge with special treatment
    if (_isUserVerified()) {
      badges.add({
        'text': 'Verified',
        'icon': Icons.verified,
        'color': Colors.blue,
        'position': 'top-right',
        'isVerified': true,
      });
    }

    if (badges.isEmpty) return const SizedBox();

    return Stack(
      children:
          badges.asMap().entries.map((entry) {
            final index = entry.key;
            final badge = entry.value;

            // Create animated badge widget
            Widget badgeWidget = AnimatedBuilder(
              animation: _badgeAnimationController,
              builder: (context, child) {
                // Stagger animation start times for each badge
                final delayFactor = index * 0.2;
                final animationProgress = (_badgeAnimationController.value -
                        delayFactor)
                    .clamp(0.0, 1.0);
                final easedProgress = Curves.easeOutBack.transform(
                  animationProgress,
                );

                return Transform.scale(
                  scale: _badgeScaleAnimation.value * easedProgress,
                  child: Opacity(
                    opacity: _badgeOpacityAnimation.value * animationProgress,
                    child: child,
                  ),
                );
              },
              child:
                  badge['isVerified'] == true
                      ? AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    badge['color'].withValues(alpha: 0.95),
                                    badge['color'].withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: badge['color'].withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    badge['icon'],
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  FxText.bodyMedium(
                                    badge['text'],
                                    color: Colors.white,
                                    fontWeight: 700,
                                    fontSize: 13,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              badge['color'].withValues(alpha: 0.9),
                              badge['color'].withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: badge['color'].withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badge['icon'], color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            FxText.bodyMedium(
                              badge['text'],
                              color: Colors.white,
                              fontWeight: 700,
                              fontSize: 13,
                            ),
                          ],
                        ),
                      ),
            );

            // Position the badge based on its position value
            if (badge['position'] == 'center-right') {
              return Positioned(top: 120, right: 16, child: badgeWidget);
            } else if (badge['position'] == 'center-left') {
              return Positioned(top: 180, left: 16, child: badgeWidget);
            }
            return const SizedBox();
          }).toList(),
    );
  }

  Widget _buildTopIndicators() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side indicators - Enhanced with more info
          Row(
            children: [
              // Premium/Featured badge
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CustomTheme.accent,
                      CustomTheme.accent.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: CustomTheme.accent.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    FxText.bodySmall(
                      'Featured',
                      color: Colors.white,
                      fontWeight: 700,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),

              // Online indicator with pulse effect
              if (_isUserOnline())
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.6),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.8),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      FxText.bodySmall(
                        'Online',
                        color: Colors.white,
                        fontWeight: 700,
                        fontSize: 11,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Right side indicators - Enhanced badges
          Row(
            children: [
              // Distance badge (moved to top for better visibility)
              if (widget.distance != null && widget.distance! > 0)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CustomTheme.primary,
                        CustomTheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: CustomTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      FxText.bodySmall(
                        '${widget.distance?.toStringAsFixed(1)} km',
                        color: Colors.white,
                        fontWeight: 700,
                        fontSize: 11,
                      ),
                    ],
                  ),
                ),

              // Verification badge - Enhanced
              if (_isUserVerified())
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent.withValues(alpha: 0.8)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
