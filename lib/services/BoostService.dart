import '../models/RespondModel.dart';
import '../utils/Utilities.dart';

class BoostService {
  static const String _baseUrl = 'boost';

  /// Activate profile boost for increased visibility
  static Future<RespondModel> boostProfile() async {
    try {
      Map<String, dynamic> data = {};

      final response = await Utils.http_post('$_baseUrl-profile', data);
      return RespondModel(response);
    } catch (e) {
      return RespondModel({
        'code': 0,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      });
    }
  }

  /// Get boost status and available boosts
  static Future<RespondModel> getBoostStatus() async {
    try {
      final response = await Utils.http_get('$_baseUrl-status', {});
      return RespondModel(response);
    } catch (e) {
      return RespondModel({
        'code': 0,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      });
    }
  }

  /// Get boost pricing information
  static Map<String, dynamic> getBoostPricing() {
    return {
      'currency': 'CAD',
      'single_boost': {
        'price': 2.99,
        'duration_minutes': 30,
        'visibility_multiplier': 3.0,
        'description': '3x more profile visibility for 30 minutes',
        'formatted_price': '\$2.99 CAD',
      },
      'premium_benefits': {
        'unlimited_boosts': true,
        'included_features': [
          'Unlimited profile boosts',
          'Premium visibility priority',
          'Enhanced matching algorithm',
          'Advanced analytics',
        ],
      },
    };
  }

  /// Check if user can use boost feature
  static bool canUseBoost(Map<String, dynamic>? subscriptionStatus) {
    if (subscriptionStatus == null) return false;

    final isPremium = subscriptionStatus['is_premium'] ?? false;
    final boostCredits = subscriptionStatus['boost_credits'] ?? 0;

    return isPremium || boostCredits > 0;
  }

  /// Get boost button state and text
  static Map<String, dynamic> getBoostButtonState(
    Map<String, dynamic>? boostStatus,
  ) {
    if (boostStatus == null) {
      return {'enabled': false, 'text': 'Loading...', 'color': 'disabled'};
    }

    final isBoosted = boostStatus['is_boosted'] ?? false;
    final availableBoosts = boostStatus['available_boosts'] ?? {};

    if (isBoosted) {
      final currentBoost = boostStatus['current_boost'];
      final remainingTime = currentBoost?['time_remaining'] ?? '0 minutes';

      return {
        'enabled': false,
        'text': 'Boosted ($remainingTime left)',
        'color': 'success',
        'subtitle': '3x more visibility active',
      };
    }

    final boostType = availableBoosts['type'] ?? 'credits';
    final boostCount = availableBoosts['count'] ?? 0;

    if (boostType == 'unlimited') {
      return {
        'enabled': true,
        'text': 'Boost My Profile',
        'color': 'premium',
        'subtitle': 'Unlimited boosts available',
      };
    }

    if (boostCount > 0) {
      return {
        'enabled': true,
        'text': 'Boost My Profile',
        'color': 'primary',
        'subtitle': '$boostCount boost${boostCount == 1 ? '' : 's'} available',
      };
    }

    return {
      'enabled': true,
      'text': 'Buy Boost (\$2.99)',
      'color': 'purchase',
      'subtitle': '30 min visibility boost',
    };
  }

  /// Format boost time remaining
  static String formatTimeRemaining(String timeString) {
    final minutes = int.tryParse(timeString.replaceAll(' minutes', '')) ?? 0;

    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      }
      return '${hours}h ${remainingMinutes}m';
    }

    return '${minutes}m';
  }

  /// Get boost analytics data
  static Map<String, dynamic> parseBoostAnalytics(
    Map<String, dynamic>? boostHistory,
  ) {
    if (boostHistory == null || boostHistory.isEmpty) {
      return {
        'total_boosts_used': 0,
        'total_views_generated': 0,
        'total_likes_generated': 0,
        'total_matches_generated': 0,
        'average_effectiveness': 0.0,
        'last_boost_date': null,
      };
    }

    int totalBoosts = 0;
    int totalViews = 0;
    int totalLikes = 0;
    int totalMatches = 0;
    double totalEffectiveness = 0.0;
    String? lastBoostDate;

    if (boostHistory['boost_history'] is List) {
      final history = boostHistory['boost_history'] as List;
      totalBoosts = history.length;

      for (var boost in history) {
        totalViews += (boost['views_generated'] ?? 0) as int;
        totalLikes += (boost['likes_generated'] ?? 0) as int;
        totalMatches += (boost['matches_generated'] ?? 0) as int;

        if (lastBoostDate == null ||
            (boost['started_at'] != null &&
                boost['started_at'].compareTo(lastBoostDate) > 0)) {
          lastBoostDate = boost['started_at'];
        }
      }

      if (totalBoosts > 0) {
        totalEffectiveness =
            (totalViews + totalLikes * 2 + totalMatches * 5) / totalBoosts;
      }
    }

    return {
      'total_boosts_used': totalBoosts,
      'total_views_generated': totalViews,
      'total_likes_generated': totalLikes,
      'total_matches_generated': totalMatches,
      'average_effectiveness': totalEffectiveness,
      'last_boost_date': lastBoostDate,
    };
  }
}
