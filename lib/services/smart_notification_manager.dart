import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// Smart Notification Manager with Intelligent Scheduling and User Preferences
class SmartNotificationManager {
  static final SmartNotificationManager _instance =
      SmartNotificationManager._internal();
  factory SmartNotificationManager() => _instance;
  SmartNotificationManager._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Notification preferences
  bool _matchNotifications = true;
  bool _messageNotifications = true;
  bool _likeNotifications = true;
  bool _boostNotifications = true;
  bool _promotionalNotifications = false;

  // Quiet hours
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0); // 10 PM
  TimeOfDay _quietEnd = const TimeOfDay(hour: 8, minute: 0); // 8 AM
  bool _enableQuietHours = true;

  // Smart scheduling
  Map<String, int> _userEngagementHours = {}; // Track when user is most active
  int _maxDailyNotifications = 5;
  int _todayNotificationCount = 0;
  DateTime _lastResetDate = DateTime.now();

  /// Initialize notification system
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android initialization
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _loadPreferences();
    await _requestPermissions();
    _resetDailyCountIfNeeded();

    _isInitialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationAction(payload);
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    final androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    final iosImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    bool granted = true;

    if (androidImplementation != null) {
      granted =
          await androidImplementation.requestNotificationsPermission() ?? false;
    }

    if (iosImplementation != null) {
      granted =
          await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return granted;
  }

  /// Smart notification scheduling that respects user preferences and engagement
  Future<void> scheduleSmartNotification({
    required String type,
    required String title,
    required String body,
    String? payload,
    Duration? delay,
  }) async {
    // Check if this type of notification is enabled
    if (!_isNotificationTypeEnabled(type)) return;

    // Check quiet hours
    if (_enableQuietHours && _isInQuietHours()) {
      // Schedule for after quiet hours
      delay = _getDelayUntilActiveHours();
    }

    // Check daily limit
    if (_todayNotificationCount >= _maxDailyNotifications) {
      debugPrint('Daily notification limit reached');
      return;
    }

    // Find optimal time based on user engagement
    if (delay == null) {
      delay = _getOptimalDelay(type);
    }

    await _scheduleNotification(
      type: type,
      title: title,
      body: body,
      payload: payload,
      delay: delay,
    );

    _todayNotificationCount++;
    await _savePreferences();
  }

  /// Schedule immediate notification for matches
  Future<void> showMatchNotification(String matchName) async {
    await scheduleSmartNotification(
      type: 'match',
      title: '💕 New Match!',
      body: 'You and $matchName liked each other! Start chatting now.',
      payload: 'match:$matchName',
    );
  }

  /// Schedule message notification
  Future<void> showMessageNotification(
    String senderName,
    String message,
  ) async {
    await scheduleSmartNotification(
      type: 'message',
      title: '💬 $senderName',
      body: message.length > 50 ? '${message.substring(0, 50)}...' : message,
      payload: 'message:$senderName',
    );
  }

  /// Schedule like notification
  Future<void> showLikeNotification(String likerName) async {
    await scheduleSmartNotification(
      type: 'like',
      title: '❤️ Someone liked you!',
      body: '$likerName and others are interested. Check it out!',
      payload: 'like:$likerName',
    );
  }

  /// Schedule boost notification
  Future<void> showBoostNotification() async {
    await scheduleSmartNotification(
      type: 'boost',
      title: '🚀 Boost Available!',
      body: 'Increase your visibility and get more matches today.',
      payload: 'boost',
    );
  }

  /// Core notification scheduling
  Future<void> _scheduleNotification({
    required String type,
    required String title,
    required String body,
    String? payload,
    Duration? delay,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    const androidDetails = AndroidNotificationDetails(
      'lovebirds_main',
      'Lovebirds Notifications',
      channelDescription: 'Main notifications for matches, messages, and likes',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (delay != null) {
      final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else {
      await _notifications.show(id, title, body, details, payload: payload);
    }
  }

  /// Check if notification type is enabled
  bool _isNotificationTypeEnabled(String type) {
    switch (type) {
      case 'match':
        return _matchNotifications;
      case 'message':
        return _messageNotifications;
      case 'like':
        return _likeNotifications;
      case 'boost':
        return _boostNotifications;
      case 'promotional':
        return _promotionalNotifications;
      default:
        return true;
    }
  }

  /// Check if current time is in quiet hours
  bool _isInQuietHours() {
    final now = TimeOfDay.now();

    // Convert to minutes for easier comparison
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = _quietStart.hour * 60 + _quietStart.minute;
    final endMinutes = _quietEnd.hour * 60 + _quietEnd.minute;

    if (startMinutes <= endMinutes) {
      // Same day range (e.g., 10 AM to 2 PM)
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } else {
      // Overnight range (e.g., 10 PM to 8 AM)
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
    }
  }

  /// Get delay until active hours
  Duration _getDelayUntilActiveHours() {
    final now = DateTime.now();
    final activeTime = DateTime(
      now.year,
      now.month,
      now.day,
      _quietEnd.hour,
      _quietEnd.minute,
    );

    if (activeTime.isBefore(now)) {
      // Active time is tomorrow
      return activeTime.add(const Duration(days: 1)).difference(now);
    } else {
      return activeTime.difference(now);
    }
  }

  /// Get optimal delay based on user engagement patterns
  Duration _getOptimalDelay(String type) {
    // For now, return immediate for high-priority notifications
    if (type == 'match' || type == 'message') {
      return Duration.zero;
    }

    // For other notifications, slight delay to batch them
    return const Duration(minutes: 2);
  }

  /// Reset daily notification count if new day
  void _resetDailyCountIfNeeded() {
    final today = DateTime.now();
    if (today.day != _lastResetDate.day) {
      _todayNotificationCount = 0;
      _lastResetDate = today;
    }
  }

  /// Handle notification actions
  void _handleNotificationAction(String payload) {
    final parts = payload.split(':');
    final action = parts[0];

    switch (action) {
      case 'match':
        // Navigate to matches screen
        break;
      case 'message':
        // Navigate to chat screen
        break;
      case 'like':
        // Navigate to who liked me screen
        break;
      case 'boost':
        // Navigate to boost screen
        break;
    }
  }

  /// Load user preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _matchNotifications = prefs.getBool('notif_matches') ?? true;
    _messageNotifications = prefs.getBool('notif_messages') ?? true;
    _likeNotifications = prefs.getBool('notif_likes') ?? true;
    _boostNotifications = prefs.getBool('notif_boosts') ?? true;
    _promotionalNotifications = prefs.getBool('notif_promotional') ?? false;
    _enableQuietHours = prefs.getBool('notif_quiet_hours') ?? true;
    _maxDailyNotifications = prefs.getInt('notif_daily_limit') ?? 5;
    _todayNotificationCount = prefs.getInt('notif_today_count') ?? 0;

    // Load quiet hours
    final quietStartMinutes = prefs.getInt('quiet_start') ?? (22 * 60);
    final quietEndMinutes = prefs.getInt('quiet_end') ?? (8 * 60);

    _quietStart = TimeOfDay(
      hour: quietStartMinutes ~/ 60,
      minute: quietStartMinutes % 60,
    );
    _quietEnd = TimeOfDay(
      hour: quietEndMinutes ~/ 60,
      minute: quietEndMinutes % 60,
    );
  }

  /// Save user preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('notif_matches', _matchNotifications);
    await prefs.setBool('notif_messages', _messageNotifications);
    await prefs.setBool('notif_likes', _likeNotifications);
    await prefs.setBool('notif_boosts', _boostNotifications);
    await prefs.setBool('notif_promotional', _promotionalNotifications);
    await prefs.setBool('notif_quiet_hours', _enableQuietHours);
    await prefs.setInt('notif_daily_limit', _maxDailyNotifications);
    await prefs.setInt('notif_today_count', _todayNotificationCount);

    // Save quiet hours
    await prefs.setInt(
      'quiet_start',
      _quietStart.hour * 60 + _quietStart.minute,
    );
    await prefs.setInt('quiet_end', _quietEnd.hour * 60 + _quietEnd.minute);
  }

  /// Public setters for preferences
  Future<void> setMatchNotifications(bool enabled) async {
    _matchNotifications = enabled;
    await _savePreferences();
  }

  Future<void> setMessageNotifications(bool enabled) async {
    _messageNotifications = enabled;
    await _savePreferences();
  }

  Future<void> setLikeNotifications(bool enabled) async {
    _likeNotifications = enabled;
    await _savePreferences();
  }

  Future<void> setBoostNotifications(bool enabled) async {
    _boostNotifications = enabled;
    await _savePreferences();
  }

  Future<void> setPromotionalNotifications(bool enabled) async {
    _promotionalNotifications = enabled;
    await _savePreferences();
  }

  Future<void> setQuietHours(
    bool enabled,
    TimeOfDay? start,
    TimeOfDay? end,
  ) async {
    _enableQuietHours = enabled;
    if (start != null) _quietStart = start;
    if (end != null) _quietEnd = end;
    await _savePreferences();
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get notification settings summary
  Map<String, dynamic> getNotificationSettings() {
    return {
      'matches': _matchNotifications,
      'messages': _messageNotifications,
      'likes': _likeNotifications,
      'boosts': _boostNotifications,
      'promotional': _promotionalNotifications,
      'quietHours': _enableQuietHours,
      'dailyLimit': _maxDailyNotifications,
      'todayCount': _todayNotificationCount,
    };
  }
}
