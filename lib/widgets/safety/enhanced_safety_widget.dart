import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/enhanced_safety_service.dart';
import '../../utils/dating_theme.dart';

/// Enhanced Safety Widget for Phase 8.2
/// Comprehensive safety and verification features
class EnhancedSafetyWidget extends StatefulWidget {
  const EnhancedSafetyWidget({Key? key}) : super(key: key);

  @override
  _EnhancedSafetyWidgetState createState() => _EnhancedSafetyWidgetState();
}

class _EnhancedSafetyWidgetState extends State<EnhancedSafetyWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EnhancedSafetyService _safetyService = EnhancedSafetyService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeSafetyFeatures();
  }

  Future<void> _initializeSafetyFeatures() async {
    await _safetyService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DatingTheme.primaryPink.withValues(alpha: 0.1), Colors.white],
        ),
      ),
      child: Column(
        children: [
          _buildSafetyHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVerificationTab(),
                _buildSafetyScoreTab(),
                _buildEmergencyContactsTab(),
                _buildSafetyTipsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DatingTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FeatherIcons.shield,
                  color: DatingTheme.primaryPink,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enhanced Safety & Verification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DatingTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ValueListenableBuilder<double>(
                      valueListenable: _safetyService.safetyScore,
                      builder: (context, score, child) {
                        return Row(
                          children: [
                            Icon(
                              _getSafetyScoreIcon(score),
                              size: 16,
                              color: _getSafetyScoreColor(score),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Safety Score: ${score.toInt()}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: _getSafetyScoreColor(score),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: DatingTheme.primaryPink,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Verify'),
          Tab(text: 'Score'),
          Tab(text: 'Contacts'),
          Tab(text: 'Tips'),
        ],
      ),
    );
  }

  Widget _buildVerificationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Identity Verification',
            'Verify your identity to build trust and improve safety',
            FeatherIcons.userCheck,
          ),
          const SizedBox(height: 20),

          ValueListenableBuilder<VerificationStatus>(
            valueListenable: _safetyService.verificationStatus,
            builder: (context, status, child) {
              return Column(
                children: [
                  _buildVerificationCard(
                    title: 'Photo Verification',
                    subtitle: 'Take a selfie to verify your identity',
                    icon: FeatherIcons.camera,
                    isCompleted:
                        status == VerificationStatus.photoVerified ||
                        status == VerificationStatus.identityVerified ||
                        status == VerificationStatus.fullyVerified,
                    onTap: _startPhotoVerification,
                  ),
                  const SizedBox(height: 16),
                  _buildVerificationCard(
                    title: 'Government ID Verification',
                    subtitle: 'Upload a valid government-issued ID',
                    icon: FeatherIcons.creditCard,
                    isCompleted:
                        status == VerificationStatus.identityVerified ||
                        status == VerificationStatus.fullyVerified,
                    onTap: _startIdentityVerification,
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: _safetyService.backgroundCheckEnabled,
                    builder: (context, isEnabled, child) {
                      return _buildVerificationCard(
                        title: 'Background Check (Premium)',
                        subtitle: 'Optional background verification',
                        icon: FeatherIcons.search,
                        isCompleted: isEnabled,
                        onTap: _requestBackgroundCheck,
                        isPremium: true,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyScoreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Safety Score',
            'Your overall safety and trustworthiness rating',
            FeatherIcons.trendingUp,
          ),
          const SizedBox(height: 20),

          ValueListenableBuilder<double>(
            valueListenable: _safetyService.safetyScore,
            builder: (context, score, child) {
              return _buildFeatureCard(
                title: 'Overall Safety Score',
                subtitle: _safetyService.getSafetyScoreExplanation(),
                icon: FeatherIcons.shield,
                iconColor: _getSafetyScoreColor(score),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildScoreCircle(score),
                    const SizedBox(height: 16),
                    _buildScoreBreakdown(),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          _buildFeatureCard(
            title: 'Improve Your Score',
            subtitle: 'Complete these steps to increase your safety rating',
            icon: FeatherIcons.arrowUp,
            iconColor: Colors.green,
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildImprovementItem(
                  'Complete Photo Verification',
                  '+25 points',
                  FeatherIcons.camera,
                ),
                _buildImprovementItem(
                  'Add Government ID',
                  '+35 points',
                  FeatherIcons.creditCard,
                ),
                _buildImprovementItem(
                  'Add Emergency Contacts',
                  '+10 points',
                  FeatherIcons.users,
                ),
                _buildImprovementItem(
                  'Background Check',
                  '+30 points',
                  FeatherIcons.search,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Emergency Contacts',
            'Add trusted contacts for emergency situations',
            FeatherIcons.users,
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _showAddEmergencyContactDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: DatingTheme.primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add Emergency Contact'),
          ),

          const SizedBox(height: 20),

          ValueListenableBuilder<List<EmergencyContact>>(
            valueListenable: _safetyService.emergencyContacts,
            builder: (context, contacts, child) {
              if (contacts.isEmpty) {
                return _buildEmptyState(
                  'No Emergency Contacts',
                  'Add trusted contacts who can be notified in emergency situations',
                  FeatherIcons.users,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Contacts (${contacts.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: DatingTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...contacts.map(
                    (contact) => _buildEmergencyContactCard(contact),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          _buildFeatureCard(
            title: 'Panic Button',
            subtitle: 'Send immediate alerts to all emergency contacts',
            icon: FeatherIcons.alertTriangle,
            iconColor: Colors.red,
            child: Column(
              children: [
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showPanicAlertDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(FeatherIcons.alertTriangle, size: 18),
                      SizedBox(width: 8),
                      Text('Emergency Alert'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTipsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Safety Tips & Guidelines',
            'Important safety information for dating',
            FeatherIcons.bookOpen,
          ),
          const SizedBox(height: 20),

          ValueListenableBuilder<List<SafetyTip>>(
            valueListenable: _safetyService.safetyTips,
            builder: (context, tips, child) {
              if (tips.isEmpty) {
                return _buildEmptyState(
                  'Loading Safety Tips',
                  'Please wait while we load safety guidelines',
                  FeatherIcons.loader,
                );
              }

              return Column(
                children: tips.map((tip) => _buildSafetyTipCard(tip)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DatingTheme.primaryPink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: DatingTheme.primaryPink, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: DatingTheme.primaryText,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: DatingTheme.primaryText,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildVerificationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isCompleted ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green[50] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted ? Colors.green[200]! : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green[100] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCompleted ? FeatherIcons.checkCircle : icon,
                  color: isCompleted ? Colors.green : Colors.grey[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: DatingTheme.primaryText,
                          ),
                        ),
                        if (isPremium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'PREMIUM',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (!isCompleted)
                Icon(
                  FeatherIcons.chevronRight,
                  color: Colors.grey[400],
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle(double score) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(_getSafetyScoreColor(score)),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${score.toInt()}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getSafetyScoreColor(score),
                ),
              ),
              Text(
                'Safety Score',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown() {
    return ValueListenableBuilder<VerificationStatus>(
      valueListenable: _safetyService.verificationStatus,
      builder: (context, status, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _safetyService.backgroundCheckEnabled,
          builder: (context, backgroundCheck, child) {
            return ValueListenableBuilder<List<EmergencyContact>>(
              valueListenable: _safetyService.emergencyContacts,
              builder: (context, contacts, child) {
                return Column(
                  children: [
                    _buildScoreItem(
                      'Photo Verification',
                      status == VerificationStatus.photoVerified ||
                          status == VerificationStatus.identityVerified ||
                          status == VerificationStatus.fullyVerified,
                      25,
                    ),
                    _buildScoreItem(
                      'Identity Verification',
                      status == VerificationStatus.identityVerified ||
                          status == VerificationStatus.fullyVerified,
                      35,
                    ),
                    _buildScoreItem('Background Check', backgroundCheck, 30),
                    _buildScoreItem(
                      'Emergency Contacts',
                      contacts.isNotEmpty,
                      (contacts.length * 5).clamp(0, 10),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildScoreItem(String label, bool isCompleted, int points) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isCompleted ? FeatherIcons.checkCircle : FeatherIcons.circle,
            color: isCompleted ? Colors.green : Colors.grey[400],
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isCompleted ? DatingTheme.primaryText : Colors.grey[600],
              ),
            ),
          ),
          Text(
            '+$points pts',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isCompleted ? Colors.green : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementItem(String title, String points, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 16),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 12))),
          Text(
            points,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard(EmergencyContact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            contact.isVerified ? FeatherIcons.userCheck : FeatherIcons.user,
            color: contact.isVerified ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: DatingTheme.primaryText,
                  ),
                ),
                Text(
                  '${contact.relationship} • ${contact.phoneNumber}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeEmergencyContact(contact.id),
            icon: const Icon(FeatherIcons.x, size: 16),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTipCard(SafetyTip tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tip.importanceColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: tip.importanceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getIconFromString(tip.icon),
                  color: tip.importanceColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: DatingTheme.primaryText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tip.importanceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tip.importance.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: tip.importanceColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tip.description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  IconData _getSafetyScoreIcon(double score) {
    if (score >= 80) return FeatherIcons.shield;
    if (score >= 60) return FeatherIcons.checkCircle;
    if (score >= 40) return FeatherIcons.alertCircle;
    return FeatherIcons.alertTriangle;
  }

  Color _getSafetyScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'users':
        return FeatherIcons.users;
      case 'message-circle':
        return FeatherIcons.messageCircle;
      case 'alert-triangle':
        return FeatherIcons.alertTriangle;
      case 'car':
        return FeatherIcons.navigation;
      case 'coffee':
        return FeatherIcons.coffee;
      case 'video':
        return FeatherIcons.video;
      default:
        return FeatherIcons.info;
    }
  }

  Future<void> _startPhotoVerification() async {
    final result = await _safetyService.startPhotoVerification();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _startIdentityVerification() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Identity Verification'),
            content: const Text(
              'Please prepare a government-issued photo ID (driver\'s license, passport, or national ID card) for verification.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _selectIDDocument();
                },
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  Future<void> _selectIDDocument() async {
    final ImagePicker picker = ImagePicker();
    final XFile? frontImage = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (frontImage == null) return;

    final result = await _safetyService.startIdentityVerification(
      documentType: 'drivers_license',
      frontImage: frontImage,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _requestBackgroundCheck() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Background Check'),
            content: const Text(
              'Background checks are a premium feature that provides additional verification. This service requires personal information and has additional costs.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showBackgroundCheckForm();
                },
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  void _showBackgroundCheckForm() {
    // In a real app, this would show a form to collect required information
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Background check feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAddEmergencyContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Emergency Contact'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: relationshipController,
                  decoration: const InputDecoration(labelText: 'Relationship'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addEmergencyContact(
                    nameController.text,
                    phoneController.text,
                    relationshipController.text,
                  );
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _addEmergencyContact(
    String name,
    String phone,
    String relationship,
  ) async {
    if (name.isEmpty || phone.isEmpty || relationship.isEmpty) return;

    final success = await _safetyService.addEmergencyContact(
      name: name,
      phoneNumber: phone,
      relationship: relationship,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Emergency contact added successfully!'
              : 'Failed to add emergency contact',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _removeEmergencyContact(String contactId) async {
    final success = await _safetyService.removeEmergencyContact(contactId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Emergency contact removed'
              : 'Failed to remove emergency contact',
        ),
        backgroundColor: success ? Colors.orange : Colors.red,
      ),
    );
  }

  void _showPanicAlertDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(FeatherIcons.alertTriangle, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Emergency Alert'),
              ],
            ),
            content: const Text(
              'This will immediately notify all your emergency contacts with your current location. Use only in real emergencies.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sendPanicAlert();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Send Alert',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _sendPanicAlert() async {
    final success = await _safetyService.sendPanicAlert(
      alertMessage: 'Emergency alert sent from Lovebirds Dating App',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Emergency alert sent to all contacts!'
              : 'Failed to send emergency alert',
        ),
        backgroundColor: success ? Colors.orange : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
