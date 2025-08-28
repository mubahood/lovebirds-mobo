import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import '../../utils/CustomTheme.dart';

/// Enhanced daily swipe limit display with visual progress and upgrade prompts
class SwipeLimitProgressWidget extends StatelessWidget {
  final int likesRemaining;
  final int superLikesRemaining;
  final bool isLoading;
  final VoidCallback onUpgradePressed;

  // Daily limits for free users
  static const int maxDailyLikes = 50;
  static const int maxDailySuperLikes = 3;

  const SwipeLimitProgressWidget({
    Key? key,
    required this.likesRemaining,
    required this.superLikesRemaining,
    required this.isLoading,
    required this.onUpgradePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final likesUsed = maxDailyLikes - likesRemaining;
    final superLikesUsed = maxDailySuperLikes - superLikesRemaining;

    final likesProgress = maxDailyLikes > 0 ? likesUsed / maxDailyLikes : 0.0;
    final superLikesProgress =
        maxDailySuperLikes > 0 ? superLikesUsed / maxDailySuperLikes : 0.0;

    // Determine if user is approaching limits (80% threshold)
    final isApproachingLikesLimit = likesProgress >= 0.8;
    final isLikesLimitReached = likesRemaining <= 0;
    final isSuperLikesLimitReached = superLikesRemaining <= 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getBackgroundGradient(
          isApproachingLikesLimit,
          isLikesLimitReached,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with title and premium indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.titleMedium(
                'Daily Swipe Limits',
                color: _getTextColor(isLikesLimitReached),
                fontWeight: 700,
              ),
              if (isLikesLimitReached || isApproachingLikesLimit)
                _buildUpgradeChip(),
            ],
          ),

          const SizedBox(height: 16),

          // Likes progress bar
          _buildProgressItem(
            icon: Icons.favorite,
            label: 'Likes',
            remaining: likesRemaining,
            total: maxDailyLikes,
            progress: likesProgress,
            color: Colors.pink,
            isLimitReached: isLikesLimitReached,
            isApproachingLimit: isApproachingLikesLimit,
          ),

          const SizedBox(height: 12),

          // Super likes progress bar
          _buildProgressItem(
            icon: Icons.star,
            label: 'Super Likes',
            remaining: superLikesRemaining,
            total: maxDailySuperLikes,
            progress: superLikesProgress,
            color: Colors.blue,
            isLimitReached: isSuperLikesLimitReached,
            isApproachingLimit: superLikesProgress >= 0.8,
          ),

          // Loading indicator
          if (isLoading) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getTextColor(isLikesLimitReached),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FxText.bodySmall(
                  'Loading more profiles...',
                  color: _getTextColor(isLikesLimitReached).withValues(alpha: 0.7),
                ),
              ],
            ),
          ],

          // Upgrade prompt when limits reached
          if (isLikesLimitReached) ...[
            const SizedBox(height: 16),
            _buildUpgradePrompt(),
          ],
        ],
      ),
    );
  }

  LinearGradient _getBackgroundGradient(
    bool isApproaching,
    bool isLimitReached,
  ) {
    if (isLimitReached) {
      // Red gradient when limit reached
      return LinearGradient(
        colors: [
          Colors.red.shade400.withValues(alpha: 0.9),
          Colors.red.shade500.withValues(alpha: 0.9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (isApproaching) {
      // Orange gradient when approaching limit
      return LinearGradient(
        colors: [
          Colors.orange.shade300.withValues(alpha: 0.9),
          Colors.orange.shade400.withValues(alpha: 0.9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // Default white gradient
      return LinearGradient(
        colors: [Colors.white, Colors.grey.shade50],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Color _getTextColor(bool isLimitReached) {
    return isLimitReached ? Colors.white : CustomTheme.color;
  }

  Widget _buildUpgradeChip() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onUpgradePressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.yellow.shade400,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.diamond, color: Colors.orange.shade800, size: 16),
            const SizedBox(width: 4),
            FxText.bodySmall(
              'Premium',
              color: Colors.orange.shade800,
              fontWeight: 700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required int remaining,
    required int total,
    required double progress,
    required Color color,
    required bool isLimitReached,
    required bool isApproachingLimit,
  }) {
    final progressColor =
        isLimitReached
            ? Colors.white.withValues(alpha: 0.8)
            : isApproachingLimit
            ? Colors.orange.shade700
            : color;

    return Column(
      children: [
        // Progress header
        Row(
          children: [
            Icon(icon, color: progressColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FxText.bodyMedium(
                    label,
                    color: _getTextColor(isLimitReached),
                    fontWeight: 600,
                  ),
                  FxText.bodyMedium(
                    '$remaining/$total',
                    color: _getTextColor(isLimitReached).withValues(alpha: 0.8),
                    fontWeight: 500,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Animated progress bar
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, animatedProgress, child) {
            return Stack(
              children: [
                // Background bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getTextColor(isLimitReached).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // Progress bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 8,
                  width:
                      MediaQuery.of(context).size.width *
                      0.8 *
                      animatedProgress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isLimitReached
                              ? [
                                Colors.white.withValues(alpha: 0.8),
                                Colors.white.withValues(alpha: 0.6),
                              ]
                              : isApproachingLimit
                              ? [Colors.orange.shade600, Colors.orange.shade400]
                              : [progressColor, progressColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        // Warning text for approaching limit
        if (isApproachingLimit && !isLimitReached) ...[
          const SizedBox(height: 4),
          FxText.bodySmall(
            'Almost out! Upgrade for unlimited $label',
            color: Colors.orange.shade700,
            fontWeight: 500,
          ),
        ],
      ],
    );
  }

  Widget _buildUpgradePrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          FxText.bodyMedium(
            'Daily limit reached!',
            color: Colors.white,
            fontWeight: 700,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          FxText.bodySmall(
            'Upgrade to Premium for unlimited swipes',
            color: Colors.white.withValues(alpha: 0.9),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildUpgradeButton(),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onUpgradePressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow.shade400, Colors.orange.shade400],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.diamond, color: Colors.orange.shade800, size: 20),
            const SizedBox(width: 8),
            FxText.bodyMedium(
              'Upgrade Now',
              color: Colors.orange.shade800,
              fontWeight: 700,
            ),
          ],
        ),
      ),
    );
  }
}
