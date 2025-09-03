import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/Utilities.dart';

class AppUpdateService {
  static bool _isCheckingUpdate = false;
  static bool _hasShownUpdateDialog = false;

  /// Initialize app update checker
  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      await _initializeAndroidUpdater();
    } else if (Platform.isIOS) {
      await _initializeIOSUpdater();
    }
  }

  /// Check for updates manually
  static Future<void> checkForUpdates({bool showNoUpdateDialog = false}) async {
    if (_isCheckingUpdate) return;

    _isCheckingUpdate = true;

    try {
      if (Platform.isAndroid) {
        await _checkAndroidUpdate(showNoUpdateDialog: showNoUpdateDialog);
      } else if (Platform.isIOS) {
        await _checkIOSUpdate(showNoUpdateDialog: showNoUpdateDialog);
      }
    } catch (e) {
      print('Error checking for updates: $e');
      if (showNoUpdateDialog) {
        _showErrorDialog('Update check failed. Please try again later.');
      }
    } finally {
      _isCheckingUpdate = false;
    }
  }

  /// Initialize Android in-app update
  static Future<void> _initializeAndroidUpdater() async {
    try {
      // Check for available updates on app start
      await Future.delayed(const Duration(seconds: 3)); // Wait for app to load
      await _checkAndroidUpdate();
    } catch (e) {
      print('Android update initialization failed: $e');
    }
  }

  /// Initialize iOS upgrader
  static Future<void> _initializeIOSUpdater() async {
    try {
      // Configure upgrader for iOS
      await Upgrader.clearSavedSettings();
    } catch (e) {
      print('iOS update initialization failed: $e');
    }
  }

  /// Check for Android updates
  static Future<void> _checkAndroidUpdate({
    bool showNoUpdateDialog = false,
  }) async {
    try {
      // Check if update is available
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        final bool isImmediate = updateInfo.immediateUpdateAllowed;
        final bool isFlexible = updateInfo.flexibleUpdateAllowed;

        if (isImmediate && _shouldForceUpdate(updateInfo)) {
          // Force immediate update for critical updates
          await _performImmediateUpdate();
        } else if (isFlexible) {
          // Show flexible update dialog
          await _showAndroidUpdateDialog(updateInfo);
        } else if (isImmediate) {
          // Show immediate update dialog
          await _showAndroidUpdateDialog(updateInfo, isImmediate: true);
        }
      } else if (showNoUpdateDialog) {
        _showNoUpdateDialog();
      }
    } on PlatformException catch (e) {
      print('Android update check failed: ${e.message}');
      if (showNoUpdateDialog) {
        _showErrorDialog('Failed to check for updates: ${e.message}');
      }
    }
  }

  /// Check for iOS updates
  static Future<void> _checkIOSUpdate({bool showNoUpdateDialog = false}) async {
    try {
      // Use upgrader to check App Store
      final Upgrader upgrader = Upgrader(
        debugDisplayAlways: false,
        debugDisplayOnce: false,
        debugLogging: false,
      );

      // Initialize and check if update is available
      await upgrader.initialize();

      if (upgrader.shouldDisplayUpgrade()) {
        await _showIOSUpdateDialog(upgrader);
      } else if (showNoUpdateDialog) {
        _showNoUpdateDialog();
      }
    } catch (e) {
      print('iOS update check failed: $e');
      if (showNoUpdateDialog) {
        _showErrorDialog('Failed to check for updates. Please try again.');
      }
    }
  }

  /// Determine if update should be forced
  static bool _shouldForceUpdate(AppUpdateInfo updateInfo) {
    // Force update if staleness days > 30 or if critical update
    return (updateInfo.clientVersionStalenessDays ?? 0) > 30;
  }

  /// Perform immediate update for Android
  static Future<void> _performImmediateUpdate() async {
    try {
      Utils.showLoading(message: "Updating app...");
      await InAppUpdate.performImmediateUpdate();
      Utils.hideLoading();
    } catch (e) {
      Utils.hideLoading();
      print('Immediate update failed: $e');
      _showErrorDialog('Update failed. Please try again.');
    }
  }

  /// Show Android update dialog
  static Future<void> _showAndroidUpdateDialog(
    AppUpdateInfo updateInfo, {
    bool isImmediate = false,
  }) async {
    if (_hasShownUpdateDialog) return;
    _hasShownUpdateDialog = true;

    final String title =
        isImmediate ? 'Critical Update Required' : 'App Update Available';
    final String message =
        isImmediate
            ? 'A critical update is required to continue using the app.'
            : 'A new version of Lovebirds is available with improvements and bug fixes.';

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.system_update, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (updateInfo.availableVersionCode != null) ...[
              const SizedBox(height: 12),
              Text(
                'Version: ${updateInfo.availableVersionCode}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          if (!isImmediate)
            TextButton(
              onPressed: () {
                Get.back();
                _hasShownUpdateDialog = false;
              },
              child: const Text('Later'),
            ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _startAndroidUpdate(isImmediate);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(isImmediate ? 'Update Now' : 'Update'),
          ),
        ],
      ),
      barrierDismissible: !isImmediate,
    );
  }

  /// Show iOS update dialog
  static Future<void> _showIOSUpdateDialog(Upgrader upgrader) async {
    if (_hasShownUpdateDialog) return;
    _hasShownUpdateDialog = true;

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.system_update, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            const Text(
              'App Update Available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new version of Lovebirds is available on the App Store with improvements and bug fixes.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _hasShownUpdateDialog = false;
            },
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _openAppStore();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Start Android update process
  static Future<void> _startAndroidUpdate(bool isImmediate) async {
    try {
      if (isImmediate) {
        Utils.showLoading(message: "Updating app...");
        await InAppUpdate.performImmediateUpdate();
        Utils.hideLoading();
      } else {
        Utils.showLoading(message: "Preparing update...");
        await InAppUpdate.startFlexibleUpdate();
        Utils.hideLoading();

        // Listen for update download completion
        InAppUpdate.completeFlexibleUpdate()
            .then((_) {
              Utils.toast('Update installed successfully!');
            })
            .catchError((error) {
              print('Flexible update completion failed: $error');
              Utils.toast('Update installation failed');
            });
      }
      _hasShownUpdateDialog = false;
    } catch (e) {
      Utils.hideLoading();
      print('Update failed: $e');
      _showErrorDialog(
        'Update failed. Please try again or update manually from Play Store.',
      );
      _hasShownUpdateDialog = false;
    }
  }

  /// Open App Store for iOS updates
  static Future<void> _openAppStore() async {
    try {
      const String appStoreUrl =
          'https://apps.apple.com/app/id1234567890'; // Replace with your App Store URL

      if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
        await launchUrl(
          Uri.parse(appStoreUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showErrorDialog('Could not open App Store. Please update manually.');
      }
      _hasShownUpdateDialog = false;
    } catch (e) {
      print('Failed to open App Store: $e');
      _showErrorDialog('Could not open App Store. Please update manually.');
      _hasShownUpdateDialog = false;
    }
  }

  /// Show no update available dialog
  static void _showNoUpdateDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Up to Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'You are already using the latest version of Lovebirds.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  static void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Update Check Failed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Check for flexible update status (Android only)
  static Future<void> checkFlexibleUpdateStatus() async {
    if (!Platform.isAndroid) return;

    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      print('Flexible update completion check failed: $e');
    }
  }

  /// Reset update dialog flag (useful for testing)
  static void resetUpdateDialogFlag() {
    _hasShownUpdateDialog = false;
  }
}
