import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../services/enhanced_location_service.dart';
import '../../services/location_service.dart';
import '../../utils/dating_theme.dart';

/// Enhanced Location Management Widget for Phase 8.1
/// Comprehensive location features with verification, sharing, and safety
class EnhancedLocationWidget extends StatefulWidget {
  const EnhancedLocationWidget({Key? key}) : super(key: key);

  @override
  _EnhancedLocationWidgetState createState() => _EnhancedLocationWidgetState();
}

class _EnhancedLocationWidgetState extends State<EnhancedLocationWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EnhancedLocationService _locationService = EnhancedLocationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeLocationFeatures();
  }

  Future<void> _initializeLocationFeatures() async {
    await _locationService.initialize();
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
          _buildLocationHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLocationVerificationTab(),
                _buildLocationSharingTab(),
                _buildDateCheckInTab(),
                _buildSafeLocationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
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
                      'Enhanced Location Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DatingTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ValueListenableBuilder<bool>(
                      valueListenable: _locationService.isLocationVerified,
                      builder: (context, isVerified, child) {
                        return Row(
                          children: [
                            Icon(
                              isVerified
                                  ? FeatherIcons.checkCircle
                                  : FeatherIcons.alertCircle,
                              size: 16,
                              color: isVerified ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isVerified
                                  ? 'Location Verified'
                                  : 'Verifying Location...',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isVerified ? Colors.green : Colors.orange,
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
          Tab(text: 'Share'),
          Tab(text: 'Check-In'),
          Tab(text: 'Safe Spots'),
        ],
      ),
    );
  }

  Widget _buildLocationVerificationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Location Verification',
            'Verify your location authenticity for enhanced safety',
            FeatherIcons.shield,
          ),
          const SizedBox(height: 20),

          ValueListenableBuilder<bool>(
            valueListenable: _locationService.isLocationVerified,
            builder: (context, isVerified, child) {
              return _buildFeatureCard(
                title: 'Location Status',
                subtitle:
                    isVerified
                        ? 'Your location has been verified as authentic'
                        : 'Verifying location authenticity...',
                icon:
                    isVerified ? FeatherIcons.checkCircle : FeatherIcons.clock,
                iconColor: isVerified ? Colors.green : Colors.orange,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildVerificationItem(
                            'GPS Accuracy',
                            isVerified ? 'Verified' : 'Checking...',
                            isVerified,
                          ),
                        ),
                        Expanded(
                          child: _buildVerificationItem(
                            'Movement Pattern',
                            isVerified ? 'Normal' : 'Analyzing...',
                            isVerified,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildVerificationItem(
                            'Backend Check',
                            isVerified ? 'Passed' : 'Verifying...',
                            isVerified,
                          ),
                        ),
                        Expanded(
                          child: _buildVerificationItem(
                            'Spoof Detection',
                            isVerified ? 'Clean' : 'Scanning...',
                            isVerified,
                          ),
                        ),
                      ],
                    ),
                    if (!isVerified) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final position =
                              LocationService.instance.currentPosition;
                          if (position != null) {
                            // Re-initialize location verification
                            await _locationService.initialize();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DatingTheme.primaryPink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retry Verification'),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          _buildFeatureCard(
            title: 'Travel Mode',
            subtitle: 'Enable when visiting new cities',
            icon: FeatherIcons.navigation,
            iconColor: DatingTheme.primaryPink,
            child: ValueListenableBuilder<bool>(
              valueListenable: _locationService.isTravelModeActive,
              builder: (context, isTravelMode, child) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    if (isTravelMode) ...[
                      ValueListenableBuilder<TravelLocation?>(
                        valueListenable: _locationService.currentTravelLocation,
                        builder: (context, travelLocation, child) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  FeatherIcons.mapPin,
                                  color: Colors.blue[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Currently in ${travelLocation?.cityName ?? "Unknown City"}',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _locationService.disableTravelMode(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Disable Travel Mode'),
                      ),
                    ] else ...[
                      ElevatedButton(
                        onPressed: _showTravelModeDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DatingTheme.primaryPink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Enable Travel Mode'),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSharingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Real-Time Location Sharing',
            'Share your location with verified matches',
            FeatherIcons.share2,
          ),
          const SizedBox(height: 20),

          ValueListenableBuilder<bool>(
            valueListenable: _locationService.isLocationSharingEnabled,
            builder: (context, isSharingEnabled, child) {
              return _buildFeatureCard(
                title: 'Location Sharing Status',
                subtitle:
                    isSharingEnabled
                        ? 'You are currently sharing your location'
                        : 'Location sharing is disabled',
                icon:
                    isSharingEnabled
                        ? FeatherIcons.navigation
                        : FeatherIcons.navigation2,
                iconColor: isSharingEnabled ? Colors.green : Colors.grey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    if (!isSharingEnabled) ...[
                      ElevatedButton(
                        onPressed: _showLocationSharingDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DatingTheme.primaryPink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Start Location Sharing'),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          ValueListenableBuilder<List<LocationShare>>(
            valueListenable: _locationService.activeLocationShares,
            builder: (context, shares, child) {
              if (shares.isEmpty) {
                return _buildEmptyState(
                  'No Active Shares',
                  'Start sharing your location with matches for enhanced safety during dates',
                  FeatherIcons.share2,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Location Shares',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: DatingTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...shares.map((share) => _buildLocationShareCard(share)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateCheckInTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Date Check-In',
            'Check in when you arrive at date locations',
            FeatherIcons.mapPin,
          ),
          const SizedBox(height: 20),

          _buildFeatureCard(
            title: 'Quick Check-In',
            subtitle: 'Check in at your current location',
            icon: FeatherIcons.checkCircle,
            iconColor: DatingTheme.primaryPink,
            child: Column(
              children: [
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showDateCheckInDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DatingTheme.primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Check In Now'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ValueListenableBuilder<List<DateCheckIn>>(
            valueListenable: _locationService.dateCheckIns,
            builder: (context, checkIns, child) {
              if (checkIns.isEmpty) {
                return _buildEmptyState(
                  'No Check-Ins Yet',
                  'Check in when you arrive at date locations for added safety',
                  FeatherIcons.mapPin,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Check-Ins',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: DatingTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...checkIns
                      .take(5)
                      .map((checkIn) => _buildCheckInCard(checkIn)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSafeLocationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Safe Meetup Locations',
            'Recommended safe locations for first dates',
            FeatherIcons.shield,
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _refreshSafeLocations,
            style: ElevatedButton.styleFrom(
              backgroundColor: DatingTheme.primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Find Safe Locations Nearby'),
          ),

          const SizedBox(height: 20),

          ValueListenableBuilder<List<SafeLocation>>(
            valueListenable: _locationService.safeLocations,
            builder: (context, locations, child) {
              if (locations.isEmpty) {
                return _buildEmptyState(
                  'No Safe Locations Found',
                  'Try refreshing to find safe meetup locations nearby',
                  FeatherIcons.shield,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Safe Locations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: DatingTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...locations.map(
                    (location) => _buildSafeLocationCard(location),
                  ),
                ],
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

  Widget _buildVerificationItem(String label, String status, bool isVerified) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isVerified ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: isVerified ? Colors.green[800] : Colors.orange[800],
              fontWeight: FontWeight.bold,
            ),
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

  Widget _buildLocationShareCard(LocationShare share) {
    final timeRemaining = share.endTime.difference(DateTime.now());
    final isActive = timeRemaining.inMinutes > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.green[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? FeatherIcons.navigation : FeatherIcons.navigation,
            color: isActive ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sharing with Match',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: DatingTheme.primaryText,
                  ),
                ),
                Text(
                  isActive
                      ? 'Expires in ${timeRemaining.inMinutes} minutes'
                      : 'Expired',
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.green[600] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            IconButton(
              onPressed: () => _locationService.stopLocationSharing(share.id),
              icon: const Icon(FeatherIcons.x, size: 16),
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard(DateCheckIn checkIn) {
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
            checkIn.isVerified ? FeatherIcons.checkCircle : FeatherIcons.clock,
            color: checkIn.isVerified ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  checkIn.locationName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: DatingTheme.primaryText,
                  ),
                ),
                Text(
                  'Checked in ${_formatDateTime(checkIn.checkInTime)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeLocationCard(SafeLocation location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FeatherIcons.mapPin,
                color: DatingTheme.primaryPink,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: DatingTheme.primaryText,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(FeatherIcons.star, color: Colors.amber, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    location.safetyRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            location.address,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  location.category,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (location.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Verified',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    }
  }

  void _showTravelModeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Enable Travel Mode'),
            content: const Text(
              'Travel mode expands your discovery radius and helps you connect with locals and other travelers. Where are you visiting?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // In a real app, this would show a city selection screen
                  _locationService.enableTravelMode(
                    cityName: 'Toronto, ON',
                    latitude: 43.6532,
                    longitude: -79.3832,
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(const Duration(days: 7)),
                  );
                },
                child: const Text('Enable'),
              ),
            ],
          ),
    );
  }

  void _showLocationSharingDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Share Location'),
            content: const Text(
              'Share your real-time location with a verified match for enhanced safety during your date.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // In a real app, this would show match selection
                  _locationService.startLocationSharing(
                    matchUserId: 'demo_match_123',
                    duration: const Duration(hours: 3),
                    customMessage:
                        'Going on a date, sharing location for safety',
                  );
                },
                child: const Text('Start Sharing'),
              ),
            ],
          ),
    );
  }

  void _showDateCheckInDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Date Check-In'),
            content: const Text(
              'Check in at your current location to let your emergency contacts know you\'ve arrived safely.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _locationService.checkInForDate(
                    dateId:
                        'demo_date_${DateTime.now().millisecondsSinceEpoch}',
                    locationName: 'Current Location',
                    notes: 'Checked in safely',
                    emergencyContacts: ['Emergency Contact 1'],
                  );
                },
                child: const Text('Check In'),
              ),
            ],
          ),
    );
  }

  Future<void> _refreshSafeLocations() async {
    await _locationService.getSafeMeetupSuggestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
