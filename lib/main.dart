import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lovebirds_app/screens/shop/models/DownloadManager.dart';
import 'middleware/paywall_middleware.dart';

import 'core/app.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize paywall middleware for subscription enforcement
  await PaywallMiddleware.initialize();

  // Initialize flutter_downloader
  await FlutterDownloader.initialize(
    debug: true, // set to false in release
    ignoreSsl: true,
  );

  // Register background callback
  DownloadManager.registerCallback();

  // iOS and Android notification settings
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@drawable/logo');

  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    // onDidReceiveLocalNotification can be added here if needed
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const MyApp());
}
