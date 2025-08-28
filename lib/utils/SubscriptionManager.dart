import '../models/LoggedInUserModel.dart';

/// Utility class for managing subscription features and limits
class SubscriptionManager {
  /// Check if user has an active premium subscription
  static Future<bool> hasActiveSubscription() async {
    try {
      final user = await LoggedInUserModel.getLoggedInUser();

      // Check if subscription tier exists and is not empty
      if (user.subscription_tier.isEmpty) return false;

      // Check if subscription hasn't expired
      if (user.subscription_expires.isNotEmpty) {
        try {
          final expiryDate = DateTime.parse(user.subscription_expires);
          return expiryDate.isAfter(DateTime.now());
        } catch (e) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get the subscription tier (free, premium, premium_plus)
  static Future<String> getSubscriptionTier() async {
    try {
      final user = await LoggedInUserModel.getLoggedInUser();
      return user.subscription_tier.isEmpty ? 'free' : user.subscription_tier;
    } catch (e) {
      return 'free';
    }
  }

  /// Get daily super like limit based on subscription
  static Future<int> getSuperLikeLimit() async {
    if (await hasActiveSubscription()) {
      return 999; // Unlimited for premium users
    }
    return 1; // 1 per day for free users
  }

  /// Get daily like limit based on subscription
  static Future<int> getDailyLikeLimit() async {
    if (await hasActiveSubscription()) {
      return 999; // Unlimited for premium users
    }
    return 50; // 50 per day for free users
  }

  /// Check if user can use super likes
  static Future<bool> canUseSuperLike(int superLikesRemaining) async {
    if (await hasActiveSubscription()) {
      return true; // Premium users have unlimited
    }
    return superLikesRemaining > 0; // Free users limited by daily count
  }

  /// Check if user can use regular likes
  static Future<bool> canUseLike(int likesRemaining) async {
    if (await hasActiveSubscription()) {
      return true; // Premium users have unlimited
    }
    return likesRemaining > 0; // Free users limited by daily count
  }

  /// Get premium features based on subscription tier
  static Future<List<String>> getPremiumFeatures() async {
    final tier = await getSubscriptionTier();

    switch (tier) {
      case 'premium':
      case 'premium_plus':
        return [
          'Unlimited daily swipes',
          'Unlimited super likes',
          'See who liked you',
          'Undo swipes',
          'Profile boost',
          'Read receipts',
          'Advanced filters',
          'Priority support',
        ];
      default:
        return [];
    }
  }

  /// Get subscription expiry text
  static Future<String> getSubscriptionExpiryText() async {
    try {
      final user = await LoggedInUserModel.getLoggedInUser();
      if (user.subscription_expires.isEmpty) {
        return 'No active subscription';
      }

      try {
        final expiryDate = DateTime.parse(user.subscription_expires);
        final daysRemaining = expiryDate.difference(DateTime.now()).inDays;

        if (daysRemaining > 0) {
          return 'Expires in $daysRemaining days';
        } else {
          return 'Subscription expired';
        }
      } catch (e) {
        return 'Invalid expiry date';
      }
    } catch (e) {
      return 'No active subscription';
    }
  }

  /// Canadian subscription pricing
  static Map<String, dynamic> getSubscriptionPricing() {
    return {
      'weekly': {
        'price': 10.0,
        'currency': 'CAD',
        'period': '1 week',
        'description': 'Perfect for trying premium features',
      },
      'monthly': {
        'price': 30.0,
        'currency': 'CAD',
        'period': '1 month',
        'description': 'Most popular choice',
      },
      'quarterly': {
        'price': 70.0,
        'currency': 'CAD',
        'period': '3 months',
        'description': 'Best value - 1 month free!',
      },
    };
  }
}
