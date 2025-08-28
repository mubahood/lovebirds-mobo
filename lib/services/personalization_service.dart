import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Personalization Service for Behavior-Based User Experience
class PersonalizationService {
  static final PersonalizationService _instance =
      PersonalizationService._internal();
  factory PersonalizationService() => _instance;
  PersonalizationService._internal();

  // User behavior tracking
  Map<String, int> _screenVisits = {};
  Map<String, int> _featureUsage = {};
  Map<String, double> _sessionDurations = {};

  // Engagement metrics
  int _totalSwipes = 0;
  int _totalLikes = 0;
  int _totalPasses = 0;
  int _totalSuperLikes = 0;
  int _totalMatches = 0;
  int _totalMessages = 0;
  double _averageSessionTime = 0.0;

  // Personalization settings
  bool _personalizedRecommendations = true;
  bool _adaptiveInterface = true;
  bool _smartNotifications = true;
  String _preferredTimeOfDay = 'evening'; // morning, afternoon, evening, night

  // User patterns
  String _userPersonalityType = 'balanced'; // active, casual, serious, balanced
  Map<String, dynamic> _behaviorInsights = {};

  // Getters
  Map<String, int> get screenVisits => _screenVisits;
  Map<String, int> get featureUsage => _featureUsage;
  int get totalSwipes => _totalSwipes;
  int get totalMatches => _totalMatches;
  double get averageSessionTime => _averageSessionTime;
  String get userPersonalityType => _userPersonalityType;
  bool get personalizedRecommendations => _personalizedRecommendations;

  /// Initialize personalization service
  Future<void> initialize() async {
    await _loadPersonalizationData();
    _analyzeUserBehavior();
  }

  /// Track screen visit
  void trackScreenVisit(String screenName) {
    _screenVisits[screenName] = (_screenVisits[screenName] ?? 0) + 1;
    _savePersonalizationData();
  }

  /// Track feature usage
  void trackFeatureUsage(String featureName) {
    _featureUsage[featureName] = (_featureUsage[featureName] ?? 0) + 1;
    _savePersonalizationData();
  }

  /// Track swipe action
  void trackSwipeAction(String action) {
    _totalSwipes++;

    switch (action) {
      case 'like':
        _totalLikes++;
        break;
      case 'pass':
        _totalPasses++;
        break;
      case 'super_like':
        _totalSuperLikes++;
        break;
    }

    _savePersonalizationData();
    _analyzeSwipeBehavior();
  }

  /// Track match
  void trackMatch() {
    _totalMatches++;
    _savePersonalizationData();
  }

  /// Track message sent
  void trackMessage() {
    _totalMessages++;
    _savePersonalizationData();
  }

  /// Track session duration
  void trackSessionDuration(String sessionType, double duration) {
    _sessionDurations[sessionType] = duration;
    _calculateAverageSessionTime();
    _savePersonalizationData();
  }

  /// Get personalized recommendations
  List<String> getPersonalizedRecommendations() {
    if (!_personalizedRecommendations) return [];

    List<String> recommendations = [];

    // Based on user personality type
    switch (_userPersonalityType) {
      case 'active':
        recommendations.addAll([
          'Try sending more super likes to stand out!',
          'Use the boost feature during peak hours for maximum visibility',
          'Complete your profile verification for better matches',
        ]);
        break;
      case 'casual':
        recommendations.addAll([
          'Browse the marketplace for fun date ideas',
          'Try the date planning feature with your matches',
          'Explore different conversation starters',
        ]);
        break;
      case 'serious':
        recommendations.addAll([
          'Use advanced filters to find compatible matches',
          'Complete your detailed profile for better compatibility',
          'Consider premium features for enhanced matching',
        ]);
        break;
      default:
        recommendations.addAll([
          'Keep swiping to find your perfect match!',
          'Try different features to enhance your experience',
          'Update your photos regularly for best results',
        ]);
    }

    // Based on usage patterns
    if (_featureUsage['chat'] != null && _featureUsage['chat']! > 10) {
      recommendations.add(
        'You\'re great at conversations! Try planning a date through the app',
      );
    }

    if (_totalMatches > 0 && _totalMessages == 0) {
      recommendations.add(
        'Start chatting with your matches to build connections',
      );
    }

    if (_totalSwipes > 50 && _totalMatches == 0) {
      recommendations.add(
        'Consider updating your profile or photos to get more matches',
      );
    }

    return recommendations.take(3).toList();
  }

  /// Get adaptive interface suggestions
  Map<String, dynamic> getAdaptiveInterfaceSettings() {
    if (!_adaptiveInterface) return {};

    Map<String, dynamic> settings = {};

    // Suggest feature shortcuts based on usage
    List<String> frequentFeatures = _getTopUsedFeatures(3);
    if (frequentFeatures.isNotEmpty) {
      settings['quickActions'] = frequentFeatures;
    }

    // Suggest optimal notification times
    if (_preferredTimeOfDay.isNotEmpty) {
      settings['optimalNotificationTime'] = _getOptimalNotificationTime();
    }

    // Suggest interface layout based on usage patterns
    int swipeVisits = _screenVisits['swipe'] ?? 0;
    int chatVisits = _screenVisits['chat'] ?? 0;

    if (swipeVisits > chatVisits) {
      settings['primaryTab'] = 'discover';
    } else if (chatVisits > 0) {
      settings['primaryTab'] = 'messages';
    }

    return settings;
  }

  /// Get smart notification preferences
  Map<String, dynamic> getSmartNotificationSettings() {
    if (!_smartNotifications) return {};

    return {
      'optimalTime': _getOptimalNotificationTime(),
      'frequency': _getOptimalNotificationFrequency(),
      'types': _getPreferredNotificationTypes(),
    };
  }

  /// Analyze user behavior and update personality type
  void _analyzeUserBehavior() {
    // Calculate engagement metrics
    double likeRate = _totalSwipes > 0 ? _totalLikes / _totalSwipes : 0.0;
    double matchRate = _totalLikes > 0 ? _totalMatches / _totalLikes : 0.0;
    double messageRate =
        _totalMatches > 0 ? _totalMessages / _totalMatches : 0.0;

    // Determine personality type based on behavior
    if (likeRate > 0.7 && _averageSessionTime > 15.0) {
      _userPersonalityType = 'active';
    } else if (likeRate < 0.3 && messageRate > 0.8) {
      _userPersonalityType = 'serious';
    } else if (_averageSessionTime < 5.0 && _featureUsage.length > 5) {
      _userPersonalityType = 'casual';
    } else {
      _userPersonalityType = 'balanced';
    }

    // Update behavior insights
    _behaviorInsights = {
      'likeRate': likeRate,
      'matchRate': matchRate,
      'messageRate': messageRate,
      'engagementLevel': _calculateEngagementLevel(),
      'primaryUsageTime': _preferredTimeOfDay,
      'topFeatures': _getTopUsedFeatures(5),
    };
  }

  /// Analyze swipe behavior for real-time suggestions
  void _analyzeSwipeBehavior() {
    if (_totalSwipes < 10) return;

    double likeRate = _totalLikes / _totalSwipes;

    if (likeRate > 0.8) {
      // User likes almost everyone - suggest being more selective
      _addBehaviorInsight(
        'suggestion',
        'Consider being more selective to improve match quality',
      );
    } else if (likeRate < 0.1) {
      // User is very picky - suggest adjusting preferences
      _addBehaviorInsight(
        'suggestion',
        'Consider expanding your preferences to find more matches',
      );
    }

    if (_totalSuperLikes > _totalLikes * 0.5) {
      // User uses too many super likes
      _addBehaviorInsight(
        'suggestion',
        'Save super likes for profiles you\'re most excited about',
      );
    }
  }

  /// Calculate engagement level
  String _calculateEngagementLevel() {
    int totalActions =
        _totalSwipes +
        _totalMessages +
        _featureUsage.values.fold(0, (sum, count) => sum + count);

    if (totalActions > 100 && _averageSessionTime > 10) {
      return 'high';
    } else if (totalActions > 50 || _averageSessionTime > 5) {
      return 'medium';
    } else {
      return 'low';
    }
  }

  /// Get top used features
  List<String> _getTopUsedFeatures(int count) {
    var sortedFeatures =
        _featureUsage.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sortedFeatures.take(count).map((e) => e.key).toList();
  }

  /// Get optimal notification time based on usage patterns
  String _getOptimalNotificationTime() {
    // Analyze session times to determine when user is most active
    // This would be enhanced with actual session timing data
    switch (_preferredTimeOfDay) {
      case 'morning':
        return '09:00';
      case 'afternoon':
        return '14:00';
      case 'evening':
        return '19:00';
      case 'night':
        return '21:00';
      default:
        return '19:00';
    }
  }

  /// Get optimal notification frequency
  String _getOptimalNotificationFrequency() {
    String engagementLevel = _calculateEngagementLevel();

    switch (engagementLevel) {
      case 'high':
        return 'frequent'; // Multiple times per day
      case 'medium':
        return 'daily'; // Once per day
      case 'low':
        return 'weekly'; // Few times per week
      default:
        return 'daily';
    }
  }

  /// Get preferred notification types
  List<String> _getPreferredNotificationTypes() {
    List<String> types = [];

    if (_totalMatches > 0) types.add('matches');
    if (_totalMessages > 0) types.add('messages');
    if (_featureUsage['boost'] != null) types.add('boost_reminders');
    if (_userPersonalityType == 'active') types.add('like_notifications');

    return types;
  }

  /// Calculate average session time
  void _calculateAverageSessionTime() {
    if (_sessionDurations.isEmpty) return;

    double total = _sessionDurations.values.fold(
      0.0,
      (sum, duration) => sum + duration,
    );
    _averageSessionTime = total / _sessionDurations.length;
  }

  /// Add behavior insight
  void _addBehaviorInsight(String type, String insight) {
    if (!_behaviorInsights.containsKey(type)) {
      _behaviorInsights[type] = [];
    }

    List<String> insights = List<String>.from(_behaviorInsights[type]);
    if (!insights.contains(insight)) {
      insights.add(insight);
      _behaviorInsights[type] = insights.take(3).toList(); // Keep only latest 3
    }
  }

  /// Update personalization settings
  Future<void> setPersonalizedRecommendations(bool enabled) async {
    _personalizedRecommendations = enabled;
    await _savePersonalizationData();
  }

  Future<void> setAdaptiveInterface(bool enabled) async {
    _adaptiveInterface = enabled;
    await _savePersonalizationData();
  }

  Future<void> setSmartNotifications(bool enabled) async {
    _smartNotifications = enabled;
    await _savePersonalizationData();
  }

  Future<void> setPreferredTimeOfDay(String timeOfDay) async {
    _preferredTimeOfDay = timeOfDay;
    await _savePersonalizationData();
  }

  /// Get personalization summary
  Map<String, dynamic> getPersonalizationSummary() {
    return {
      'personalityType': _userPersonalityType,
      'engagementLevel': _calculateEngagementLevel(),
      'totalSwipes': _totalSwipes,
      'totalMatches': _totalMatches,
      'averageSessionTime': _averageSessionTime,
      'topFeatures': _getTopUsedFeatures(3),
      'recommendations': getPersonalizedRecommendations(),
      'behaviorInsights': _behaviorInsights,
    };
  }

  /// Load personalization data from storage
  Future<void> _loadPersonalizationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load basic metrics
      _totalSwipes = prefs.getInt('personalization_total_swipes') ?? 0;
      _totalLikes = prefs.getInt('personalization_total_likes') ?? 0;
      _totalPasses = prefs.getInt('personalization_total_passes') ?? 0;
      _totalSuperLikes = prefs.getInt('personalization_total_super_likes') ?? 0;
      _totalMatches = prefs.getInt('personalization_total_matches') ?? 0;
      _totalMessages = prefs.getInt('personalization_total_messages') ?? 0;
      _averageSessionTime =
          prefs.getDouble('personalization_avg_session_time') ?? 0.0;

      // Load settings
      _personalizedRecommendations =
          prefs.getBool('personalization_recommendations') ?? true;
      _adaptiveInterface =
          prefs.getBool('personalization_adaptive_interface') ?? true;
      _smartNotifications =
          prefs.getBool('personalization_smart_notifications') ?? true;
      _preferredTimeOfDay =
          prefs.getString('personalization_preferred_time') ?? 'evening';
      _userPersonalityType =
          prefs.getString('personalization_personality_type') ?? 'balanced';

      // Load maps
      String? screenVisitsJson = prefs.getString(
        'personalization_screen_visits',
      );
      if (screenVisitsJson != null) {
        _screenVisits = Map<String, int>.from(jsonDecode(screenVisitsJson));
      }

      String? featureUsageJson = prefs.getString(
        'personalization_feature_usage',
      );
      if (featureUsageJson != null) {
        _featureUsage = Map<String, int>.from(jsonDecode(featureUsageJson));
      }

      String? sessionDurationsJson = prefs.getString(
        'personalization_session_durations',
      );
      if (sessionDurationsJson != null) {
        _sessionDurations = Map<String, double>.from(
          jsonDecode(sessionDurationsJson),
        );
      }

      String? behaviorInsightsJson = prefs.getString(
        'personalization_behavior_insights',
      );
      if (behaviorInsightsJson != null) {
        _behaviorInsights = Map<String, dynamic>.from(
          jsonDecode(behaviorInsightsJson),
        );
      }
    } catch (e) {
      debugPrint('Error loading personalization data: $e');
    }
  }

  /// Save personalization data to storage
  Future<void> _savePersonalizationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save basic metrics
      await prefs.setInt('personalization_total_swipes', _totalSwipes);
      await prefs.setInt('personalization_total_likes', _totalLikes);
      await prefs.setInt('personalization_total_passes', _totalPasses);
      await prefs.setInt('personalization_total_super_likes', _totalSuperLikes);
      await prefs.setInt('personalization_total_matches', _totalMatches);
      await prefs.setInt('personalization_total_messages', _totalMessages);
      await prefs.setDouble(
        'personalization_avg_session_time',
        _averageSessionTime,
      );

      // Save settings
      await prefs.setBool(
        'personalization_recommendations',
        _personalizedRecommendations,
      );
      await prefs.setBool(
        'personalization_adaptive_interface',
        _adaptiveInterface,
      );
      await prefs.setBool(
        'personalization_smart_notifications',
        _smartNotifications,
      );
      await prefs.setString(
        'personalization_preferred_time',
        _preferredTimeOfDay,
      );
      await prefs.setString(
        'personalization_personality_type',
        _userPersonalityType,
      );

      // Save maps
      await prefs.setString(
        'personalization_screen_visits',
        jsonEncode(_screenVisits),
      );
      await prefs.setString(
        'personalization_feature_usage',
        jsonEncode(_featureUsage),
      );
      await prefs.setString(
        'personalization_session_durations',
        jsonEncode(_sessionDurations),
      );
      await prefs.setString(
        'personalization_behavior_insights',
        jsonEncode(_behaviorInsights),
      );
    } catch (e) {
      debugPrint('Error saving personalization data: $e');
    }
  }

  /// Reset personalization data
  Future<void> resetPersonalizationData() async {
    _screenVisits.clear();
    _featureUsage.clear();
    _sessionDurations.clear();
    _behaviorInsights.clear();

    _totalSwipes = 0;
    _totalLikes = 0;
    _totalPasses = 0;
    _totalSuperLikes = 0;
    _totalMatches = 0;
    _totalMessages = 0;
    _averageSessionTime = 0.0;

    _userPersonalityType = 'balanced';
    _preferredTimeOfDay = 'evening';

    await _savePersonalizationData();
  }
}
