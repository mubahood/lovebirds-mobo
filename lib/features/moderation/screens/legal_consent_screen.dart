import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';

import '../../../services/moderation_service.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart';
import '../../../utils/consent_manager.dart';

class LegalConsentScreen extends StatefulWidget {
  const LegalConsentScreen({Key? key}) : super(key: key);

  @override
  State<LegalConsentScreen> createState() => _LegalConsentScreenState();
}

class _LegalConsentScreenState extends State<LegalConsentScreen> {
  bool _consentToTerms = false;
  bool _consentToDataProcessing = false;
  bool _consentToContentModeration = false;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadConsentStatus();
  }

  Future<void> _loadConsentStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ModerationService.getLegalConsentStatus();
      if (result['code'] == 1 && result['data'] != null) {
        final data = result['data'];
        setState(() {
          _consentToTerms =
              data['consent_to_terms'] == 1 || data['consent_to_terms'] == true;
          _consentToDataProcessing =
              data['consent_to_data_processing'] == 1 ||
              data['consent_to_data_processing'] == true;
          _consentToContentModeration =
              data['consent_to_content_moderation'] == 1 ||
              data['consent_to_content_moderation'] == true;
        });
      }
    } catch (e) {
      Utils.toast('Failed to load consent status');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitConsent() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ModerationService.submitLegalConsent(
        accepted:
            _consentToTerms &&
            _consentToDataProcessing &&
            _consentToContentModeration,
      );

      if (result['code'] == 1) {
        // Update local consent status
        await ConsentManager.setLocalConsent(
          _consentToTerms &&
              _consentToDataProcessing &&
              _consentToContentModeration,
        );
        Utils.toast('Legal consent preferences updated successfully');
      } else {
        Utils.toast(
          result['message'] ?? 'Failed to update consent preferences',
        );
      }
    } catch (e) {
      Utils.toast('An error occurred while updating consent preferences');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: FxText.titleLarge('Legal Consent', color: Colors.white),
        backgroundColor: CustomTheme.primary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: CustomTheme.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Card(
                      color: Colors.blue[50],
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.gavel,
                                  color: Colors.blue[700],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                FxText.titleMedium(
                                  'Legal Consent Management',
                                  fontWeight: 600,
                                  color: Colors.blue[800],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FxText.bodyMedium(
                              'Manage your consent preferences for legal and compliance requirements. '
                              'These settings help us provide better service while respecting your privacy and legal rights.',
                              color: Colors.blue[700],
                              height: 1.4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Consent Options
                    FxText.titleMedium(
                      'Consent Preferences',
                      fontWeight: 600,
                      color: Colors.grey[800],
                    ),
                    const SizedBox(height: 16),

                    // Terms of Service Consent
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
                    ),

                    // Data Processing Consent
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
                    ),

                    // Content Moderation Consent
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
                    ),

                    const SizedBox(height: 32),

                    // Important Notice
                    Card(
                      color: Colors.amber[50],
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber,
                                  color: Colors.amber[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                FxText.titleSmall(
                                  'Important Notice',
                                  fontWeight: 600,
                                  color: Colors.amber[800],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FxText.bodySmall(
                              '• You can withdraw consent at any time\n'
                              '• Some features may not be available without certain consents\n'
                              '• Changes take effect immediately upon saving\n'
                              '• For questions about data processing, contact our support team',
                              color: Colors.amber[700],
                              height: 1.6,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitConsent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                  'Save Consent Preferences',
                                  color: Colors.white,
                                  fontWeight: 600,
                                ),
                      ),
                    ),
                  ],
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
  }) {
    return Card(
      elevation: 1,
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
                Expanded(child: FxText.titleSmall(title, fontWeight: 600)),
                Switch(value: value, onChanged: onChanged, activeColor: color),
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
}
