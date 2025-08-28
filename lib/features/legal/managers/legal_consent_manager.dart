import 'package:get/get.dart';
import 'package:lovebirds_app/models/LoggedInUserModel.dart';
import 'package:lovebirds_app/features/legal/views/terms_of_service_screen.dart';
import 'package:lovebirds_app/features/legal/views/privacy_policy_screen.dart';
import 'package:lovebirds_app/features/legal/views/community_guidelines_screen.dart';
import 'package:lovebirds_app/features/legal/views/legal_consent_screen.dart';
import '../../../utils/Utilities.dart';

class LegalConsentManager {
  static const String TERMS_ACCEPTED = "Yes";
  static const String PRIVACY_ACCEPTED = "Yes";
  static const String GUIDELINES_ACCEPTED = "Yes";

  /// Check if user has accepted all required legal documents
  static bool hasUserAcceptedAllLegal(LoggedInUserModel user) {
    return user.terms_of_service_accepted == TERMS_ACCEPTED &&
        user.privacy_policy_accepted == PRIVACY_ACCEPTED &&
        user.community_guidelines_accepted == GUIDELINES_ACCEPTED;
  }

  /// Get list of missing legal acceptances
  static List<String> getMissingAcceptances(LoggedInUserModel user) {
    List<String> missing = [];

    if (user.terms_of_service_accepted != TERMS_ACCEPTED) {
      missing.add("Terms of Service");
    }

    if (user.privacy_policy_accepted != PRIVACY_ACCEPTED) {
      missing.add("Privacy Policy");
    }

    if (user.community_guidelines_accepted != GUIDELINES_ACCEPTED) {
      missing.add("Community Guidelines");
    }

    return missing;
  }

  /// Force user to accept missing legal documents
  static Future<bool> enforceAgreement(LoggedInUserModel user) async {
    List<String> missing = getMissingAcceptances(user);

    if (missing.isEmpty) {
      return true; // All already accepted
    }

    Utils.log("User missing legal acceptances: ${missing.join(', ')}");

    // Navigate to comprehensive legal consent screen
    final result = await Get.to(
      () => LegalConsentScreen(user: user, missingAcceptances: missing),
    );

    return result == true;
  }

  /// Show individual legal document for acceptance
  static Future<bool?> showLegalDocument(String documentType) async {
    switch (documentType.toLowerCase()) {
      case 'terms of service':
      case 'terms':
        return await Get.to(() => const TermsOfServiceScreen(isRequired: true));

      case 'privacy policy':
      case 'privacy':
        return await Get.to(() => const PrivacyPolicyScreen(isRequired: true));

      case 'community guidelines':
      case 'guidelines':
        return await Get.to(
          () => const CommunityGuidelinesScreen(isRequired: true),
        );

      default:
        return false;
    }
  }

  /// Update user's legal acceptance status
  static Future<bool> updateUserLegalAcceptance(
    LoggedInUserModel user,
    String documentType,
    bool accepted,
  ) async {
    final now = DateTime.now().toIso8601String();

    switch (documentType.toLowerCase()) {
      case 'terms of service':
      case 'terms':
        user.terms_of_service_accepted = accepted ? TERMS_ACCEPTED : "No";
        if (accepted) user.terms_accepted_date = now;
        break;

      case 'privacy policy':
      case 'privacy':
        user.privacy_policy_accepted = accepted ? PRIVACY_ACCEPTED : "No";
        if (accepted) user.privacy_accepted_date = now;
        break;

      case 'community guidelines':
      case 'guidelines':
        user.community_guidelines_accepted =
            accepted ? GUIDELINES_ACCEPTED : "No";
        if (accepted) user.guidelines_accepted_date = now;
        break;

      default:
        return false;
    }

    // Save user data locally
    await user.save();

    // TODO: Send update to backend API
    // await _updateBackendUserLegal(user);

    Utils.log("Updated ${documentType} acceptance: ${accepted}");
    return true;
  }

  /// Update all legal acceptances at once
  static Future<bool> updateAllLegalAcceptances(
    LoggedInUserModel user,
    bool termsAccepted,
    bool privacyAccepted,
    bool guidelinesAccepted,
  ) async {
    final now = DateTime.now().toIso8601String();

    user.terms_of_service_accepted = termsAccepted ? TERMS_ACCEPTED : "No";
    user.privacy_policy_accepted = privacyAccepted ? PRIVACY_ACCEPTED : "No";
    user.community_guidelines_accepted =
        guidelinesAccepted ? GUIDELINES_ACCEPTED : "No";

    if (termsAccepted) user.terms_accepted_date = now;
    if (privacyAccepted) user.privacy_accepted_date = now;
    if (guidelinesAccepted) user.guidelines_accepted_date = now;

    // Save user data locally
    await user.save();

    // TODO: Send update to backend API
    // await _updateBackendUserLegal(user);

    Utils.log("Updated all legal acceptances");
    return true;
  }

  /// Check legal compliance on app startup
  static Future<bool> checkComplianceOnStartup() async {
    try {
      LoggedInUserModel user = await LoggedInUserModel.getLoggedInUser();

      // If no user logged in, no need to check legal compliance
      if (user.id == 0) {
        return true;
      }

      // TODO: Fetch fresh user data from backend
      // user = await _fetchFreshUserData(user.id);

      // Check if user has accepted all required legal documents
      if (!hasUserAcceptedAllLegal(user)) {
        Utils.log("User compliance check failed - enforcing legal agreement");
        return await enforceAgreement(user);
      }

      Utils.log("User compliance check passed");
      return true;
    } catch (e) {
      Utils.log("Error checking legal compliance: ${e.toString()}");
      return false;
    }
  }

  /// Check legal compliance on login
  static Future<bool> checkComplianceOnLogin(LoggedInUserModel user) async {
    try {
      // TODO: Fetch fresh user data from backend
      // user = await _fetchFreshUserData(user.id);

      // Check if user has accepted all required legal documents
      if (!hasUserAcceptedAllLegal(user)) {
        Utils.log("Login compliance check failed - enforcing legal agreement");
        return await enforceAgreement(user);
      }

      Utils.log("Login compliance check passed");
      return true;
    } catch (e) {
      Utils.log("Error checking login compliance: ${e.toString()}");
      return false;
    }
  }

  /// Set default user settings
  static void setDefaultUserSettings(LoggedInUserModel user) {
    // Default notification settings
    if (user.push_notifications.isEmpty) {
      user.push_notifications = "Yes";
    }
    if (user.email_notifications.isEmpty) {
      user.email_notifications = "No";
    }

    // Default privacy settings
    if (user.profile_visibility.isEmpty) {
      user.profile_visibility = "Public";
    }
    if (user.location_sharing.isEmpty) {
      user.location_sharing = "No";
    }

    // Default safety settings
    if (user.content_filtering.isEmpty) {
      user.content_filtering = "Moderate";
    }
    if (user.safe_mode.isEmpty) {
      user.safe_mode = "Yes";
    }

    // Default consent settings
    if (user.analytics_consent.isEmpty) {
      user.analytics_consent = "Yes";
    }
    if (user.crash_reporting.isEmpty) {
      user.crash_reporting = "Yes";
    }
    if (user.content_moderation_consent.isEmpty) {
      user.content_moderation_consent = "Yes";
    }
  }

  /// Set local consent for legal documents
  static Future<bool> setLocalConsent({
    required String userId,
    required String documentType,
    required bool accepted,
  }) async {
    try {
      // Implementation for setting local consent
      Utils.log("Setting local consent for $documentType: $accepted");

      // For now, just return true as this is a placeholder
      // In a full implementation, this would update local storage
      return true;
    } catch (e) {
      Utils.log("Error setting local consent: $e");
      return false;
    }
  }

  // TODO: Backend API integration methods
  /*
  static Future<LoggedInUserModel> _fetchFreshUserData(int userId) async {
    // Implement backend API call to fetch fresh user data
    // This should include all legal acceptance statuses
  }

  static Future<bool> _updateBackendUserLegal(LoggedInUserModel user) async {
    // Implement backend API call to update user's legal acceptance status
    // This should sync with the backend database
  }
  */
}
