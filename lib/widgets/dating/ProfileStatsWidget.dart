import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shimmer/shimmer.dart';

import '../../services/swipe_service.dart';
import '../../utils/CustomTheme.dart';

class ProfileStatsWidget extends StatefulWidget {
  const ProfileStatsWidget({Key? key}) : super(key: key);

  @override
  _ProfileStatsWidgetState createState() => _ProfileStatsWidgetState();
}

class _ProfileStatsWidgetState extends State<ProfileStatsWidget>
    with TickerProviderStateMixin {
  ProfileStats? profileStats;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadProfileStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileStats() async {
    try {
      final stats = await SwipeService.getProfileStats();
      setState(() {
        profileStats = stats;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildShimmerLoading();
    }

    if (profileStats == null) {
      return _buildErrorWidget();
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: FadeTransition(
        opacity: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CustomTheme.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildProfileViews(),
              _buildWeeklyStats(),
              _buildMonthlyStats(),
              _buildProfileCompletion(),
              _buildOptimalTimes(),
              _buildPopularityTrend(),
              _buildUpgradeRecommendations(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.primary, CustomTheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          FxText.titleMedium(
            'Profile Analytics',
            color: Colors.white,
            fontWeight: 700,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
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

  Widget _buildProfileViews() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.visibility, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.titleMedium(
                  profileStats!.profileViews.toString(),
                  color: CustomTheme.color,
                  fontWeight: 700,
                ),
                FxText.bodySmall('Profile Views', color: CustomTheme.color2),
              ],
            ),
          ),
          Icon(Icons.trending_up, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.bodyMedium(
            'This Week',
            color: CustomTheme.color,
            fontWeight: 600,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Likes',
                  profileStats!.weeklyLikesReceived.toString(),
                  Icons.favorite,
                  Colors.red,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: CustomTheme.color2.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Matches',
                  profileStats!.weeklyMatches.toString(),
                  Icons.people,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.bodyMedium(
            'This Month',
            color: CustomTheme.color,
            fontWeight: 600,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Likes',
                  profileStats!.monthlyLikesReceived.toString(),
                  Icons.favorite,
                  Colors.red,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: CustomTheme.color2.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Matches',
                  profileStats!.monthlyMatches.toString(),
                  Icons.people,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletion() {
    final completion = profileStats!.profileCompletion;
    final color =
        completion >= 80
            ? Colors.green
            : completion >= 60
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle, color: color, size: 20),
              const SizedBox(width: 8),
              FxText.bodyMedium(
                'Profile Completion',
                color: CustomTheme.color,
                fontWeight: 600,
              ),
              const Spacer(),
              FxText.bodyMedium(
                '${completion}%',
                color: color,
                fontWeight: 700,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completion / 100,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          if (completion < 100) ...[
            const SizedBox(height: 8),
            FxText.bodySmall(
              'Complete your profile to get more matches!',
              color: CustomTheme.color2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptimalTimes() {
    if (profileStats!.optimalHours.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: CustomTheme.primary, size: 20),
              const SizedBox(width: 8),
              FxText.bodyMedium(
                'Optimal Active Hours',
                color: CustomTheme.color,
                fontWeight: 600,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children:
                profileStats!.optimalHours.map((hour) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: CustomTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: FxText.bodySmall(
                      '${hour}:00',
                      color: CustomTheme.primary,
                      fontWeight: 600,
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 8),
          FxText.bodySmall(
            'You get most likes during these hours',
            color: CustomTheme.color2,
          ),
        ],
      ),
    );
  }

  Widget _buildPopularityTrend() {
    final trend = profileStats!.popularityTrend;
    Color trendColor = Colors.blue;
    IconData trendIcon = Icons.trending_flat;
    String trendText = 'Stable';

    switch (trend.direction) {
      case 'increasing':
        trendColor = Colors.green;
        trendIcon = Icons.trending_up;
        trendText = 'Increasing';
        break;
      case 'decreasing':
        trendColor = Colors.red;
        trendIcon = Icons.trending_down;
        trendText = 'Decreasing';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(trendIcon, color: trendColor, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FxText.bodyMedium(
                'Popularity Trend',
                color: CustomTheme.color,
                fontWeight: 600,
              ),
              FxText.bodySmall(trendText, color: trendColor, fontWeight: 600),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeRecommendations() {
    if (profileStats!.upgradeRecommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.bodyMedium(
            'Upgrade Recommendations',
            color: CustomTheme.color,
            fontWeight: 600,
          ),
          const SizedBox(height: 12),
          ...profileStats!.upgradeRecommendations.map((rec) {
            final isHighPriority = rec.priority == 'high';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isHighPriority
                        ? CustomTheme.primary.withValues(alpha: 0.1)
                        : CustomTheme.cardDark,
                borderRadius: BorderRadius.circular(10),
                border:
                    isHighPriority
                        ? Border.all(
                          color: CustomTheme.primary.withValues(alpha: 0.3),
                        )
                        : null,
              ),
              child: Row(
                children: [
                  Icon(
                    isHighPriority ? Icons.priority_high : Icons.lightbulb,
                    color: isHighPriority ? CustomTheme.primary : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FxText.bodyMedium(
                          rec.title,
                          color: CustomTheme.color,
                          fontWeight: 600,
                        ),
                        FxText.bodySmall(
                          rec.description,
                          color: CustomTheme.color2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        FxText.titleMedium(value, color: CustomTheme.color, fontWeight: 700),
        FxText.bodySmall(label, color: CustomTheme.color2),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Shimmer.fromColors(
        baseColor: CustomTheme.cardDark,
        highlightColor: CustomTheme.cardDark.withValues(alpha: 0.3),
        child: Column(
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(
                  4,
                  (index) => Container(
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: CustomTheme.color2),
          const SizedBox(height: 16),
          FxText.bodyMedium(
            'Unable to load profile statistics',
            color: CustomTheme.color2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
