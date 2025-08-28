import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/CustomTheme.dart';

class TermsOfServiceScreen extends StatefulWidget {
  final bool isRequired;

  const TermsOfServiceScreen({Key? key, this.isRequired = false})
    : super(key: key);

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
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
          'Terms of Service',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header warning
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CustomTheme.primary.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: CustomTheme.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: CustomTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please read these terms carefully. Your use of Lovebirds Dating is subject to these conditions.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Terms content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'ZERO TOLERANCE POLICY',
                    'Lovebirds Dating maintains a strict zero-tolerance policy for harassment, fake profiles, and inappropriate behavior. Any violation will result in immediate account suspension and potential law enforcement involvement.',
                    isImportant: true,
                  ),

                  _buildSection(
                    '1. ACCEPTABLE USE',
                    'You agree to use Lovebirds Dating for genuine dating and relationship purposes. This includes:\n\n'
                        '• Creating an authentic profile with real photos and information\n'
                        '• Treating all users with respect and dignity\n'
                        '• No harassment, stalking, or unwanted contact after being blocked\n'
                        '• No solicitation for commercial services, escort services, or paid arrangements\n'
                        '• No sharing of explicit content without consent\n'
                        '• No attempts to obtain personal information for harmful purposes\n'
                        '• Respecting boundaries and consent in all interactions',
                  ),

                  _buildSection(
                    '2. PROFILE AUTHENTICITY',
                    'All profiles must be genuine and represent real people:\n\n'
                        '• Use only your own recent, unedited photos\n'
                        '• Provide accurate age, location, and personal information\n'
                        '• No fake profiles, catfishing, or impersonation\n'
                        '• Photos must clearly show your face\n'
                        '• Regular verification may be required to maintain account status\n'
                        '• Misleading profiles will be removed immediately',
                  ),

                  _buildSection(
                    '3. COMMUNICATION AND CONSENT',
                    'Respect and consent are fundamental to our community:\n\n'
                        '• Obtain consent before sharing personal contact information\n'
                        '• Respect when someone says no or blocks you\n'
                        '• No unsolicited explicit messages or images\n'
                        '• Report harassment or inappropriate behavior immediately\n'
                        '• Conversations should focus on getting to know each other respectfully',
                  ),

                  _buildSection(
                    '4. SAFETY AND SECURITY',
                    'Your safety is our top priority:\n\n'
                        '• Meet in public places for first dates\n'
                        '• Trust your instincts and report suspicious behavior\n'
                        '• Never share personal information too quickly\n'
                        '• Use our in-app messaging until you feel comfortable\n'
                        '• Report any users who ask for money or financial information\n'
                        '• Block and report users who make you uncomfortable',
                  ),

                  _buildSection(
                    '5. PROHIBITED ACTIVITIES',
                    'The following activities will result in immediate account termination:\n\n'
                        '• Creating fake profiles or using stolen photos\n'
                        '• Harassment, stalking, or threatening behavior\n'
                        '• Soliciting money, gifts, or commercial services\n'
                        '• Sharing or requesting explicit content\n'
                        '• Attempting to contact users outside the app after being blocked\n'
                        '• Using the platform for anything other than genuine dating',
                  ),

                  _buildSection(
                    '6. ENFORCEMENT AND CONSEQUENCES',
                    'Safety violations will result in immediate action:\n\n'
                        '• Profile verification required for suspicious accounts\n'
                        '• Temporary suspension for first-time minor violations\n'
                        '• Immediate permanent ban for serious safety violations\n'
                        '• Law enforcement involvement for illegal activities\n'
                        '• No appeals for fake profiles or harassment cases',
                  ),

                  _buildSection(
                    '7. PREMIUM FEATURES AND PAYMENTS',
                    'Enhanced features are available through subscription:\n\n'
                        '• Premium subscriptions provide additional matching capabilities\n'
                        '• All payments are processed securely through app stores\n'
                        '• Refunds are subject to app store policies\n'
                        '• Subscription benefits are clearly outlined before purchase\n'
                        '• Account termination forfeits remaining subscription time',
                  ),

                  _buildSection(
                    '8. CONTACT & SUPPORT',
                    'Need help or want to report an issue?\n\n'
                        '• Use the in-app reporting system for safety concerns\n'
                        '• Contact support@lovebirds.dating for technical problems\n'
                        '• Safety reports are prioritized and reviewed within 24 hours\n'
                        '• Emergency safety line: emergency@lovebirds.dating',
                  ),

                  const SizedBox(height: 40),

                  // Scroll indicator
                  if (!_hasScrolledToBottom)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CustomTheme.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: CustomTheme.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: CustomTheme.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Please scroll to the bottom to continue',
                            style: TextStyle(
                              color: CustomTheme.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Acceptance section
          if (widget.isRequired)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CustomTheme.card,
                border: Border(top: BorderSide(color: Colors.grey[800]!)),
              ),
              child: Column(
                children: [
                  // Acceptance checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _hasAccepted,
                        activeColor: CustomTheme.primary,
                        checkColor: Colors.white,
                        onChanged:
                            _hasScrolledToBottom
                                ? (value) {
                                  setState(() {
                                    _hasAccepted = value ?? false;
                                  });
                                }
                                : null,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap:
                              _hasScrolledToBottom
                                  ? () {
                                    setState(() {
                                      _hasAccepted = !_hasAccepted;
                                    });
                                  }
                                  : null,
                          child: Text(
                            'I have read and agree to the Terms of Service and Community Guidelines',
                            style: TextStyle(
                              color:
                                  _hasScrolledToBottom
                                      ? Colors.white
                                      : Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(result: false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[600]!),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Decline',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _hasAccepted
                                  ? () => Get.back(result: true)
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _hasAccepted
                                    ? CustomTheme.primary
                                    : Colors.grey[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Accept',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            // Simple close button for non-required viewing
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content, {
    bool isImportant = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isImportant
                      ? CustomTheme.primary.withValues(alpha: 0.15)
                      : CustomTheme.card,
              borderRadius: BorderRadius.circular(6),
              border:
                  isImportant
                      ? Border.all(
                        color: CustomTheme.primary.withValues(alpha: 0.3),
                      )
                      : null,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isImportant ? CustomTheme.primary : CustomTheme.accent,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.white,
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
