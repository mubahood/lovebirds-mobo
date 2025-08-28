import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/UserModel.dart';
import '../../models/LoggedInUserModel.dart';
import '../../services/compatibility_scoring.dart';
import '../../utils/dating_theme.dart';

/// Simple compatibility display widget for existing swipe cards
class CompatibilityIndicator extends StatelessWidget {
  final UserModel targetUser;
  final double size;
  final bool showScore;

  const CompatibilityIndicator({
    Key? key,
    required this.targetUser,
    this.size = 32,
    this.showScore = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LoggedInUserModel>(
      future: LoggedInUserModel.getLoggedInUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          );
        }

        final currentUser = _convertToUserModel(snapshot.data!);
        final score = CompatibilityScoring.instance.calculateCompatibilityScore(
          currentUser,
          targetUser,
        );

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getScoreColor(score),
                _getScoreColor(score).withValues(alpha: 0.8),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getScoreColor(score).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              showScore
                  ? Center(
                    child: FxText.bodySmall(
                      '${score.round()}%',
                      color: Colors.white,
                      fontWeight: 700,
                      fontSize: size * 0.25,
                    ),
                  )
                  : Icon(Icons.favorite, color: Colors.white, size: size * 0.5),
        );
      },
    );
  }

  UserModel _convertToUserModel(LoggedInUserModel loggedInUser) {
    // Convert LoggedInUserModel to UserModel for compatibility scoring
    final user = UserModel();
    user.id = loggedInUser.id;
    user.first_name = loggedInUser.first_name;
    user.last_name = loggedInUser.last_name;
    user.dob = loggedInUser.dob;
    user.city = loggedInUser.city;
    user.occupation = loggedInUser.occupation;
    user.education_level = loggedInUser.education_level;
    user.smoking_habit = loggedInUser.smoking_habit;
    user.drinking_habit = loggedInUser.drinking_habit;
    user.looking_for = loggedInUser.looking_for;
    user.height_cm = loggedInUser.height_cm;
    user.body_type = loggedInUser.body_type;
    user.latitude = loggedInUser.latitude;
    user.longitude = loggedInUser.longitude;
    return user;
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF4CAF50); // Green
    if (score >= 60) return const Color(0xFFFF9800); // Orange
    if (score >= 40) return const Color(0xFFFFC107); // Yellow
    return const Color(0xFFF44336); // Red
  }
}

/// Compatibility insights bottom sheet
class CompatibilityInsightsSheet extends StatelessWidget {
  final UserModel targetUser;

  const CompatibilityInsightsSheet({Key? key, required this.targetUser})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LoggedInUserModel>(
      future: LoggedInUserModel.getLoggedInUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 400,
            decoration: const BoxDecoration(
              color: DatingTheme.cardBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  DatingTheme.primaryPink,
                ),
              ),
            ),
          );
        }

        final currentUser = _convertToUserModel(snapshot.data!);
        final compatibilityService = CompatibilityScoring.instance;
        final score = compatibilityService.calculateCompatibilityScore(
          currentUser,
          targetUser,
        );
        final insights = compatibilityService.getCompatibilityInsights(
          currentUser,
          targetUser,
        );
        final breakdown = compatibilityService.getCompatibilityBreakdown(
          currentUser,
          targetUser,
        );

        return Container(
          decoration: const BoxDecoration(
            color: DatingTheme.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: FxText.titleLarge(
                        'Compatibility with ${targetUser.first_name}',
                        color: Colors.white,
                        fontWeight: 600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: DatingTheme.heartGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: FxText.bodyMedium(
                        '${score.round()}% Match',
                        color: Colors.white,
                        fontWeight: 600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Compatibility breakdown
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FxText.titleMedium(
                      'Compatibility Breakdown',
                      color: Colors.white,
                      fontWeight: 600,
                    ),
                    const SizedBox(height: 12),
                    ...breakdown.entries
                        .map(
                          (entry) =>
                              _buildBreakdownItem(entry.key, entry.value),
                        )
                        .toList(),
                  ],
                ),
              ),

              if (insights.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: DatingTheme.accentGold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          FxText.titleMedium(
                            'Insights',
                            color: Colors.white,
                            fontWeight: 600,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...insights
                          .take(3)
                          .map(
                            (insight) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.only(
                                      top: 8,
                                      right: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: DatingTheme.accentGold,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: FxText.bodyMedium(
                                      insight,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownItem(String category, double score) {
    final displayScore = score.clamp(0.0, 100.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodyMedium(
                _getCategoryDisplayName(category),
                color: Colors.white,
                fontWeight: 500,
              ),
              FxText.bodyMedium(
                '${displayScore.round()}%',
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: 600,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: displayScore / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getScoreColor(displayScore),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'age':
        return 'Age Compatibility';
      case 'location':
        return 'Location';
      case 'lifestyle':
        return 'Lifestyle';
      case 'goals':
        return 'Relationship Goals';
      case 'education':
        return 'Education & Career';
      case 'physical':
        return 'Physical Preferences';
      default:
        return category.toUpperCase();
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFFFF9800);
    if (score >= 40) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  UserModel _convertToUserModel(LoggedInUserModel loggedInUser) {
    final user = UserModel();
    user.id = loggedInUser.id;
    user.first_name = loggedInUser.first_name;
    user.last_name = loggedInUser.last_name;
    user.dob = loggedInUser.dob;
    user.city = loggedInUser.city;
    user.occupation = loggedInUser.occupation;
    user.education_level = loggedInUser.education_level;
    user.smoking_habit = loggedInUser.smoking_habit;
    user.drinking_habit = loggedInUser.drinking_habit;
    user.looking_for = loggedInUser.looking_for;
    user.height_cm = loggedInUser.height_cm;
    user.body_type = loggedInUser.body_type;
    user.latitude = loggedInUser.latitude;
    user.longitude = loggedInUser.longitude;
    return user;
  }
}

/// Extension to add compatibility features to existing swipe cards
class CompatibilityEnhancedSwipeCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onLike;
  final VoidCallback? onSuperLike;
  final VoidCallback? onPass;

  const CompatibilityEnhancedSwipeCard({
    Key? key,
    required this.user,
    this.onLike,
    this.onSuperLike,
    this.onPass,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCompatibilityInsights(context),
      child: Container(
        decoration: DatingTheme.getSwipeCardDecoration(),
        child: Stack(
          children: [
            // Main user profile display
            _buildUserProfile(),

            // Compatibility indicator
            Positioned(
              top: 16,
              right: 16,
              child: CompatibilityIndicator(targetUser: user, size: 48),
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

  Widget _buildUserProfile() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // Profile image
          Container(
            height: double.infinity,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: user.avatar.isEmpty ? '' : user.avatar,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: DatingTheme.cardBackground,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: DatingTheme.cardBackground,
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
            ),
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
                FxText.headlineSmall(
                  '${user.first_name}, ${_calculateAge(user.dob)}',
                  color: Colors.white,
                  fontWeight: 700,
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
              ],
            ),
          ),
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
          onTap: onPass,
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
          onTap: onLike,
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
          onTap: onSuperLike,
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

  void _showCompatibilityInsights(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: CompatibilityInsightsSheet(targetUser: user),
              );
            },
          ),
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
