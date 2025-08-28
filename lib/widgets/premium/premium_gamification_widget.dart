import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../services/premium_gamification_service.dart';
import '../../utils/dating_theme.dart';

/// Premium Gamification Widget for Phase 9: Premium Features & Gamification
/// Comprehensive UI for premium features, achievements, rewards, and user progression
class PremiumGamificationWidget extends StatefulWidget {
  const PremiumGamificationWidget({Key? key}) : super(key: key);

  @override
  State<PremiumGamificationWidget> createState() =>
      _PremiumGamificationWidgetState();
}

class _PremiumGamificationWidgetState extends State<PremiumGamificationWidget>
    with SingleTickerProviderStateMixin {
  final PremiumGamificationService _gamificationService =
      PremiumGamificationService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPremiumTab(),
                _buildAchievementsTab(),
                _buildRewardsTab(),
                _buildAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DatingTheme.primaryPink,
            DatingTheme.primaryPink.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  FeatherIcons.star,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Premium & Gamification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ValueListenableBuilder<PremiumTier>(
                      valueListenable: _gamificationService.currentTier,
                      builder: (context, tier, child) {
                        return Text(
                          '${tier.name.toUpperCase()} Member',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressCard(),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _gamificationService.currentLevel,
        builder: (context, level, child) {
          return ValueListenableBuilder<double>(
            valueListenable: _gamificationService.levelProgress,
            builder: (context, progress, child) {
              return ValueListenableBuilder<int>(
                valueListenable: _gamificationService.totalPoints,
                builder: (context, points, child) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level $level',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                FeatherIcons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$points pts',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation(Colors.amber),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toInt()}% to Level ${level + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: DatingTheme.primaryPink,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: DatingTheme.primaryPink,
        tabs: const [
          Tab(icon: Icon(FeatherIcons.star), text: 'Premium'),
          Tab(icon: Icon(FeatherIcons.award), text: 'Achievements'),
          Tab(icon: Icon(FeatherIcons.gift), text: 'Rewards'),
          Tab(icon: Icon(FeatherIcons.trendingUp), text: 'Stats'),
        ],
      ),
    );
  }

  Widget _buildPremiumTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentTierCard(),
          const SizedBox(height: 20),
          _buildPremiumFeatures(),
          const SizedBox(height: 20),
          _buildUpgradeOptions(),
        ],
      ),
    );
  }

  Widget _buildCurrentTierCard() {
    return ValueListenableBuilder<PremiumTier>(
      valueListenable: _gamificationService.currentTier,
      builder: (context, tier, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getTierColors(tier),
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getTierColors(tier).first.withValues(alpha: 0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getTierIcon(tier), color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tier.name.toUpperCase()} MEMBER',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _getTierDescription(tier),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _getTierBenefits(tier),
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: DatingTheme.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<PremiumFeature>>(
          valueListenable: _gamificationService.availableFeatures,
          builder: (context, features, child) {
            return Column(
              children:
                  features
                      .map((feature) => _buildFeatureCard(feature))
                      .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(PremiumFeature feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: feature.isEnabled ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: feature.isEnabled ? Colors.green[300]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            feature.isEnabled ? FeatherIcons.checkCircle : FeatherIcons.lock,
            color: feature.isEnabled ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        feature.isEnabled
                            ? Colors.green[800]
                            : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        feature.isEnabled
                            ? Colors.green[600]
                            : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTierColors(feature.tier).first,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              feature.tier.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upgrade Options',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: DatingTheme.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        ..._buildPricingCards(),
      ],
    );
  }

  List<Widget> _buildPricingCards() {
    final pricing = _gamificationService.getPremiumPricing();
    return pricing.entries
        .map((entry) => _buildPricingCard(entry.value))
        .toList();
  }

  Widget _buildPricingCard(PremiumPricing pricing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getTierColors(pricing.tier).first),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getTierIcon(pricing.tier),
                color: _getTierColors(pricing.tier).first,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                pricing.tier.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getTierColors(pricing.tier).first,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '\$${pricing.monthlyPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: DatingTheme.primaryText,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/month',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...pricing.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(FeatherIcons.check, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(feature, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _upgradeTier(pricing.tier),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getTierColors(pricing.tier).first,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Upgrade to ${pricing.tier.name.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ValueListenableBuilder<List<Achievement>>(
        valueListenable: _gamificationService.achievements,
        builder: (context, achievements, child) {
          final categories = AchievementCategory.values;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                categories.map((category) {
                  final categoryAchievements =
                      achievements
                          .where((a) => a.category == category)
                          .toList();

                  if (categoryAchievements.isEmpty)
                    return const SizedBox.shrink();

                  return _buildAchievementCategory(
                    category,
                    categoryAchievements,
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildAchievementCategory(
    AchievementCategory category,
    List<Achievement> achievements,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getCategoryName(category),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: DatingTheme.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        ...achievements.map(
          (achievement) => _buildAchievementCard(achievement),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.amber[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              achievement.isUnlocked ? Colors.amber[300]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: achievement.isUnlocked ? Colors.amber : Colors.grey[400],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(achievement.icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        achievement.isUnlocked
                            ? Colors.amber[800]
                            : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        achievement.isUnlocked
                            ? Colors.amber[600]
                            : Colors.grey[500],
                  ),
                ),
                if (achievement.isUnlocked && achievement.unlockedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(
                achievement.isUnlocked ? FeatherIcons.award : FeatherIcons.lock,
                color: achievement.isUnlocked ? Colors.amber : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                '${achievement.points} pts',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:
                      achievement.isUnlocked
                          ? Colors.amber[800]
                          : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ValueListenableBuilder<List<Reward>>(
        valueListenable: _gamificationService.availableRewards,
        builder: (context, rewards, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Rewards',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DatingTheme.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              ...rewards.map((reward) => _buildRewardCard(reward)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    return ValueListenableBuilder<int>(
      valueListenable: _gamificationService.totalPoints,
      builder: (context, points, child) {
        final canAfford = points >= reward.cost;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: canAfford ? Colors.blue[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canAfford ? Colors.blue[300]! : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: canAfford ? Colors.blue : Colors.grey[400],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(reward.icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: canAfford ? Colors.blue[800] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: canAfford ? Colors.blue[600] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '${reward.cost} pts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? Colors.blue[800] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: ElevatedButton(
                      onPressed: canAfford ? () => _redeemReward(reward) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAfford ? Colors.blue : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Redeem',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ValueListenableBuilder<PremiumAnalytics>(
        valueListenable: _gamificationService.analytics,
        builder: (context, analytics, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Premium Analytics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DatingTheme.primaryText,
                ),
              ),
              const SizedBox(height: 20),
              _buildAnalyticsGrid(analytics),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsGrid(PremiumAnalytics analytics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildAnalyticsCard(
          'Total Users',
          '${analytics.totalUsers}',
          FeatherIcons.users,
          Colors.blue,
        ),
        _buildAnalyticsCard(
          'Premium Users',
          '${analytics.premiumUsers}',
          FeatherIcons.award,
          Colors.amber,
        ),
        _buildAnalyticsCard(
          'Conversion Rate',
          '${analytics.conversionRate.toStringAsFixed(1)}%',
          FeatherIcons.trendingUp,
          Colors.green,
        ),
        _buildAnalyticsCard(
          'Daily Active',
          '${analytics.dailyActiveUsers}',
          FeatherIcons.activity,
          Colors.purple,
        ),
        _buildAnalyticsCard(
          'Avg Matches',
          '${analytics.averageMatchesPerUser.toStringAsFixed(1)}',
          FeatherIcons.heart,
          Colors.red,
        ),
        _buildAnalyticsCard(
          'Satisfaction',
          '${analytics.customerSatisfactionScore.toStringAsFixed(1)}/5',
          FeatherIcons.star,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<Color> _getTierColors(PremiumTier tier) {
    switch (tier) {
      case PremiumTier.basic:
        return [Colors.grey[400]!, Colors.grey[600]!];
      case PremiumTier.gold:
        return [Colors.amber[400]!, Colors.amber[600]!];
      case PremiumTier.platinum:
        return [Colors.blue[400]!, Colors.blue[600]!];
      case PremiumTier.diamond:
        return [Colors.purple[400]!, Colors.purple[600]!];
    }
  }

  IconData _getTierIcon(PremiumTier tier) {
    switch (tier) {
      case PremiumTier.basic:
        return FeatherIcons.user;
      case PremiumTier.gold:
        return FeatherIcons.award;
      case PremiumTier.platinum:
        return FeatherIcons.star;
      case PremiumTier.diamond:
        return FeatherIcons.star;
    }
  }

  String _getTierDescription(PremiumTier tier) {
    switch (tier) {
      case PremiumTier.basic:
        return 'Essential dating features';
      case PremiumTier.gold:
        return 'Enhanced matching & discovery';
      case PremiumTier.platinum:
        return 'Premium dating experience';
      case PremiumTier.diamond:
        return 'Exclusive VIP experience';
    }
  }

  String _getTierBenefits(PremiumTier tier) {
    switch (tier) {
      case PremiumTier.basic:
        return 'Access to basic matching and messaging features for connecting with potential dates.';
      case PremiumTier.gold:
        return 'Unlimited likes, super likes, profile boosts, and advanced filtering options for better matches.';
      case PremiumTier.platinum:
        return 'See who liked you, priority placement, read receipts, and unlimited rewinds for optimal dating.';
      case PremiumTier.diamond:
        return 'Exclusive matching pool, personal concierge service, VIP events, and verified safety features.';
    }
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.profile:
        return 'Profile Achievements';
      case AchievementCategory.matching:
        return 'Matching Achievements';
      case AchievementCategory.dating:
        return 'Dating Achievements';
      case AchievementCategory.social:
        return 'Social Achievements';
      case AchievementCategory.streak:
        return 'Streak Achievements';
      case AchievementCategory.premium:
        return 'Premium Achievements';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Action methods
  Future<void> _upgradeTier(PremiumTier tier) async {
    final success = await _gamificationService.upgradePremiumTier(tier);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '🎉 Successfully upgraded to ${tier.name.toUpperCase()}!'
              : '❌ Failed to upgrade tier',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _redeemReward(Reward reward) async {
    final success = await _gamificationService.redeemReward(reward.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '🎁 Successfully redeemed ${reward.name}!'
              : '❌ Failed to redeem reward',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
