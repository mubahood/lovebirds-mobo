import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../services/enhanced_location_service.dart';
import '../../widgets/location/enhanced_location_widget.dart';
import '../../utils/dating_theme.dart';

/// Demo screen showcasing Phase 8.1 GPS & Location Services implementation
/// Enhanced location features with verification, sharing, and safety
class Phase8_1Demo extends StatefulWidget {
  const Phase8_1Demo({Key? key}) : super(key: key);

  @override
  State<Phase8_1Demo> createState() => _Phase8_1DemoState();
}

class _Phase8_1DemoState extends State<Phase8_1Demo> {
  final EnhancedLocationService _locationService = EnhancedLocationService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePhase8_1();
  }

  Future<void> _initializePhase8_1() async {
    await _locationService.initialize();
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
          'Phase 8.1: GPS & Location Services',
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
                      ? const EnhancedLocationWidget()
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
                        FeatherIcons.mapPin,
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
                            'Enhanced GPS & Location Services',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: DatingTheme.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Advanced location features for safety and discovery',
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
            'Location Verification',
            'Authentic GPS',
            FeatherIcons.shield,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildHighlightCard(
            'Real-time Sharing',
            'Safe Dates',
            FeatherIcons.navigation,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildHighlightCard(
            'Date Check-in',
            'Safety First',
            FeatherIcons.checkCircle,
            DatingTheme.primaryPink,
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
            'Initializing Enhanced Location Services...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Setting up GPS verification, location sharing, and safety features',
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
            'Phase 8.1 Demo Controls',
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
                  'Simulate Travel Mode',
                  FeatherIcons.navigation,
                  () => _simulateTravelMode(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDemoButton(
                  'Emergency Demo',
                  FeatherIcons.alertTriangle,
                  () => _showEmergencyDemo(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDemoButton(
                  'Mock Check-in',
                  FeatherIcons.mapPin,
                  () => _mockDateCheckIn(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDemoButton(
                  'Share Location',
                  FeatherIcons.share2,
                  () => _mockLocationSharing(),
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

  Future<void> _simulateTravelMode() async {
    final success = await _locationService.enableTravelMode(
      cityName: 'Vancouver, BC',
      latitude: 49.2827,
      longitude: -123.1207,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 5)),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✈️ Travel mode enabled for Vancouver!'
              : '❌ Failed to enable travel mode',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _showEmergencyDemo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(FeatherIcons.alertTriangle, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Emergency Alert Demo'),
              ],
            ),
            content: const Text(
              'This would send an emergency alert with your current location to emergency contacts and authorities.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sendMockEmergencyAlert();
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

  Future<void> _sendMockEmergencyAlert() async {
    final success = await _locationService.sendEmergencyAlert(
      alertType: 'date_emergency',
      customMessage: 'Demo emergency alert - not a real emergency',
      emergencyContacts: ['Emergency Contact 1', 'Emergency Contact 2'],
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '🚨 Emergency alert sent successfully!'
              : '❌ Failed to send emergency alert',
        ),
        backgroundColor: success ? Colors.orange : Colors.red,
      ),
    );
  }

  Future<void> _mockDateCheckIn() async {
    final success = await _locationService.checkInForDate(
      dateId: 'demo_date_${DateTime.now().millisecondsSinceEpoch}',
      locationName: 'Tim Hortons - Demo Location',
      notes: 'Demo check-in for Phase 8.1 testing',
      emergencyContacts: ['Emergency Contact 1'],
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '📍 Successfully checked in at demo location!'
              : '❌ Failed to check in',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _mockLocationSharing() async {
    final success = await _locationService.startLocationSharing(
      matchUserId: 'demo_match_user_123',
      duration: const Duration(hours: 2),
      customMessage: 'Demo location sharing for Phase 8.1 testing',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '📱 Location sharing started with demo match!'
              : '❌ Failed to start location sharing',
        ),
        backgroundColor: success ? Colors.blue : Colors.red,
      ),
    );
  }

  Future<void> _resetDemo() async {
    setState(() {
      _isInitialized = false;
    });

    // Reset demo data
    await _locationService.disableTravelMode();

    // Re-initialize
    await _initializePhase8_1();

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
    _locationService.dispose();
    super.dispose();
  }
}
