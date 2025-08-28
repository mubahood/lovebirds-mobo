import 'dart:convert';
import 'package:flutter/material.dart';

/// Service for chat safety and moderation features
/// Implements AI-powered content detection, safety warnings, and emergency features
class ChatSafetyService {
  static final ChatSafetyService _instance = ChatSafetyService._internal();
  factory ChatSafetyService() => _instance;
  ChatSafetyService._internal();

  // Safety keywords and patterns for inappropriate content detection
  static const List<String> _inappropriateKeywords = [
    'explicit',
    'inappropriate',
    'harassment',
    'abuse',
    'threat',
    'violence',
    'hate',
    'discriminatory',
    'stalking',
    'predator',
  ];

  static const List<String> _suggestiveKeywords = [
    'meet tonight',
    'your place',
    'my place',
    'send pics',
    'private photos',
    'naked',
    'nude',
    'sexy time',
    'hook up',
    'one night',
  ];

  static const List<String> _emergencyKeywords = [
    'help me',
    'emergency',
    'danger',
    'scared',
    'threatening',
    'unsafe',
    'police',
    'call 911',
    'in trouble',
    'need help',
  ];

  /// Analyze message content for inappropriate content
  Future<MessageSafetyResult> analyzeMessage(
    String message,
    String? senderId,
  ) async {
    try {
      // Simulate API call for AI-powered content analysis
      await Future.delayed(const Duration(milliseconds: 300));

      final lowerMessage = message.toLowerCase();

      // Check for emergency keywords
      bool hasEmergencyKeywords = _emergencyKeywords.any(
        (keyword) => lowerMessage.contains(keyword),
      );

      // Check for inappropriate content
      bool hasInappropriateContent = _inappropriateKeywords.any(
        (keyword) => lowerMessage.contains(keyword),
      );

      // Check for suggestive content
      bool hasSuggestiveContent = _suggestiveKeywords.any(
        (keyword) => lowerMessage.contains(keyword),
      );

      // Calculate sentiment score (mock analysis)
      double sentimentScore = _calculateSentimentScore(message);

      // Determine safety level
      SafetyLevel safetyLevel = _determineSafetyLevel(
        hasInappropriateContent,
        hasSuggestiveContent,
        hasEmergencyKeywords,
        sentimentScore,
      );

      return MessageSafetyResult(
        message: message,
        safetyLevel: safetyLevel,
        sentimentScore: sentimentScore,
        hasInappropriateContent: hasInappropriateContent,
        hasSuggestiveContent: hasSuggestiveContent,
        hasEmergencyKeywords: hasEmergencyKeywords,
        warnings: _generateWarnings(
          safetyLevel,
          hasInappropriateContent,
          hasSuggestiveContent,
        ),
        suggestions: _generateSuggestions(safetyLevel),
        shouldBlock: safetyLevel == SafetyLevel.dangerous,
        requiresReview:
            safetyLevel == SafetyLevel.warning || hasEmergencyKeywords,
      );
    } catch (e) {
      return MessageSafetyResult.safe(message);
    }
  }

  /// Analyze conversation sentiment over time
  Future<ConversationSentiment> analyzeConversationSentiment(
    List<String> recentMessages,
    String userId,
    String partnerId,
  ) async {
    try {
      if (recentMessages.isEmpty) {
        return ConversationSentiment.neutral();
      }

      // Calculate overall sentiment
      double totalSentiment = 0;
      int positiveCount = 0;
      int negativeCount = 0;
      int neutralCount = 0;

      for (String message in recentMessages) {
        double sentiment = _calculateSentimentScore(message);
        totalSentiment += sentiment;

        if (sentiment > 0.6) {
          positiveCount++;
        } else if (sentiment < 0.4) {
          negativeCount++;
        } else {
          neutralCount++;
        }
      }

      double averageSentiment = totalSentiment / recentMessages.length;

      // Determine conversation health
      ConversationHealth health = _determineConversationHealth(
        averageSentiment,
        positiveCount,
        negativeCount,
        recentMessages.length,
      );

      return ConversationSentiment(
        averageSentiment: averageSentiment,
        positiveMessageCount: positiveCount,
        negativeMessageCount: negativeCount,
        neutralMessageCount: neutralCount,
        totalMessages: recentMessages.length,
        health: health,
        recommendations: _generateConversationRecommendations(
          health,
          averageSentiment,
        ),
      );
    } catch (e) {
      return ConversationSentiment.neutral();
    }
  }

  /// Check if photo sharing should trigger safety warnings
  PhotoSharingWarning checkPhotoSharingRisk(
    String senderId,
    String receiverId,
  ) {
    // Check relationship duration
    Duration? relationshipDuration = _calculateRelationshipDuration(
      senderId,
      receiverId,
    );

    bool isNewRelationship =
        relationshipDuration == null || relationshipDuration.inDays < 7;

    bool isFirstPhoto = true; // This would be tracked in actual implementation

    // Determine risk level
    PhotoSharingRisk riskLevel = PhotoSharingRisk.low;
    List<String> warnings = [];

    if (isNewRelationship) {
      riskLevel = PhotoSharingRisk.medium;
      warnings.add(
        "You've been chatting for less than a week. Consider getting to know each other better first.",
      );
    }

    if (isFirstPhoto) {
      warnings.add(
        "This is your first photo share. Remember that shared photos can be saved or screenshot.",
      );
    }

    // Always include general safety reminders
    warnings.addAll([
      "Only share photos you're comfortable with others potentially seeing",
      "Consider if this photo reveals personal information about your location",
      "Remember that you can report inappropriate photo requests",
    ]);

    return PhotoSharingWarning(
      riskLevel: riskLevel,
      warnings: warnings,
      shouldShowConsent: isNewRelationship || isFirstPhoto,
      consentMessage:
          "I understand the risks and consent to sharing this photo",
    );
  }

  /// Generate emergency safety options
  List<EmergencySafetyOption> getEmergencySafetyOptions() {
    return [
      EmergencySafetyOption(
        id: 'quick_exit',
        title: 'Quick Exit',
        description: 'Immediately exit the app and return to home screen',
        icon: Icons.exit_to_app,
        action: EmergencyAction.quickExit,
        priority: 1,
      ),
      EmergencySafetyOption(
        id: 'block_report',
        title: 'Block & Report',
        description: 'Block this user and report to our safety team',
        icon: Icons.block,
        action: EmergencyAction.blockAndReport,
        priority: 2,
      ),
      EmergencySafetyOption(
        id: 'safety_alert',
        title: 'Send Safety Alert',
        description: 'Alert your emergency contacts about your situation',
        icon: Icons.warning,
        action: EmergencyAction.safetyAlert,
        priority: 3,
      ),
      EmergencySafetyOption(
        id: 'call_support',
        title: 'Call Support',
        description: 'Call our 24/7 safety support line',
        icon: Icons.phone,
        action: EmergencyAction.callSupport,
        priority: 4,
      ),
      EmergencySafetyOption(
        id: 'emergency_services',
        title: 'Emergency Services',
        description: 'Call local emergency services (911)',
        icon: Icons.local_hospital,
        action: EmergencyAction.emergencyServices,
        priority: 5,
      ),
    ];
  }

  /// Implement mutual consent verification for meetup planning
  Future<MeetupConsentResult> verifyMeetupConsent(
    String userId,
    String partnerId,
    MeetupDetails meetupDetails,
  ) async {
    try {
      // Simulate API call to verify mutual consent
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock successful verification
      return MeetupConsentResult(
        isSuccessful: true,
        bothConsented: true,
        message: 'Both users have consented to the meetup',
        consentTimestamp: DateTime.now(),
        safetyReminders: [
          'Meet in a public place',
          'Tell someone about your plans',
          'Trust your instincts',
          'Have your own transportation',
        ],
      );
    } catch (e) {
      return MeetupConsentResult.failed(
        'Network error during consent verification',
      );
    }
  }

  /// Report unsafe behavior or content
  Future<Map<String, dynamic>> reportUnsafeBehavior(
    String reportedUserId,
    String reportingUserId,
    ReportReason reason,
    String description, {
    List<String>? evidenceMessageIds,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      return {
        'success': true,
        'message':
            'Report submitted successfully. Our safety team will review it within 24 hours.',
        'report_id': 'RPT${DateTime.now().millisecondsSinceEpoch}',
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit report: $e'};
    }
  }

  // Private helper methods

  double _calculateSentimentScore(String message) {
    // Simple sentiment analysis (in production, use ML model)
    final positiveWords = [
      'happy',
      'love',
      'great',
      'amazing',
      'wonderful',
      'fantastic',
      'good',
      'nice',
      'beautiful',
    ];
    final negativeWords = [
      'hate',
      'terrible',
      'awful',
      'bad',
      'horrible',
      'disgusting',
      'ugly',
      'stupid',
      'annoying',
    ];

    final lowerMessage = message.toLowerCase();
    int positiveCount = 0;
    int negativeCount = 0;

    for (String word in positiveWords) {
      if (lowerMessage.contains(word)) positiveCount++;
    }

    for (String word in negativeWords) {
      if (lowerMessage.contains(word)) negativeCount++;
    }

    // Return score between 0.0 (very negative) and 1.0 (very positive)
    if (positiveCount == 0 && negativeCount == 0) return 0.5; // Neutral

    return (positiveCount / (positiveCount + negativeCount + 1)).clamp(
      0.0,
      1.0,
    );
  }

  SafetyLevel _determineSafetyLevel(
    bool hasInappropriate,
    bool hasSuggestive,
    bool hasEmergency,
    double sentiment,
  ) {
    if (hasEmergency) return SafetyLevel.emergency;
    if (hasInappropriate || sentiment < 0.2) return SafetyLevel.dangerous;
    if (hasSuggestive || sentiment < 0.4) return SafetyLevel.warning;
    return SafetyLevel.safe;
  }

  List<String> _generateWarnings(
    SafetyLevel level,
    bool hasInappropriate,
    bool hasSuggestive,
  ) {
    List<String> warnings = [];

    switch (level) {
      case SafetyLevel.emergency:
        warnings.add(
          "Emergency keywords detected. Safety resources are available.",
        );
        break;
      case SafetyLevel.dangerous:
        warnings.add("This message contains inappropriate content.");
        if (hasInappropriate) {
          warnings.add(
            "Consider blocking this user if they continue inappropriate behavior.",
          );
        }
        break;
      case SafetyLevel.warning:
        if (hasSuggestive) {
          warnings.add(
            "This message contains suggestive content. Take your time getting to know each other.",
          );
        }
        break;
      case SafetyLevel.safe:
        break;
    }

    return warnings;
  }

  List<String> _generateSuggestions(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.emergency:
        return [
          "If you're in danger, consider using our emergency safety features",
          "Report this conversation to our safety team",
          "Consider reaching out to local emergency services if needed",
        ];
      case SafetyLevel.dangerous:
        return [
          "Report this user for inappropriate behavior",
          "Block this user to stop receiving messages",
          "Save screenshots as evidence if needed",
        ];
      case SafetyLevel.warning:
        return [
          "Take time to get to know each other better",
          "Consider meeting in public places first",
          "Trust your instincts about this conversation",
        ];
      case SafetyLevel.safe:
        return [
          "This conversation appears to be going well",
          "Continue getting to know each other",
          "Remember to stay safe when planning to meet",
        ];
    }
  }

  ConversationHealth _determineConversationHealth(
    double averageSentiment,
    int positive,
    int negative,
    int total,
  ) {
    if (negative > positive && averageSentiment < 0.3) {
      return ConversationHealth.concerning;
    } else if (averageSentiment < 0.4 || (negative / total) > 0.4) {
      return ConversationHealth.needsAttention;
    } else if (averageSentiment > 0.7 && (positive / total) > 0.6) {
      return ConversationHealth.excellent;
    } else {
      return ConversationHealth.healthy;
    }
  }

  List<String> _generateConversationRecommendations(
    ConversationHealth health,
    double sentiment,
  ) {
    switch (health) {
      case ConversationHealth.excellent:
        return [
          "Your conversation is going great! 🎉",
          "Consider planning a fun activity together",
          "Keep up the positive energy",
        ];
      case ConversationHealth.healthy:
        return [
          "Your conversation is developing nicely",
          "Try asking open-ended questions to learn more",
          "Share something interesting about yourself",
        ];
      case ConversationHealth.needsAttention:
        return [
          "The conversation could use some positive energy",
          "Try changing the topic to something lighter",
          "Ask about their interests or hobbies",
        ];
      case ConversationHealth.concerning:
        return [
          "This conversation may not be going well",
          "Consider if this person is a good match for you",
          "Trust your instincts about continuing this chat",
        ];
    }
  }

  Duration? _calculateRelationshipDuration(String userId1, String userId2) {
    // In actual implementation, this would query the database
    // For now, return a mock duration
    return Duration(days: 3); // Mock: 3 days of chatting
  }
}

// Data models for safety features

enum SafetyLevel { safe, warning, dangerous, emergency }

enum PhotoSharingRisk { low, medium, high }

enum EmergencyAction {
  quickExit,
  blockAndReport,
  safetyAlert,
  callSupport,
  emergencyServices,
}

enum ConversationHealth { excellent, healthy, needsAttention, concerning }

enum ReportReason {
  inappropriateMessages,
  harassment,
  spam,
  fakeProfile,
  unsafeRequest,
  other,
}

class MessageSafetyResult {
  final String message;
  final SafetyLevel safetyLevel;
  final double sentimentScore;
  final bool hasInappropriateContent;
  final bool hasSuggestiveContent;
  final bool hasEmergencyKeywords;
  final List<String> warnings;
  final List<String> suggestions;
  final bool shouldBlock;
  final bool requiresReview;

  MessageSafetyResult({
    required this.message,
    required this.safetyLevel,
    required this.sentimentScore,
    required this.hasInappropriateContent,
    required this.hasSuggestiveContent,
    required this.hasEmergencyKeywords,
    required this.warnings,
    required this.suggestions,
    required this.shouldBlock,
    required this.requiresReview,
  });

  factory MessageSafetyResult.safe(String message) {
    return MessageSafetyResult(
      message: message,
      safetyLevel: SafetyLevel.safe,
      sentimentScore: 0.5,
      hasInappropriateContent: false,
      hasSuggestiveContent: false,
      hasEmergencyKeywords: false,
      warnings: [],
      suggestions: [],
      shouldBlock: false,
      requiresReview: false,
    );
  }
}

class ConversationSentiment {
  final double averageSentiment;
  final int positiveMessageCount;
  final int negativeMessageCount;
  final int neutralMessageCount;
  final int totalMessages;
  final ConversationHealth health;
  final List<String> recommendations;

  ConversationSentiment({
    required this.averageSentiment,
    required this.positiveMessageCount,
    required this.negativeMessageCount,
    required this.neutralMessageCount,
    required this.totalMessages,
    required this.health,
    required this.recommendations,
  });

  factory ConversationSentiment.neutral() {
    return ConversationSentiment(
      averageSentiment: 0.5,
      positiveMessageCount: 0,
      negativeMessageCount: 0,
      neutralMessageCount: 0,
      totalMessages: 0,
      health: ConversationHealth.healthy,
      recommendations: [],
    );
  }
}

class PhotoSharingWarning {
  final PhotoSharingRisk riskLevel;
  final List<String> warnings;
  final bool shouldShowConsent;
  final String consentMessage;

  PhotoSharingWarning({
    required this.riskLevel,
    required this.warnings,
    required this.shouldShowConsent,
    required this.consentMessage,
  });
}

class EmergencySafetyOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final EmergencyAction action;
  final int priority;

  EmergencySafetyOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.action,
    required this.priority,
  });
}

class MeetupDetails {
  final String location;
  final DateTime dateTime;
  final String activity;
  final bool isPublicPlace;
  final String? emergencyContact;

  MeetupDetails({
    required this.location,
    required this.dateTime,
    required this.activity,
    required this.isPublicPlace,
    this.emergencyContact,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'date_time': dateTime.toIso8601String(),
      'activity': activity,
      'is_public_place': isPublicPlace,
      'emergency_contact': emergencyContact,
    };
  }
}

class MeetupConsentResult {
  final bool isSuccessful;
  final bool bothConsented;
  final String? message;
  final DateTime? consentTimestamp;
  final List<String>? safetyReminders;

  MeetupConsentResult({
    required this.isSuccessful,
    required this.bothConsented,
    this.message,
    this.consentTimestamp,
    this.safetyReminders,
  });

  factory MeetupConsentResult.fromJson(Map<String, dynamic> json) {
    return MeetupConsentResult(
      isSuccessful: json['is_successful'] ?? false,
      bothConsented: json['both_consented'] ?? false,
      message: json['message'],
      consentTimestamp:
          json['consent_timestamp'] != null
              ? DateTime.parse(json['consent_timestamp'])
              : null,
      safetyReminders: json['safety_reminders']?.cast<String>(),
    );
  }

  factory MeetupConsentResult.failed(String message) {
    return MeetupConsentResult(
      isSuccessful: false,
      bothConsented: false,
      message: message,
    );
  }
}
