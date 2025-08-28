import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/dating/PremiumUpgradeDialog.dart';
import 'swipe_service.dart';

class UpgradePromptService {
  static const String _lastPromptKey = 'last_upgrade_prompt';
  static const String _promptCountKey = 'upgrade_prompt_count';
  static const String _dismissCountKey = 'upgrade_dismiss_count';
  static const Duration _cooldownPeriod = Duration(hours: 4);

  // Track user actions for smart prompting
  static int _swipesSinceLastPrompt = 0;
  static int _matchesSinceLastPrompt = 0;
  static bool _hasShownDailyLimitToday = false;

  /// Check if we should show an upgrade prompt based on user behavior
  static Future<bool> shouldShowPrompt(String triggerType) async {
    final prefs = await SharedPreferences.getInstance();

    // Check cooldown period
    final lastPromptTime = prefs.getInt(_lastPromptKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastPromptTime < _cooldownPeriod.inMilliseconds) {
      return false;
    }

    // Check dismiss count - don't be too aggressive
    final dismissCount = prefs.getInt(_dismissCountKey) ?? 0;
    if (dismissCount >= 3) {
      return false; // User has dismissed too many times today
    }

    // Trigger-specific logic
    switch (triggerType) {
      case 'daily_limit':
        return !_hasShownDailyLimitToday;
      case 'match_potential':
        return _matchesSinceLastPrompt >= 2; // Show after getting some matches
      case 'profile_boost':
        return _swipesSinceLastPrompt >= 30; // After active swiping
      case 'super_likes':
        return _swipesSinceLastPrompt >= 20; // After regular usage
      case 'analytics_pro':
        return true; // Can show anytime
      default:
        return false;
    }
  }

  /// Show upgrade prompt if conditions are met
  static Future<void> checkAndShowPrompt(
    BuildContext context,
    String triggerType, {
    SwipeStats? stats,
    Map<String, dynamic>? customData,
  }) async {
    if (!await shouldShowPrompt(triggerType)) {
      return;
    }

    await _recordPromptShown();

    switch (triggerType) {
      case 'daily_limit':
        if (stats != null) {
          PremiumPrompts.showDailyLimitReached(context, stats);
          _hasShownDailyLimitToday = true;
        }
        break;
      case 'match_potential':
        PremiumPrompts.showMatchPotential(
          context,
          matchCount: customData?['matchCount'] ?? 0,
        );
        break;
      case 'profile_boost':
        PremiumPrompts.showBoostOpportunity(context);
        break;
      case 'super_likes':
        PremiumPrompts.showSuperLikesUpgrade(context);
        break;
      case 'analytics_pro':
        PremiumPrompts.showAnalyticsPro(context);
        break;
    }

    // Reset counters after showing prompt
    _swipesSinceLastPrompt = 0;
    _matchesSinceLastPrompt = 0;
  }

  /// Call this when user performs a swipe action
  static void trackSwipeAction() {
    _swipesSinceLastPrompt++;
  }

  /// Call this when user gets a new match
  static void trackNewMatch() {
    _matchesSinceLastPrompt++;
  }

  /// Call this when user reaches daily swipe limit
  static Future<void> handleDailyLimitReached(
    BuildContext context,
    SwipeStats stats,
  ) async {
    await checkAndShowPrompt(context, 'daily_limit', stats: stats);
  }

  /// Call this when user is actively swiping (boost opportunity)
  static Future<void> handleActiveSwipingSession(BuildContext context) async {
    if (_swipesSinceLastPrompt >= 25) {
      await checkAndShowPrompt(context, 'profile_boost');
    }
  }

  /// Call this when user gets matches but hasn't upgraded
  static Future<void> handleMatchSuccess(
    BuildContext context,
    int totalMatches,
  ) async {
    if (totalMatches >= 3 && _matchesSinceLastPrompt >= 2) {
      await checkAndShowPrompt(
        context,
        'match_potential',
        customData: {'matchCount': totalMatches},
      );
    }
  }

  /// Call this when user views analytics screen
  static Future<void> handleAnalyticsView(BuildContext context) async {
    await checkAndShowPrompt(context, 'analytics_pro');
  }

  /// Call this when user tries to use super like but is at limit
  static Future<void> handleSuperLikeLimit(BuildContext context) async {
    await checkAndShowPrompt(context, 'super_likes');
  }

  /// Record that a prompt was shown
  static Future<void> _recordPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    await prefs.setInt(_lastPromptKey, now);

    final currentCount = prefs.getInt(_promptCountKey) ?? 0;
    await prefs.setInt(_promptCountKey, currentCount + 1);
  }

  /// Call this when user dismisses a prompt
  static Future<void> recordPromptDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_dismissCountKey) ?? 0;
    await prefs.setInt(_dismissCountKey, currentCount + 1);
  }

  /// Reset daily counters (call at app start or daily reset)
  static Future<void> resetDailyCounters() async {
    _hasShownDailyLimitToday = false;
    _swipesSinceLastPrompt = 0;
    _matchesSinceLastPrompt = 0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dismissCountKey, 0);
  }

  /// Check if user has been active enough to warrant upgrade prompts
  static bool isUserActiveEnough() {
    return _swipesSinceLastPrompt >= 10 || _matchesSinceLastPrompt >= 1;
  }

  /// Get personalized upgrade recommendations based on usage
  static List<String> getPersonalizedRecommendations(SwipeStats? stats) {
    final recommendations = <String>[];

    if (stats == null) return recommendations;

    // High usage patterns
    if (stats.likesRemaining <= 10) {
      recommendations.add(
        'You\'re running low on likes! Get unlimited swipes.',
      );
    }

    // Low match rate
    final matchRate =
        stats.matches > 0 && stats.likesRemaining < 50
            ? (stats.matches / (50 - stats.likesRemaining)) * 100
            : 0;

    if (matchRate < 10) {
      recommendations.add('Boost your profile to increase your match rate!');
    }

    // Active user
    if (_swipesSinceLastPrompt >= 20) {
      recommendations.add(
        'You\'re very active! Premium features could help you find matches faster.',
      );
    }

    // Has matches but could get more
    if (stats.matches >= 2 && stats.matches < 10) {
      recommendations.add(
        'You\'re getting matches! Premium could 3x your results.',
      );
    }

    return recommendations;
  }

  /// Smart timing for showing prompts during natural breaks
  static bool isGoodTimingForPrompt() {
    final now = DateTime.now();
    final hour = now.hour;

    // Avoid prompts during typical sleep hours
    if (hour >= 23 || hour <= 6) return false;

    // Prefer evening hours when people are more likely to be dating-focused
    if (hour >= 18 && hour <= 22) return true;

    // Lunch time is also good
    if (hour >= 12 && hour <= 14) return true;

    return false;
  }
}
