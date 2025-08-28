import 'package:flutter/material.dart';
import '../models/UserModel.dart';
import '../models/RespondModel.dart';
import '../utils/Utilities.dart';
import 'compatibility_scoring.dart';

/// Advanced search service with intelligent filtering and compatibility integration
class SmartSearchService {
  static final SmartSearchService _instance = SmartSearchService._();
  static SmartSearchService get instance => _instance;
  SmartSearchService._();

  static final CompatibilityScoring _compatibilityService =
      CompatibilityScoring.instance;

  /// Search users with advanced filters and compatibility scoring
  static Future<SearchResult> searchUsers({
    required SearchFilters filters,
    UserModel? currentUser,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = _buildSearchParams(filters, page, limit);
      final response = await Utils.http_post('advanced-search', params);
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final usersData = resp.data['users'] as List? ?? [];
        final total = Utils.int_parse(resp.data['total']);

        List<SearchCandidate> candidates = [];

        if (currentUser != null) {
          for (var userData in usersData) {
            final user = UserModel.fromJson(userData);
            final compatibilityScore = _compatibilityService
                .calculateCompatibilityScore(currentUser, user);

            candidates.add(
              SearchCandidate(
                user: user,
                compatibilityScore: compatibilityScore,
                matchReasons: _generateMatchReasons(currentUser, user, filters),
              ),
            );
          }

          // Sort by compatibility score for intelligent results
          candidates.sort(
            (a, b) => b.compatibilityScore.compareTo(a.compatibilityScore),
          );
        } else {
          // Fallback without compatibility scoring
          for (var userData in usersData) {
            candidates.add(
              SearchCandidate(
                user: UserModel.fromJson(userData),
                compatibilityScore: 0.0,
                matchReasons: [],
              ),
            );
          }
        }

        return SearchResult(
          success: true,
          candidates: candidates,
          total: total,
          hasMore: (page * limit) < total,
          message: 'Found ${candidates.length} matches',
        );
      } else {
        return SearchResult(
          success: false,
          candidates: [],
          total: 0,
          hasMore: false,
          message: resp.message,
        );
      }
    } catch (e) {
      print('Error searching users: $e');
      return SearchResult(
        success: false,
        candidates: [],
        total: 0,
        hasMore: false,
        message: 'Search failed: $e',
      );
    }
  }

  /// Save user's search preferences for future use
  static Future<bool> saveSearchPreferences(SearchFilters filters) async {
    try {
      final params = _buildSearchParams(filters, 1, 1);
      params['save_preferences'] = 'true';

      final response = await Utils.http_post('save-search-preferences', params);
      final resp = RespondModel(response);

      return resp.code == 1;
    } catch (e) {
      print('Error saving search preferences: $e');
      return false;
    }
  }

  /// Get user's saved search preferences
  static Future<SearchFilters?> getSavedSearchPreferences() async {
    try {
      final response = await Utils.http_get('get-search-preferences', {});
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        return SearchFilters.fromJson(resp.data);
      }
      return null;
    } catch (e) {
      print('Error getting search preferences: $e');
      return null;
    }
  }

  /// Get smart search suggestions based on user's activity
  static Future<List<String>> getSearchSuggestions(
    UserModel currentUser,
  ) async {
    try {
      final params = {'user_id': currentUser.id.toString()};

      final response = await Utils.http_post('search-suggestions', params);
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final suggestions = resp.data['suggestions'] as List? ?? [];
        return suggestions.cast<String>();
      }
      return [];
    } catch (e) {
      print('Error getting search suggestions: $e');
      return [];
    }
  }

  /// Quick search with auto-complete
  static Future<List<UserModel>> quickSearch(String query) async {
    try {
      final params = {'query': query, 'limit': '10'};

      final response = await Utils.http_post('quick-search', params);
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final usersData = resp.data['users'] as List? ?? [];
        return usersData
            .map((userData) => UserModel.fromJson(userData))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error in quick search: $e');
      return [];
    }
  }

  static Map<String, String> _buildSearchParams(
    SearchFilters filters,
    int page,
    int limit,
  ) {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    // Age range
    if (filters.ageRange != null) {
      params['age_min'] = filters.ageRange!.start.round().toString();
      params['age_max'] = filters.ageRange!.end.round().toString();
    }

    // Distance
    if (filters.maxDistance != null) {
      params['max_distance'] = filters.maxDistance!.round().toString();
    }

    // Height range
    if (filters.heightRange != null) {
      params['height_min'] = filters.heightRange!.start.round().toString();
      params['height_max'] = filters.heightRange!.end.round().toString();
    }

    // Body types
    if (filters.bodyTypes.isNotEmpty) {
      params['body_types'] = filters.bodyTypes.join(',');
    }

    // Education levels
    if (filters.educationLevels.isNotEmpty) {
      params['education_levels'] = filters.educationLevels.join(',');
    }

    // Occupations
    if (filters.occupations.isNotEmpty) {
      params['occupations'] = filters.occupations.join(',');
    }

    // Relationship goals
    if (filters.relationshipGoals.isNotEmpty) {
      params['relationship_goals'] = filters.relationshipGoals.join(',');
    }

    // Lifestyle preferences
    filters.lifestylePreferences.forEach((key, value) {
      if (value) {
        params['lifestyle_$key'] = 'true';
      }
    });

    return params;
  }

  static List<String> _generateMatchReasons(
    UserModel currentUser,
    UserModel targetUser,
    SearchFilters filters,
  ) {
    List<String> reasons = [];

    // Age compatibility
    if (filters.ageRange != null) {
      final targetAge = _calculateAge(targetUser.dob);
      if (targetAge >= filters.ageRange!.start &&
          targetAge <= filters.ageRange!.end) {
        reasons.add('Perfect age match');
      }
    }

    // Education compatibility
    if (filters.educationLevels.contains(targetUser.education_level)) {
      reasons.add('Similar education level');
    }

    // Relationship goals alignment
    if (filters.relationshipGoals.contains(targetUser.looking_for)) {
      reasons.add('Same relationship goals');
    }

    // Lifestyle compatibility
    if (currentUser.smoking_habit == targetUser.smoking_habit &&
        filters.lifestylePreferences['smoking'] == true) {
      reasons.add('Compatible smoking preferences');
    }

    if (currentUser.drinking_habit == targetUser.drinking_habit &&
        filters.lifestylePreferences['drinking'] == true) {
      reasons.add('Similar drinking habits');
    }

    // Location proximity
    if (filters.maxDistance != null) {
      final distance = _calculateDistance(currentUser, targetUser);
      if (distance <= filters.maxDistance!) {
        reasons.add('Lives nearby (${distance.round()}km away)');
      }
    }

    return reasons.take(3).toList(); // Limit to top 3 reasons
  }

  static int _calculateAge(String dob) {
    if (dob.isEmpty) return 0;

    try {
      final birthDate = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birthDate.year;

      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }

      return age;
    } catch (e) {
      return 0;
    }
  }

  static double _calculateDistance(UserModel user1, UserModel user2) {
    // Simple distance calculation - in a real app, use proper geolocation formulas
    if (user1.latitude.isEmpty ||
        user1.longitude.isEmpty ||
        user2.latitude.isEmpty ||
        user2.longitude.isEmpty) {
      return 0.0;
    }

    try {
      final lat1 = double.parse(user1.latitude);
      final lon1 = double.parse(user1.longitude);
      final lat2 = double.parse(user2.latitude);
      final lon2 = double.parse(user2.longitude);

      // Simplified distance calculation for demo purposes
      final deltaLat = (lat2 - lat1) * 111; // Rough km per degree
      final deltaLon = (lon2 - lon1) * 111;

      return (deltaLat * deltaLat + deltaLon * deltaLon).abs();
    } catch (e) {
      return 0.0;
    }
  }
}

/// Search filters data class
class SearchFilters {
  final RangeValues? ageRange;
  final double? maxDistance;
  final RangeValues? heightRange;
  final List<String> bodyTypes;
  final List<String> educationLevels;
  final List<String> occupations;
  final List<String> relationshipGoals;
  final Map<String, bool> lifestylePreferences;

  SearchFilters({
    this.ageRange,
    this.maxDistance,
    this.heightRange,
    this.bodyTypes = const [],
    this.educationLevels = const [],
    this.occupations = const [],
    this.relationshipGoals = const [],
    this.lifestylePreferences = const {},
  });

  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    return SearchFilters(
      ageRange:
          json['age_range'] != null
              ? RangeValues(
                Utils.int_parse(json['age_range']['start']).toDouble(),
                Utils.int_parse(json['age_range']['end']).toDouble(),
              )
              : null,
      maxDistance:
          json['max_distance'] != null
              ? Utils.int_parse(json['max_distance']).toDouble()
              : null,
      heightRange:
          json['height_range'] != null
              ? RangeValues(
                Utils.int_parse(json['height_range']['start']).toDouble(),
                Utils.int_parse(json['height_range']['end']).toDouble(),
              )
              : null,
      bodyTypes: (json['body_types'] as List?)?.cast<String>() ?? [],
      educationLevels:
          (json['education_levels'] as List?)?.cast<String>() ?? [],
      occupations: (json['occupations'] as List?)?.cast<String>() ?? [],
      relationshipGoals:
          (json['relationship_goals'] as List?)?.cast<String>() ?? [],
      lifestylePreferences:
          (json['lifestyle_preferences'] as Map?)?.cast<String, bool>() ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age_range':
          ageRange != null
              ? {'start': ageRange!.start, 'end': ageRange!.end}
              : null,
      'max_distance': maxDistance,
      'height_range':
          heightRange != null
              ? {'start': heightRange!.start, 'end': heightRange!.end}
              : null,
      'body_types': bodyTypes,
      'education_levels': educationLevels,
      'occupations': occupations,
      'relationship_goals': relationshipGoals,
      'lifestyle_preferences': lifestylePreferences,
    };
  }
}

/// Search candidate with compatibility information
class SearchCandidate {
  final UserModel user;
  final double compatibilityScore;
  final List<String> matchReasons;

  SearchCandidate({
    required this.user,
    required this.compatibilityScore,
    required this.matchReasons,
  });
}

/// Search result wrapper
class SearchResult {
  final bool success;
  final List<SearchCandidate> candidates;
  final int total;
  final bool hasMore;
  final String message;

  SearchResult({
    required this.success,
    required this.candidates,
    required this.total,
    required this.hasMore,
    required this.message,
  });
}
