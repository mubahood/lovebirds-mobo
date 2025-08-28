import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/common/responsive_dialog_wrapper.dart';

class GuestSessionManager {
  static const String _isGuestModeKey = 'is_guest_mode';
  static const String _guestSessionIdKey = 'guest_session_id';
  static const String _guestStartTimeKey = 'guest_start_time';

  /// Check if the app is currently in guest mode
  static Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isGuestModeKey) ?? false;
  }

  /// Start a guest session
  static Future<void> startGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    await prefs.setBool(_isGuestModeKey, true);
    await prefs.setString(_guestSessionIdKey, sessionId);
    await prefs.setInt(
      _guestStartTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// End guest session and clear guest data
  static Future<void> endGuestSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_isGuestModeKey);
    await prefs.remove(_guestSessionIdKey);
    await prefs.remove(_guestStartTimeKey);
  }

  /// Get the current guest session ID
  static Future<String?> getGuestSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_guestSessionIdKey);
  }

  /// Get when the guest session started
  static Future<DateTime?> getGuestSessionStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_guestStartTimeKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Get guest session duration
  static Future<Duration?> getGuestSessionDuration() async {
    final startTime = await getGuestSessionStartTime();
    if (startTime != null) {
      return DateTime.now().difference(startTime);
    }
    return null;
  }

  /// Check if guest should be prompted to create account
  /// (e.g., after watching X movies or after Y time)
  static Future<bool> shouldPromptRegistration() async {
    final isGuest = await isGuestMode();
    if (!isGuest) return false;

    final duration = await getGuestSessionDuration();
    if (duration == null) return false;

    // Prompt after 30 minutes of usage
    const promptThreshold = Duration(minutes: 30);
    return duration > promptThreshold;
  }

  /// Show registration prompt with benefits
  static void showRegistrationPrompt() {
    if (!Get.isDialogOpen!) {
      Get.dialog(
        ResponsiveDialogWrapper(
          backgroundColor: const Color(0xFF1E1E1E),
          child: ResponsiveDialogPadding(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.star, color: const Color(0xFF6366F1), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enjoying Lovebirds Dating?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: Colors.grey[400]),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  'Create an account to unlock:',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 12),

                _buildBenefitItem('💾', 'Save your favorite movies'),
                _buildBenefitItem('📱', 'Download movies for offline viewing'),
                _buildBenefitItem('🔔', 'Get notified of new releases'),
                _buildBenefitItem('💬', 'Comment and rate movies'),
                _buildBenefitItem('📂', 'Create custom playlists'),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[600]!),
                          ),
                        ),
                        child: const Text(
                          'Maybe Later',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.toNamed('/register');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      );
    }
  }

  static Widget _buildBenefitItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// Track guest actions for analytics (optional)
  static Future<void> trackGuestAction(
    String action, {
    Map<String, dynamic>? data,
  }) async {
    final isGuest = await isGuestMode();
    if (!isGuest) return;

    final sessionId = await getGuestSessionId();
    final duration = await getGuestSessionDuration();

    // Here you could send analytics data to your backend
    print('Guest Action: $action');
    print('Session ID: $sessionId');
    print('Session Duration: ${duration?.inMinutes} minutes');
    if (data != null) {
      print('Data: $data');
    }
  }
}
