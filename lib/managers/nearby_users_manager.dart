import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';
import '../models/UserModel.dart';

class NearbyUsersManager {
  static NearbyUsersManager? _instance;
  static NearbyUsersManager get instance =>
      _instance ??= NearbyUsersManager._();
  NearbyUsersManager._();

  List<UserModel> _nearbyUsers = [];
  Timer? _updateTimer;
  bool _isUpdating = false;

  // Nearby users listeners
  final List<Function(List<UserModel>)> _nearbyUsersListeners = [];

  /// Initialize nearby users manager
  Future<void> initialize() async {
    await LocationService.instance.initialize();

    // Start periodic updates every 30 seconds
    _startPeriodicUpdates();

    // Listen to location changes
    LocationService.instance.addLocationListener(_onLocationUpdate);
  }

  /// Start periodic updates of nearby users
  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      updateNearbyUsers();
    });
  }

  /// Handle location updates
  void _onLocationUpdate(Position position) {
    // Update nearby users when location changes significantly
    updateNearbyUsers();
  }

  /// Update nearby users list
  Future<void> updateNearbyUsers({
    int maxDistanceKm = 25,
    int? minAge,
    int? maxAge,
    String? gender,
  }) async {
    if (_isUpdating) return;

    _isUpdating = true;

    try {
      List<Map<String, dynamic>> nearbyData = await LocationService.instance
          .getNearbyUsers(
            maxDistanceKm: maxDistanceKm,
            minAge: minAge,
            maxAge: maxAge,
            gender: gender,
          );

      // Convert to UserModel objects
      List<UserModel> users =
          nearbyData.map((data) {
            UserModel user = UserModel.fromJson(data);

            // Calculate distance
            if (LocationService.instance.currentPosition != null &&
                user.latitude.isNotEmpty &&
                user.longitude.isNotEmpty) {
              try {
                double userLat = double.parse(user.latitude);
                double userLng = double.parse(user.longitude);
                double distance = LocationService.calculateDistance(
                  LocationService.instance.currentPosition!.latitude,
                  LocationService.instance.currentPosition!.longitude,
                  userLat,
                  userLng,
                );
                user.distance = distance;
              } catch (e) {
                user.distance = 0.0;
              }
            }

            return user;
          }).toList();

      // Sort by distance
      users.sort((a, b) {
        return a.distance.compareTo(b.distance);
      });

      _nearbyUsers = users;

      // Notify all listeners
      for (var listener in _nearbyUsersListeners) {
        listener(_nearbyUsers);
      }
    } catch (e) {
      print('Error updating nearby users: $e');
    } finally {
      _isUpdating = false;
    }
  }

  /// Get nearby users for discovery
  Future<List<UserModel>> getDiscoveryUsers({
    int limit = 10,
    int maxDistanceKm = 25,
    int? minAge,
    int? maxAge,
  }) async {
    if (_nearbyUsers.isEmpty) {
      await updateNearbyUsers(
        maxDistanceKm: maxDistanceKm,
        minAge: minAge,
        maxAge: maxAge,
      );
    }

    return _nearbyUsers.take(limit).toList();
  }

  /// Check if user is nearby (within specified radius)
  bool isUserNearby(UserModel user, {double radiusKm = 25}) {
    if (user.latitude.isEmpty || user.longitude.isEmpty) return false;

    try {
      double userLat = double.parse(user.latitude);
      double userLng = double.parse(user.longitude);
      return LocationService.instance.isUserWithinRadius(
        userLat,
        userLng,
        radiusKm,
      );
    } catch (e) {
      return false;
    }
  }

  /// Get users within specific distance
  List<UserModel> getUsersWithinDistance(double maxKm) {
    return _nearbyUsers.where((user) {
      return user.distance <= maxKm;
    }).toList();
  }

  /// Get distance to user
  double? getDistanceToUser(UserModel user) {
    if (user.latitude.isEmpty || user.longitude.isEmpty) return null;

    final currentPosition = LocationService.instance.currentPosition;
    if (currentPosition == null) return null;

    try {
      double userLat = double.parse(user.latitude);
      double userLng = double.parse(user.longitude);
      return LocationService.calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        userLat,
        userLng,
      );
    } catch (e) {
      return null;
    }
  }

  /// Format distance for display
  String formatDistance(double? distanceKm) {
    if (distanceKm == null) return 'Distance unknown';

    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m away';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km away';
    } else {
      return '${distanceKm.round()}km away';
    }
  }

  /// Add listener for nearby users updates
  void addNearbyUsersListener(Function(List<UserModel>) listener) {
    _nearbyUsersListeners.add(listener);
  }

  /// Remove listener for nearby users updates
  void removeNearbyUsersListener(Function(List<UserModel>) listener) {
    _nearbyUsersListeners.remove(listener);
  }

  /// Get current nearby users
  List<UserModel> get nearbyUsers => List.unmodifiable(_nearbyUsers);

  /// Check if updating
  bool get isUpdating => _isUpdating;

  /// Travel mode - get users in a different location
  Future<List<UserModel>> getTravelModeUsers({
    required double latitude,
    required double longitude,
    int radiusKm = 50,
  }) async {
    try {
      List<Map<String, dynamic>> travelData = await LocationService.instance
          .getTravelModeUsers(
            tempLat: latitude,
            tempLon: longitude,
            radiusKm: radiusKm,
          );

      return travelData.map((data) => UserModel.fromJson(data)).toList();
    } catch (e) {
      print('Error getting travel mode users: $e');
      return [];
    }
  }

  /// Dispose and cleanup
  void dispose() {
    _updateTimer?.cancel();
    _nearbyUsersListeners.clear();
    LocationService.instance.removeLocationListener(_onLocationUpdate);
  }
}
