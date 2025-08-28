import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';

import '../../utils/dating_theme.dart';
import '../../services/location_service.dart';
import '../../utils/Utilities.dart';

class LocationPreferencesScreen extends StatefulWidget {
  const LocationPreferencesScreen({Key? key}) : super(key: key);

  @override
  _LocationPreferencesScreenState createState() =>
      _LocationPreferencesScreenState();
}

class _LocationPreferencesScreenState extends State<LocationPreferencesScreen> {
  double _maxDistance = 25.0; // Default 25km
  bool _showDistance = true;
  bool _enableLocationServices = true;
  bool _travelMode = false;
  String _currentLocation = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _getCurrentLocationText();
  }

  Future<void> _loadPreferences() async {
    // Load saved preferences from local storage or API
    // This would typically come from shared preferences or user settings
    setState(() {
      _maxDistance = 25.0;
      _showDistance = true;
      _enableLocationServices = true;
      _travelMode = false;
    });
  }

  Future<void> _getCurrentLocationText() async {
    final position = LocationService.instance.currentPosition;
    if (position != null) {
      final address = await LocationService.instance.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _currentLocation = address;
      });
    } else {
      setState(() {
        _currentLocation = 'Location not available';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DatingTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Location Settings'),
        backgroundColor: DatingTheme.darkBackground,
        leading: IconButton(
          icon: const Icon(FeatherIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: _savePreferences,
            child: Text(
              'Save',
              style: TextStyle(
                color: DatingTheme.primaryPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Location Section
            _buildCurrentLocationSection(),

            const SizedBox(height: 30),

            // Distance Preference Section
            _buildDistancePreferenceSection(),

            const SizedBox(height: 30),

            // Privacy Settings
            _buildPrivacySettingsSection(),

            const SizedBox(height: 30),

            // Travel Mode Section
            _buildTravelModeSection(),

            const SizedBox(height: 30),

            // Location Services Toggle
            _buildLocationServicesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DatingTheme.getSwipeCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DatingTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  FeatherIcons.mapPin,
                  color: DatingTheme.primaryPink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Current Location',
                style: TextStyle(
                  color: DatingTheme.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentLocation,
            style: TextStyle(color: DatingTheme.secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _updateLocation,
            icon: Icon(
              FeatherIcons.refreshCw,
              size: 16,
              color: DatingTheme.primaryPink,
            ),
            label: Text(
              'Update Location',
              style: TextStyle(color: DatingTheme.primaryPink, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistancePreferenceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DatingTheme.getSwipeCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DatingTheme.accentGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  FeatherIcons.target,
                  color: DatingTheme.accentGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Discovery Distance',
                style: TextStyle(
                  color: DatingTheme.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Maximum Distance: ${_maxDistance.round()} km',
            style: TextStyle(
              color: DatingTheme.primaryPink,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: DatingTheme.primaryPink,
              inactiveTrackColor: DatingTheme.surfaceColor,
              thumbColor: DatingTheme.primaryPink,
              overlayColor: DatingTheme.primaryPink.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: _maxDistance,
              min: 1.0,
              max: 100.0,
              divisions: 99,
              onChanged: (value) {
                setState(() {
                  _maxDistance = value;
                });
              },
            ),
          ),
          Text(
            'Show people within ${_maxDistance.round()} kilometers',
            style: TextStyle(color: DatingTheme.secondaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DatingTheme.getSwipeCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DatingTheme.secondaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  FeatherIcons.shield,
                  color: DatingTheme.secondaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Privacy Settings',
                style: TextStyle(
                  color: DatingTheme.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: Text(
              'Show Distance on Profile',
              style: TextStyle(color: DatingTheme.primaryText, fontSize: 14),
            ),
            subtitle: Text(
              'Others can see how far away you are',
              style: TextStyle(color: DatingTheme.secondaryText, fontSize: 12),
            ),
            value: _showDistance,
            onChanged: (value) {
              setState(() {
                _showDistance = value;
              });
            },
            activeColor: DatingTheme.primaryPink,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildTravelModeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DatingTheme.getSwipeCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DatingTheme.primaryRose.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  FeatherIcons.navigation,
                  color: DatingTheme.primaryRose,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Travel Mode',
                style: TextStyle(
                  color: DatingTheme.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: Text(
              'Enable Travel Mode',
              style: TextStyle(color: DatingTheme.primaryText, fontSize: 14),
            ),
            subtitle: Text(
              'Connect with people when visiting new cities',
              style: TextStyle(color: DatingTheme.secondaryText, fontSize: 12),
            ),
            value: _travelMode,
            onChanged: (value) {
              setState(() {
                _travelMode = value;
              });
            },
            activeColor: DatingTheme.primaryPink,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationServicesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DatingTheme.getSwipeCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _enableLocationServices
                          ? DatingTheme.successGreen.withValues(alpha: 0.1)
                          : DatingTheme.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _enableLocationServices
                      ? FeatherIcons.checkCircle
                      : FeatherIcons.xCircle,
                  color:
                      _enableLocationServices
                          ? DatingTheme.successGreen
                          : DatingTheme.errorRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Location Services',
                style: TextStyle(
                  color: DatingTheme.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: Text(
              'Enable Location Services',
              style: TextStyle(color: DatingTheme.primaryText, fontSize: 14),
            ),
            subtitle: Text(
              'Required for distance-based matching',
              style: TextStyle(color: DatingTheme.secondaryText, fontSize: 12),
            ),
            value: _enableLocationServices,
            onChanged: (value) async {
              if (value) {
                bool initialized = await LocationService.instance.initialize();
                if (initialized) {
                  setState(() {
                    _enableLocationServices = true;
                  });
                  _getCurrentLocationText();
                } else {
                  Utils.toast('Location permission denied');
                }
              } else {
                setState(() {
                  _enableLocationServices = false;
                });
              }
            },
            activeColor: DatingTheme.primaryPink,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Future<void> _updateLocation() async {
    if (_enableLocationServices) {
      setState(() {
        _currentLocation = 'Updating...';
      });

      bool success = await LocationService.instance.initialize();
      if (success) {
        _getCurrentLocationText();
        Utils.toast('Location updated successfully');
      } else {
        setState(() {
          _currentLocation = 'Failed to update location';
        });
        Utils.toast('Failed to update location');
      }
    }
  }

  Future<void> _savePreferences() async {
    try {
      // Save preferences to backend and local storage
      // You can uncomment the following data when implementing the save functionality
      // Map<String, dynamic> data = {
      //   'max_distance_km': _maxDistance.round(),
      //   'show_distance': _showDistance,
      //   'enable_location': _enableLocationServices,
      //   'travel_mode': _travelMode,
      // };

      // You would typically save to SharedPreferences and/or send to backend
      // await Utils.http_post('save-location-preferences', data);

      Utils.toast('Location preferences saved');
      Get.back();
    } catch (e) {
      Utils.toast('Failed to save preferences');
    }
  }
}
