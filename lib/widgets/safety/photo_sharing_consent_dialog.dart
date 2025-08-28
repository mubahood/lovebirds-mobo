import 'package:flutter/material.dart';

// Enums and data structures for photo sharing safety
enum PhotoSharingRisk { low, medium, high }

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

// Mock service for photo sharing safety
class MockPhotoSafetyService {
  PhotoSharingWarning checkPhotoSharingRisk(
    String senderId,
    String receiverId,
  ) {
    // Mock risk assessment - in real app, this would check relationship duration, etc.
    bool isNewRelationship = true; // Mock: assume new relationship
    bool isFirstPhoto = true; // Mock: assume first photo share

    PhotoSharingRisk riskLevel = PhotoSharingRisk.medium;
    List<String> warnings = [];

    if (isNewRelationship) {
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
}

/// Photo Sharing Consent Widget
/// Shows safety warnings and requires explicit consent before sharing photos
class PhotoSharingConsentDialog extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final VoidCallback onConsent;
  final VoidCallback onCancel;

  const PhotoSharingConsentDialog({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.onConsent,
    required this.onCancel,
  });

  @override
  State<PhotoSharingConsentDialog> createState() =>
      _PhotoSharingConsentDialogState();
}

class _PhotoSharingConsentDialogState extends State<PhotoSharingConsentDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool _hasReadWarnings = false;
  bool _hasAcceptedConsent = false;
  PhotoSharingWarning? _warning;
  final MockPhotoSafetyService _safetyService = MockPhotoSafetyService();

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _loadPhotoSharingWarning();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _loadPhotoSharingWarning() {
    setState(() {
      _warning = _safetyService.checkPhotoSharingRisk(
        widget.senderId,
        widget.receiverId,
      );
    });
  }

  void _handleConsentToggle(bool? value) {
    setState(() {
      _hasAcceptedConsent = value ?? false;
    });
  }

  void _handleProceed() {
    if (_hasReadWarnings && _hasAcceptedConsent) {
      _slideController.reverse().then((_) {
        widget.onConsent();
      });
    }
  }

  void _handleCancel() {
    _slideController.reverse().then((_) {
      widget.onCancel();
    });
  }

  Color _getRiskColor(PhotoSharingRisk risk) {
    switch (risk) {
      case PhotoSharingRisk.low:
        return Colors.green;
      case PhotoSharingRisk.medium:
        return Colors.orange;
      case PhotoSharingRisk.high:
        return Colors.red;
    }
  }

  IconData _getRiskIcon(PhotoSharingRisk risk) {
    switch (risk) {
      case PhotoSharingRisk.low:
        return Icons.check_circle_outline;
      case PhotoSharingRisk.medium:
        return Icons.warning_amber_outlined;
      case PhotoSharingRisk.high:
        return Icons.error_outline;
    }
  }

  String _getRiskTitle(PhotoSharingRisk risk) {
    switch (risk) {
      case PhotoSharingRisk.low:
        return 'Low Risk';
      case PhotoSharingRisk.medium:
        return 'Medium Risk';
      case PhotoSharingRisk.high:
        return 'High Risk';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_warning == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with risk indicator
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getRiskColor(
                          _warning!.riskLevel,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getRiskIcon(_warning!.riskLevel),
                        color: _getRiskColor(_warning!.riskLevel),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Photo Sharing Safety',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getRiskTitle(_warning!.riskLevel),
                            style: TextStyle(
                              fontSize: 14,
                              color: _getRiskColor(_warning!.riskLevel),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Safety warnings
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Safety Reminders',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._warning!.warnings.map(
                        (warning) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade600,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  warning,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Additional safety tips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Safety Tips',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Photos can be saved or screenshot by the recipient\n'
                        '• Avoid sharing photos with personal information\n'
                        '• You can report inappropriate photo requests\n'
                        '• Trust your instincts about what to share',
                        style: TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Read confirmation
                Row(
                  children: [
                    Checkbox(
                      value: _hasReadWarnings,
                      onChanged: (value) {
                        setState(() {
                          _hasReadWarnings = value ?? false;
                        });
                      },
                      activeColor: Colors.pink,
                    ),
                    const Expanded(
                      child: Text(
                        'I have read and understand the safety warnings',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),

                // Consent confirmation
                if (_warning!.shouldShowConsent) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _hasAcceptedConsent,
                        onChanged:
                            _hasReadWarnings ? _handleConsentToggle : null,
                        activeColor: Colors.pink,
                      ),
                      Expanded(
                        child: Text(
                          _warning!.consentMessage,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _handleCancel,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            (_hasReadWarnings &&
                                    (!_warning!.shouldShowConsent ||
                                        _hasAcceptedConsent))
                                ? _handleProceed
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Share Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to show photo sharing consent dialog
Future<bool> showPhotoSharingConsent(
  BuildContext context,
  String senderId,
  String receiverId,
) async {
  bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => PhotoSharingConsentDialog(
          senderId: senderId,
          receiverId: receiverId,
          onConsent: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
        ),
  );

  return result ?? false;
}
