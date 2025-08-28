import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/RespondModel.dart';
import '../utils/Utilities.dart';

/// Comprehensive analytics integration service for performance tracking,
/// user behavior analysis, and business intelligence
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Analytics configuration
  static const String _analyticsEndpoint = 'api/analytics/track';
  static const String _userEventsKey = 'analytics_user_events';
  static const String _performanceKey = 'analytics_performance';
  static const String _conversionKey = 'analytics_conversion';

  // Session tracking
  String? _sessionId;
  DateTime? _sessionStart;
  Timer? _sessionTimer;
  int _eventCounter = 0;

  // Event batching
  final List<AnalyticsEvent> _eventQueue = [];
  Timer? _batchTimer;
  static const int _batchSize = 20;
  static const int _batchDelaySeconds = 30;

  // Performance tracking
  final Map<String, ScreenPerformanceMetrics> _screenMetrics = {};
  final Map<String, APIPerformanceMetrics> _apiMetrics = {};

  // User behavior tracking
  final Map<String, int> _featureUsage = {};
  final List<UserAction> _userJourney = [];

  /// Initialize analytics service
  Future<void> initialize() async {
    await _startNewSession();
    await _loadStoredData();
    _startBatchTimer();
    _startSessionTimer();
  }

  /// Start new analytics session
  Future<void> _startNewSession() async {
    _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _sessionStart = DateTime.now();

    await trackEvent(
      event: 'session_start',
      properties: {
        'session_id': _sessionId,
        'app_version': '1.0.0',
        'platform': 'mobile',
      },
    );
  }

  /// Track user event with properties
  Future<void> trackEvent({
    required String event,
    Map<String, dynamic>? properties,
    String? userId,
    bool immediate = false,
  }) async {
    final analyticsEvent = AnalyticsEvent(
      id: '${_sessionId}_${_eventCounter++}',
      event: event,
      properties: properties ?? {},
      userId: userId,
      timestamp: DateTime.now(),
      sessionId: _sessionId!,
    );

    _eventQueue.add(analyticsEvent);
    _addToUserJourney(event, properties);

    if (immediate || _eventQueue.length >= _batchSize) {
      await _sendEventBatch();
    }
  }

  /// Track screen view
  Future<void> trackScreenView({
    required String screenName,
    Map<String, dynamic>? properties,
    Duration? timeSpent,
  }) async {
    await trackEvent(
      event: 'screen_view',
      properties: {
        'screen_name': screenName,
        'time_spent_seconds': timeSpent?.inSeconds,
        ...?properties,
      },
    );

    // Update screen metrics
    if (!_screenMetrics.containsKey(screenName)) {
      _screenMetrics[screenName] = ScreenPerformanceMetrics(
        screenName: screenName,
      );
    }

    _screenMetrics[screenName]!.visits++;
    if (timeSpent != null) {
      _screenMetrics[screenName]!.totalTimeSpent += timeSpent;
      _screenMetrics[screenName]!.averageTimeSpent =
          _screenMetrics[screenName]!.totalTimeSpent ~/
          _screenMetrics[screenName]!.visits;
    }
  }

  /// Track swipe action for dating analytics
  Future<void> trackSwipeAction({
    required String action, // 'like', 'pass', 'super_like'
    required String targetUserId,
    Map<String, dynamic>? userProperties,
  }) async {
    await trackEvent(
      event: 'swipe_action',
      properties: {
        'action': action,
        'target_user_id': targetUserId,
        'user_properties': userProperties,
      },
    );

    _updateFeatureUsage('swipe_$action');
  }

  /// Track match event
  Future<void> trackMatch({
    required String matchedUserId,
    required String matchType, // 'mutual_like', 'super_like_match'
    Map<String, dynamic>? matchProperties,
  }) async {
    await trackEvent(
      event: 'match_created',
      properties: {
        'matched_user_id': matchedUserId,
        'match_type': matchType,
        'match_properties': matchProperties,
      },
    );

    _updateFeatureUsage('matches');
  }

  /// Track message sent
  Future<void> trackMessage({
    required String conversationId,
    required String messageType,
    int? characterCount,
  }) async {
    await trackEvent(
      event: 'message_sent',
      properties: {
        'conversation_id': conversationId,
        'message_type': messageType,
        'character_count': characterCount,
      },
    );

    _updateFeatureUsage('messaging');
  }

  /// Track subscription event
  Future<void> trackSubscription({
    required String action, // 'subscribe', 'cancel', 'upgrade', 'downgrade'
    required String plan,
    double? amount,
    String? currency,
  }) async {
    await trackEvent(
      event: 'subscription_$action',
      properties: {'plan': plan, 'amount': amount, 'currency': currency},
      immediate: true, // Critical revenue event
    );

    _updateFeatureUsage('subscription_$action');
  }

  /// Track marketplace purchase
  Future<void> trackPurchase({
    required String productId,
    required double amount,
    required String currency,
    String? category,
    Map<String, dynamic>? productProperties,
  }) async {
    await trackEvent(
      event: 'purchase_completed',
      properties: {
        'product_id': productId,
        'amount': amount,
        'currency': currency,
        'category': category,
        'product_properties': productProperties,
      },
      immediate: true, // Critical revenue event
    );

    _updateFeatureUsage('marketplace_purchase');
  }

  /// Track API performance
  Future<void> trackAPIPerformance({
    required String endpoint,
    required int durationMs,
    required bool success,
    int? statusCode,
    String? errorMessage,
  }) async {
    // Update internal metrics
    if (!_apiMetrics.containsKey(endpoint)) {
      _apiMetrics[endpoint] = APIPerformanceMetrics(endpoint: endpoint);
    }

    final metrics = _apiMetrics[endpoint]!;
    metrics.totalRequests++;

    if (success) {
      metrics.successfulRequests++;
      metrics.totalDuration += durationMs;
      metrics.averageDuration =
          metrics.totalDuration / metrics.successfulRequests;
    } else {
      metrics.failedRequests++;
    }

    // Track critical performance issues
    if (durationMs > 5000 || !success) {
      await trackEvent(
        event: 'api_performance_issue',
        properties: {
          'endpoint': endpoint,
          'duration_ms': durationMs,
          'success': success,
          'status_code': statusCode,
          'error_message': errorMessage,
        },
      );
    }
  }

  /// Track user conversion funnel
  Future<void> trackConversion({
    required String funnelStep,
    required String funnelName,
    Map<String, dynamic>? conversionProperties,
  }) async {
    await trackEvent(
      event: 'conversion_funnel',
      properties: {
        'funnel_name': funnelName,
        'funnel_step': funnelStep,
        'conversion_properties': conversionProperties,
      },
    );
  }

  /// Track app launch performance
  Future<void> trackAppLaunch({
    required int coldStartMs,
    required int warmStartMs,
    required String launchType,
  }) async {
    await trackEvent(
      event: 'app_launch',
      properties: {
        'cold_start_ms': coldStartMs,
        'warm_start_ms': warmStartMs,
        'launch_type': launchType,
      },
    );
  }

  /// Track feature usage
  void _updateFeatureUsage(String feature) {
    _featureUsage[feature] = (_featureUsage[feature] ?? 0) + 1;
  }

  /// Add action to user journey
  void _addToUserJourney(String event, Map<String, dynamic>? properties) {
    _userJourney.add(
      UserAction(
        event: event,
        properties: properties ?? {},
        timestamp: DateTime.now(),
      ),
    );

    // Keep only last 100 actions to prevent memory issues
    if (_userJourney.length > 100) {
      _userJourney.removeAt(0);
    }
  }

  /// Send batch of events to analytics endpoint
  Future<void> _sendEventBatch() async {
    if (_eventQueue.isEmpty) return;

    final eventsToSend = List<AnalyticsEvent>.from(_eventQueue);
    _eventQueue.clear();

    try {
      final response = await Utils.http_post(_analyticsEndpoint, {
        'events': eventsToSend.map((e) => e.toJson()).toList(),
        'session_id': _sessionId,
        'batch_size': eventsToSend.length,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      final respondModel = RespondModel(response);

      if (respondModel.code != 1) {
        // Re-queue events if sending failed
        _eventQueue.insertAll(0, eventsToSend);
      }
    } catch (e) {
      // Re-queue events if sending failed
      _eventQueue.insertAll(0, eventsToSend);
    }
  }

  /// Start batch timer for automatic event sending
  void _startBatchTimer() {
    _batchTimer = Timer.periodic(
      Duration(seconds: _batchDelaySeconds),
      (timer) => _sendEventBatch(),
    );
  }

  /// Start session timer for periodic session updates
  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _updateSessionMetrics(),
    );
  }

  /// Update session metrics
  Future<void> _updateSessionMetrics() async {
    if (_sessionStart == null) return;

    final sessionDuration = DateTime.now().difference(_sessionStart!);

    await trackEvent(
      event: 'session_heartbeat',
      properties: {
        'session_duration_minutes': sessionDuration.inMinutes,
        'events_count': _eventCounter,
        'screens_visited': _screenMetrics.length,
      },
    );
  }

  /// Get analytics dashboard data
  Future<Map<String, dynamic>> getAnalyticsDashboard() async {
    await _sendEventBatch(); // Ensure latest data is sent

    try {
      final response = await Utils.http_get('api/analytics/dashboard', {});
      final respondModel = RespondModel(response);

      if (respondModel.code == 1 && respondModel.data != null) {
        return respondModel.data;
      }
    } catch (e) {
      // Return local data if server unavailable
    }

    return _getLocalAnalytics();
  }

  /// Get local analytics data
  Map<String, dynamic> _getLocalAnalytics() {
    final sessionDuration =
        _sessionStart != null
            ? DateTime.now().difference(_sessionStart!).inMinutes
            : 0;

    return {
      'session': {
        'session_id': _sessionId,
        'duration_minutes': sessionDuration,
        'events_count': _eventCounter,
        'start_time': _sessionStart?.toIso8601String(),
      },
      'feature_usage': Map.from(_featureUsage),
      'screen_metrics': _screenMetrics.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'api_metrics': _apiMetrics.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'user_journey': _userJourney.map((action) => action.toJson()).toList(),
    };
  }

  /// Get performance insights
  Map<String, dynamic> getPerformanceInsights() {
    final slowAPIs =
        _apiMetrics.values
            .where((metric) => metric.averageDuration > 3000)
            .map((metric) => metric.toJson())
            .toList();

    final popularScreens =
        _screenMetrics.entries.toList()
          ..sort((a, b) => b.value.visits.compareTo(a.value.visits));

    final topFeatures =
        _featureUsage.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'slow_apis': slowAPIs,
      'popular_screens':
          popularScreens
              .take(10)
              .map(
                (e) => {
                  'screen': e.key,
                  'visits': e.value.visits,
                  'avg_time_seconds': e.value.averageTimeSpent.inSeconds,
                },
              )
              .toList(),
      'top_features':
          topFeatures
              .take(10)
              .map((e) => {'feature': e.key, 'usage_count': e.value})
              .toList(),
    };
  }

  /// Load stored analytics data
  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load feature usage
    final featureUsageJson = prefs.getString(_userEventsKey);
    if (featureUsageJson != null) {
      try {
        final data = jsonDecode(featureUsageJson);
        _featureUsage.addAll(Map<String, int>.from(data));
      } catch (e) {
        // Ignore corrupted data
      }
    }
  }

  /// Save analytics data to storage
  Future<void> _saveAnalyticsData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save feature usage
    final featureUsageJson = jsonEncode(_featureUsage);
    await prefs.setString(_userEventsKey, featureUsageJson);
  }

  /// Force send all pending events
  Future<void> flushEvents() async {
    await _sendEventBatch();
  }

  /// End current session
  Future<void> endSession() async {
    await _updateSessionMetrics();

    await trackEvent(
      event: 'session_end',
      properties: {
        'session_duration_minutes':
            _sessionStart != null
                ? DateTime.now().difference(_sessionStart!).inMinutes
                : 0,
        'total_events': _eventCounter,
      },
      immediate: true,
    );

    await _saveAnalyticsData();
  }

  /// Clear all analytics data
  Future<void> clearAnalyticsData() async {
    _eventQueue.clear();
    _screenMetrics.clear();
    _apiMetrics.clear();
    _featureUsage.clear();
    _userJourney.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEventsKey);
    await prefs.remove(_performanceKey);
    await prefs.remove(_conversionKey);
  }

  /// Dispose resources
  void dispose() {
    _batchTimer?.cancel();
    _sessionTimer?.cancel();
  }
}

/// Analytics event model
class AnalyticsEvent {
  final String id;
  final String event;
  final Map<String, dynamic> properties;
  final String? userId;
  final DateTime timestamp;
  final String sessionId;

  AnalyticsEvent({
    required this.id,
    required this.event,
    required this.properties,
    this.userId,
    required this.timestamp,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': event,
      'properties': properties,
      'user_id': userId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'session_id': sessionId,
    };
  }
}

/// User action model for journey tracking
class UserAction {
  final String event;
  final Map<String, dynamic> properties;
  final DateTime timestamp;

  UserAction({
    required this.event,
    required this.properties,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'properties': properties,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

/// Screen performance metrics
class ScreenPerformanceMetrics {
  final String screenName;
  int visits = 0;
  Duration totalTimeSpent = Duration.zero;
  Duration averageTimeSpent = Duration.zero;

  ScreenPerformanceMetrics({required this.screenName});

  Map<String, dynamic> toJson() {
    return {
      'screen_name': screenName,
      'visits': visits,
      'total_time_spent_seconds': totalTimeSpent.inSeconds,
      'average_time_spent_seconds': averageTimeSpent.inSeconds,
    };
  }
}

/// API performance metrics
class APIPerformanceMetrics {
  final String endpoint;
  int totalRequests = 0;
  int successfulRequests = 0;
  int failedRequests = 0;
  int totalDuration = 0;
  double averageDuration = 0.0;

  APIPerformanceMetrics({required this.endpoint});

  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'total_requests': totalRequests,
      'successful_requests': successfulRequests,
      'failed_requests': failedRequests,
      'average_duration_ms': averageDuration.toStringAsFixed(2),
      'success_rate':
          totalRequests > 0
              ? ((successfulRequests / totalRequests) * 100).toStringAsFixed(2)
              : '0.00',
    };
  }
}
