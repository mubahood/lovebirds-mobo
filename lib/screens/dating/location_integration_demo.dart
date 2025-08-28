import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../services/location_service.dart';
import '../../managers/nearby_users_manager.dart';
import '../../widgets/location/nearby_users_widget.dart';
import '../../screens/location/location_preferences_screen.dart';
import '../../utils/dating_theme.dart';

/// Demo screen showcasing Phase 5.1 Location-Based Matching implementation
class LocationIntegrationDemo extends StatefulWidget {
  const LocationIntegrationDemo({Key? key}) : super(key: key);

  @override
  State<LocationIntegrationDemo> createState() =>
      _LocationIntegrationDemoState();
}

class _LocationIntegrationDemoState extends State<LocationIntegrationDemo> {
  bool _isLocationEnabled = false;
  String _locationStatus = 'Location services disabled';
  int _nearbyUsersCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeLocationFeatures();
  }

  Future<void> _initializeLocationFeatures() async {
    try {
      // Initialize location service
      await LocationService.instance.requestLocationPermissions();
      await LocationService.instance.getCurrentLocation();

      // Initialize nearby users manager
      NearbyUsersManager.instance.addNearbyUsersListener(_onNearbyUsersUpdated);

      // Update nearby users
      await NearbyUsersManager.instance.updateNearbyUsers();

      setState(() {
        _isLocationEnabled = true;
        _locationStatus = 'Location services enabled';
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Location error: $e';
      });
    }
  }

  void _onNearbyUsersUpdated(List users) {
    setState(() {
      _nearbyUsersCount = users.length;
    });
  }

  @override
  void dispose() {
    NearbyUsersManager.instance.removeNearbyUsersListener(
      _onNearbyUsersUpdated,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Location-Based Matching',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: DatingTheme.primaryPink,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(FeatherIcons.settings, color: Colors.white),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationPreferencesScreen(),
                  ),
                ),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhaseHeader(),
                const SizedBox(height: 30),
                _buildLocationStatusCard(),
                const SizedBox(height: 20),
                _buildStatsCard(),
                const SizedBox(height: 30),
                _buildFeaturesSection(),
                const SizedBox(height: 30),
                if (_isLocationEnabled) _buildNearbyUsersSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DatingTheme.secondaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  FeatherIcons.mapPin,
                  color: DatingTheme.secondaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phase 5.1 Complete',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DatingTheme.secondaryPurple,
                      ),
                    ),
                    const Text(
                      'Location-Based Matching System',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'GPS-enabled user discovery with distance calculations, location preferences, and real-time matching based on proximity.',
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            _isLocationEnabled ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _isLocationEnabled ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isLocationEnabled
                ? FeatherIcons.checkCircle
                : FeatherIcons.alertCircle,
            color: _isLocationEnabled ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              _locationStatus,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:
                    _isLocationEnabled
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Nearby Users',
              _nearbyUsersCount.toString(),
              FeatherIcons.users,
              DatingTheme.primaryPink,
            ),
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          Expanded(
            child: _buildStatItem(
              'Location Status',
              _isLocationEnabled ? 'Active' : 'Inactive',
              FeatherIcons.mapPin,
              DatingTheme.secondaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Implemented Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        _buildFeatureCard(
          'GPS Location Service',
          'Real-time location tracking with permissions',
          FeatherIcons.navigation,
          DatingTheme.primaryPink,
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          'Nearby Users Manager',
          'Intelligent user discovery with distance filtering',
          FeatherIcons.users,
          DatingTheme.secondaryPurple,
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          'Location Preferences',
          'Customizable distance and privacy settings',
          FeatherIcons.sliders,
          DatingTheme.accentGold,
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          'Distance Calculation',
          'Precise distance measurements and sorting',
          FeatherIcons.compass,
          DatingTheme.primaryRose,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby Users',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(20.0),
            child: NearbyUsersWidget(),
          ),
        ),
      ],
    );
  }
}
