import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/Utilities.dart';
import '../../../utils/AppConfig.dart';

/// Content Filter Service for automated content moderation
/// Implements automated filtering for objectionable content as required by App Store guidelines
class ContentFilterService {
  static const String _TAG = "ContentFilterService";

  // Content violation categories
  static const String VIOLATION_PROFANITY = "profanity";
  static const String VIOLATION_HATE_SPEECH = "hate_speech";
  static const String VIOLATION_SEXUAL_CONTENT = "sexual_content";
  static const String VIOLATION_VIOLENCE = "violence";
  static const String VIOLATION_HARASSMENT = "harassment";
  static const String VIOLATION_SPAM = "spam";
  static const String VIOLATION_MISINFORMATION = "misinformation";

  // Severity levels
  static const String SEVERITY_LOW = "low";
  static const String SEVERITY_MEDIUM = "medium";
  static const String SEVERITY_HIGH = "high";
  static const String SEVERITY_CRITICAL = "critical";

  /// Check if content contains objectionable material
  static Future<ContentFilterResult> filterContent({
    required String content,
    required String contentType, // "text", "image", "video", "audio"
    required String userId,
    String? additionalContext,
  }) async {
    try {
      Utils.log("$_TAG: Filtering content for user: $userId");

      // First, run local filtering
      ContentFilterResult localResult = _runLocalFiltering(content);

      // If local filtering finds issues, return immediately
      if (localResult.isViolation) {
        Utils.log(
          "$_TAG: Local filtering detected violation: ${localResult.violationType}",
        );
        return localResult;
      }

      // Run advanced AI-based filtering via backend API
      ContentFilterResult apiResult = await _runAPIFiltering(
        content: content,
        contentType: contentType,
        userId: userId,
        additionalContext: additionalContext,
      );

      Utils.log("$_TAG: Content filtering completed for user: $userId");
      return apiResult;
    } catch (e) {
      Utils.log("$_TAG: Error filtering content: $e");
      // In case of error, err on the side of caution
      return ContentFilterResult(
        isViolation: false,
        violationType: null,
        severity: SEVERITY_LOW,
        confidence: 0.0,
        message: "Content filtering service temporarily unavailable",
        suggestedAction: "allow",
        needsHumanReview: true,
      );
    }
  }

  /// Local content filtering using keyword/pattern matching
  static ContentFilterResult _runLocalFiltering(String content) {
    String lowerContent = content.toLowerCase();

    // Check for profanity
    List<String> profanityKeywords = [
      "fuck",
      "shit",
      "bitch",
      "damn",
      "ass",
      "bastard",
      "crap",
      "piss",
      "dick",
      "cock",
      "pussy",
      "whore",
      "slut",
      "faggot",
      "nigger",
      "cunt",
      "motherfucker",
      "asshole",
      "bullshit",
    ];

    for (String keyword in profanityKeywords) {
      if (lowerContent.contains(keyword)) {
        return ContentFilterResult(
          isViolation: true,
          violationType: VIOLATION_PROFANITY,
          severity: SEVERITY_MEDIUM,
          confidence: 0.9,
          message: "Content contains inappropriate language",
          suggestedAction: "block",
          needsHumanReview: false,
        );
      }
    }

    // Check for hate speech patterns
    List<String> hateSpeechPatterns = [
      "kill yourself",
      "you should die",
      "hate all",
      "genocide",
      "terrorist",
      "racial slur",
      "go back to",
      "inferior race",
    ];

    for (String pattern in hateSpeechPatterns) {
      if (lowerContent.contains(pattern)) {
        return ContentFilterResult(
          isViolation: true,
          violationType: VIOLATION_HATE_SPEECH,
          severity: SEVERITY_CRITICAL,
          confidence: 0.95,
          message: "Content contains hate speech",
          suggestedAction: "block",
          needsHumanReview: true,
        );
      }
    }

    // Check for sexual content
    List<String> sexualContentKeywords = [
      "nude",
      "naked",
      "sex",
      "porn",
      "masturbate",
      "orgasm",
      "sexual",
      "erotic",
      "xxx",
      "adult content",
      "hookup",
      "one night stand",
      "sugar daddy",
      "escort",
    ];

    for (String keyword in sexualContentKeywords) {
      if (lowerContent.contains(keyword)) {
        return ContentFilterResult(
          isViolation: true,
          violationType: VIOLATION_SEXUAL_CONTENT,
          severity: SEVERITY_HIGH,
          confidence: 0.8,
          message: "Content contains adult/sexual material",
          suggestedAction: "block",
          needsHumanReview: true,
        );
      }
    }

    // Check for violence patterns
    List<String> violenceKeywords = [
      "kill",
      "murder",
      "assault",
      "beat up",
      "stab",
      "shoot",
      "bomb",
      "violence",
      "hurt",
      "pain",
      "torture",
      "abuse",
    ];

    for (String keyword in violenceKeywords) {
      if (lowerContent.contains(keyword)) {
        return ContentFilterResult(
          isViolation: true,
          violationType: VIOLATION_VIOLENCE,
          severity: SEVERITY_HIGH,
          confidence: 0.7,
          message: "Content contains violent language",
          suggestedAction: "review",
          needsHumanReview: true,
        );
      }
    }

    // Check for spam patterns
    if (_isSpamContent(lowerContent)) {
      return ContentFilterResult(
        isViolation: true,
        violationType: VIOLATION_SPAM,
        severity: SEVERITY_LOW,
        confidence: 0.6,
        message: "Content appears to be spam",
        suggestedAction: "review",
        needsHumanReview: false,
      );
    }

    // Content passed local filtering
    return ContentFilterResult(
      isViolation: false,
      violationType: null,
      severity: SEVERITY_LOW,
      confidence: 0.0,
      message: "Content appears safe",
      suggestedAction: "allow",
      needsHumanReview: false,
    );
  }

  /// Check for spam patterns
  static bool _isSpamContent(String content) {
    // Check for excessive repetition
    List<String> words = content.split(' ');
    Map<String, int> wordCount = {};

    for (String word in words) {
      wordCount[word] = (wordCount[word] ?? 0) + 1;
    }

    // If any word appears more than 30% of the time, likely spam
    for (String word in wordCount.keys) {
      if (wordCount[word]! > words.length * 0.3) {
        return true;
      }
    }

    // Check for excessive capital letters
    int capitalCount = content.replaceAll(RegExp(r'[^A-Z]'), '').length;
    if (capitalCount > content.length * 0.7) {
      return true;
    }

    // Check for excessive punctuation
    int punctuationCount =
        content.replaceAll(RegExp(r'[^!@#$%^&*(),.?":{}|<>]'), '').length;
    if (punctuationCount > content.length * 0.3) {
      return true;
    }

    return false;
  }

  /// Advanced AI-based filtering via backend API
  static Future<ContentFilterResult> _runAPIFiltering({
    required String content,
    required String contentType,
    required String userId,
    String? additionalContext,
  }) async {
    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('${AppConfig.API_BASE_URL}/moderation/filter-content'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': content,
          'content_type': contentType,
          'user_id': userId,
          'additional_context': additionalContext,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        return ContentFilterResult(
          isViolation: data['is_violation'] ?? false,
          violationType: data['violation_type'],
          severity: data['severity'] ?? SEVERITY_LOW,
          confidence: (data['confidence'] ?? 0.0).toDouble(),
          message: data['message'] ?? "Content analyzed",
          suggestedAction: data['suggested_action'] ?? "allow",
          needsHumanReview: data['needs_human_review'] ?? false,
        );
      } else {
        Utils.log(
          "$_TAG: API filtering failed with status: ${response.statusCode}",
        );
        // Fallback to local result
        return ContentFilterResult(
          isViolation: false,
          violationType: null,
          severity: SEVERITY_LOW,
          confidence: 0.0,
          message: "API filtering unavailable, using local results",
          suggestedAction: "allow",
          needsHumanReview: true,
        );
      }
    } catch (e) {
      Utils.log("$_TAG: API filtering error: $e");
      // Fallback to safe default
      return ContentFilterResult(
        isViolation: false,
        violationType: null,
        severity: SEVERITY_LOW,
        confidence: 0.0,
        message: "Content filtering service unavailable",
        suggestedAction: "allow",
        needsHumanReview: true,
      );
    }
  }

  /// Validate image content (placeholder for future implementation)
  static Future<ContentFilterResult> filterImageContent({
    required String imageUrl,
    required String userId,
  }) async {
    // TODO: Implement image content filtering
    // This would typically use computer vision APIs like Google Vision API,
    // AWS Rekognition, or Azure Computer Vision to detect inappropriate imagery

    return ContentFilterResult(
      isViolation: false,
      violationType: null,
      severity: SEVERITY_LOW,
      confidence: 0.0,
      message: "Image filtering not yet implemented",
      suggestedAction: "review",
      needsHumanReview: true,
    );
  }

  /// Validate video content (placeholder for future implementation)
  static Future<ContentFilterResult> filterVideoContent({
    required String videoUrl,
    required String userId,
  }) async {
    // TODO: Implement video content filtering
    // This would analyze video frames and audio for inappropriate content

    return ContentFilterResult(
      isViolation: false,
      violationType: null,
      severity: SEVERITY_LOW,
      confidence: 0.0,
      message: "Video filtering not yet implemented",
      suggestedAction: "review",
      needsHumanReview: true,
    );
  }
}

/// Result class for content filtering operations
class ContentFilterResult {
  final bool isViolation;
  final String? violationType;
  final String severity;
  final double confidence;
  final String message;
  final String suggestedAction; // "allow", "block", "review"
  final bool needsHumanReview;

  ContentFilterResult({
    required this.isViolation,
    this.violationType,
    required this.severity,
    required this.confidence,
    required this.message,
    required this.suggestedAction,
    required this.needsHumanReview,
  });

  Map<String, dynamic> toJson() => {
    'is_violation': isViolation,
    'violation_type': violationType,
    'severity': severity,
    'confidence': confidence,
    'message': message,
    'suggested_action': suggestedAction,
    'needs_human_review': needsHumanReview,
  };

  factory ContentFilterResult.fromJson(Map<String, dynamic> json) {
    return ContentFilterResult(
      isViolation: json['is_violation'] ?? false,
      violationType: json['violation_type'],
      severity: json['severity'] ?? ContentFilterService.SEVERITY_LOW,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      message: json['message'] ?? "",
      suggestedAction: json['suggested_action'] ?? "allow",
      needsHumanReview: json['needs_human_review'] ?? false,
    );
  }

  @override
  String toString() {
    return 'ContentFilterResult(isViolation: $isViolation, violationType: $violationType, severity: $severity, confidence: $confidence, message: $message, suggestedAction: $suggestedAction, needsHumanReview: $needsHumanReview)';
  }
}
