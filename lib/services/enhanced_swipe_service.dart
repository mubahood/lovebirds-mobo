import '../models/RespondModel.dart';
import '../models/UserModel.dart';
import '../utils/Utilities.dart';
import 'compatibility_scoring.dart';

class SwipeService {
  static final CompatibilityScoring _compatibilityService =
      CompatibilityScoring.instance;

  // Get next user to swipe on with compatibility scoring
  static Future<UserModel?> getSwipeUser() async {
    try {
      final response = await Utils.http_get('swipe-discovery', {});
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final userData = resp.data['user'];
        if (userData != null) {
          return UserModel.fromJson(userData);
        }
      }
      return null;
    } catch (e) {
      print('Error getting swipe user: $e');
      return null;
    }
  }

  // Get multiple swipe candidates with compatibility scores
  static Future<List<SwipeCandidate>> getSwipeCandidates({
    int limit = 10,
    UserModel? currentUser,
  }) async {
    try {
      final response = await Utils.http_get('swipe-discovery-batch', {
        'limit': limit.toString(),
      });
      final resp = RespondModel(response);

      List<SwipeCandidate> candidates = [];

      if (resp.code == 1 && resp.data != null) {
        final usersData = resp.data['users'] as List?;
        if (usersData != null && currentUser != null) {
          for (var userData in usersData) {
            final user = UserModel.fromJson(userData);
            final compatibilityScore = _compatibilityService
                .calculateCompatibilityScore(currentUser, user);

            candidates.add(
              SwipeCandidate(
                user: user,
                compatibilityScore: compatibilityScore,
                compatibilityLevel: _compatibilityService.getCompatibilityLevel(
                  compatibilityScore,
                ),
                compatibilityInsights: _compatibilityService
                    .getCompatibilityInsights(currentUser, user),
              ),
            );
          }

          // Sort by compatibility score for better experience
          candidates.sort(
            (a, b) => b.compatibilityScore.compareTo(a.compatibilityScore),
          );
        }
      }

      return candidates;
    } catch (e) {
      print('Error getting swipe candidates: $e');
      return [];
    }
  }

  // Send swipe action to backend
  static Future<SwipeResult> performSwipe({
    required int targetUserId,
    required String action, // 'like', 'super_like', 'pass'
    String? message,
    double? compatibilityScore,
  }) async {
    try {
      final params = {
        'target_user_id': targetUserId.toString(),
        'action': action,
      };

      if (message != null && message.isNotEmpty) {
        params['message'] = message;
      }

      if (compatibilityScore != null) {
        params['compatibility_score'] = compatibilityScore.toString();
      }

      final response = await Utils.http_post('swipe-action', params);
      final resp = RespondModel(response);

      if (resp.code == 1) {
        return SwipeResult(
          success: true,
          isMatch: resp.data?['is_match'] == true,
          message: resp.message,
          matchId: resp.data?['match_id'],
          compatibilityScore: compatibilityScore,
        );
      } else {
        return SwipeResult(
          success: false,
          isMatch: false,
          message: resp.message,
        );
      }
    } catch (e) {
      print('Error performing swipe: $e');
      return SwipeResult(
        success: false,
        isMatch: false,
        message: 'Network error occurred',
      );
    }
  }

  // Get compatibility insights for a specific user pair
  static List<String> getCompatibilityInsights(
    UserModel user1,
    UserModel user2,
  ) {
    return _compatibilityService.getCompatibilityInsights(user1, user2);
  }

  // Get detailed compatibility breakdown
  static Map<String, double> getCompatibilityBreakdown(
    UserModel user1,
    UserModel user2,
  ) {
    return _compatibilityService.getCompatibilityBreakdown(user1, user2);
  }

  // Calculate match potential based on compatibility
  static MatchPotential calculateMatchPotential(
    UserModel user1,
    UserModel user2,
  ) {
    final score = _compatibilityService.calculateCompatibilityScore(
      user1,
      user2,
    );
    final level = _compatibilityService.getCompatibilityLevel(score);
    final insights = _compatibilityService.getCompatibilityInsights(
      user1,
      user2,
    );

    return MatchPotential(
      score: score,
      level: level,
      insights: insights,
      recommendation: _getSwipeRecommendation(score),
    );
  }

  static SwipeRecommendation _getSwipeRecommendation(double score) {
    if (score >= 80) return SwipeRecommendation.superLike;
    if (score >= 65) return SwipeRecommendation.like;
    if (score >= 40) return SwipeRecommendation.consider;
    return SwipeRecommendation.pass;
  }

  // Get suggested swipe action based on compatibility
  static String getSuggestedAction(UserModel user1, UserModel user2) {
    final score = _compatibilityService.calculateCompatibilityScore(
      user1,
      user2,
    );
    final recommendation = _getSwipeRecommendation(score);

    switch (recommendation) {
      case SwipeRecommendation.superLike:
        return 'super_like';
      case SwipeRecommendation.like:
        return 'like';
      case SwipeRecommendation.consider:
        return 'like';
      case SwipeRecommendation.pass:
        return 'pass';
    }
  }
}

class SwipeCandidate {
  final UserModel user;
  final double compatibilityScore;
  final String compatibilityLevel;
  final List<String> compatibilityInsights;

  SwipeCandidate({
    required this.user,
    required this.compatibilityScore,
    required this.compatibilityLevel,
    required this.compatibilityInsights,
  });
}

class SwipeResult {
  final bool success;
  final bool isMatch;
  final String message;
  final int? matchId;
  final double? compatibilityScore;

  SwipeResult({
    required this.success,
    required this.isMatch,
    required this.message,
    this.matchId,
    this.compatibilityScore,
  });
}

class MatchPotential {
  final double score;
  final String level;
  final List<String> insights;
  final SwipeRecommendation recommendation;

  MatchPotential({
    required this.score,
    required this.level,
    required this.insights,
    required this.recommendation,
  });
}

enum SwipeRecommendation { superLike, like, consider, pass }
