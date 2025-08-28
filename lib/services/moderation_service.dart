import '../utils/Utilities.dart';

class ModerationService {
  /// Report content (movie, comment, user, etc.)
  static Future<Map<String, dynamic>> reportContent({
    required String contentType,
    required String contentId,
    required String reason,
    String? description,
    String? reportedUserId,
  }) async {
    try {
      final result = await Utils.http_post('moderation/report-content', {
        'reported_content_type': contentType,
        'reported_content_id': contentId,
        'reported_user_id': reportedUserId ?? '',
        'report_type': reason,
        'description': description ?? '',
      });

      return _processApiResponse(result);
    } catch (e) {
      return {
        'code': 0,
        'message': 'Failed to report content: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Block a user
  static Future<Map<String, dynamic>> blockUser({
    required String blockedUserId,
    String? reason,
  }) async {
    try {
      final result = await Utils.http_post('moderation/block-user', {
        'blocked_user_id': blockedUserId,
        'reason': reason ?? '',
      });
      return _processApiResponse(result);
    } catch (e) {
      return {
        'code': 0,
        'message': 'Failed to block user: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Unblock a user
  static Future<Map<String, dynamic>> unblockUser({
    required String blockedUserId,
  }) async {
    try {
      final result = await Utils.http_post('moderation/unblock-user', {
        'blocked_user_id': blockedUserId,
      });
      return _processApiResponse(result);
    } catch (e) {
      return {
        'code': 0,
        'message': 'Failed to unblock user: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Get list of blocked users
  static Future<Map<String, dynamic>> getBlockedUsers() async {
    try {
      final result = await Utils.http_get('moderation/blocked-users', {});
      return _processApiResponse(result);
    } catch (e) {
      return {
        'code': 0,
        'message': 'Failed to get blocked users: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Get my reports
  static Future<Map<String, dynamic>> getMyReports() async {
    try {
      final result = await Utils.http_get('moderation/my-reports', {});
      return _processApiResponse(result);
    } catch (e) {
      return {
        'code': 0,
        'message': 'Failed to get reports: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Get content with filtering applied
  static Future<Map<String, dynamic>> getFilteredContent({
    required String contentType,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      Map<String, dynamic> params = {
        'content_type': contentType,
        ...?additionalParams,
      };

      final result = await Utils.http_post('moderation/filter-content', params);
      return result;
    } catch (e) {
      return {
        'code': 0,
        'message': 'Failed to get filtered content: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Submit legal consent
  static Future<Map<String, dynamic>> submitLegalConsent({
    required bool accepted,
    String? ipAddress,
  }) async {
    try {
      final result = await Utils.http_post('moderation/legal-consent', {
        'accepted': accepted ? '1' : '0',
        'ip_address': ipAddress ?? '',
      });
      return _processApiResponse(result);
    } catch (e) {
      return {
        'code': 0,
        'message': 'Failed to submit legal consent: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Get legal consent status
  static Future<Map<String, dynamic>> getLegalConsentStatus() async {
    try {
      final result = await Utils.http_get(
        'moderation/legal-consent-status',
        {},
      );
      return _processApiResponse(result);
    } catch (e) {
      return {
        'code': 0,
        'message': 'Failed to get legal consent status: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Filter content for inappropriate language
  static Future<Map<String, dynamic>> filterContent(String content) async {
    try {
      final result = await Utils.http_post('moderation/filter-content', {
        'content': content,
      });
      return _processApiResponse(result);
    } catch (e) {
      return {
        'code': 0,
        'message': 'Failed to filter content: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Get moderation dashboard data (admin only)
  static Future<Map<String, dynamic>> getModerationDashboard() async {
    try {
      final result = await Utils.http_get('moderation/dashboard', {});
      return result;
    } catch (e) {
      return {
        'code': 0,
        'message': 'Failed to get moderation dashboard: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final result = await Utils.http_get('moderation/is-admin', {});
      final processed = _processApiResponse(result);
      return processed['code'] == 1 && processed['data'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Process API response to ensure consistent format
  static Map<String, dynamic> _processApiResponse(dynamic result) {
    if (result == null) {
      return {'code': 0, 'message': 'No response from server', 'data': null};
    }

    // Handle string response (JSON encoded)
    if (result is String) {
      try {
        final decoded = Utils.to_str(result, '{}');
        if (decoded.startsWith('{')) {
          // Try to parse as JSON if it looks like JSON
          return {'code': 0, 'message': decoded, 'data': null};
        }
      } catch (e) {
        return {'code': 0, 'message': result, 'data': null};
      }
    }

    // Handle map response
    if (result is Map<String, dynamic>) {
      return {
        'code': Utils.int_parse(result['code'] ?? result['status'] ?? 0),
        'message': Utils.to_str(result['message'] ?? '', 'Unknown error'),
        'data': result['data'],
      };
    }

    return {'code': 0, 'message': 'Invalid response format', 'data': null};
  }
}
