import 'dart:async';
import 'dart:collection';
import '../models/UserModel.dart';

/// Smart Profile Cache Service for optimized loading and memory management
class ProfileCacheService {
  static final ProfileCacheService _instance = ProfileCacheService._internal();
  factory ProfileCacheService() => _instance;
  ProfileCacheService._internal();

  // LRU Cache with maximum capacity
  static const int _maxCacheSize = 100;
  final LinkedHashMap<String, UserModel> _cache = LinkedHashMap();
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheExpiry = const Duration(hours: 2);

  // Pre-loading queue for smooth swiping
  final Set<String> _preloadingQueue = {};
  final Map<String, Completer<UserModel?>> _loadingCompleters = {};

  /// Add user to cache with LRU management
  void cacheUser(UserModel user) {
    final userId = user.id.toString();

    // Remove if exists to update position
    if (_cache.containsKey(userId)) {
      _cache.remove(userId);
    }

    // Add to end (most recently used)
    _cache[userId] = user;
    _cacheTimestamps[userId] = DateTime.now();

    // Maintain cache size limit
    while (_cache.length > _maxCacheSize) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
  }

  /// Get user from cache if available and not expired
  UserModel? getCachedUser(String userId) {
    final timestamp = _cacheTimestamps[userId];
    if (timestamp == null) return null;

    // Check if cache entry is expired
    if (DateTime.now().difference(timestamp) > _cacheExpiry) {
      _cache.remove(userId);
      _cacheTimestamps.remove(userId);
      return null;
    }

    // Move to end (mark as recently used)
    final user = _cache.remove(userId);
    if (user != null) {
      _cache[userId] = user;
    }

    return user;
  }

  /// Pre-load upcoming users for smooth swiping
  Future<void> preloadUsers(List<String> userIds) async {
    for (final userId in userIds) {
      if (!_cache.containsKey(userId) && !_preloadingQueue.contains(userId)) {
        _preloadingQueue.add(userId);
        _loadUserInBackground(userId);
      }
    }
  }

  /// Background user loading for pre-caching
  Future<void> _loadUserInBackground(String userId) async {
    if (_loadingCompleters.containsKey(userId)) {
      return; // Already loading
    }

    final completer = Completer<UserModel?>();
    _loadingCompleters[userId] = completer;

    try {
      // Simulate user loading (replace with actual API call)
      await Future.delayed(const Duration(milliseconds: 500));

      // In real implementation, this would be:
      // final user = await UserService.fetchUser(userId);
      // cacheUser(user);

      completer.complete(null);
    } catch (e) {
      completer.complete(null);
    } finally {
      _preloadingQueue.remove(userId);
      _loadingCompleters.remove(userId);
    }
  }

  /// Get cache statistics for performance monitoring
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    int expiredCount = 0;

    for (final timestamp in _cacheTimestamps.values) {
      if (now.difference(timestamp) > _cacheExpiry) {
        expiredCount++;
      }
    }

    return {
      'totalCached': _cache.length,
      'maxCapacity': _maxCacheSize,
      'expiredEntries': expiredCount,
      'preloadingCount': _preloadingQueue.length,
      'cacheUtilization': (_cache.length / _maxCacheSize * 100).toStringAsFixed(
        1,
      ),
    };
  }

  /// Clear expired entries manually
  void cleanupExpiredEntries() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _cacheExpiry) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Clear all cache
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    _preloadingQueue.clear();
    _loadingCompleters.clear();
  }

  /// Get cached user count for UI display
  int get cachedUserCount => _cache.length;

  /// Check if user is cached
  bool isUserCached(String userId) => _cache.containsKey(userId);
}
