import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/CustomTheme.dart';

class CommunityGuidelinesScreen extends StatefulWidget {
  final bool isRequired;

  const CommunityGuidelinesScreen({Key? key, this.isRequired = false})
    : super(key: key);

  @override
  State<CommunityGuidelinesScreen> createState() =>
      _CommunityGuidelinesScreenState();
}

class _CommunityGuidelinesScreenState extends State<CommunityGuidelinesScreen> {
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
          'Community Guidelines',
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
                  Text(
                    'Lovebirds Dating Community Guidelines',
                    style: TextStyle(
                      fontSize: 24,
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

                  _buildIntroSection(),

                  _buildSection('Zero Tolerance Policy', [
                    'Lovebirds Dating maintains a ZERO TOLERANCE policy for harassment, fake profiles, and predatory behavior',
                    'Violations result in immediate account suspension or permanent ban',
                    'No warnings given for serious safety violations including stalking, threats, or catfishing',
                    'Law enforcement will be contacted for illegal activities',
                    'Appeals process available but safety decisions are final',
                  ], isHighlight: true),

                  _buildSection('Prohibited Content and Behavior', [
                    'Fake profiles, catfishing, or using stolen/misleading photos',
                    'Harassment, stalking, threats, or unwanted contact after being blocked',
                    'Explicit sexual content, nudity, or unsolicited intimate images',
                    'Discrimination based on race, religion, gender, sexual orientation, or other protected characteristics',
                    'Requests for money, gifts, or commercial/escort services',
                    'Sharing personal information without consent (phone numbers, addresses, social media)',
                    'Promoting illegal activities, substances, or harmful behaviors',
                    'Spam messages or mass messaging for non-dating purposes',
                  ]),

                  _buildSection('Dating Safety Standards', [
                    'Create an authentic profile with recent, unedited photos of yourself',
                    'Be honest about your age, location, and intentions',
                    'Respect boundaries and take no for an answer',
                    'Meet in public places for first dates',
                    'Trust your instincts and report suspicious behavior',
                    'Keep conversations respectful and appropriate',
                    'Obtain consent before sharing personal contact information',
                    'Block and report users who make you uncomfortable',
                  ]),

                  _buildSection('Profile and Photo Guidelines', [
                    'Use only recent photos that clearly show your face',
                    'No group photos as your main profile picture',
                    'Avoid heavily filtered or edited photos',
                    'Include a variety of photos that represent your interests',
                    'All photos must be appropriate and non-explicit',
                    'No photos with other potential romantic partners',
                  ]),

                  _buildSection('Communication Guidelines', [
                    'Start conversations with genuine interest and respect',
                    'Ask questions and share about yourself authentically',
                    'Respect if someone doesn\'t respond or seems uninterested',
                    'No copy-paste messages or mass messaging',
                    'Keep conversations appropriate and family-friendly',
                    'Report any requests for money or suspicious behavior',
                  ]),

                  _buildSection('Reporting and Safety Features', [
                    'Report inappropriate profiles using the report button',
                    'Block users who make you uncomfortable immediately',
                    'Our safety team reviews all reports within 24 hours',
                    'Multiple report categories: harassment, fake profile, inappropriate content, scam',
                    'Anonymous reporting system protects your privacy',
                    'Safety alerts sent to community about active threats',
                    'Emergency contact feature for immediate help',
                  ]),

                  _buildSection('Consequences and Enforcement', [
                    'Minor violations: Profile warning and content removal',
                    'Serious violations: Immediate account suspension or ban',
                    'Fake profiles: Permanent ban with no appeal',
                    'Harassment or threats: Account ban and law enforcement notification',
                    'All safety decisions documented and final',
                    'Appeals only accepted for mistaken identity cases',
                  ]),

                  _buildSection('Dating Safety Resources', [
                    'In-app safety tips and dating advice',
                    'Emergency contacts and support hotlines',
                    'Educational content about online dating safety',
                    'Regular safety reminders and community updates',
                    'Partnership with local safety organizations',
                    'Crisis support and mental health resources',
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

  Widget _buildIntroSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: CustomTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomTheme.primary.withValues(alpha: 0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Our Community',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Lovebirds Dating is committed to providing a safe, respectful, and enjoyable environment for all users. These guidelines help us maintain a positive community where everyone can find meaningful connections and authentic relationships.',
            style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> points, {
    bool isHighlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: isHighlight ? const EdgeInsets.all(16) : EdgeInsets.zero,
      decoration:
          isHighlight
              ? BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              )
              : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isHighlight)
                const Icon(Icons.warning, color: Colors.red, size: 24),
              if (isHighlight) const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isHighlight ? Colors.red : Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 16,
                      color: isHighlight ? Colors.red.shade300 : Colors.white70,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            isHighlight ? Colors.red.shade100 : Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
              'I have read and agree to follow the Community Guidelines',
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
                    ? 'Accept Community Guidelines'
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
