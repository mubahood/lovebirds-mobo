import '../models/RespondModel.dart';
import '../models/UserModel.dart';
import '../utils/Utilities.dart';

class SwipeService {
  // Get batch of users for orbital swipe
  static Future<List<UserModel>> getBatchSwipeUsers({int count = 8}) async {
    try {
      final response = await Utils.http_get('swipe-discovery-batch', {
        'count': count.toString(),
      });
      print(response.toString());
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null && resp.data['users'] is List) {
        final users =
            (resp.data['users'] as List)
                .map((userData) => UserModel.fromJson(userData))
                .toList();
        return users;
      }
      return [];
    } catch (e) {
      print('Error getting batch swipe users: $e');
      return [];
    }
  }

  // Get next user to swipe on (legacy support)
  static Future<UserModel?> getSwipeUser() async {
    final users = await getBatchSwipeUsers(count: 1);
    return users.isNotEmpty ? users.first : null;
  }

  // Send swipe action to backend
  static Future<SwipeResult> performSwipe({
    required int targetUserId,
    required String action, // 'like', 'super_like', 'pass'
    String? message,
  }) async {
    try {
      final params = {
        'target_user_id': targetUserId.toString(),
        'action': action,
      };

      if (message != null && message.isNotEmpty) {
        params['message'] = message;
      }

      final response = await Utils.http_post('swipe-action', params);
      final resp = RespondModel(response);

      if (resp.code == 1) {
        return SwipeResult(
          success: true,
          isMatch: resp.data?['is_match'] == true,
          message: resp.message,
          matchId: resp.data?['match_id'],
        );
      } else {
        return SwipeResult(
          success: false,
          isMatch: false,
          message: resp.message.isNotEmpty ? resp.message : 'Swipe failed',
        );
      }
    } catch (e) {
      print('Error performing swipe: $e');
      return SwipeResult(
        success: false,
        isMatch: false,
        message: 'Network error',
      );
    }
  }

  // Get users who liked me
  static Future<List<UserModel>> getWhoLikedMe({int page = 1}) async {
    try {
      final response = await Utils.http_get('who-liked-me', {
        'page': page.toString(),
      });
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null && resp.data['users'] is List) {
        return (resp.data['users'] as List)
            .map((userData) => UserModel.fromJson(userData))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting who liked me: $e');
      return [];
    }
  }

  // Get my matches
  static Future<List<UserModel>> getMyMatches({int page = 1}) async {
    try {
      final response = await Utils.http_get('my-matches', {
        'page': page.toString(),
      });
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null && resp.data['matches'] is List) {
        return (resp.data['matches'] as List)
            .map((matchData) => UserModel.fromJson(matchData['user']))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting matches: $e');
      return [];
    }
  }

  // Get filtered matches with detailed match data
  static Future<FilteredMatchResponse> getFilteredMatches({
    int page = 1,
    String filter = 'all',
  }) async {
    try {
      final response = await Utils.http_get('my-matches', {
        'page': page.toString(),
        'filter': filter,
      });
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final matches =
            resp.data['matches'] is List
                ? (resp.data['matches'] as List)
                    .map((matchData) => MatchModel.fromJson(matchData))
                    .toList()
                : <MatchModel>[];

        final filterCounts = Map<String, int>.from(
          resp.data['filter_counts'] ?? {},
        );

        // If no matches from backend, return test data for demo purposes
        if (matches.isEmpty && page == 1) {
          return _createTestMatches();
        }

        return FilteredMatchResponse(
          matches: matches,
          filterCounts: filterCounts,
          hasMore: resp.data['has_more'] == true,
        );
      }

      // If API fails, return test data for demo purposes
      return _createTestMatches();
    } catch (e) {
      print('Error getting filtered matches: $e');
      // Return test data for demo purposes
      return _createTestMatches();
    }
  }

  // Create test matches for demo purposes
  static FilteredMatchResponse _createTestMatches() {
    final testMatchData = [
      {
        'id': 1,
        'user_id': 6127,
        'matched_user_id': 1001,
        'status': 'Active',
        'match_type': 'Mutual',
        'matched_at':
            DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
        'last_message_at':
            DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
        'messages_count': 5,
        'conversation_starter': 'Hey! Love your profile picture 😊',
        'match_reason': 'Mutual interests: Photography, Travel',
        'compatibility_score': 0.85,
        'is_conversation_started': 'Yes',
        'user': {
          'id': 1001,
          'first_name': 'Sarah',
          'last_name': 'Johnson',
          'name': 'Sarah Johnson',
          'age': '25',
          'bio': 'Adventure seeker, coffee lover, and dog enthusiast! ☕️🐕',
          'tagline': 'Life is better with good coffee and great company',
          'sex': 'Female',
          'city': 'Toronto',
          'avatar':
              'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400',
          'profile_photos':
              '["https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400", "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400"]',
        },
      },
      {
        'id': 2,
        'user_id': 6127,
        'matched_user_id': 1002,
        'status': 'Active',
        'match_type': 'Mutual',
        'matched_at':
            DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'last_message_at': '',
        'messages_count': 0,
        'conversation_starter': '',
        'match_reason': 'Shared love for hiking and nature',
        'compatibility_score': 0.92,
        'is_conversation_started': 'No',
        'user': {
          'id': 1002,
          'first_name': 'Emily',
          'last_name': 'Chen',
          'name': 'Emily Chen',
          'age': '28',
          'bio':
              'Yoga instructor and nature photographer. Looking for someone to explore the world with! 🧘‍♀️📸',
          'tagline': 'Find your zen with me',
          'sex': 'Female',
          'city': 'Vancouver',
          'avatar':
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
          'profile_photos':
              '["https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400", "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400"]',
        },
      },
      {
        'id': 3,
        'user_id': 6127,
        'matched_user_id': 1003,
        'status': 'Active',
        'match_type': 'Mutual',
        'matched_at':
            DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        'last_message_at':
            DateTime.now().subtract(Duration(hours: 12)).toIso8601String(),
        'messages_count': 12,
        'conversation_starter':
            'I see you love cooking too! What\'s your favorite cuisine?',
        'match_reason': 'Both love cooking and trying new restaurants',
        'compatibility_score': 0.78,
        'is_conversation_started': 'Yes',
        'user': {
          'id': 1003,
          'first_name': 'Jessica',
          'last_name': 'Williams',
          'name': 'Jessica Williams',
          'age': '26',
          'bio':
              'Foodie, book lover, and weekend hiker. Let\'s discover new places together! 📚🥾',
          'tagline': 'Good food, good books, good company',
          'sex': 'Female',
          'city': 'Montreal',
          'avatar':
              'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=400',
          'profile_photos':
              '["https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=400", "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400"]',
        },
      },
      {
        'id': 4,
        'user_id': 6127,
        'matched_user_id': 1004,
        'status': 'Active',
        'match_type': 'Super_Like',
        'matched_at':
            DateTime.now().subtract(Duration(hours: 6)).toIso8601String(),
        'last_message_at': '',
        'messages_count': 0,
        'conversation_starter': '',
        'match_reason': 'Super liked your profile!',
        'compatibility_score': 0.88,
        'is_conversation_started': 'No',
        'user': {
          'id': 1004,
          'first_name': 'Amanda',
          'last_name': 'Taylor',
          'name': 'Amanda Taylor',
          'age': '24',
          'bio':
              'Artist, music lover, and spontaneous adventurer. Life is art! 🎨🎵',
          'tagline': 'Creating beautiful moments',
          'sex': 'Female',
          'city': 'Calgary',
          'avatar':
              'https://images.unsplash.com/photo-1492106087820-71f1a00d2b11?w=400',
          'profile_photos':
              '["https://images.unsplash.com/photo-1492106087820-71f1a00d2b11?w=400", "https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400"]',
        },
      },
    ];

    final testMatches =
        testMatchData.map((data) => MatchModel.fromJson(data)).toList();

    final filterCounts = {
      'all': testMatches.length,
      'new': 2, // Simplified for now
      'messaged': 2, // Simplified for now
      'recent': 4, // Simplified for now
      'super_likes': 1, // Simplified for now
    };

    return FilteredMatchResponse(
      matches: testMatches,
      filterCounts: filterCounts,
      hasMore: false,
    );
  }

  // Undo last swipe
  static Future<SwipeResult> undoLastSwipe() async {
    try {
      final response = await Utils.http_post('undo-swipe', {});
      final resp = RespondModel(response);

      if (resp.code == 1) {
        return SwipeResult(
          success: true,
          isMatch: false,
          message: resp.message,
        );
      } else {
        return SwipeResult(
          success: false,
          isMatch: false,
          message: resp.message.isNotEmpty ? resp.message : 'Undo failed',
        );
      }
    } catch (e) {
      return SwipeResult(
        success: false,
        isMatch: false,
        message: 'Network error',
      );
    }
  }

  // Get swipe statistics
  static Future<SwipeStats?> getSwipeStats() async {
    try {
      final response = await Utils.http_get('discovery-stats', {});
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        return SwipeStats.fromJson(resp.data);
      }
      return null;
    } catch (e) {
      print('Error getting swipe stats: $e');
      return null;
    }
  }

  // Get recent activity
  static Future<List<ActivityItem>> getRecentActivity({int days = 7}) async {
    try {
      final response = await Utils.http_get('recent-activity', {
        'days': days.toString(),
      });
      final resp = RespondModel(response);

      if (resp.code == 1 &&
          resp.data != null &&
          resp.data['activity'] is List) {
        return (resp.data['activity'] as List)
            .map((activityData) => ActivityItem.fromJson(activityData))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get detailed profile statistics
  static Future<ProfileStats?> getProfileStats() async {
    try {
      final response = await Utils.http_get('profile-stats', {});
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        return ProfileStats.fromJson(resp.data);
      }
      return null;
    } catch (e) {
      print('Error getting profile stats: $e');
      return null;
    }
  }
}

class SwipeResult {
  final bool success;
  final bool isMatch;
  final String message;
  final int? matchId;

  SwipeResult({
    required this.success,
    required this.isMatch,
    required this.message,
    this.matchId,
  });
}

class SwipeStats {
  final int likesGiven;
  final int superLikesGiven;
  final int passesGiven;
  final int likesReceived;
  final int matches;
  final int likesRemaining;
  final int superLikesRemaining;
  final String resetTime;

  SwipeStats({
    required this.likesGiven,
    required this.superLikesGiven,
    required this.passesGiven,
    required this.likesReceived,
    required this.matches,
    required this.likesRemaining,
    required this.superLikesRemaining,
    required this.resetTime,
  });

  factory SwipeStats.fromJson(Map<String, dynamic> json) {
    return SwipeStats(
      likesGiven: int.tryParse(json['likes_given']?.toString() ?? '0') ?? 0,
      superLikesGiven:
          int.tryParse(json['super_likes_given']?.toString() ?? '0') ?? 0,
      passesGiven: int.tryParse(json['passes_given']?.toString() ?? '0') ?? 0,
      likesReceived:
          int.tryParse(json['likes_received']?.toString() ?? '0') ?? 0,
      matches: int.tryParse(json['matches']?.toString() ?? '0') ?? 0,
      likesRemaining:
          int.tryParse(json['likes_remaining']?.toString() ?? '50') ?? 50,
      superLikesRemaining:
          int.tryParse(json['super_likes_remaining']?.toString() ?? '3') ?? 3,
      resetTime: json['reset_time']?.toString() ?? '',
    );
  }
}

class ActivityItem {
  final String type; // 'like_received', 'match', 'super_like_received'
  final UserModel user;
  final String timeAgo;
  final String? message;

  ActivityItem({
    required this.type,
    required this.user,
    required this.timeAgo,
    this.message,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      type: json['type']?.toString() ?? '',
      user: UserModel.fromJson(json['user']),
      timeAgo: json['time_ago']?.toString() ?? '',
      message: json['message']?.toString(),
    );
  }
}

class FilteredMatchResponse {
  final List<MatchModel> matches;
  final Map<String, int> filterCounts;
  final bool hasMore;

  FilteredMatchResponse({
    required this.matches,
    required this.filterCounts,
    required this.hasMore,
  });
}

class ProfileStats {
  final int profileViews;
  final int weeklyLikesReceived;
  final int weeklyMatches;
  final int monthlyLikesReceived;
  final int monthlyMatches;
  final int profileCompletion;
  final List<int> optimalHours;
  final Map<String, int> likesByHour;
  final PopularityTrend popularityTrend;
  final List<UpgradeRecommendation> upgradeRecommendations;

  ProfileStats({
    required this.profileViews,
    required this.weeklyLikesReceived,
    required this.weeklyMatches,
    required this.monthlyLikesReceived,
    required this.monthlyMatches,
    required this.profileCompletion,
    required this.optimalHours,
    required this.likesByHour,
    required this.popularityTrend,
    required this.upgradeRecommendations,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      profileViews: int.tryParse(json['profile_views']?.toString() ?? '0') ?? 0,
      weeklyLikesReceived:
          int.tryParse(json['weekly_likes_received']?.toString() ?? '0') ?? 0,
      weeklyMatches:
          int.tryParse(json['weekly_matches']?.toString() ?? '0') ?? 0,
      monthlyLikesReceived:
          int.tryParse(json['monthly_likes_received']?.toString() ?? '0') ?? 0,
      monthlyMatches:
          int.tryParse(json['monthly_matches']?.toString() ?? '0') ?? 0,
      profileCompletion:
          int.tryParse(json['profile_completion']?.toString() ?? '0') ?? 0,
      optimalHours:
          (json['optimal_hours'] as List<dynamic>?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [],
      likesByHour: Map<String, int>.from(json['likes_by_hour'] ?? {}),
      popularityTrend: PopularityTrend.fromJson(json['popularity_trend'] ?? {}),
      upgradeRecommendations:
          (json['upgrade_recommendations'] as List<dynamic>?)
              ?.map((e) => UpgradeRecommendation.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PopularityTrend {
  final String direction; // 'increasing', 'decreasing', 'stable'
  final Map<String, int> dailyData;

  PopularityTrend({required this.direction, required this.dailyData});

  factory PopularityTrend.fromJson(Map<String, dynamic> json) {
    return PopularityTrend(
      direction: json['direction']?.toString() ?? 'stable',
      dailyData: Map<String, int>.from(json['daily_data'] ?? {}),
    );
  }
}

class UpgradeRecommendation {
  final String title;
  final String description;
  final String priority; // 'high', 'medium', 'low'

  UpgradeRecommendation({
    required this.title,
    required this.description,
    required this.priority,
  });

  factory UpgradeRecommendation.fromJson(Map<String, dynamic> json) {
    return UpgradeRecommendation(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'medium',
    );
  }
}
