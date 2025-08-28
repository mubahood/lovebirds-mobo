import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';

import '../utils/Utilities.dart';
import '../models/RespondModel.dart';
import '../models/UserModel.dart';

/// Enhanced Safety Service for Phase 8.2 User Safety & Verification
/// Comprehensive safety and verification system for user protection
class EnhancedSafetyService {
  static final EnhancedSafetyService _instance =
      EnhancedSafetyService._internal();
  factory EnhancedSafetyService() => _instance;
  EnhancedSafetyService._internal();

  static const String _verificationStatusKey = 'verification_status';
  static const String _safetyScoreKey = 'safety_score';
  static const String _emergencyContactsKey = 'emergency_contacts';
  static const String _safetyTipsKey = 'safety_tips_viewed';

  // Verification status
  ValueNotifier<VerificationStatus> verificationStatus = ValueNotifier(
    VerificationStatus.none,
  );
  ValueNotifier<double> safetyScore = ValueNotifier(0.0);
  ValueNotifier<List<EmergencyContact>> emergencyContacts = ValueNotifier([]);

  // Safety features
  ValueNotifier<List<SafetyTip>> safetyTips = ValueNotifier([]);
  ValueNotifier<bool> backgroundCheckEnabled = ValueNotifier(false);
  ValueNotifier<List<SafetyReport>> safetyReports = ValueNotifier([]);

  /// Initialize enhanced safety service
  Future<void> initialize() async {
    await _loadStoredData();
    await _loadSafetyTips();
    await _updateSafetyScore();
  }

  /// Load stored data from SharedPreferences
  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load verification status
    final statusString = prefs.getString(_verificationStatusKey);
    if (statusString != null) {
      verificationStatus.value = VerificationStatus.values.firstWhere(
        (status) => status.toString() == statusString,
        orElse: () => VerificationStatus.none,
      );
    }

    // Load safety score
    safetyScore.value = prefs.getDouble(_safetyScoreKey) ?? 0.0;

    // Load emergency contacts
    final contactsJson = prefs.getString(_emergencyContactsKey);
    if (contactsJson != null) {
      final List<dynamic> contactsList = json.decode(contactsJson);
      emergencyContacts.value =
          contactsList.map((json) => EmergencyContact.fromJson(json)).toList();
    }

    // Load background check status
    backgroundCheckEnabled.value =
        prefs.getBool('background_check_enabled') ?? false;
  }

  /// Start photo verification process
  Future<PhotoVerificationResult> startPhotoVerification() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );

      if (image == null) {
        return PhotoVerificationResult(
          success: false,
          message: 'Photo capture cancelled',
        );
      }

      // Convert image to base64
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Send to backend for verification
      final response = await Utils.http_post('verify-photo', {
        'photo_data': base64Image,
        'verification_type': 'selfie_verification',
      });

      if (response.code == 1) {
        final verificationData = response.data;
        final isVerified = verificationData['is_verified'] == true;
        final confidence =
            double.tryParse(verificationData['confidence'].toString()) ?? 0.0;

        if (isVerified && confidence >= 0.85) {
          verificationStatus.value = VerificationStatus.photoVerified;
          await saveVerificationStatus();
          await _updateSafetyScore();

          return PhotoVerificationResult(
            success: true,
            message: 'Photo verification successful!',
            confidence: confidence,
          );
        } else {
          return PhotoVerificationResult(
            success: false,
            message: 'Photo verification failed. Please try again.',
            confidence: confidence,
          );
        }
      }

      return PhotoVerificationResult(
        success: false,
        message: 'Verification service unavailable',
      );
    } catch (e) {
      debugPrint('Photo verification error: $e');
      return PhotoVerificationResult(
        success: false,
        message: 'Photo verification failed: $e',
      );
    }
  }

  /// Start identity verification process
  Future<IdentityVerificationResult> startIdentityVerification({
    required String documentType,
    required XFile frontImage,
    XFile? backImage,
  }) async {
    try {
      // Convert images to base64
      final frontBytes = await frontImage.readAsBytes();
      final frontBase64 = base64Encode(frontBytes);

      String? backBase64;
      if (backImage != null) {
        final backBytes = await backImage.readAsBytes();
        backBase64 = base64Encode(backBytes);
      }

      final response = await Utils.http_post('verify-identity', {
        'document_type': documentType,
        'front_image': frontBase64,
        'back_image': backBase64,
      });

      if (response.code == 1) {
        final verificationData = response.data;
        final isVerified = verificationData['is_verified'] == true;
        final extractedInfo = verificationData['extracted_info'] ?? {};

        if (isVerified) {
          verificationStatus.value = VerificationStatus.identityVerified;
          await saveVerificationStatus();
          await _updateSafetyScore();

          return IdentityVerificationResult(
            success: true,
            message: 'Identity verification successful!',
            extractedInfo: Map<String, dynamic>.from(extractedInfo),
          );
        } else {
          return IdentityVerificationResult(
            success: false,
            message:
                'Identity verification failed. Please ensure document is clear and valid.',
          );
        }
      }

      return IdentityVerificationResult(
        success: false,
        message: 'Identity verification service unavailable',
      );
    } catch (e) {
      debugPrint('Identity verification error: $e');
      return IdentityVerificationResult(
        success: false,
        message: 'Identity verification failed: $e',
      );
    }
  }

  /// Request background check
  Future<BackgroundCheckResult> requestBackgroundCheck({
    required String fullName,
    required DateTime dateOfBirth,
    required String socialSecurityNumber,
  }) async {
    try {
      final response = await Utils.http_post('request-background-check', {
        'full_name': fullName,
        'date_of_birth': dateOfBirth.toIso8601String(),
        'ssn_hash': _hashSensitiveData(socialSecurityNumber),
      });

      if (response.code == 1) {
        backgroundCheckEnabled.value = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('background_check_enabled', true);

        return BackgroundCheckResult(
          success: true,
          message:
              'Background check requested successfully. Results will be available within 24-48 hours.',
          requestId: response.data['request_id'],
        );
      }

      return BackgroundCheckResult(
        success: false,
        message: response.message ?? 'Background check request failed',
      );
    } catch (e) {
      debugPrint('Background check error: $e');
      return BackgroundCheckResult(
        success: false,
        message: 'Background check request failed: $e',
      );
    }
  }

  /// Add emergency contact
  Future<bool> addEmergencyContact({
    required String name,
    required String phoneNumber,
    required String relationship,
    String? email,
  }) async {
    try {
      final contact = EmergencyContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        phoneNumber: phoneNumber,
        relationship: relationship,
        email: email,
        isVerified: false,
      );

      // Send verification SMS/email
      final response = await Utils.http_post('add-emergency-contact', {
        'name': name,
        'phone_number': phoneNumber,
        'relationship': relationship,
        'email': email,
      });

      if (response.code == 1) {
        final updatedContacts = List<EmergencyContact>.from(
          emergencyContacts.value,
        );
        updatedContacts.add(
          contact.copyWith(id: response.data['contact_id'], isVerified: true),
        );
        emergencyContacts.value = updatedContacts;

        await _saveEmergencyContacts();
        await _updateSafetyScore();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error adding emergency contact: $e');
      return false;
    }
  }

  /// Remove emergency contact
  Future<bool> removeEmergencyContact(String contactId) async {
    try {
      final response = await Utils.http_post('remove-emergency-contact', {
        'contact_id': contactId,
      });

      if (response.code == 1) {
        final updatedContacts =
            emergencyContacts.value
                .where((contact) => contact.id != contactId)
                .toList();
        emergencyContacts.value = updatedContacts;

        await _saveEmergencyContacts();
        await _updateSafetyScore();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error removing emergency contact: $e');
      return false;
    }
  }

  /// Report unsafe behavior
  Future<bool> reportUnsafeBehavior({
    required String reportedUserId,
    required String reportType,
    required String description,
    List<String>? evidence,
  }) async {
    try {
      final response = await Utils.http_post('report-unsafe-behavior', {
        'reported_user_id': reportedUserId,
        'report_type': reportType,
        'description': description,
        'evidence': evidence,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (response.code == 1) {
        final report = SafetyReport(
          id: response.data['report_id'],
          reportedUserId: reportedUserId,
          reportType: reportType,
          description: description,
          status: 'submitted',
          submittedAt: DateTime.now(),
        );

        final updatedReports = List<SafetyReport>.from(safetyReports.value);
        updatedReports.add(report);
        safetyReports.value = updatedReports;

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error reporting unsafe behavior: $e');
      return false;
    }
  }

  /// Load safety tips and guidelines
  Future<void> _loadSafetyTips() async {
    try {
      final response = await Utils.http_get('safety-tips', {});

      if (response.code == 1 && response.data != null) {
        final List<dynamic> tipsData = response.data;
        safetyTips.value =
            tipsData.map((json) => SafetyTip.fromJson(json)).toList();
      } else {
        // Load default safety tips
        _loadDefaultSafetyTips();
      }
    } catch (e) {
      debugPrint('Error loading safety tips: $e');
      _loadDefaultSafetyTips();
    }
  }

  /// Load default safety tips
  void _loadDefaultSafetyTips() {
    safetyTips.value = [
      SafetyTip(
        id: '1',
        title: 'Meet in Public Places',
        description:
            'Always meet for first dates in public, well-lit locations with other people around.',
        category: 'first_date',
        importance: 'high',
        icon: 'users',
      ),
      SafetyTip(
        id: '2',
        title: 'Tell Someone Your Plans',
        description:
            'Share your date details with a trusted friend or family member.',
        category: 'communication',
        importance: 'high',
        icon: 'message-circle',
      ),
      SafetyTip(
        id: '3',
        title: 'Trust Your Instincts',
        description:
            'If something feels wrong, trust your gut and leave immediately.',
        category: 'intuition',
        importance: 'critical',
        icon: 'alert-triangle',
      ),
      SafetyTip(
        id: '4',
        title: 'Have Your Own Transportation',
        description:
            'Drive yourself or arrange your own ride to maintain independence.',
        category: 'transportation',
        importance: 'medium',
        icon: 'car',
      ),
      SafetyTip(
        id: '5',
        title: 'Limit Alcohol Consumption',
        description: 'Stay alert by limiting alcohol intake on dates.',
        category: 'personal_safety',
        importance: 'medium',
        icon: 'coffee',
      ),
      SafetyTip(
        id: '6',
        title: 'Video Chat Before Meeting',
        description:
            'Verify identity with a video call before meeting in person.',
        category: 'verification',
        importance: 'high',
        icon: 'video',
      ),
    ];
  }

  /// Calculate and update safety score
  Future<void> _updateSafetyScore() async {
    double score = 0.0;

    // Base score components
    if (verificationStatus.value == VerificationStatus.photoVerified) {
      score += 25.0;
    }
    if (verificationStatus.value == VerificationStatus.identityVerified) {
      score += 35.0;
    }
    if (backgroundCheckEnabled.value) {
      score += 30.0;
    }

    // Emergency contacts (up to 10 points)
    score += (emergencyContacts.value.length * 5.0).clamp(0.0, 10.0);

    safetyScore.value = score.clamp(0.0, 100.0);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_safetyScoreKey, safetyScore.value);
  }

  /// Hash sensitive data for security
  String _hashSensitiveData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Save verification status
  Future<void> saveVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _verificationStatusKey,
      verificationStatus.value.toString(),
    );
  }

  /// Update safety score (public method for demo)
  Future<void> updateSafetyScore() async {
    await _updateSafetyScore();
  }

  /// Save emergency contacts
  Future<void> _saveEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = json.encode(
      emergencyContacts.value.map((contact) => contact.toJson()).toList(),
    );
    await prefs.setString(_emergencyContactsKey, contactsJson);
  }

  /// Mark safety tips as viewed
  Future<void> markSafetyTipsAsViewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_safetyTipsKey, true);
  }

  /// Check if safety tips have been viewed
  Future<bool> haveSafetyTipsBeenViewed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_safetyTipsKey) ?? false;
  }

  /// Send panic alert to emergency contacts
  Future<bool> sendPanicAlert({
    required String alertMessage,
    Map<String, dynamic>? locationData,
  }) async {
    try {
      final response = await Utils.http_post('send-panic-alert', {
        'alert_message': alertMessage,
        'location_data': locationData,
        'emergency_contacts':
            emergencyContacts.value.map((c) => c.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      return response.code == 1;
    } catch (e) {
      debugPrint('Error sending panic alert: $e');
      return false;
    }
  }

  /// Get safety score explanation
  String getSafetyScoreExplanation() {
    final score = safetyScore.value;

    if (score >= 80) {
      return 'Excellent safety profile! You have comprehensive verification and safety measures in place.';
    } else if (score >= 60) {
      return 'Good safety profile. Consider adding more verification methods to enhance your safety score.';
    } else if (score >= 40) {
      return 'Moderate safety profile. We recommend completing photo verification and adding emergency contacts.';
    } else {
      return 'Basic safety profile. Please complete verification steps to improve your safety and trustworthiness.';
    }
  }

  /// Cleanup and dispose
  void dispose() {
    verificationStatus.dispose();
    safetyScore.dispose();
    emergencyContacts.dispose();
    safetyTips.dispose();
    backgroundCheckEnabled.dispose();
    safetyReports.dispose();
  }
}

/// Enums and Model Classes
enum VerificationStatus {
  none,
  photoVerified,
  identityVerified,
  backgroundChecked,
  fullyVerified,
}

class PhotoVerificationResult {
  final bool success;
  final String message;
  final double? confidence;

  PhotoVerificationResult({
    required this.success,
    required this.message,
    this.confidence,
  });
}

class IdentityVerificationResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? extractedInfo;

  IdentityVerificationResult({
    required this.success,
    required this.message,
    this.extractedInfo,
  });
}

class BackgroundCheckResult {
  final bool success;
  final String message;
  final String? requestId;

  BackgroundCheckResult({
    required this.success,
    required this.message,
    this.requestId,
  });
}

class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final String? email;
  final bool isVerified;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.email,
    required this.isVerified,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      relationship: json['relationship'] ?? '',
      email: json['email'],
      isVerified: json['is_verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'relationship': relationship,
      'email': email,
      'is_verified': isVerified,
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    String? email,
    bool? isVerified,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class SafetyTip {
  final String id;
  final String title;
  final String description;
  final String category;
  final String importance;
  final String icon;

  SafetyTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.importance,
    required this.icon,
  });

  factory SafetyTip.fromJson(Map<String, dynamic> json) {
    return SafetyTip(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      importance: json['importance'] ?? 'medium',
      icon: json['icon'] ?? 'info',
    );
  }

  Color get importanceColor {
    switch (importance) {
      case 'critical':
        return const Color(0xFFD32F2F);
      case 'high':
        return const Color(0xFFFF9800);
      case 'medium':
        return const Color(0xFF1976D2);
      default:
        return const Color(0xFF388E3C);
    }
  }
}

class SafetyReport {
  final String id;
  final String reportedUserId;
  final String reportType;
  final String description;
  final String status;
  final DateTime submittedAt;

  SafetyReport({
    required this.id,
    required this.reportedUserId,
    required this.reportType,
    required this.description,
    required this.status,
    required this.submittedAt,
  });

  factory SafetyReport.fromJson(Map<String, dynamic> json) {
    return SafetyReport(
      id: json['id'].toString(),
      reportedUserId: json['reported_user_id'] ?? '',
      reportType: json['report_type'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'submitted',
      submittedAt: DateTime.parse(json['submitted_at']),
    );
  }
}
