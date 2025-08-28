import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/CustomTheme.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final bool isRequired;

  const PrivacyPolicyScreen({Key? key, this.isRequired = false})
    : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _hasAccepted = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
  }

  void _checkScrollPosition() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        foregroundColor: Colors.white,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lovebirds Dating Privacy Policy',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: July 2025',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 24),

                  _buildSection('Information We Collect', [
                    'Profile Information: Name, age, gender, bio, photos, and dating preferences you provide',
                    'Usage Data: How you interact with profiles, swipe patterns, and messaging activity',
                    'Device Information: Device type, operating system, and app version for compatibility',
                    'Location Data: Your location for finding nearby matches (with your explicit consent)',
                    'Contact Information: Email and phone number for account verification and communication',
                    'Social Media: Information from connected social accounts (optional)',
                  ]),

                  _buildSection('How We Use Your Information', [
                    'Match you with compatible profiles based on preferences and location',
                    'Facilitate meaningful connections and conversations',
                    'Provide safety features including profile verification and reporting',
                    'Send notifications about matches, messages, and app updates',
                    'Improve our matching algorithm and dating experience',
                    'Ensure platform safety and prevent fraudulent activity',
                    'Comply with legal obligations and law enforcement requests',
                  ]),

                  _buildSection('Data Sharing and Disclosure', [
                    'We never sell your personal information or dating data to third parties',
                    'Profile information is only shared with potential matches you interact with',
                    'We may share limited data with verified service providers (payment processing, messaging)',
                    'Photos and profile details are only visible to users you choose to match with',
                    'We may disclose information when legally required or to protect user safety',
                    'Aggregated, anonymous data may be used for improving matching algorithms',
                  ]),

                  _buildSection('Data Security', [
                    'End-to-end encryption for all private messages and sensitive data',
                    'Secure photo storage with access controls and verification',
                    'Advanced fraud detection and fake profile prevention',
                    'Regular security audits and penetration testing',
                    'Two-factor authentication available for account protection',
                    'Immediate account lockdown if suspicious activity is detected',
                  ]),

                  _buildSection('Your Rights and Choices', [
                    'Control who can see your profile and photos',
                    'Hide your profile or go invisible at any time',
                    'Delete specific photos or conversations',
                    'Block and report users who violate guidelines',
                    'Request all your data or permanently delete your account',
                    'Opt-out of promotional emails and push notifications',
                    'Change location sharing and discovery preferences',
                    'Download a copy of your profile data and conversations',
                  ]),

                  _buildSection('Data Retention', [
                    'Active profiles and conversations are maintained while you use the app',
                    'Deleted accounts are permanently removed within 30 days',
                    'Blocked user data is retained for safety and to prevent re-contact',
                    'Message history is deleted from both users when one deletes the conversation',
                    'Safety reports are retained for community protection purposes',
                    'Some data may be retained longer if required by law enforcement',
                  ]),

                  _buildSection('Age Requirements and Safety', [
                    'You must be 18 or older to use Lovebirds Dating',
                    'Age verification is required during registration',
                    'We actively detect and remove underage users',
                    'Additional verification may be required for profile authenticity',
                    'Report any suspected underage users immediately',
                  ]),

                  _buildSection('Contact Information', [
                    'Privacy concerns: privacy@lovebirds.dating',
                    'Safety reports: safety@lovebirds.dating',
                    'Data requests: data@lovebirds.dating',
                    'General support: support@lovebirds.dating',
                    'Emergency safety: emergency@lovebirds.dating',
                    'Response time: 24 hours for safety issues, 72 hours for other requests',
                  ]),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (widget.isRequired) _buildAcceptanceSection(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAcceptanceSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        border: Border(top: BorderSide(color: CustomTheme.primary, width: 1)),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: _hasAccepted,
            onChanged:
                _hasScrolledToBottom
                    ? (value) => setState(() => _hasAccepted = value ?? false)
                    : null,
            title: const Text(
              'I have read and agree to the Privacy Policy',
              style: TextStyle(color: Colors.white),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: CustomTheme.primary,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (_hasScrolledToBottom && _hasAccepted)
                      ? () {
                        // Handle acceptance logic here
                        Get.back(result: true);
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _hasScrolledToBottom
                    ? 'Accept Privacy Policy'
                    : 'Please scroll to the bottom first',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
