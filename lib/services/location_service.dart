import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../utils/Utilities.dart';
import '../models/RespondModel.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isLocationEnabled = false;

  // Location update listeners
  final List<Function(Position)> _locationListeners = [];

  /// Initialize location service and request permissions
  Future<bool> initialize() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      _isLocationEnabled = true;
      await _getCurrentLocation();
      _startLocationUpdates();

      return true;
    } catch (e) {
      print('Location initialization error: $e');
      return false;
    }
  }

  /// Request location permissions - public method
  Future<bool> requestLocationPermissions() async {
    return await initialize();
  }

  /// Get current location - public method
  Future<Position?> getCurrentLocation() async {
    return await _getCurrentLocation();
  }

  /// Get current location
  Future<Position?> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Notify listeners
      if (_currentPosition != null) {
        for (var listener in _locationListeners) {
          listener(_currentPosition!);
        }
      }

      return _currentPosition;
    } catch (e) {
      print('Get current location error: $e');
      return null;
    }
  }

  /// Start continuous location updates
  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // Update every 100 meters
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _currentPosition = position;

        // Notify all listeners
        for (var listener in _locationListeners) {
          listener(position);
        }

        // Update user location on backend
        _updateUserLocationOnBackend(position);
      },
      onError: (error) {
        print('Location stream error: $error');
      },
    );
  }

  /// Update user location on backend
  Future<void> _updateUserLocationOnBackend(Position position) async {
    try {
      Map<String, dynamic> data = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': DateTime.now().toIso8601String(),
      };

      RespondModel resp = await Utils.http_post('update-location', data);

      if (resp.code != 1) {
        print('Failed to update location on backend: ${resp.message}');
      }
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  /// Get nearby users based on distance preference
  Future<List<Map<String, dynamic>>> getNearbyUsers({
    required int maxDistanceKm,
    int? minAge,
    int? maxAge,
    String? gender,
  }) async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
      if (_currentPosition == null) return [];
    }

    try {
      Map<String, dynamic> params = {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'max_distance_km': maxDistanceKm,
        'min_age': minAge,
        'max_age': maxAge,
        'gender': gender,
      };

      RespondModel resp = await Utils.http_post('nearby-users', params);

      if (resp.code == 1 && resp.data != null) {
        return List<Map<String, dynamic>>.from(resp.data);
      }

      return [];
    } catch (e) {
      print('Error getting nearby users: $e');
      return [];
    }
  }

  /// Calculate distance between two coordinates
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // in km
  }

  /// Check if user is within specified radius
  bool isUserWithinRadius(double userLat, double userLon, double radiusKm) {
    if (_currentPosition == null) return false;

    double distance = calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      userLat,
      userLon,
    );

    return distance <= radiusKm;
  }

  /// Add location update listener
  void addLocationListener(Function(Position) listener) {
    _locationListeners.add(listener);
  }

  /// Remove location update listener
  void removeLocationListener(Function(Position) listener) {
    _locationListeners.remove(listener);
  }

  /// Get current position
  Position? get currentPosition => _currentPosition;

  /// Check if location is enabled
  bool get isLocationEnabled => _isLocationEnabled;

  /// Get formatted address from coordinates
  Future<String> getAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality}, ${place.administrativeArea}';
      }
      return 'Unknown location';
    } catch (e) {
      print('Error getting address: $e');
      return 'Unknown location';
    }
  }

  /// Travel mode - temporarily expand search radius
  Future<List<Map<String, dynamic>>> getTravelModeUsers({
    required double tempLat,
    required double tempLon,
    required int radiusKm,
  }) async {
    try {
      Map<String, dynamic> params = {
        'latitude': tempLat,
        'longitude': tempLon,
        'max_distance_km': radiusKm,
        'travel_mode': true,
      };

      RespondModel resp = await Utils.http_post('travel-mode-users', params);

      if (resp.code == 1 && resp.data != null) {
        return List<Map<String, dynamic>>.from(resp.data);
      }

      return [];
    } catch (e) {
      print('Error getting travel mode users: $e');
      return [];
    }
  }

  /// Stop location updates and cleanup
  void dispose() {
    _positionStream?.cancel();
    _locationListeners.clear();
  }
}
