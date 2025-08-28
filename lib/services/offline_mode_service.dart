import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/RespondModel.dart';
import '../utils/Utilities.dart';

/// Comprehensive offline mode service for basic app functionality
/// Provides data persistence, sync management, and offline-first experience
class OfflineModeService {
  static final OfflineModeService _instance = OfflineModeService._internal();
  factory OfflineModeService() => _instance;
  OfflineModeService._internal();

  // Offline storage keys
  static const String _offlineProfilesKey = 'offline_profiles';
  static const String _offlineMatchesKey = 'offline_matches';
  static const String _offlineMessagesKey = 'offline_messages';
  static const String _offlineSettingsKey = 'offline_settings';
  static const String _pendingActionsKey = 'pending_actions';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _offlineStatusKey = 'offline_mode_enabled';

  // Connectivity monitoring
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isOnline = true;
  bool _offlineModeEnabled = false;

  // Sync management
  final List<PendingAction> _pendingActions = [];
  Timer? _syncTimer;
  bool _isSyncing = false;

  // Data cache
  final Map<String, CachedData> _offlineCache = {};

  // Random string generator
  static const String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String _getRandomString(int length) => String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
    ),
  );

  /// Initialize offline mode service
  Future<void> initialize() async {
    await _loadOfflineSettings();
    await _loadPendingActions();
    await _loadOfflineCache();

    _startConnectivityMonitoring();
    _startPeriodicSync();
  }

  /// Check if app is currently online
  bool get isOnline => _isOnline;

  /// Check if offline mode is enabled
  bool get isOfflineModeEnabled => _offlineModeEnabled;

  /// Get pending actions count
  int get pendingActionsCount => _pendingActions.length;

  /// Enable/disable offline mode
  Future<void> setOfflineModeEnabled(bool enabled) async {
    _offlineModeEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineStatusKey, enabled);

    if (enabled && _isOnline) {
      await _performFullDataSync();
    }
  }

  /// Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    // Use Utils.is_connected() to check connectivity periodically
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      final wasOffline = !_isOnline;
      _isOnline = await Utils.is_connected();

      if (wasOffline && _isOnline && _offlineModeEnabled) {
        // Coming back online - sync pending actions
        await _syncPendingActions();
      }
    });
  }

  /// Start periodic sync when online
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (_isOnline && _offlineModeEnabled && !_isSyncing) {
        await _performIncrementalSync();
      }
    });
  }

  /// Store data for offline access
  Future<void> cacheData(String key, dynamic data, {Duration? expiry}) async {
    final expiryTime =
        expiry != null
            ? DateTime.now().add(expiry)
            : DateTime.now().add(const Duration(hours: 24));

    _offlineCache[key] = CachedData(
      data: data,
      timestamp: DateTime.now(),
      expiry: expiryTime,
    );

    await _saveOfflineCache();
  }

  /// Retrieve cached data for offline use
  T? getCachedData<T>(String key) {
    final cached = _offlineCache[key];
    if (cached == null) return null;

    // Check if data has expired
    if (DateTime.now().isAfter(cached.expiry)) {
      _offlineCache.remove(key);
      _saveOfflineCache();
      return null;
    }

    return cached.data as T?;
  }

  /// Cache user profiles for offline browsing
  Future<void> cacheProfiles(List<dynamic> profiles) async {
    await cacheData(
      _offlineProfilesKey,
      profiles,
      expiry: const Duration(hours: 6),
    );
  }

  /// Get cached profiles for offline browsing
  List<dynamic> getCachedProfiles() {
    return getCachedData<List<dynamic>>(_offlineProfilesKey) ?? [];
  }

  /// Cache matches for offline viewing
  Future<void> cacheMatches(List<dynamic> matches) async {
    await cacheData(
      _offlineMatchesKey,
      matches,
      expiry: const Duration(hours: 12),
    );
  }

  /// Get cached matches
  List<dynamic> getCachedMatches() {
    return getCachedData<List<dynamic>>(_offlineMatchesKey) ?? [];
  }

  /// Cache messages for offline reading
  Future<void> cacheMessages(
    String conversationId,
    List<dynamic> messages,
  ) async {
    final key = '${_offlineMessagesKey}_$conversationId';
    await cacheData(key, messages, expiry: const Duration(hours: 24));
  }

  /// Get cached messages for a conversation
  List<dynamic> getCachedMessages(String conversationId) {
    final key = '${_offlineMessagesKey}_$conversationId';
    return getCachedData<List<dynamic>>(key) ?? [];
  }

  /// Add action to pending queue for later sync
  Future<void> addPendingAction(PendingAction action) async {
    _pendingActions.add(action);
    await _savePendingActions();
  }

  /// Record a swipe action for later sync
  Future<void> recordOfflineSwipe({
    required String userId,
    required String action, // 'like', 'pass', 'super_like'
    Map<String, dynamic>? metadata,
  }) async {
    final pendingAction = PendingAction(
      id: _getRandomString(12),
      type: 'swipe',
      endpoint: 'api/dating/swipe',
      data: {'user_id': userId, 'action': action, 'metadata': metadata},
      timestamp: DateTime.now(),
    );

    await addPendingAction(pendingAction);
  }

  /// Record a message for later sync
  Future<void> recordOfflineMessage({
    required String conversationId,
    required String message,
    required String type,
  }) async {
    final pendingAction = PendingAction(
      id: _getRandomString(12),
      type: 'message',
      endpoint: 'api/chat/send',
      data: {
        'conversation_id': conversationId,
        'message': message,
        'type': type,
      },
      timestamp: DateTime.now(),
    );

    await addPendingAction(pendingAction);
  }

  /// Record profile update for later sync
  Future<void> recordOfflineProfileUpdate(
    Map<String, dynamic> profileData,
  ) async {
    final pendingAction = PendingAction(
      id: _getRandomString(12),
      type: 'profile_update',
      endpoint: 'api/profile/update',
      data: profileData,
      timestamp: DateTime.now(),
    );

    await addPendingAction(pendingAction);
  }

  /// Sync all pending actions when online
  Future<bool> _syncPendingActions() async {
    if (!_isOnline || _isSyncing) return false;

    _isSyncing = true;
    bool allSynced = true;

    try {
      final actionsToSync = List<PendingAction>.from(_pendingActions);

      for (final action in actionsToSync) {
        try {
          final response = await Utils.http_post(action.endpoint, action.data);
          final respondModel = RespondModel(response);

          if (respondModel.code == 1) {
            // Successfully synced - remove from pending
            _pendingActions.removeWhere((a) => a.id == action.id);
          } else {
            allSynced = false;
          }
        } catch (e) {
          allSynced = false;
          // Keep action in queue for next sync attempt
        }
      }

      await _savePendingActions();

      if (allSynced) {
        await _updateLastSyncTimestamp();
      }
    } finally {
      _isSyncing = false;
    }

    return allSynced;
  }

  /// Perform full data sync for offline mode
  Future<void> _performFullDataSync() async {
    if (!_isOnline || _isSyncing) return;

    _isSyncing = true;

    try {
      // Sync profiles for offline browsing
      await _syncProfilesForOffline();

      // Sync matches
      await _syncMatchesForOffline();

      // Sync recent messages
      await _syncMessagesForOffline();

      // Sync user settings
      await _syncUserSettings();

      await _updateLastSyncTimestamp();
    } finally {
      _isSyncing = false;
    }
  }

  /// Perform incremental sync
  Future<void> _performIncrementalSync() async {
    // Sync pending actions first
    await _syncPendingActions();

    // Check if enough time has passed for data refresh
    final lastSync = await _getLastSyncTimestamp();
    final timeSinceSync = DateTime.now().difference(lastSync);

    if (timeSinceSync.inMinutes >= 30) {
      await _performFullDataSync();
    }
  }

  /// Sync profiles for offline browsing
  Future<void> _syncProfilesForOffline() async {
    try {
      final response = await Utils.http_get('api/dating/discover', {});
      final respondModel = RespondModel(response);

      if (respondModel.code == 1 && respondModel.data != null) {
        await cacheProfiles(respondModel.data);
      }
    } catch (e) {
      // Sync failed - keep existing cache
    }
  }

  /// Sync matches for offline viewing
  Future<void> _syncMatchesForOffline() async {
    try {
      final response = await Utils.http_get('api/dating/matches', {});
      final respondModel = RespondModel(response);

      if (respondModel.code == 1 && respondModel.data != null) {
        await cacheMatches(respondModel.data);
      }
    } catch (e) {
      // Sync failed - keep existing cache
    }
  }

  /// Sync messages for offline reading
  Future<void> _syncMessagesForOffline() async {
    final matches = getCachedMatches();

    for (final match in matches) {
      try {
        final conversationId = match['conversation_id']?.toString();
        if (conversationId != null) {
          final response = await Utils.http_get('api/chat/messages', {
            'conversation_id': conversationId,
            'limit': '50',
          });

          final respondModel = RespondModel(response);
          if (respondModel.code == 1 && respondModel.data != null) {
            await cacheMessages(conversationId, respondModel.data);
          }
        }
      } catch (e) {
        // Continue with next conversation
      }
    }
  }

  /// Sync user settings
  Future<void> _syncUserSettings() async {
    try {
      final response = await Utils.http_get('api/user/settings', {});
      final respondModel = RespondModel(response);

      if (respondModel.code == 1 && respondModel.data != null) {
        await cacheData(_offlineSettingsKey, respondModel.data);
      }
    } catch (e) {
      // Sync failed - keep existing settings
    }
  }

  /// Force sync now (user-triggered)
  Future<bool> forceSyncNow() async {
    if (!_isOnline) return false;

    await _performFullDataSync();
    return await _syncPendingActions();
  }

  /// Get offline mode statistics
  Map<String, dynamic> getOfflineStatistics() {
    final totalCachedItems = _offlineCache.length;
    final pendingActions = _pendingActions.length;
    final cacheSize = _calculateCacheSize();

    return {
      'is_online': _isOnline,
      'offline_mode_enabled': _offlineModeEnabled,
      'cached_items': totalCachedItems,
      'pending_actions': pendingActions,
      'cache_size_kb': cacheSize.toStringAsFixed(2),
      'last_sync': _getLastSyncTimestamp(),
      'cached_profiles': getCachedProfiles().length,
      'cached_matches': getCachedMatches().length,
    };
  }

  /// Calculate total cache size
  double _calculateCacheSize() {
    double totalSize = 0;

    for (final cached in _offlineCache.values) {
      try {
        final jsonString = jsonEncode(cached.data);
        totalSize += jsonString.length / 1024; // Convert to KB
      } catch (e) {
        // Skip items that can't be serialized
      }
    }

    return totalSize;
  }

  /// Clear all offline data
  Future<void> clearOfflineData() async {
    _offlineCache.clear();
    _pendingActions.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_offlineProfilesKey);
    await prefs.remove(_offlineMatchesKey);
    await prefs.remove(_offlineMessagesKey);
    await prefs.remove(_offlineSettingsKey);
    await prefs.remove(_pendingActionsKey);
    await prefs.remove(_lastSyncKey);
  }

  /// Load offline settings
  Future<void> _loadOfflineSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _offlineModeEnabled = prefs.getBool(_offlineStatusKey) ?? false;
  }

  /// Load pending actions from storage
  Future<void> _loadPendingActions() async {
    final prefs = await SharedPreferences.getInstance();
    final actionsJson = prefs.getString(_pendingActionsKey);

    if (actionsJson != null) {
      try {
        final List<dynamic> actionsList = jsonDecode(actionsJson);
        _pendingActions.clear();

        for (final actionData in actionsList) {
          _pendingActions.add(PendingAction.fromJson(actionData));
        }
      } catch (e) {
        // Clear corrupted data
        await prefs.remove(_pendingActionsKey);
      }
    }
  }

  /// Save pending actions to storage
  Future<void> _savePendingActions() async {
    final prefs = await SharedPreferences.getInstance();
    final actionsJson = jsonEncode(
      _pendingActions.map((a) => a.toJson()).toList(),
    );
    await prefs.setString(_pendingActionsKey, actionsJson);
  }

  /// Load offline cache from storage
  Future<void> _loadOfflineCache() async {
    final prefs = await SharedPreferences.getInstance();

    // Load each cache category
    final cacheKeys = [
      _offlineProfilesKey,
      _offlineMatchesKey,
      _offlineSettingsKey,
    ];

    for (final key in cacheKeys) {
      final dataJson = prefs.getString(key);
      if (dataJson != null) {
        try {
          final data = jsonDecode(dataJson);
          _offlineCache[key] = CachedData(
            data: data,
            timestamp: DateTime.now(),
            expiry: DateTime.now().add(const Duration(hours: 24)),
          );
        } catch (e) {
          // Clear corrupted cache entry
          await prefs.remove(key);
        }
      }
    }
  }

  /// Save offline cache to storage
  Future<void> _saveOfflineCache() async {
    final prefs = await SharedPreferences.getInstance();

    for (final entry in _offlineCache.entries) {
      try {
        final dataJson = jsonEncode(entry.value.data);
        await prefs.setString(entry.key, dataJson);
      } catch (e) {
        // Skip items that can't be serialized
      }
    }
  }

  /// Update last sync timestamp
  Future<void> _updateLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get last sync timestamp
  Future<DateTime> _getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey) ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}

/// Pending action model for offline sync
class PendingAction {
  final String id;
  final String type;
  final String endpoint;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  PendingAction({
    required this.id,
    required this.type,
    required this.endpoint,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'endpoint': endpoint,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory PendingAction.fromJson(Map<String, dynamic> json) {
    return PendingAction(
      id: json['id'],
      type: json['type'],
      endpoint: json['endpoint'],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }
}

/// Cached data model
class CachedData {
  final dynamic data;
  final DateTime timestamp;
  final DateTime expiry;

  CachedData({
    required this.data,
    required this.timestamp,
    required this.expiry,
  });
}
