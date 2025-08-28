import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../services/enhanced_safety_service.dart';
import '../../widgets/safety/enhanced_safety_widget.dart';
import '../../utils/dating_theme.dart';

/// Demo screen showcasing Phase 8.2 User Safety & Verification implementation
/// Comprehensive safety and verification features for user protection
class Phase8_2Demo extends StatefulWidget {
  const Phase8_2Demo({Key? key}) : super(key: key);

  @override
  State<Phase8_2Demo> createState() => _Phase8_2DemoState();
}

class _Phase8_2DemoState extends State<Phase8_2Demo> {
  final EnhancedSafetyService _safetyService = EnhancedSafetyService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePhase8_2();
  }

  Future<void> _initializePhase8_2() async {
    await _safetyService.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DatingTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Phase 8.2: User Safety & Verification',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: DatingTheme.primaryPink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(FeatherIcons.refreshCw, color: Colors.white),
            onPressed: _resetDemo,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DatingTheme.primaryPink,
              DatingTheme.primaryPink.withValues(alpha: 0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.6],
          ),
        ),
        child: Column(
          children: [
            _buildDemoHeader(),
            Expanded(
              child:
                  _isInitialized
                      ? const EnhancedSafetyWidget()
                      : _buildLoadingState(),
            ),
            _buildDemoControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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
                            'Enhanced User Safety & Verification',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: DatingTheme.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Comprehensive safety features for secure dating',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFeatureHighlights(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    return Row(
      children: [
        Expanded(
          child: _buildHighlightCard(
            'Identity Verification',
            'Selfie + ID',
            FeatherIcons.userCheck,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildHighlightCard(
            'Safety Score',
            'Trust Rating',
            FeatherIcons.trendingUp,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildHighlightCard(
            'Emergency System',
            'Panic Button',
            FeatherIcons.alertTriangle,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 8, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(DatingTheme.primaryPink),
          ),
          const SizedBox(height: 16),
          Text(
            'Initializing Safety & Verification System...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Setting up identity verification, safety scores, and emergency features',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDemoControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Phase 8.2 Demo Controls',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: DatingTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDemoButton(
                  'Mock Photo Verify',
                  FeatherIcons.camera,
                  () => _mockPhotoVerification(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDemoButton(
                  'Mock ID Verify',
                  FeatherIcons.creditCard,
                  () => _mockIdentityVerification(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDemoButton(
                  'Add Demo Contact',
                  FeatherIcons.userPlus,
                  () => _addDemoEmergencyContact(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDemoButton(
                  'Background Check',
                  FeatherIcons.search,
                  () => _mockBackgroundCheck(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: DatingTheme.primaryPink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _mockPhotoVerification() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Verifying photo...'),
              ],
            ),
          ),
    );

    // Simulate verification delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    // Mock successful verification
    _safetyService.verificationStatus.value = VerificationStatus.photoVerified;
    await _safetyService.saveVerificationStatus();
    await _safetyService.updateSafetyScore();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 Photo verification completed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _mockIdentityVerification() async {
    // Check if photo verification is done first
    if (_safetyService.verificationStatus.value == VerificationStatus.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete photo verification first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Verifying identity document...'),
              ],
            ),
          ),
    );

    // Simulate verification delay
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    // Mock successful verification
    _safetyService.verificationStatus.value =
        VerificationStatus.identityVerified;
    await _safetyService.saveVerificationStatus();
    await _safetyService.updateSafetyScore();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🆔 Identity verification completed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _addDemoEmergencyContact() async {
    final success = await _safetyService.addEmergencyContact(
      name: 'Demo Emergency Contact',
      phoneNumber: '+1 (555) 123-4567',
      relationship: 'Friend',
      email: 'demo@example.com',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '👥 Demo emergency contact added successfully!'
              : '❌ Failed to add emergency contact',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _mockBackgroundCheck() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Background Check Demo'),
            content: const Text(
              'This demonstrates the background check feature. In a real app, this would require identity verification and payment.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performMockBackgroundCheck();
                },
                child: const Text('Start Check'),
              ),
            ],
          ),
    );
  }

  Future<void> _performMockBackgroundCheck() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Processing background check...'),
              ],
            ),
          ),
    );

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    // Mock successful background check
    _safetyService.backgroundCheckEnabled.value = true;
    await _safetyService.updateSafetyScore();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔍 Background check completed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _resetDemo() async {
    setState(() {
      _isInitialized = false;
    });

    // Reset demo data
    _safetyService.verificationStatus.value = VerificationStatus.none;
    _safetyService.backgroundCheckEnabled.value = false;
    _safetyService.emergencyContacts.value = [];
    _safetyService.safetyScore.value = 0.0;

    // Re-initialize
    await _initializePhase8_2();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Demo reset successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _safetyService.dispose();
    super.dispose();
  }
}
