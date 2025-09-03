// Example of how to integrate the AppUpdateService into your main application
// This file is for reference purposes and shows the integration steps

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_update_service.dart';

// 1. Add to your main.dart file:
/*
import 'services/app_update_service.dart';
import 'widgets/update_checker_widget.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppUpdateWrapper(
      checkOnStart: true, // This will automatically check for updates on app start
      child: GetMaterialApp(
        title: 'LoveBirds',
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: YourHomeScreen(),
      ),
    );
  }
}
*/

// 2. Add to your Settings/Profile screen:
/*
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          // ... other settings items
          
          // Add the update checker widget
          UpdateCheckerWidget(showAsMenuItem: true),
          
          // ... more settings items
        ],
      ),
    );
  }
}
*/

// 3. Add a manual check button anywhere:
/*
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.system_update),
            onPressed: () {
              AppUpdateService.checkForUpdates(showNoUpdateDialog: true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ... your dashboard content
          
          // Or add the update checker as a card
          UpdateCheckerWidget(showAsMenuItem: false),
          
          // ... more content
        ],
      ),
    );
  }
}
*/

// 4. For Android, you may want to configure your AndroidManifest.xml:
/*
Add these permissions to android/app/src/main/AndroidManifest.xml if not already present:

<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

For in-app updates, add to the <application> tag:
<meta-data
    android:name="com.google.android.play.billingclient.version"
    android:value="4.0.0" />
*/

// 5. For iOS, configure your App Store ID in the AppUpdateService:
/*
In the AppUpdateService class, update this line:
static const String _appStoreId = 'YOUR_APP_STORE_ID_HERE';

You can find your App Store ID in App Store Connect.
*/

// 6. Testing the update functionality:
/*
- For Android: Use internal testing tracks in Google Play Console
- For iOS: Use TestFlight or App Store Connect
- You can also test the UI by temporarily modifying the version comparison logic
*/

class AppUpdateIntegrationGuide {
  // Example of how to call the service methods directly

  static Future<void> checkForUpdatesManually() async {
    try {
      await AppUpdateService.checkForUpdates(showNoUpdateDialog: true);
    } catch (e) {
      print('Error checking for updates: $e');
      Get.snackbar(
        'Error',
        'Failed to check for updates. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  static Future<void> initializeUpdateService() async {
    try {
      await AppUpdateService.initialize();
      print('Update service initialized successfully');
    } catch (e) {
      print('Failed to initialize update service: $e');
    }
  }

  // Example of a custom update dialog
  static void showCustomUpdateDialog(String newVersion, String currentVersion) {
    Get.dialog(
      AlertDialog(
        title: const Text('🎉 Update Available!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A new version of LoveBirds is available!'),
            const SizedBox(height: 8),
            Text('Current version: $currentVersion'),
            Text('New version: $newVersion'),
            const SizedBox(height: 16),
            const Text(
              'Update now to enjoy the latest features and improvements.',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Later')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              AppUpdateService.checkForUpdates();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Now'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

// Configuration constants you might want to adjust:
class UpdateConfiguration {
  static const bool AUTO_CHECK_ON_APP_START = true;
  static const bool SHOW_UPDATE_DIALOG_IMMEDIATELY = true;
  static const bool ALLOW_FLEXIBLE_UPDATE_ON_ANDROID = true;
  static const Duration UPDATE_CHECK_INTERVAL = Duration(hours: 24);

  // You can modify these in the AppUpdateService class
  static const String ANDROID_PACKAGE_NAME = 'com.yourcompany.lovebirds';
  static const String IOS_APP_STORE_ID = 'YOUR_APP_STORE_ID';
}
