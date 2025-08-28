import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

import '../../models/UserModel.dart';
import '../../services/enhanced_swipe_service.dart';
import '../../utils/dating_theme.dart';
import '../compatibility/compatibility_score_widget.dart';
import '../dating/multi_photo_gallery.dart';

class EnhancedSwipeCard extends StatefulWidget {
  final SwipeCandidate candidate;
  final UserModel currentUser;
  final VoidCallback? onLike;
  final VoidCallback? onSuperLike;
  final VoidCallback? onPass;
  final VoidCallback? onViewProfile;

  const EnhancedSwipeCard({
    Key? key,
    required this.candidate,
    required this.currentUser,
    this.onLike,
    this.onSuperLike,
    this.onPass,
    this.onViewProfile,
  }) : super(key: key);

  @override
  _EnhancedSwipeCardState createState() => _EnhancedSwipeCardState();
}

class _EnhancedSwipeCardState extends State<EnhancedSwipeCard>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (!_showBack) {
      _flipController.forward();
      setState(() => _showBack = true);
    } else {
      _flipController.reverse();
      setState(() => _showBack = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onViewProfile?.call(),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: DatingTheme.getSwipeCardDecoration(),
        child: Stack(
          children: [
            // Main card content
            AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final isShowingFront = _flipAnimation.value < 0.5;
                return Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_flipAnimation.value * 3.14159),
                  child:
                      isShowingFront
                          ? _buildFrontCard()
                          : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(3.14159),
                            child: _buildBackCard(),
                          ),
                );
              },
            ),

            // Compatibility score overlay
            Positioned(
              top: 16,
              right: 16,
              child: CompactCompatibilityWidget(
                user1: widget.currentUser,
                user2: widget.candidate.user,
                size: 48,
              ),
            ),

            // Flip button
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: _flipCard,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _showBack ? Icons.flip_to_front : Icons.flip_to_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Action buttons
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    final user = widget.candidate.user;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // Multi-photo gallery
          MultiPhotoGallery(
            user: user,
            height: double.infinity,
            showIndicators: true,
            allowSwipe: true,
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // User info
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FxText.headlineSmall(
                        '${user.first_name}, ${_calculateAge(user.dob)}',
                        color: Colors.white,
                        fontWeight: 700,
                      ),
                    ),
                    if (user.isVerified == true)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: DatingTheme.successGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FxText.bodySmall(
                          'Verified',
                          color: Colors.white,
                          fontWeight: 600,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                if (user.occupation.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.work_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: FxText.bodyMedium(
                          user.occupation,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),

                if (user.city.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: FxText.bodyMedium(
                          user.city,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Compatibility level badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: DatingTheme.heartGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FxText.bodySmall(
                    widget.candidate.compatibilityLevel,
                    color: Colors.white,
                    fontWeight: 600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: DatingTheme.loveGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60), // Space for overlay buttons
          // Compatibility score display
          Expanded(
            child: CompatibilityScoreWidget(
              user1: widget.currentUser,
              user2: widget.candidate.user,
              showDetails: true,
            ),
          ),

          const SizedBox(height: 80), // Space for action buttons
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pass button
        GestureDetector(
          onTap: widget.onPass,
          child: Container(
            width: 56,
            height: 56,
            decoration: DatingTheme.getActionButtonDecoration(
              DatingTheme.passRed,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ),

        // Like button
        GestureDetector(
          onTap: widget.onLike,
          child: Container(
            width: 64,
            height: 64,
            decoration: DatingTheme.getActionButtonDecoration(
              DatingTheme.likeGreen,
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 32),
          ),
        ),

        // Super like button
        GestureDetector(
          onTap: widget.onSuperLike,
          child: Container(
            width: 56,
            height: 56,
            decoration: DatingTheme.getActionButtonDecoration(
              DatingTheme.superLikePurple,
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  String _calculateAge(String dob) {
    if (dob.isEmpty) return 'N/A';

    try {
      final birthDate = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birthDate.year;

      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }

      return age.toString();
    } catch (e) {
      return 'N/A';
    }
  }
}
