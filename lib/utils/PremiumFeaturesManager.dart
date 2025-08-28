import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/RespondModel.dart';
import '../utils/SubscriptionManager.dart';
import '../utils/Utilities.dart';
import '../widgets/common/upgrade_prompt_dialog.dart';

/// Advanced premium features manager for dating app monetization
class PremiumFeaturesManager {
  /// Check if user can use profile boost feature
  static Future<bool> canUseBoost() async {
    try {
      final response = await Utils.http_get('check-boost-availability', {});
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        return resp.data['can_use_boost'] == true;
      }
      return false;
    } catch (e) {
      print('Error checking boost availability: $e');
      return false;
    }
  }

  /// Activate profile boost (2x visibility for 30 minutes)
  static Future<BoostResult> activateBoost() async {
    try {
      if (!await SubscriptionManager.hasActiveSubscription()) {
        return BoostResult(
          success: false,
          message: 'Premium subscription required for boost feature',
          requiresUpgrade: true,
        );
      }

      final response = await Utils.http_post('activate-boost', {});
      final resp = RespondModel(response);

      if (resp.code == 1) {
        return BoostResult(
          success: true,
          message:
              resp.message.isNotEmpty
                  ? resp.message
                  : 'Boost activated successfully!',
          boostExpiresAt: resp.data?['expires_at'],
          viewsIncrease:
              resp.data?['visibility_multiplier'] != null
                  ? (resp.data!['visibility_multiplier'] * 100).round()
                  : 200,
        );
      } else {
        return BoostResult(
          success: false,
          message:
              resp.message.isNotEmpty
                  ? resp.message
                  : 'Failed to activate boost',
        );
      }
    } catch (e) {
      return BoostResult(success: false, message: 'Network error occurred');
    }
  }

  /// Get remaining boost count for premium users
  static Future<int> getRemainingBoosts() async {
    try {
      final response = await Utils.http_get('boost-status', {});
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        return int.tryParse(resp.data['remaining_boosts']?.toString() ?? '0') ??
            0;
      }
      return 0;
    } catch (e) {
      print('Error getting boost status: $e');
      return 0;
    }
  }

  /// Check if user can see who liked them (premium feature)
  static Future<bool> canSeeWhoLikedMe() async {
    return await SubscriptionManager.hasActiveSubscription();
  }

  /// Check if user can undo swipes (premium feature)
  static Future<bool> canUndoSwipes() async {
    return await SubscriptionManager.hasActiveSubscription();
  }

  /// Check if user has unlimited swipes
  static Future<bool> hasUnlimitedSwipes() async {
    return await SubscriptionManager.hasActiveSubscription();
  }

  /// Check if user has unlimited super likes
  static Future<bool> hasUnlimitedSuperLikes() async {
    return await SubscriptionManager.hasActiveSubscription();
  }

  /// Get advanced search filters availability
  static Future<bool> canUseAdvancedFilters() async {
    return await SubscriptionManager.hasActiveSubscription();
  }

  /// Check if user can see read receipts
  static Future<bool> canSeeReadReceipts() async {
    return await SubscriptionManager.hasActiveSubscription();
  }

  /// Show strategic upgrade prompt based on feature attempted
  static void showFeatureUpgradePrompt(
    BuildContext context,
    String featureName,
  ) {
    String title = 'Unlock $featureName';
    String message =
        'Upgrade to premium to access $featureName and other exclusive features!';

    List<String> features = [];

    switch (featureName.toLowerCase()) {
      case 'unlimited swipes':
        features = [
          'Unlimited daily swipes',
          '5 super likes per day',
          'See who liked you',
          'Profile boost feature',
        ];
        break;
      case 'super likes':
        features = [
          '5 super likes per day',
          'Stand out to potential matches',
          'Unlimited daily swipes',
          'See who liked you',
        ];
        break;
      case 'profile boost':
        features = [
          '2x profile visibility for 30 minutes',
          'Get more matches instantly',
          'Unlimited swipes and super likes',
          'See who liked you',
        ];
        break;
      case 'who liked me':
        features = [
          'See everyone who liked you',
          'Like them back for instant matches',
          'Unlimited swipes and super likes',
          'Profile boost feature',
        ];
        break;
      case 'undo swipes':
        features = [
          'Undo unlimited swipes',
          'Second chances on great profiles',
          'Unlimited daily swipes',
          'See who liked you',
        ];
        break;
      case 'advanced filters':
        features = [
          'Filter by age, distance, interests',
          'Education and career filters',
          'Lifestyle preference filters',
          'Unlimited swipes and matches',
        ];
        break;
      case 'read receipts':
        features = [
          'See when messages are read',
          'Know when someone is interested',
          'Priority message delivery',
          'All premium dating features',
        ];
        break;
      default:
        features = [
          'Unlimited daily swipes',
          '5 super likes per day',
          'See who liked you',
          'Profile boost feature',
          'Undo swipes',
          'Advanced search filters',
          'Read receipts',
          'Priority support',
        ];
    }

    showDialog(
      context: context,
      builder:
          (context) => UpgradePromptDialog(
            title: title,
            message: message,
            features: features,
          ),
    );
  }

  /// Check daily limits and show upgrade prompts when necessary
  static Future<bool> checkDailyLimitsAndPrompt(
    BuildContext context,
    String featureType,
    int remainingCount,
  ) async {
    final hasSubscription = await SubscriptionManager.hasActiveSubscription();

    if (hasSubscription) {
      return true; // Premium users have unlimited access
    }

    // Check limits for free users
    switch (featureType) {
      case 'likes':
        if (remainingCount <= 0) {
          showFeatureUpgradePrompt(context, 'Unlimited Swipes');
          return false;
        }
        // Show warning when close to limit
        if (remainingCount <= 5) {
          _showLimitWarning(context, 'swipes', remainingCount);
        }
        break;

      case 'super_likes':
        if (remainingCount <= 0) {
          showFeatureUpgradePrompt(context, 'Super Likes');
          return false;
        }
        break;
    }

    return true;
  }

  /// Show warning when approaching daily limits
  static void _showLimitWarning(
    BuildContext context,
    String limitType,
    int remaining,
  ) {
    Get.snackbar(
      'Daily Limit Warning',
      'You have $remaining $limitType remaining today. Upgrade to premium for unlimited access!',
      backgroundColor: Colors.orange.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
      onTap: (_) => showFeatureUpgradePrompt(context, 'Unlimited Swipes'),
    );
  }

  /// Get premium feature status summary
  static Future<PremiumFeatureStatus> getPremiumFeatureStatus() async {
    final hasSubscription = await SubscriptionManager.hasActiveSubscription();
    final tier = await SubscriptionManager.getSubscriptionTier();
    final expiryText = await SubscriptionManager.getSubscriptionExpiryText();

    if (!hasSubscription) {
      return PremiumFeatureStatus(
        isActive: false,
        tier: 'free',
        expiryText: 'No active subscription',
        unlimitedSwipes: false,
        unlimitedSuperLikes: false,
        canSeeWhoLikedMe: false,
        canUseBoost: false,
        canUndoSwipes: false,
        canUseAdvancedFilters: false,
        canSeeReadReceipts: false,
        remainingBoosts: 0,
      );
    }

    final remainingBoosts = await getRemainingBoosts();

    return PremiumFeatureStatus(
      isActive: true,
      tier: tier,
      expiryText: expiryText,
      unlimitedSwipes: true,
      unlimitedSuperLikes: true,
      canSeeWhoLikedMe: true,
      canUseBoost: true,
      canUndoSwipes: true,
      canUseAdvancedFilters: true,
      canSeeReadReceipts: true,
      remainingBoosts: remainingBoosts,
    );
  }

  /// Track premium feature usage for analytics
  static Future<void> trackFeatureUsage(String featureName) async {
    try {
      await Utils.http_post('track-feature-usage', {
        'feature_name': featureName,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking feature usage: $e');
    }
  }

  /// Get personalized upgrade recommendations
  static Future<List<String>> getPersonalizedUpgradeReasons() async {
    try {
      final response = await Utils.http_get('upgrade-recommendations', {});
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null && resp.data['reasons'] is List) {
        return List<String>.from(resp.data['reasons']);
      }

      // Fallback default reasons
      return [
        'You\'ve reached your daily swipe limit 3 times this week',
        'You have 12 people who liked you waiting',
        'Premium users get 3x more matches on average',
        'Boost your profile for instant visibility',
      ];
    } catch (e) {
      return [
        'Unlock unlimited swipes and super likes',
        'See who liked you for instant matches',
        'Boost your profile visibility',
        'Access advanced search filters',
      ];
    }
  }
}

/// Result object for boost operations
class BoostResult {
  final bool success;
  final String message;
  final bool requiresUpgrade;
  final String? boostExpiresAt;
  final int? viewsIncrease;

  BoostResult({
    required this.success,
    required this.message,
    this.requiresUpgrade = false,
    this.boostExpiresAt,
    this.viewsIncrease,
  });
}

/// Premium feature status data model
class PremiumFeatureStatus {
  final bool isActive;
  final String tier;
  final String expiryText;
  final bool unlimitedSwipes;
  final bool unlimitedSuperLikes;
  final bool canSeeWhoLikedMe;
  final bool canUseBoost;
  final bool canUndoSwipes;
  final bool canUseAdvancedFilters;
  final bool canSeeReadReceipts;
  final int remainingBoosts;

  PremiumFeatureStatus({
    required this.isActive,
    required this.tier,
    required this.expiryText,
    required this.unlimitedSwipes,
    required this.unlimitedSuperLikes,
    required this.canSeeWhoLikedMe,
    required this.canUseBoost,
    required this.canUndoSwipes,
    required this.canUseAdvancedFilters,
    required this.canSeeReadReceipts,
    required this.remainingBoosts,
  });
}
