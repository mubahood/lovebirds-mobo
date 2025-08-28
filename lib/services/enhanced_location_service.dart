import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/Utilities.dart';
import '../models/RespondModel.dart';
import 'location_service.dart';

/// Enhanced Location Service for Phase 8.1 GPS & Location Services
/// Builds upon existing LocationService with advanced features
class EnhancedLocationService {
  static final EnhancedLocationService _instance =
      EnhancedLocationService._internal();
  factory EnhancedLocationService() => _instance;
  EnhancedLocationService._internal();

  static const String _dateCheckInsKey = 'date_check_ins';
  static const String _locationHistoryKey = 'location_history';
  static const String _safeLocationsKey = 'safe_locations';

  // Location verification
  ValueNotifier<bool> isLocationVerified = ValueNotifier(false);
  ValueNotifier<List<SafeLocation>> safeLocations = ValueNotifier([]);
  ValueNotifier<List<DateCheckIn>> dateCheckIns = ValueNotifier([]);

  // Real-time location sharing
  ValueNotifier<bool> isLocationSharingEnabled = ValueNotifier(false);
  ValueNotifier<List<LocationShare>> activeLocationShares = ValueNotifier([]);

  // Travel mode
  ValueNotifier<bool> isTravelModeActive = ValueNotifier(false);
  ValueNotifier<TravelLocation?> currentTravelLocation = ValueNotifier(null);

  /// Initialize enhanced location service
  Future<void> initialize() async {
    await _loadStoredData();
    await _initializeLocationVerification();
    await _loadSafeLocations();
  }

  /// Load stored data from SharedPreferences
  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load date check-ins
    final checkInsJson = prefs.getString(_dateCheckInsKey);
    if (checkInsJson != null) {
      final List<dynamic> checkInsList = json.decode(checkInsJson);
      dateCheckIns.value =
          checkInsList.map((json) => DateCheckIn.fromJson(json)).toList();
    }

    // Load location sharing status
    isLocationSharingEnabled.value =
        prefs.getBool('location_sharing_enabled') ?? false;

    // Load travel mode status
    isTravelModeActive.value = prefs.getBool('travel_mode_active') ?? false;
  }

  /// Initialize location verification
  Future<void> _initializeLocationVerification() async {
    try {
      final position = LocationService.instance.currentPosition;
      if (position != null) {
        await _verifyLocationAuthenticity(position);
      }
    } catch (e) {
      debugPrint('Location verification initialization error: $e');
    }
  }

  /// Verify location authenticity to prevent spoofing
  Future<bool> _verifyLocationAuthenticity(Position position) async {
    try {
      // Multiple verification checks
      final verificationChecks = await Future.wait([
        _checkLocationAccuracy(position),
        _checkLocationConsistency(position),
        _verifyWithBackend(position),
      ]);

      final isVerified = verificationChecks.every((check) => check);
      isLocationVerified.value = isVerified;

      return isVerified;
    } catch (e) {
      debugPrint('Location verification error: $e');
      isLocationVerified.value = false;
      return false;
    }
  }

  /// Check location accuracy for verification
  Future<bool> _checkLocationAccuracy(Position position) async {
    // Location should have reasonable accuracy (less than 50 meters)
    return position.accuracy <= 50.0;
  }

  /// Check location consistency over time
  Future<bool> _checkLocationConsistency(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_locationHistoryKey);

    if (historyJson == null) {
      // First location record
      await _saveLocationToHistory(position);
      return true;
    }

    final List<dynamic> history = json.decode(historyJson);
    if (history.isEmpty) return true;

    // Check if movement is realistic (not teleporting)
    final lastLocation = history.last;
    final lastTime = DateTime.parse(lastLocation['timestamp']);
    final timeDiff = DateTime.now().difference(lastTime).inMinutes;

    if (timeDiff > 0) {
      final distance = Geolocator.distanceBetween(
        lastLocation['latitude'],
        lastLocation['longitude'],
        position.latitude,
        position.longitude,
      );

      // Maximum realistic speed: 200 km/h (for cars/planes)
      final maxDistance = (200 * 1000 / 60) * timeDiff; // meters per minute

      if (distance <= maxDistance) {
        await _saveLocationToHistory(position);
        return true;
      }
    }

    return false;
  }

  /// Verify location with backend
  Future<bool> _verifyWithBackend(Position position) async {
    try {
      final response = await Utils.http_post('verify-location', {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return response.code == 1;
    } catch (e) {
      debugPrint('Backend location verification error: $e');
      return false; // Fail safe
    }
  }

  /// Save location to history for consistency checking
  Future<void> _saveLocationToHistory(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_locationHistoryKey);

    List<dynamic> history = historyJson != null ? json.decode(historyJson) : [];

    history.add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Keep only last 20 locations
    if (history.length > 20) {
      history = history.sublist(history.length - 20);
    }

    await prefs.setString(_locationHistoryKey, json.encode(history));
  }

  /// Load safe meetup locations
  Future<void> _loadSafeLocations() async {
    try {
      final response = await Utils.http_get('safe-locations', {});

      if (response.code == 1 && response.data != null) {
        final List<dynamic> locationsData = response.data;
        safeLocations.value =
            locationsData.map((json) => SafeLocation.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading safe locations: $e');
      // Load default safe locations
      _loadDefaultSafeLocations();
    }
  }

  /// Load default safe locations
  void _loadDefaultSafeLocations() {
    safeLocations.value = [
      SafeLocation(
        id: '1',
        name: 'Tim Hortons - Downtown',
        category: 'Cafe',
        address: '123 Main St, Toronto, ON',
        latitude: 43.6532,
        longitude: -79.3832,
        safetyRating: 4.8,
        isVerified: true,
        operatingHours: '24/7',
        description:
            'Popular coffee chain with public seating and security cameras',
      ),
      SafeLocation(
        id: '2',
        name: 'Harbourfront Centre',
        category: 'Public Space',
        address: '235 Queens Quay W, Toronto, ON',
        latitude: 43.6387,
        longitude: -79.3816,
        safetyRating: 4.6,
        isVerified: true,
        operatingHours: '6:00 AM - 11:00 PM',
        description: 'Cultural center with good lighting and security',
      ),
      SafeLocation(
        id: '3',
        name: 'CN Tower',
        category: 'Tourist Attraction',
        address: '290 Bremner Blvd, Toronto, ON',
        latitude: 43.6426,
        longitude: -79.3871,
        safetyRating: 4.9,
        isVerified: true,
        operatingHours: '9:00 AM - 10:30 PM',
        description:
            'Iconic landmark with high security and public accessibility',
      ),
    ];
  }

  /// Start real-time location sharing with a match
  Future<bool> startLocationSharing({
    required String matchUserId,
    required Duration duration,
    String? customMessage,
  }) async {
    try {
      final position = LocationService.instance.currentPosition;
      if (position == null) {
        throw Exception('Current location not available');
      }

      final locationShare = LocationShare(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        matchUserId: matchUserId,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(duration),
        currentLatitude: position.latitude,
        currentLongitude: position.longitude,
        customMessage: customMessage,
        isActive: true,
      );

      // Save to backend
      final response = await Utils.http_post('start-location-sharing', {
        'match_user_id': matchUserId,
        'duration_minutes': duration.inMinutes,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'custom_message': customMessage,
      });

      if (response.code == 1) {
        final updatedShares = List<LocationShare>.from(
          activeLocationShares.value,
        );
        updatedShares.add(locationShare);
        activeLocationShares.value = updatedShares;

        isLocationSharingEnabled.value = true;
        await _saveLocationSharingStatus();

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error starting location sharing: $e');
      return false;
    }
  }

  /// Stop location sharing
  Future<bool> stopLocationSharing(String shareId) async {
    try {
      final response = await Utils.http_post('stop-location-sharing', {
        'share_id': shareId,
      });

      if (response.code == 1) {
        final updatedShares =
            activeLocationShares.value
                .where((share) => share.id != shareId)
                .toList();
        activeLocationShares.value = updatedShares;

        if (updatedShares.isEmpty) {
          isLocationSharingEnabled.value = false;
        }

        await _saveLocationSharingStatus();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error stopping location sharing: $e');
      return false;
    }
  }

  /// Check in for a planned date
  Future<bool> checkInForDate({
    required String dateId,
    required String locationName,
    String? notes,
    List<String>? emergencyContacts,
  }) async {
    try {
      final position = LocationService.instance.currentPosition;
      if (position == null) {
        throw Exception('Current location not available');
      }

      // Verify location authenticity before check-in
      final isLocationVerified = await _verifyLocationAuthenticity(position);
      if (!isLocationVerified) {
        throw Exception('Location verification failed');
      }

      final checkIn = DateCheckIn(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateId: dateId,
        locationName: locationName,
        latitude: position.latitude,
        longitude: position.longitude,
        checkInTime: DateTime.now(),
        notes: notes,
        emergencyContacts: emergencyContacts ?? [],
        isVerified: true,
      );

      // Save to backend
      final response = await Utils.http_post('date-check-in', {
        'date_id': dateId,
        'location_name': locationName,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'notes': notes,
        'emergency_contacts': emergencyContacts,
      });

      if (response.code == 1) {
        final updatedCheckIns = List<DateCheckIn>.from(dateCheckIns.value);
        updatedCheckIns.add(checkIn);
        dateCheckIns.value = updatedCheckIns;

        await _saveDateCheckIns();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking in for date: $e');
      return false;
    }
  }

  /// Enable travel mode
  Future<bool> enableTravelMode({
    required String cityName,
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final travelLocation = TravelLocation(
        cityName: cityName,
        latitude: latitude,
        longitude: longitude,
        startDate: startDate,
        endDate: endDate,
      );

      final response = await Utils.http_post('enable-travel-mode', {
        'city_name': cityName,
        'latitude': latitude,
        'longitude': longitude,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      });

      if (response.code == 1) {
        currentTravelLocation.value = travelLocation;
        isTravelModeActive.value = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('travel_mode_active', true);
        await prefs.setString(
          'travel_location',
          json.encode(travelLocation.toJson()),
        );

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error enabling travel mode: $e');
      return false;
    }
  }

  /// Disable travel mode
  Future<bool> disableTravelMode() async {
    try {
      final response = await Utils.http_post('disable-travel-mode', {});

      if (response.code == 1) {
        currentTravelLocation.value = null;
        isTravelModeActive.value = false;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('travel_mode_active', false);
        await prefs.remove('travel_location');

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error disabling travel mode: $e');
      return false;
    }
  }

  /// Get safe meetup location suggestions near current position
  Future<List<SafeLocation>> getSafeMeetupSuggestions({
    double radiusKm = 5.0,
  }) async {
    final position = LocationService.instance.currentPosition;
    if (position == null) return [];

    return safeLocations.value.where((location) {
        final distance =
            Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              location.latitude,
              location.longitude,
            ) /
            1000; // Convert to km

        return distance <= radiusKm;
      }).toList()
      ..sort((a, b) => b.safetyRating.compareTo(a.safetyRating));
  }

  /// Send emergency alert with current location
  Future<bool> sendEmergencyAlert({
    required String alertType,
    String? customMessage,
    List<String>? emergencyContacts,
  }) async {
    try {
      final position = LocationService.instance.currentPosition;
      if (position == null) {
        throw Exception('Current location not available');
      }

      final response = await Utils.http_post('emergency-alert', {
        'alert_type': alertType,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'custom_message': customMessage,
        'emergency_contacts': emergencyContacts,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return response.code == 1;
    } catch (e) {
      debugPrint('Error sending emergency alert: $e');
      return false;
    }
  }

  /// Save date check-ins to storage
  Future<void> _saveDateCheckIns() async {
    final prefs = await SharedPreferences.getInstance();
    final checkInsJson = json.encode(
      dateCheckIns.value.map((checkIn) => checkIn.toJson()).toList(),
    );
    await prefs.setString(_dateCheckInsKey, checkInsJson);
  }

  /// Save location sharing status
  Future<void> _saveLocationSharingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'location_sharing_enabled',
      isLocationSharingEnabled.value,
    );
  }

  /// Cleanup and dispose
  void dispose() {
    isLocationVerified.dispose();
    safeLocations.dispose();
    dateCheckIns.dispose();
    isLocationSharingEnabled.dispose();
    activeLocationShares.dispose();
    isTravelModeActive.dispose();
    currentTravelLocation.dispose();
  }
}

/// Model classes for enhanced location features
class SafeLocation {
  final String id;
  final String name;
  final String category;
  final String address;
  final double latitude;
  final double longitude;
  final double safetyRating;
  final bool isVerified;
  final String operatingHours;
  final String description;

  SafeLocation({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.safetyRating,
    required this.isVerified,
    required this.operatingHours,
    required this.description,
  });

  factory SafeLocation.fromJson(Map<String, dynamic> json) {
    return SafeLocation(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      address: json['address'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      safetyRating: double.tryParse(json['safety_rating'].toString()) ?? 0.0,
      isVerified: json['is_verified'] == true,
      operatingHours: json['operating_hours'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'safety_rating': safetyRating,
      'is_verified': isVerified,
      'operating_hours': operatingHours,
      'description': description,
    };
  }
}

class LocationShare {
  final String id;
  final String matchUserId;
  final DateTime startTime;
  final DateTime endTime;
  final double currentLatitude;
  final double currentLongitude;
  final String? customMessage;
  final bool isActive;

  LocationShare({
    required this.id,
    required this.matchUserId,
    required this.startTime,
    required this.endTime,
    required this.currentLatitude,
    required this.currentLongitude,
    this.customMessage,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_user_id': matchUserId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'custom_message': customMessage,
      'is_active': isActive,
    };
  }
}

class DateCheckIn {
  final String id;
  final String dateId;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime checkInTime;
  final String? notes;
  final List<String> emergencyContacts;
  final bool isVerified;

  DateCheckIn({
    required this.id,
    required this.dateId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.checkInTime,
    this.notes,
    required this.emergencyContacts,
    required this.isVerified,
  });

  factory DateCheckIn.fromJson(Map<String, dynamic> json) {
    return DateCheckIn(
      id: json['id'].toString(),
      dateId: json['date_id'] ?? '',
      locationName: json['location_name'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      checkInTime: DateTime.parse(json['check_in_time']),
      notes: json['notes'],
      emergencyContacts: List<String>.from(json['emergency_contacts'] ?? []),
      isVerified: json['is_verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_id': dateId,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'check_in_time': checkInTime.toIso8601String(),
      'notes': notes,
      'emergency_contacts': emergencyContacts,
      'is_verified': isVerified,
    };
  }
}

class TravelLocation {
  final String cityName;
  final double latitude;
  final double longitude;
  final DateTime startDate;
  final DateTime endDate;

  TravelLocation({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.startDate,
    required this.endDate,
  });

  factory TravelLocation.fromJson(Map<String, dynamic> json) {
    return TravelLocation(
      cityName: json['city_name'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city_name': cityName,
      'latitude': latitude,
      'longitude': longitude,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}
