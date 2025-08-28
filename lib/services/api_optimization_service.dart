import 'dart:async';
import 'dart:convert';
import '../utils/Utilities.dart';
import '../models/RespondModel.dart';

/// Advanced API optimization service with intelligent batching,
/// request deduplication, and performance monitoring
class APIOptimizationService {
  static final APIOptimizationService _instance =
      APIOptimizationService._internal();
  factory APIOptimizationService() => _instance;
  APIOptimizationService._internal();

  // Batch processing configuration
  static const int _batchSize = 10;
  static const int _batchDelayMs = 500;
  static const int _maxRetries = 3;
  static const int _cacheExpiryMinutes = 30;

  // Request batching queues
  final Map<String, List<BatchRequest>> _batchQueues = {};
  final Map<String, Timer> _batchTimers = {};

  // Request deduplication
  final Map<String, Completer<RespondModel>> _pendingRequests = {};

  // Performance analytics
  final Map<String, APIPerformanceMetrics> _performanceMetrics = {};

  // Request caching
  final Map<String, CachedResponse> _responseCache = {};

  /// Batch multiple API requests for optimal performance
  Future<RespondModel> batchRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    int priority = 1,
  }) async {
    final requestKey = _generateRequestKey(endpoint, method, data);

    // Check for duplicate requests
    if (_pendingRequests.containsKey(requestKey)) {
      return await _pendingRequests[requestKey]!.future;
    }

    // Check cache first
    final cachedResponse = _getCachedResponse(requestKey);
    if (cachedResponse != null) {
      _updatePerformanceMetrics(endpoint, 0, true);
      return cachedResponse;
    }

    final completer = Completer<RespondModel>();
    _pendingRequests[requestKey] = completer;

    final batchRequest = BatchRequest(
      endpoint: endpoint,
      method: method,
      data: data,
      headers: headers,
      priority: priority,
      completer: completer,
      requestKey: requestKey,
      timestamp: DateTime.now(),
    );

    _addToBatch(endpoint, batchRequest);
    return await completer.future;
  }

  /// Add request to appropriate batch queue
  void _addToBatch(String endpoint, BatchRequest request) {
    final batchKey = _getBatchKey(endpoint);

    if (!_batchQueues.containsKey(batchKey)) {
      _batchQueues[batchKey] = [];
    }

    _batchQueues[batchKey]!.add(request);

    // Sort by priority (higher priority first)
    _batchQueues[batchKey]!.sort((a, b) => b.priority.compareTo(a.priority));

    // Process batch if size limit reached
    if (_batchQueues[batchKey]!.length >= _batchSize) {
      _processBatch(batchKey);
    } else {
      _scheduleDelayedBatch(batchKey);
    }
  }

  /// Schedule delayed batch processing
  void _scheduleDelayedBatch(String batchKey) {
    _batchTimers[batchKey]?.cancel();
    _batchTimers[batchKey] = Timer(
      Duration(milliseconds: _batchDelayMs),
      () => _processBatch(batchKey),
    );
  }

  /// Process batch of requests
  Future<void> _processBatch(String batchKey) async {
    final batch = _batchQueues[batchKey];
    if (batch == null || batch.isEmpty) return;

    _batchTimers[batchKey]?.cancel();
    _batchQueues[batchKey] = [];

    // Group requests by type for parallel processing
    final getRequests =
        batch.where((r) => r.method.toUpperCase() == 'GET').toList();
    final postRequests =
        batch.where((r) => r.method.toUpperCase() == 'POST').toList();

    // Process GET requests in parallel
    if (getRequests.isNotEmpty) {
      await _processGetBatch(getRequests);
    }

    // Process POST requests sequentially (to maintain order)
    if (postRequests.isNotEmpty) {
      await _processPostBatch(postRequests);
    }
  }

  /// Process batch of GET requests in parallel
  Future<void> _processGetBatch(List<BatchRequest> requests) async {
    final futures = requests.map((request) => _executeRequest(request));
    await Future.wait(futures);
  }

  /// Process batch of POST requests sequentially
  Future<void> _processPostBatch(List<BatchRequest> requests) async {
    for (final request in requests) {
      await _executeRequest(request);
    }
  }

  /// Execute individual request with retry logic
  Future<void> _executeRequest(BatchRequest request) async {
    final startTime = DateTime.now();
    int retryCount = 0;

    while (retryCount <= _maxRetries) {
      try {
        dynamic rawResponse;

        if (request.method.toUpperCase() == 'GET') {
          rawResponse = await Utils.http_get(
            request.endpoint,
            request.data ?? {},
          );
        } else {
          rawResponse = await Utils.http_post(
            request.endpoint,
            request.data ?? {},
          );
        }

        final response = RespondModel(rawResponse);

        // Cache successful responses
        if (response.code == 1) {
          _cacheResponse(request.requestKey, response);
        }

        // Update performance metrics
        final duration = DateTime.now().difference(startTime).inMilliseconds;
        _updatePerformanceMetrics(request.endpoint, duration, false);

        // Complete the request
        if (!request.completer.isCompleted) {
          request.completer.complete(response);
        }

        _pendingRequests.remove(request.requestKey);
        return;
      } catch (error) {
        retryCount++;

        if (retryCount > _maxRetries) {
          // Failed after all retries
          final errorResponse = RespondModel({
            'code': 0,
            'message': 'Request failed after $retryCount retries: $error',
            'data': null,
          });

          if (!request.completer.isCompleted) {
            request.completer.complete(errorResponse);
          }

          _pendingRequests.remove(request.requestKey);

          // Update performance metrics for failed request
          final duration = DateTime.now().difference(startTime).inMilliseconds;
          _updatePerformanceMetrics(
            request.endpoint,
            duration,
            false,
            failed: true,
          );
        } else {
          // Wait before retry with exponential backoff
          await Future.delayed(Duration(milliseconds: 1000 * retryCount));
        }
      }
    }
  }

  /// Generate unique request key for deduplication
  String _generateRequestKey(
    String endpoint,
    String method,
    Map<String, dynamic>? data,
  ) {
    final dataString = data != null ? jsonEncode(data) : '';
    return '${method.toUpperCase()}_${endpoint}_${dataString.hashCode}';
  }

  /// Get batch key for grouping similar requests
  String _getBatchKey(String endpoint) {
    // Group by endpoint base (remove parameters)
    final baseEndpoint = endpoint.split('?').first;
    return baseEndpoint.replaceAll('/', '_');
  }

  /// Cache response for future use
  void _cacheResponse(String requestKey, RespondModel response) {
    _responseCache[requestKey] = CachedResponse(
      response: response,
      timestamp: DateTime.now(),
    );

    // Clean up old cache entries
    _cleanupCache();
  }

  /// Get cached response if available and not expired
  RespondModel? _getCachedResponse(String requestKey) {
    final cached = _responseCache[requestKey];
    if (cached == null) return null;

    final isExpired =
        DateTime.now().difference(cached.timestamp).inMinutes >
        _cacheExpiryMinutes;
    if (isExpired) {
      _responseCache.remove(requestKey);
      return null;
    }

    return cached.response;
  }

  /// Clean up expired cache entries
  void _cleanupCache() {
    final now = DateTime.now();
    _responseCache.removeWhere((key, cached) {
      return now.difference(cached.timestamp).inMinutes > _cacheExpiryMinutes;
    });
  }

  /// Update performance metrics
  void _updatePerformanceMetrics(
    String endpoint,
    int durationMs,
    bool fromCache, {
    bool failed = false,
  }) {
    if (!_performanceMetrics.containsKey(endpoint)) {
      _performanceMetrics[endpoint] = APIPerformanceMetrics(endpoint: endpoint);
    }

    final metrics = _performanceMetrics[endpoint]!;
    metrics.totalRequests++;

    if (failed) {
      metrics.failedRequests++;
    } else if (fromCache) {
      metrics.cacheHits++;
    } else {
      metrics.networkRequests++;
      metrics.totalDuration += durationMs;
      metrics.averageDuration = metrics.totalDuration / metrics.networkRequests;

      if (durationMs > metrics.maxDuration) {
        metrics.maxDuration = durationMs;
      }

      if (metrics.minDuration == 0 || durationMs < metrics.minDuration) {
        metrics.minDuration = durationMs;
      }
    }
  }

  /// Get performance analytics for specific endpoint
  APIPerformanceMetrics? getPerformanceMetrics(String endpoint) {
    return _performanceMetrics[endpoint];
  }

  /// Get all performance metrics
  Map<String, APIPerformanceMetrics> getAllPerformanceMetrics() {
    return Map.from(_performanceMetrics);
  }

  /// Clear all caches and reset metrics
  void clearCache() {
    _responseCache.clear();
    _performanceMetrics.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStatistics() {
    final totalEntries = _responseCache.length;
    final totalMemoryKB =
        _responseCache.values
            .map(
              (cached) =>
                  jsonEncode({
                    'code': cached.response.code,
                    'message': cached.response.message,
                    'data': cached.response.data,
                  }).length,
            )
            .fold(0, (sum, size) => sum + size) /
        1024;

    return {
      'total_entries': totalEntries,
      'memory_usage_kb': totalMemoryKB.toStringAsFixed(2),
      'cache_hit_rate': _calculateOverallCacheHitRate(),
    };
  }

  /// Calculate overall cache hit rate
  double _calculateOverallCacheHitRate() {
    int totalRequests = 0;
    int totalCacheHits = 0;

    for (final metrics in _performanceMetrics.values) {
      totalRequests += metrics.totalRequests;
      totalCacheHits += metrics.cacheHits;
    }

    return totalRequests > 0 ? (totalCacheHits / totalRequests) * 100 : 0.0;
  }

  /// Force process all pending batches (useful for app backgrounding)
  Future<void> flushAllBatches() async {
    final batchKeys = List.from(_batchQueues.keys);
    final futures = batchKeys.map((key) => _processBatch(key));
    await Future.wait(futures);
  }

  /// Cleanup resources
  void dispose() {
    for (final timer in _batchTimers.values) {
      timer.cancel();
    }
    _batchTimers.clear();
    _batchQueues.clear();
    _pendingRequests.clear();
  }
}

/// Batch request model
class BatchRequest {
  final String endpoint;
  final String method;
  final Map<String, dynamic>? data;
  final Map<String, String>? headers;
  final int priority;
  final Completer<RespondModel> completer;
  final String requestKey;
  final DateTime timestamp;

  BatchRequest({
    required this.endpoint,
    required this.method,
    this.data,
    this.headers,
    required this.priority,
    required this.completer,
    required this.requestKey,
    required this.timestamp,
  });
}

/// Cached response model
class CachedResponse {
  final RespondModel response;
  final DateTime timestamp;

  CachedResponse({required this.response, required this.timestamp});
}

/// API performance metrics model
class APIPerformanceMetrics {
  final String endpoint;
  int totalRequests = 0;
  int networkRequests = 0;
  int cacheHits = 0;
  int failedRequests = 0;
  int totalDuration = 0;
  double averageDuration = 0.0;
  int maxDuration = 0;
  int minDuration = 0;

  APIPerformanceMetrics({required this.endpoint});

  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'total_requests': totalRequests,
      'network_requests': networkRequests,
      'cache_hits': cacheHits,
      'failed_requests': failedRequests,
      'average_duration_ms': averageDuration.toStringAsFixed(2),
      'max_duration_ms': maxDuration,
      'min_duration_ms': minDuration,
      'cache_hit_rate':
          totalRequests > 0
              ? ((cacheHits / totalRequests) * 100).toStringAsFixed(2)
              : '0.00',
      'success_rate':
          totalRequests > 0
              ? (((totalRequests - failedRequests) / totalRequests) * 100)
                  .toStringAsFixed(2)
              : '0.00',
    };
  }
}
