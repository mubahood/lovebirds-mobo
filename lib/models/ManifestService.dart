import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:lovebirds_app/utils/Utilities.dart';

class ManifestService {
  static const String manifestKey = "manifest_data";

  /// Returns the manifest as a Map.
  /// If a locally cached version exists, returns that immediately and launches a background fetch.
  /// Otherwise, waits for the online fetch to complete.
  Future<Map<String, dynamic>> getManifest() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedManifest = prefs.getString(manifestKey);
    String? data = prefs.getString(manifestKey);

    if (cachedManifest != null) {
      // Launch background update
      _updateManifestInBackground();
      return jsonDecode(cachedManifest);
    } else {
      // No cached version, fetch online first.
      final onlineManifest = await fetchManifestOnline();
      await prefs.setString(manifestKey, jsonEncode(onlineManifest));
      return onlineManifest;
    }
  }

  /// Fetches the manifest from the online API.
  Future<Map<String, dynamic>> fetchManifestOnline() async {
    // Call your dynamic API endpoint "manifest"
    // The response structure is expected to be: { "code":1, "message":"...", "data": { ... } }
    final resp = await Utils.http_get("manifest", {});

    if (resp != null && resp['code'] == 1 && resp['data'] != null) {
      return Map<String, dynamic>.from(resp['data']);
    } else {
      throw Exception("Failed to fetch manifest online");
    }
  }

  /// Called in the background to update the locally stored manifest.
  Future<void> _updateManifestInBackground() async {
    try {
      final onlineManifest = await fetchManifestOnline();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(manifestKey, jsonEncode(onlineManifest));
    } catch (e) {
      // Log the error silently, keeping the cached version if update fails.
      Utils.log("Error updating manifest in background: ${e.toString()}");
    }
  }
}
