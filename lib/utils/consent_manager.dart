import 'package:shared_preferences/shared_preferences.dart';
import '../services/moderation_service.dart';

class ConsentManager {
  static const String _consentKey = 'user_legal_consent_completed';
  static const String _lastConsentCheckKey = 'last_consent_check';

  /// Check if user has completed legal consent locally
  static Future<bool> hasLocalConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  /// Mark user as having completed consent locally
  static Future<void> setLocalConsent(bool hasConsented) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, hasConsented);
    await prefs.setInt(
      _lastConsentCheckKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Check if we need to verify consent status from server
  static Future<bool> shouldCheckServerConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastConsentCheckKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const checkInterval = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

    return (now - lastCheck) > checkInterval;
  }

  /// Check consent status from server and update local storage
  static Future<bool> checkAndUpdateConsentStatus() async {
    try {
      final result = await ModerationService.getLegalConsentStatus();

      if (result['code'] == 1 && result['data'] != null) {
        final data = result['data'];
        final hasAllConsents =
            (data['consent_to_terms'] == 1 ||
                data['consent_to_terms'] == true) &&
            (data['consent_to_data_processing'] == 1 ||
                data['consent_to_data_processing'] == true) &&
            (data['consent_to_content_moderation'] == 1 ||
                data['consent_to_content_moderation'] == true);

        await setLocalConsent(hasAllConsents);
        return hasAllConsents;
      }
    } catch (e) {
      // If server check fails, rely on local storage
      return await hasLocalConsent();
    }

    return false;
  }

  /// Clear consent status (for logout or reset)
  static Future<void> clearConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consentKey);
    await prefs.remove(_lastConsentCheckKey);
  }
}
