import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../services/moderation_service.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart';
import '../../../utils/consent_manager.dart';
import '../../../screens/shop/screens/shop/full_app/full_app.dart';

class ForceConsentScreen extends StatefulWidget {
  const ForceConsentScreen({Key? key}) : super(key: key);

  @override
  State<ForceConsentScreen> createState() => _ForceConsentScreenState();
}

class _ForceConsentScreenState extends State<ForceConsentScreen> {
  bool _consentToTerms = false;
  bool _consentToDataProcessing = false;
  bool _consentToContentModeration = false;
  bool _isSubmitting = false;

  bool get _allConsentsGiven =>
      _consentToTerms &&
      _consentToDataProcessing &&
      _consentToContentModeration;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent going back
      child: Scaffold(
        backgroundColor: CustomTheme.background,
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove back button
          title: FxText.titleLarge(
            'Legal Consent Required',
            color: Colors.white,
          ),
          backgroundColor: CustomTheme.primary,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: CustomTheme.primary,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Important Notice Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red[700],
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    FxText.titleLarge(
                      'Consent Required to Continue',
                      fontWeight: 700,
                      color: Colors.red[800],
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FxText.bodyMedium(
                      'To use this application, you must provide consent to our legal agreements. '
                      'This is required for legal compliance and to ensure the best user experience.',
                      color: Colors.red[700],
                      height: 1.5,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Consent Checkboxes
              FxText.titleMedium(
                'Required Consents',
                fontWeight: 600,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 16),

              // Terms of Service
              _buildConsentTile(
                icon: Icons.description,
                title: 'Terms of Service Agreement',
                description:
                    'I agree to the Terms of Service and End User License Agreement (EULA). '
                    'This includes accepting the rules and conditions for using this application.',
                value: _consentToTerms,
                onChanged: (value) {
                  setState(() {
                    _consentToTerms = value;
                  });
                },
                color: Colors.blue,
                required: true,
              ),

              // Data Processing
              _buildConsentTile(
                icon: Icons.data_usage,
                title: 'Data Processing Consent',
                description:
                    'I consent to the processing of my personal data in accordance with the Privacy Policy. '
                    'This includes data collection, storage, and usage for providing services.',
                value: _consentToDataProcessing,
                onChanged: (value) {
                  setState(() {
                    _consentToDataProcessing = value;
                  });
                },
                color: Colors.green,
                required: true,
              ),

              // Content Moderation
              _buildConsentTile(
                icon: Icons.security,
                title: 'Content Moderation Agreement',
                description:
                    'I agree to content moderation policies and understand that my content may be '
                    'reviewed for compliance with community guidelines and legal requirements.',
                value: _consentToContentModeration,
                onChanged: (value) {
                  setState(() {
                    _consentToContentModeration = value;
                  });
                },
                color: Colors.orange,
                required: true,
              ),

              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _allConsentsGiven && !_isSubmitting
                          ? _submitConsent
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _allConsentsGiven
                            ? CustomTheme.primary
                            : Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : FxText.titleSmall(
                            'Accept All & Continue',
                            color: Colors.white,
                            fontWeight: 700,
                          ),
                ),
              ),

              const SizedBox(height: 16),

              // Note
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey[600],
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        FxText.titleSmall(
                          'Important Information',
                          fontWeight: 600,
                          color: Colors.grey[800],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FxText.bodySmall(
                      '• All consents are required to use the application\n'
                      '• You can review and modify these settings later in Account settings\n'
                      '• Your privacy and data protection are our top priorities\n'
                      '• You may withdraw consent at any time, though some features may become unavailable',
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              //   add logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Utils.logout();
                    // Handle logout logic here
                    // Get.offAll(() => const HomeScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: FxText.titleSmall(
                    'Logout',
                    color: Colors.white,
                    fontWeight: 700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsentTile({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
    required bool required,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.titleSmall(title, fontWeight: 600),
                      if (required)
                        FxText.bodySmall(
                          'REQUIRED',
                          color: Colors.red[600],
                          fontWeight: 700,
                          fontSize: 10,
                        ),
                    ],
                  ),
                ),
                Checkbox(
                  value: value,
                  onChanged: (bool? newValue) => onChanged(newValue ?? false),
                  activeColor: color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: FxText.bodySmall(
                description,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitConsent() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ModerationService.submitLegalConsent(
        accepted: _allConsentsGiven,
      );

      if (result['code'] == 1) {
        // Update local consent status
        await ConsentManager.setLocalConsent(true);

        Utils.toast('Legal consent completed successfully');

        // Navigate to main app
        Get.offAll(() => const HomeScreen());
      } else {
        Utils.toast(
          result['message'] ?? 'Failed to submit consent',
          color: Colors.red,
        );
      }
    } catch (e) {
      Utils.toast(
        'An error occurred while submitting consent',
        color: Colors.red,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
