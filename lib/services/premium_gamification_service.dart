import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/Utilities.dart';
import '../models/RespondModel.dart';
import '../models/UserModel.dart';

/// Premium Gamification Service for Phase 9: Premium Features & Gamification
/// Advanced premium features and gamification elements for enhanced user engagement
class PremiumGamificationService {
  static final PremiumGamificationService _instance =
      PremiumGamificationService._internal();
  factory PremiumGamificationService() => _instance;
  PremiumGamificationService._internal();

  static const String _premiumStatusKey = 'premium_status';
  static const String _gamificationDataKey = 'gamification_data';
  static const String _achievementsKey = 'achievements';
  static const String _streaksKey = 'streaks';
  static const String _rewardsKey = 'rewards';

  // Premium Features
  ValueNotifier<PremiumTier> currentTier = ValueNotifier(PremiumTier.basic);
  ValueNotifier<List<PremiumFeature>> availableFeatures = ValueNotifier([]);
  ValueNotifier<Map<String, bool>> featureAccess = ValueNotifier({});

  // Gamification Elements
  ValueNotifier<int> totalPoints = ValueNotifier(0);
  ValueNotifier<int> currentLevel = ValueNotifier(1);
  ValueNotifier<double> levelProgress = ValueNotifier(0.0);
  ValueNotifier<List<Achievement>> achievements = ValueNotifier([]);
  ValueNotifier<Map<String, int>> streaks = ValueNotifier({});
  ValueNotifier<List<Reward>> availableRewards = ValueNotifier([]);

  // Premium Analytics
  ValueNotifier<PremiumAnalytics> analytics = ValueNotifier(
    PremiumAnalytics.empty(),
  );

  /// Initialize premium gamification service
  Future<void> initialize() async {
    await _loadStoredData();
    await _initializePremiumFeatures();
    await _initializeGamificationSystem();
    await _updateAnalytics();
  }

  /// Load stored data from SharedPreferences
  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load premium status
    final tierString = prefs.getString(_premiumStatusKey);
    if (tierString != null) {
      currentTier.value = PremiumTier.values.firstWhere(
        (tier) => tier.name == tierString,
        orElse: () => PremiumTier.basic,
      );
    }

    // Load gamification data
    final gamificationString = prefs.getString(_gamificationDataKey);
    if (gamificationString != null) {
      final data = jsonDecode(gamificationString);
      totalPoints.value = data['totalPoints'] ?? 0;
      currentLevel.value = data['currentLevel'] ?? 1;
      levelProgress.value = data['levelProgress'] ?? 0.0;
    }

    // Load achievements
    final achievementsString = prefs.getString(_achievementsKey);
    if (achievementsString != null) {
      final List<dynamic> achievementsList = jsonDecode(achievementsString);
      achievements.value =
          achievementsList.map((data) => Achievement.fromMap(data)).toList();
    }

    // Load streaks
    final streaksString = prefs.getString(_streaksKey);
    if (streaksString != null) {
      final Map<String, dynamic> streaksData = jsonDecode(streaksString);
      streaks.value = streaksData.map(
        (key, value) => MapEntry(key, value as int),
      );
    }
  }

  /// Save data to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save premium status
    await prefs.setString(_premiumStatusKey, currentTier.value.name);

    // Save gamification data
    final gamificationData = {
      'totalPoints': totalPoints.value,
      'currentLevel': currentLevel.value,
      'levelProgress': levelProgress.value,
    };
    await prefs.setString(_gamificationDataKey, jsonEncode(gamificationData));

    // Save achievements
    final achievementsList = achievements.value.map((a) => a.toMap()).toList();
    await prefs.setString(_achievementsKey, jsonEncode(achievementsList));

    // Save streaks
    await prefs.setString(_streaksKey, jsonEncode(streaks.value));
  }

  /// Initialize premium features based on tier
  Future<void> _initializePremiumFeatures() async {
    final features = <PremiumFeature>[
      // Basic Tier Features (Free)
      PremiumFeature(
        id: 'basic_matching',
        name: 'Basic Matching',
        description: 'Standard swipe and match functionality',
        tier: PremiumTier.basic,
        isEnabled: true,
      ),
      PremiumFeature(
        id: 'basic_messaging',
        name: 'Basic Messaging',
        description: 'Send messages to matches',
        tier: PremiumTier.basic,
        isEnabled: true,
      ),

      // Gold Tier Features
      PremiumFeature(
        id: 'unlimited_likes',
        name: 'Unlimited Likes',
        description: 'Like as many profiles as you want',
        tier: PremiumTier.gold,
        isEnabled: currentTier.value.index >= PremiumTier.gold.index,
      ),
      PremiumFeature(
        id: 'super_likes',
        name: 'Super Likes',
        description: 'Stand out with super likes (5 per day)',
        tier: PremiumTier.gold,
        isEnabled: currentTier.value.index >= PremiumTier.gold.index,
      ),
      PremiumFeature(
        id: 'boost_profile',
        name: 'Profile Boost',
        description: 'Be seen by more people (1 per week)',
        tier: PremiumTier.gold,
        isEnabled: currentTier.value.index >= PremiumTier.gold.index,
      ),
      PremiumFeature(
        id: 'advanced_filters',
        name: 'Advanced Filters',
        description: 'Filter by education, job, interests',
        tier: PremiumTier.gold,
        isEnabled: currentTier.value.index >= PremiumTier.gold.index,
      ),

      // Platinum Tier Features
      PremiumFeature(
        id: 'see_who_liked',
        name: 'See Who Liked You',
        description: 'View all profiles that liked you',
        tier: PremiumTier.platinum,
        isEnabled: currentTier.value.index >= PremiumTier.platinum.index,
      ),
      PremiumFeature(
        id: 'priority_likes',
        name: 'Priority Likes',
        description: 'Your likes are shown first',
        tier: PremiumTier.platinum,
        isEnabled: currentTier.value.index >= PremiumTier.platinum.index,
      ),
      PremiumFeature(
        id: 'read_receipts',
        name: 'Read Receipts',
        description: 'See when messages are read',
        tier: PremiumTier.platinum,
        isEnabled: currentTier.value.index >= PremiumTier.platinum.index,
      ),
      PremiumFeature(
        id: 'unlimited_rewinds',
        name: 'Unlimited Rewinds',
        description: 'Undo swipes anytime',
        tier: PremiumTier.platinum,
        isEnabled: currentTier.value.index >= PremiumTier.platinum.index,
      ),

      // Diamond Tier Features
      PremiumFeature(
        id: 'exclusive_matching',
        name: 'Exclusive Matching',
        description: 'Only match with other premium users',
        tier: PremiumTier.diamond,
        isEnabled: currentTier.value.index >= PremiumTier.diamond.index,
      ),
      PremiumFeature(
        id: 'concierge_service',
        name: 'Dating Concierge',
        description: 'Personal dating assistant and advice',
        tier: PremiumTier.diamond,
        isEnabled: currentTier.value.index >= PremiumTier.diamond.index,
      ),
      PremiumFeature(
        id: 'background_checks',
        name: 'Background Verification',
        description: 'Enhanced safety with background checks',
        tier: PremiumTier.diamond,
        isEnabled: currentTier.value.index >= PremiumTier.diamond.index,
      ),
      PremiumFeature(
        id: 'vip_events',
        name: 'VIP Events',
        description: 'Exclusive dating events and mixers',
        tier: PremiumTier.diamond,
        isEnabled: currentTier.value.index >= PremiumTier.diamond.index,
      ),
    ];

    availableFeatures.value = features;

    // Update feature access map
    final access = <String, bool>{};
    for (final feature in features) {
      access[feature.id] = feature.isEnabled;
    }
    featureAccess.value = access;
  }

  /// Initialize gamification system
  Future<void> _initializeGamificationSystem() async {
    // Initialize default achievements if empty
    if (achievements.value.isEmpty) {
      achievements.value = _getDefaultAchievements();
    }

    // Initialize default streaks if empty
    if (streaks.value.isEmpty) {
      streaks.value = {
        'daily_login': 0,
        'weekly_active': 0,
        'monthly_dates': 0,
        'profile_completion': 0,
        'social_sharing': 0,
      };
    }

    // Initialize rewards
    availableRewards.value = _getAvailableRewards();

    // Calculate current level and progress
    _updateLevelProgress();
  }

  /// Get default achievements
  List<Achievement> _getDefaultAchievements() {
    return [
      // Profile Achievements
      Achievement(
        id: 'profile_complete',
        name: 'Profile Master',
        description: 'Complete your profile 100%',
        icon: '👤',
        points: 100,
        isUnlocked: false,
        category: AchievementCategory.profile,
      ),
      Achievement(
        id: 'first_photo',
        name: 'Picture Perfect',
        description: 'Upload your first photo',
        icon: '📸',
        points: 50,
        isUnlocked: false,
        category: AchievementCategory.profile,
      ),

      // Matching Achievements
      Achievement(
        id: 'first_match',
        name: 'First Connection',
        description: 'Get your first match',
        icon: '💕',
        points: 100,
        isUnlocked: false,
        category: AchievementCategory.matching,
      ),
      Achievement(
        id: 'ten_matches',
        name: 'Popular Person',
        description: 'Get 10 matches',
        icon: '🌟',
        points: 250,
        isUnlocked: false,
        category: AchievementCategory.matching,
      ),
      Achievement(
        id: 'fifty_matches',
        name: 'Match Magnet',
        description: 'Get 50 matches',
        icon: '🔥',
        points: 500,
        isUnlocked: false,
        category: AchievementCategory.matching,
      ),

      // Dating Achievements
      Achievement(
        id: 'first_date',
        name: 'First Date',
        description: 'Go on your first date',
        icon: '💑',
        points: 200,
        isUnlocked: false,
        category: AchievementCategory.dating,
      ),
      Achievement(
        id: 'weekend_warrior',
        name: 'Weekend Warrior',
        description: 'Go on 3 dates in one weekend',
        icon: '⚡',
        points: 300,
        isUnlocked: false,
        category: AchievementCategory.dating,
      ),

      // Social Achievements
      Achievement(
        id: 'social_butterfly',
        name: 'Social Butterfly',
        description: 'Share 5 dating experiences',
        icon: '🦋',
        points: 150,
        isUnlocked: false,
        category: AchievementCategory.social,
      ),
      Achievement(
        id: 'helpful_reviewer',
        name: 'Helpful Reviewer',
        description: 'Leave 10 restaurant reviews',
        icon: '⭐',
        points: 200,
        isUnlocked: false,
        category: AchievementCategory.social,
      ),

      // Streak Achievements
      Achievement(
        id: 'daily_streak_7',
        name: 'Week Warrior',
        description: 'Login daily for 7 days',
        icon: '📅',
        points: 150,
        isUnlocked: false,
        category: AchievementCategory.streak,
      ),
      Achievement(
        id: 'daily_streak_30',
        name: 'Monthly Master',
        description: 'Login daily for 30 days',
        icon: '🗓️',
        points: 500,
        isUnlocked: false,
        category: AchievementCategory.streak,
      ),

      // Premium Achievements
      Achievement(
        id: 'premium_user',
        name: 'Premium Member',
        description: 'Upgrade to premium',
        icon: '💎',
        points: 300,
        isUnlocked: false,
        category: AchievementCategory.premium,
      ),
      Achievement(
        id: 'diamond_member',
        name: 'Diamond Elite',
        description: 'Reach Diamond tier',
        icon: '💠',
        points: 1000,
        isUnlocked: false,
        category: AchievementCategory.premium,
      ),
    ];
  }

  /// Get available rewards
  List<Reward> _getAvailableRewards() {
    return [
      Reward(
        id: 'free_super_like',
        name: 'Free Super Like',
        description: 'Get 1 free super like',
        icon: '⭐',
        cost: 100,
        type: RewardType.feature,
        isAvailable: true,
      ),
      Reward(
        id: 'profile_boost_1h',
        name: '1 Hour Boost',
        description: 'Boost your profile for 1 hour',
        icon: '🚀',
        cost: 200,
        type: RewardType.feature,
        isAvailable: true,
      ),
      Reward(
        id: 'premium_day',
        name: '24h Premium',
        description: 'Premium features for 24 hours',
        icon: '💎',
        cost: 500,
        type: RewardType.premium,
        isAvailable: true,
      ),
      Reward(
        id: 'custom_badge',
        name: 'Custom Badge',
        description: 'Unlock special profile badge',
        icon: '🏆',
        cost: 750,
        type: RewardType.cosmetic,
        isAvailable: true,
      ),
      Reward(
        id: 'date_discount',
        name: 'Restaurant Discount',
        description: '10% off at partner restaurants',
        icon: '🍽️',
        cost: 300,
        type: RewardType.marketplace,
        isAvailable: true,
      ),
    ];
  }

  /// Update level progress based on total points
  void _updateLevelProgress() {
    // Calculate level based on points (exponential growth)
    final pointsForNextLevel = _calculatePointsForLevel(currentLevel.value + 1);
    final pointsForCurrentLevel = _calculatePointsForLevel(currentLevel.value);

    // Check if user leveled up
    while (totalPoints.value >= pointsForNextLevel) {
      currentLevel.value++;
      _onLevelUp();
    }

    // Calculate progress towards next level
    final progressPoints = totalPoints.value - pointsForCurrentLevel;
    final requiredPoints = pointsForNextLevel - pointsForCurrentLevel;
    levelProgress.value = progressPoints / requiredPoints;
  }

  /// Calculate points required for a specific level
  int _calculatePointsForLevel(int level) {
    if (level <= 1) return 0;
    return ((level - 1) * 100 * pow(1.2, level - 1)).round();
  }

  /// Handle level up
  void _onLevelUp() {
    // Award level up bonus
    final bonus = currentLevel.value * 50;
    _awardPoints(bonus, 'Level ${currentLevel.value} Bonus');

    // Unlock level-based achievements
    _checkLevelAchievements();
  }

  /// Check for level-based achievements
  void _checkLevelAchievements() {
    // Implementation for level-based achievement unlocking
  }

  /// Award points to user
  Future<void> awardPoints(int points, String reason) async {
    totalPoints.value += points;
    _updateLevelProgress();
    await _saveData();

    // Check for point-based achievements
    await _checkPointAchievements();
  }

  /// Internal points awarding
  void _awardPoints(int points, String reason) {
    totalPoints.value += points;
    _updateLevelProgress();
  }

  /// Check for achievements based on points
  Future<void> _checkPointAchievements() async {
    // Implementation for point-based achievement checking
  }

  /// Unlock achievement
  Future<bool> unlockAchievement(String achievementId) async {
    final achievementIndex = achievements.value.indexWhere(
      (a) => a.id == achievementId,
    );

    if (achievementIndex != -1 &&
        !achievements.value[achievementIndex].isUnlocked) {
      final achievement = achievements.value[achievementIndex];
      achievement.isUnlocked = true;
      achievement.unlockedAt = DateTime.now();

      // Award points
      await awardPoints(achievement.points, 'Achievement: ${achievement.name}');

      // Update achievements list
      final updatedAchievements = List<Achievement>.from(achievements.value);
      updatedAchievements[achievementIndex] = achievement;
      achievements.value = updatedAchievements;

      await _saveData();
      return true;
    }

    return false;
  }

  /// Update streak
  Future<void> updateStreak(String streakType, int value) async {
    final currentStreaks = Map<String, int>.from(streaks.value);
    currentStreaks[streakType] = value;
    streaks.value = currentStreaks;

    // Check for streak achievements
    await _checkStreakAchievements(streakType, value);
    await _saveData();
  }

  /// Check for streak achievements
  Future<void> _checkStreakAchievements(String streakType, int value) async {
    if (streakType == 'daily_login') {
      if (value >= 7) {
        await unlockAchievement('daily_streak_7');
      }
      if (value >= 30) {
        await unlockAchievement('daily_streak_30');
      }
    }
  }

  /// Redeem reward
  Future<bool> redeemReward(String rewardId) async {
    final reward = availableRewards.value.firstWhere(
      (r) => r.id == rewardId,
      orElse: () => throw Exception('Reward not found'),
    );

    if (totalPoints.value >= reward.cost && reward.isAvailable) {
      totalPoints.value -= reward.cost;
      _updateLevelProgress();

      // Apply reward effect
      await _applyRewardEffect(reward);
      await _saveData();

      return true;
    }

    return false;
  }

  /// Apply reward effect
  Future<void> _applyRewardEffect(Reward reward) async {
    switch (reward.type) {
      case RewardType.feature:
        // Grant temporary feature access
        break;
      case RewardType.premium:
        // Grant temporary premium access
        break;
      case RewardType.cosmetic:
        // Unlock cosmetic item
        break;
      case RewardType.marketplace:
        // Apply marketplace benefit
        break;
    }
  }

  /// Upgrade premium tier
  Future<bool> upgradePremiumTier(PremiumTier newTier) async {
    if (newTier.index > currentTier.value.index) {
      currentTier.value = newTier;
      await _initializePremiumFeatures();

      // Unlock premium achievement
      if (newTier == PremiumTier.gold || newTier == PremiumTier.platinum) {
        await unlockAchievement('premium_user');
      }
      if (newTier == PremiumTier.diamond) {
        await unlockAchievement('diamond_member');
      }

      await _saveData();
      return true;
    }

    return false;
  }

  /// Check feature access
  bool hasFeatureAccess(String featureId) {
    return featureAccess.value[featureId] ?? false;
  }

  /// Get premium pricing
  Map<PremiumTier, PremiumPricing> getPremiumPricing() {
    return {
      PremiumTier.gold: PremiumPricing(
        tier: PremiumTier.gold,
        weeklyPrice: 15.99,
        monthlyPrice: 39.99,
        threeMonthPrice: 89.99,
        features: [
          'Unlimited Likes',
          'Super Likes (5/day)',
          'Profile Boost (1/week)',
          'Advanced Filters',
        ],
      ),
      PremiumTier.platinum: PremiumPricing(
        tier: PremiumTier.platinum,
        weeklyPrice: 24.99,
        monthlyPrice: 59.99,
        threeMonthPrice: 149.99,
        features: [
          'All Gold Features',
          'See Who Liked You',
          'Priority Likes',
          'Read Receipts',
          'Unlimited Rewinds',
        ],
      ),
      PremiumTier.diamond: PremiumPricing(
        tier: PremiumTier.diamond,
        weeklyPrice: 39.99,
        monthlyPrice: 99.99,
        threeMonthPrice: 249.99,
        features: [
          'All Platinum Features',
          'Exclusive Matching',
          'Dating Concierge',
          'Background Verification',
          'VIP Events Access',
        ],
      ),
    };
  }

  /// Update analytics
  Future<void> _updateAnalytics() async {
    final newAnalytics = PremiumAnalytics(
      totalUsers: 150000,
      premiumUsers: 15000,
      conversionRate: 10.0,
      averageSessionTime: const Duration(minutes: 25),
      dailyActiveUsers: 12000,
      monthlyActiveUsers: 85000,
      averageMatchesPerUser: 8.5,
      averageDatesPerMonth: 2.3,
      customerSatisfactionScore: 4.6,
      retentionRate30Day: 75.0,
      revenuePerUser: 45.50,
      churnRate: 5.2,
    );

    analytics.value = newAnalytics;
  }

  /// Dispose service
  void dispose() {
    currentTier.dispose();
    availableFeatures.dispose();
    featureAccess.dispose();
    totalPoints.dispose();
    currentLevel.dispose();
    levelProgress.dispose();
    achievements.dispose();
    streaks.dispose();
    availableRewards.dispose();
    analytics.dispose();
  }
}

// Data Models

enum PremiumTier { basic, gold, platinum, diamond }

class PremiumFeature {
  final String id;
  final String name;
  final String description;
  final PremiumTier tier;
  final bool isEnabled;

  PremiumFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.isEnabled,
  });
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int points;
  bool isUnlocked;
  DateTime? unlockedAt;
  final AchievementCategory category;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.points,
    required this.isUnlocked,
    this.unlockedAt,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'points': points,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'category': category.name,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      points: map['points'],
      isUnlocked: map['isUnlocked'],
      unlockedAt:
          map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
      category: AchievementCategory.values.firstWhere(
        (cat) => cat.name == map['category'],
        orElse: () => AchievementCategory.profile,
      ),
    );
  }
}

enum AchievementCategory { profile, matching, dating, social, streak, premium }

class Reward {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int cost;
  final RewardType type;
  final bool isAvailable;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.cost,
    required this.type,
    required this.isAvailable,
  });
}

enum RewardType { feature, premium, cosmetic, marketplace }

class PremiumPricing {
  final PremiumTier tier;
  final double weeklyPrice;
  final double monthlyPrice;
  final double threeMonthPrice;
  final List<String> features;

  PremiumPricing({
    required this.tier,
    required this.weeklyPrice,
    required this.monthlyPrice,
    required this.threeMonthPrice,
    required this.features,
  });
}

class PremiumAnalytics {
  final int totalUsers;
  final int premiumUsers;
  final double conversionRate;
  final Duration averageSessionTime;
  final int dailyActiveUsers;
  final int monthlyActiveUsers;
  final double averageMatchesPerUser;
  final double averageDatesPerMonth;
  final double customerSatisfactionScore;
  final double retentionRate30Day;
  final double revenuePerUser;
  final double churnRate;

  PremiumAnalytics({
    required this.totalUsers,
    required this.premiumUsers,
    required this.conversionRate,
    required this.averageSessionTime,
    required this.dailyActiveUsers,
    required this.monthlyActiveUsers,
    required this.averageMatchesPerUser,
    required this.averageDatesPerMonth,
    required this.customerSatisfactionScore,
    required this.retentionRate30Day,
    required this.revenuePerUser,
    required this.churnRate,
  });

  factory PremiumAnalytics.empty() {
    return PremiumAnalytics(
      totalUsers: 0,
      premiumUsers: 0,
      conversionRate: 0.0,
      averageSessionTime: Duration.zero,
      dailyActiveUsers: 0,
      monthlyActiveUsers: 0,
      averageMatchesPerUser: 0.0,
      averageDatesPerMonth: 0.0,
      customerSatisfactionScore: 0.0,
      retentionRate30Day: 0.0,
      revenuePerUser: 0.0,
      churnRate: 0.0,
    );
  }
}
