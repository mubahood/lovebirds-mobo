import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutx/widgets/button/button.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:lovebirds_app/screens/auth/login_screen.dart';
import 'package:lovebirds_app/screens/dating/ProfileEditScreen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/LoggedInUserModel.dart';
import 'AppConfig.dart';
import 'CustomTheme.dart';

class Utils {
  static double double_parse(dynamic x) {
    if (x == null) {
      return 0.0;
    }
    double temp = 0.0;
    try {
      temp = double.parse(x.toString());
    } catch (e) {
      temp = 0.0;
    }

    return temp;
  }

  static String shotten(String data, int limit) {
    if (data.length > limit) {
      return "${data.substring(0, limit - 2)}...";
    }
    return data;
  }

  static bool isValidMail(String mail) {
    if (mail.isEmpty) {
      return false;
    }
    if (mail.length < 3) {
      return false;
    }
    if (!mail.contains('@')) {
      return false;
    }
    if (!mail.contains('.')) {
      return false;
    }
    return true;
  }

  static Future<void> checkUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {}).catchError((e) {
      // Utils.toast(e.toString());
    });
  }

  static Future<bool> getStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    // 1) Check if already granted
    final status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      return true;
    }

    // 2) Attempt to request permission
    final result = await Permission.manageExternalStorage.request();

    // 3) Handle the various possible outcomes:

    if (result.isGranted) {
      // The user just granted permission
      return true;
    }

    if (result.isDenied) {
      bool retry = await Get.defaultDialog<bool>(
        title: "Storage Permission Required",
        middleText:
            "We need access to your device storage in order to save and play downloaded videos. "
            "Without this permission, the app cannot store video files locally.\n\n"
            "To enable storage permission, tap 'Open Settings' below, then:\n"
            "1. In the App Info screen, tap 'Permissions'.\n"
            "2. Find and enable 'Storage' permission for this app.\n"
            "3. Return to the app and try again.",
        textCancel: "Cancel",
        textConfirm: "Retry",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(result: true);
        },
        onCancel: () {
          Get.back(result: false);
        },
      ).then((value) => value ?? false);

      if (retry) {
        // Recursively try again
        return getStoragePermission();
      } else {
        // User chose “Cancel”
        return false;
      }
    }

    if (result.isPermanentlyDenied) {
      // The user denied permanently. We must direct them to Settings.
      bool openSettings = await Get.defaultDialog<bool>(
        title: "Storage Permission Permanently Denied",
        middleText:
            "You have permanently denied storage access. To save and watch downloaded videos, please enable storage permission in your device settings.\n\n"
            "Tap 'Open Settings' to go directly to the app’s permission page.",
        textCancel: "Cancel",
        textConfirm: "Open Settings",
        confirmTextColor: Colors.white,
        onConfirm: () async {
          Get.back(result: true);
        },
        onCancel: () {
          Get.back(result: false);
        },
      ).then((value) => value ?? false);

      if (openSettings) {
        // Launch the app’s settings page
        await openAppSettings();
      }
      return false;
    }

    // 4) Other statuses (restricted, limited, etc.): treat similarly to plain denial
    Utils.toast(
      "Storage permission ${result.toString()}. Cannot proceed without it.",
      isLong: true,
    );
    return false;
  }

  /// Returns the path to a dedicated UGFlix folder,
  /// creating it if necessary.
  static Future<String> getAppDirectoryPath() async {
    Directory baseDir;
    if (Platform.isAndroid) {
      // On Android use external storage
      baseDir = (await getExternalStorageDirectory())!;
    } else {
      // On iOS, desktop, etc.
      baseDir = await getApplicationDocumentsDirectory();
    }

    if (await baseDir.exists()) {
      return baseDir.path;
    }
    //check if baseDir exists
    if (!await baseDir.exists()) {
      try {
        await baseDir.create(recursive: true);
      } catch (e) {
        // Fallback: use default app documents directory
        final fallbackDir = await getApplicationDocumentsDirectory();
        if (!await fallbackDir.exists()) {
          await fallbackDir.create(recursive: true);
        }
        return fallbackDir.path;
      }
    }

    //check if baseDir exist and return it
    if (baseDir.path.isEmpty) {
      final fallbackDir = await getApplicationDocumentsDirectory();
      if (!await fallbackDir.exists()) {
        await fallbackDir.create(recursive: true);
      }
      return fallbackDir.path;
    }
    return baseDir.path;
  }

  /// Returns a Directory instance for the UGFlix folder (never empty).
  /// Displays a toast and returns null only if something truly fails.
  static Future<Directory?> createAppDirectory() async {
    try {
      final dirPath = await getAppDirectoryPath();
      return Directory(dirPath);
    } catch (e) {
      try {
        final fallbackDir = await getApplicationDocumentsDirectory();
        if (!await fallbackDir.exists()) {
          await fallbackDir.create(recursive: true);
        }
        return fallbackDir;
      } catch (e2) {
        Utils.toast("Failed to create app directory: $e2", color: Colors.red);
        return null;
      }
    }
  }

  static void shouldCompletedProfile(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Complete Profile",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, anim, __, child) {
        return Transform.scale(
          scale: anim.value,
          child: Opacity(
            opacity: anim.value,
            child: Scaffold(
              backgroundColor: Colors.black.withValues(alpha: 0.9),
              body: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: CustomTheme.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FxText.titleLarge(
                        "Complete Your Profile",
                        color: CustomTheme.accent,
                        fontWeight: 900,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FxText.bodyMedium(
                        "You're almost there!\nComplete your profile to unlock full access to chats, likes, matches, and more.",
                        color: Colors.grey[400],
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FxButton.block(
                        borderRadiusAll: 12,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: CustomTheme.primary,
                        onPressed: () async {
                          Get.back(); // Close dialog
                          LoggedInUserModel x =
                              await LoggedInUserModel.getLoggedInUser();
                          Get.to(() => ProfileEditScreen(user: x));
                        },
                        child: FxText.bodyLarge(
                          "Complete Now",
                          color: Colors.white,
                          fontWeight: 800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: FxText.bodySmall(
                          "Maybe Later",
                          color: Colors.grey,
                          fontWeight: 600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Color getColor(String col) {
    col = col.toLowerCase();
    Color color = Colors.white;
    if (col.isEmpty) {
      return color;
    } else if (col == "white") {
      return Colors.white;
    } else if (col == "black") {
      return Colors.black;
    } else if (col == "red") {
      return Colors.red;
    } else if (col == "green") {
      return Colors.green;
    } else if (col == "blue") {
      return Colors.blue;
    } else if (col == "yellow") {
      return Colors.yellow;
    } else if (col == "orange") {
      return Colors.orange;
    } else if (col == "pink") {
      return Colors.pink;
    } else if (col == "purple") {
      return Colors.purple;
    } else if (col == "brown") {
      return Colors.brown;
    } else if (col == "grey") {
      return Colors.grey;
    } else if (col == "maroon") {
      return Color(0xFF800000);
    } else if (col == "gold") {
      return Color(0xFFD4AF37);
    } else if (col == "silver") {
      return Color(0xFFC0C0C0);
    } else if (col == "darkblue") {
      return Color(0xFF00008B);
    } else if (col == "bronze") {
      return Color(0xFFCD7F32);
    } else {
      return Colors.white;
    }
  }

  static String money(String price) {
    return "${AppConfig.CURRENCY} ${moneyFormat(price)}";
  }

  static String img(dynamic img) {
    return getImageUrl(img);
  }

  static Future<void> initOneSignal(LoggedInUserModel u) async {
    // await Firebase.initializeApp();

    OneSignal.initialize(AppConfig.ONESIGNAL_APP_ID);
    print(AppConfig.ONESIGNAL_APP_ID);

    String my_id = "my-id-${u.id}";
    OneSignal.login(my_id.toString());
    OneSignal.User.addAlias("fb_id", my_id.toString());

    OneSignal.User.addObserver((state) {
      var userState = state.jsonRepresentation();
      print('OneSignal user changed: $my_id');
    });

    OneSignal.Notifications.addPermissionObserver((state) {
      print("Has permission " + state.toString());
    });

    OneSignal.Notifications.addClickListener((event) {
      Utils.toast("Clicked notification #${event.notification.title}");
    });
  }

  static void showLoader(bool dismissable) {
    if (EasyLoading.isShow) {
      return;
    } else {
      EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: dismissable,
      );
    }
    return;
  }

  static void hideLoader() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    return;
  }

  static String timeAgo(dynamic date) {
    DateTime d;
    if (date is String) {
      d = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is DateTime) {
      d = date;
    } else {
      return '';
    }

    final now = DateTime.now();
    final diff = now.difference(d);

    if (diff.inSeconds < 60) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m minute${m == 1 ? '' : 's'} ago';
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h hour${h == 1 ? '' : 's'} ago';
    } else if (diff.inDays < 2) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d day${d == 1 ? '' : 's'} ago';
    } else if (diff.inDays < 30) {
      final w = diff.inDays ~/ 7;
      return '$w week${w == 1 ? '' : 's'} ago';
    } else if (diff.inDays < 365) {
      final m = diff.inDays ~/ 30;
      return '$m month${m == 1 ? '' : 's'} ago';
    } else {
      final y = diff.inDays ~/ 365;
      return '$y year${y == 1 ? '' : 's'} ago';
    }
  }

  static String moneyFormat(String price) {
    String lastPart = '';
    bool hasDecimal = false;
    if (price.contains('.')) {
      // lastPart = price.split('.').last;
      // hasDecimal = true;
      price = price.split('.')[0];
    }

    int value0 = Utils.int_parse(price);
    if (price.length > 2) {
      var value = price;
      value = value.replaceAll(RegExp(r'\D'), '');
      value = value.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');
      if (value0 < 0) {
        value = "-$value";
      }
      if (hasDecimal) {
        value = '${value}.${lastPart}';
      }
      return value;
    }
    if (hasDecimal) {
      price = "$price.$lastPart";
    }
    return price;
  }

  static SystemUiOverlayStyle overlay() {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.black,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    );
  }

  static Future<List<String>> getDownloadPics() async {
    List<String> downloadedPics = [];
    Directory dir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = dir.listSync();
    for (FileSystemEntity file in files) {
      if (file is File) {
        downloadedPics.add(file.path.split('/').last);
      }
    }
    return downloadedPics;
  }

  static Future<Directory?> getMyRealDownload() async {
    Directory? dir;
    try {
      dir = await Utils.createAppDirectory();
    } catch (e) {
      //try to get the default app directory
      try {
        dir = await getApplicationDocumentsDirectory();
      } catch (e) {
        Utils.toast(
          "Failed to get application documents directory",
          color: Colors.red,
        );
        return null;
      }
    }
    return dir;
  }

  static Future<String?> downloadFile(
    String url,
    String directory_path,
    String file_name,
  ) async {
    String filePath = '$directory_path/$file_name';

    File file = File(filePath);
    if (await file.exists()) {
      //delete it
      try {
        await file.delete();
      } catch (e) {
        Utils.toast("Failed to delete existing file: $e", color: Colors.red);
        return null;
      }
    }

    try {
      String? taskId = await FlutterDownloader.enqueue(
        url: url,
        headers: {},
        savedDir: directory_path,
        showNotification: true,
        openFileFromNotification: true,
        fileName: file_name,
        saveInPublicStorage: false,
        requiresStorageNotLow: false,
        allowCellular: true,
      );
      return taskId;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<void> downloadPhoto(String pic) async {
    List<String> downloadedPics = await getDownloadPics();
    if (downloadedPics.contains(pic)) {
      return;
    }

    Directory dir = await getApplicationDocumentsDirectory();

    dio.Dio dioClient = dio.Dio();
    String dirPath = dir.path;

    String url = '${Utils.img(pic)}';
    var response = await dioClient.download(url, '$dirPath/$pic');
    if (response.statusCode == 200) {
    } else {}
  }

  static Future<List<String>> getFilesInDirectory() async {
    //Directory appDir = await getApplicationDocumentsDirectory();
    Directory appDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = appDir.listSync();
    List<String> fileNames = [];

    for (FileSystemEntity file in files) {
      if (file is File) {
        fileNames.add(file.path.split('/').last);
      }
    }

    return fileNames;
  }

  static String getUniqueText() {
    String uniqueText = DateTime.now().millisecondsSinceEpoch.toString();
    Random random = Random();
    int randomNumber = random.nextInt(1000000);
    uniqueText += randomNumber.toString();
    uniqueText += random.nextInt(1000000).toString();
    uniqueText += random.nextInt(1000000).toString();
    uniqueText += random.nextInt(1000000).toString();
    uniqueText += random.nextInt(1000000).toString();
    uniqueText += random.nextInt(1000000).toString();
    uniqueText += random.nextInt(1000000).toString();
    return uniqueText;
  }

  static Future<Database> getDb() async {
    return await openDatabase(
      AppConfig.DATABASE_PATH,
      version: Utils.int_parse('12'),
    );
  }

  static Future<Database> dbInit() async {
    return await getDb();
  }

  static void system_boot() {}

  static void init_theme() {
    Utils.checkUpdate();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: CustomTheme.primary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: CustomTheme.primary,
      ),
    );
  }

  static String to_date(dynamic updatedAt) {
    String dateText = "--:--";
    if (updatedAt == null) {
      return "--:--";
    }
    if (updatedAt.toString().length < 5) {
      return "--:--";
    }

    try {
      DateTime date = DateTime.parse(updatedAt.toString());

      dateText = DateFormat("d MMM, y - ").format(date);
      dateText += DateFormat("jm").format(date);
    } catch (e) {}

    return dateText;
  }

  static String getImageUrl(dynamic img) {
    if (img.toString().contains('http')) {
      return img;
    }
    List<String> splits = img.toString().split('/');
    if (splits.isEmpty) {
      return img;
    }
    String last = splits.last;
    return '${AppConfig.MAIN_SITE_URL}/storage/images/$last';
    String img0 = "logo.png";
    if (img != null) {
      img = img.toString();
      if (img.toString().isNotEmpty) {
        img0 = img;
      }
    }
    img0.replaceAll('/images', '');
  }

  static String to_date_1(dynamic updatedAt) {
    String dateText = "__/__/___";
    if (updatedAt == null) {
      return "__/__/____";
    }
    if (updatedAt.toString().length < 5) {
      return "__/__/____";
    }

    try {
      DateTime date = DateTime.parse(updatedAt.toString());

      dateText = DateFormat("d MMM, y").format(date);
    } catch (e) {}

    return dateText;
  }

  static DateTime toDate(dynamic updatedAt) {
    DateTime date = DateTime.now();
    try {
      date = DateTime.parse(updatedAt.toString());
    } catch (e) {
      date = DateTime.now();
    }

    return date;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear both old and new token keys for backward compatibility
    await prefs.remove('token');
    await LoggedInUserModel.clearToken(); // Use new token management system
    await deleteDatabase(AppConfig.DATABASE_PATH);
    Get.offAll(const LoginScreen());
    return;
  }

  static String replaceAfterDot(String originalString, String replacement) {
    List<String> parts = originalString.split('.');

    if (parts.length > 1) {
      parts[1] = replacement;
      return parts.join('.');
    } else {
      return originalString;
    }
  }

  static String to_date_2(dynamic updatedAt) {
    String dateText = "__/__/___";
    if (updatedAt == null) {
      return "__/__/____";
    }
    if (updatedAt.toString().length < 5) {
      return "__/__/____";
    }
    try {
      DateTime date = DateTime.parse(updatedAt.toString());

      dateText = DateFormat("EEEE - dd MMM, y").format(date);
    } catch (e) {}
    return dateText;
  }

  static String to_date_3(dynamic updatedAt) {
    String dateText = "__/__/___";
    if (updatedAt == null) {
      return "__/__/____";
    }
    if (updatedAt.toString().length < 5) {
      return "__/__/____";
    }
    try {
      DateTime date = DateTime.parse(updatedAt.toString());

      dateText = DateFormat("jm").format(date);
    } catch (e) {}
    return dateText;
  }

  static String to_str(dynamic x, String y) {
    if (x == null) {
      return y;
    }
    if (x.toString().toString() == 'null') {
      return y;
    }
    if (x.toString().isEmpty) {
      return y.toString();
    }
    if (x is List<String> && x.isNotEmpty) {
      // If x is a list of strings, join them with ', ' separator
      return jsonEncode(x);
    }

    return x.toString();
  }

  static int int_parse(dynamic x) {
    if (x == null) {
      return 0;
    }
    int temp = 0;
    try {
      temp = int.parse(x.toString());
    } catch (e) {
      temp = 0;
    }

    return temp;
  }

  static bool bool_parse(dynamic x) {
    int temp = 0;
    bool ans = false;
    try {
      temp = int.parse(x.toString());
    } catch (e) {
      temp = 0;
    }

    if (temp == 1) {
      ans = true;
    } else {
      ans = false;
    }
    return ans;
  }

  static Future<dynamic> http_post(
    String path,
    Map<String, dynamic> body,
  ) async {
    if (!await Utils.is_connected()) {
      return {
        'code': 0,
        'message': 'You are not connected to internet.',
        'data': null,
      };
    }

    // Make a mutable copy of the incoming body
    final Map<String, dynamic> payload = Map<String, dynamic>.from(body);

    dynamic response;
    var dioClient = dio.Dio();

    // Enhanced iPad compatibility configuration
    (dioClient.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (
      HttpClient client,
    ) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      client.connectionTimeout = const Duration(seconds: 30);
      client.idleTimeout = const Duration(seconds: 30);
      client.userAgent = 'UGFlix-iOS/${Platform.operatingSystemVersion}';
      return client;
    };

    dioClient.options
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30)
      ..sendTimeout = const Duration(seconds: 30);

    // Retrieve token using the new token management system
    final token = await LoggedInUserModel.getToken();

    // Add logged‐in user ID
    LoggedInUserModel userModel = await LoggedInUserModel.getLoggedInUser();
        payload['logged_in_user_id'] = userModel.id.toString();
    print("${AppConfig.API_BASE_URL}/$path");
    /*
    print("============START CONNECTION==============");

    print("Request Body: ${jsonEncode(payload)}");
    print("Token: $token");
    print("logged_in_user_id: ${ userModel.id.toString()}");
    print("===========================================");
*/

    // Platform info
    String platform_type;
    String device_info;
    if (Platform.isIOS) {
      platform_type = 'ios';
      device_info = 'iOS/${Platform.operatingSystemVersion}';
    } else {
      platform_type = 'android';
      device_info = 'Android/${Platform.operatingSystemVersion}';
    }
    payload['platform_type'] = platform_type;
    payload['device_info'] = device_info;

    // Build FormData from our mutable payload
    var formData = dio.FormData.fromMap(payload);
    // print("=======> ${token} <========");

    try {
      response = await dioClient.post(
        "${AppConfig.API_BASE_URL}/$path",
        data: formData,
        options: dio.Options(
          headers: <String, String>{
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
            "Tok": "Bearer $token",
            "logged_in_user_id": userModel.id.toString(),
            "User-Agent": "UGFlix-$device_info",
            "X-Platform": platform_type,
            "X-App-Version": "1.0.0",
          },
        ),
      );

            print("============SUCCESS CONNECTION==============");
      print("${AppConfig.API_BASE_URL}/$path");
      print("Response Status: ${response.statusCode}");
      log("Response Data: ${response.data}");
      print("==========================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        return {
          'code': 0,
          'message': 'Server returned status ${response.statusCode}',
          'data': null,
        };
      }
    } on dio.DioException catch (e) {
      print("============FAILED CONNECTION==============");
      print("${AppConfig.API_BASE_URL}/$path");
      print("Error Type: ${e.type}");
      print("Error Message: ${e.message}");
      if (e.response != null) {
        print("Response Status: ${e.response?.statusCode}");
        print("Response Data: ${e.response?.data}");
      }
      print("==========================");

      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout ||
          e.type == dio.DioExceptionType.sendTimeout) {
        return {
          'code': 0,
          'message':
              'Connection timeout. Please check your internet connection and try again.',
          'data': null,
        };
      }

      if (e.type == dio.DioExceptionType.connectionError) {
        return {
          'code': 0,
          'message':
              'Unable to connect to server. Please check your internet connection.',
          'data': null,
        };
      }

      if (e.response?.data != null &&
          e.response?.data.runtimeType.toString() == '_Map<String, dynamic>') {
        return e.response?.data;
      }

      return {
        'code': 0,
        'message': "Network error: ${e.message ?? 'Unknown error occurred'}",
        'data': null,
      };
    } catch (e) {
      print("Unexpected error in http_post: $e");
      return {
        'code': 0,
        'message': 'Unexpected error occurred. Please try again.',
        'data': null,
      };
    }
  }

  static Future<dynamic> http_get(
    String path,
    Map<String, dynamic> body, {
    bool addBase = true,
  }) async {
    // Check connectivity
    if (!await Utils.is_connected()) {
      return {
        'code': 0,
        'message': 'You are not connected to internet.',
        'data': null,
      };
    }

    // Load current user and token using new token management system
    final LoggedInUserModel u = await LoggedInUserModel.getLoggedInUser();
    final String token = await LoggedInUserModel.getToken();

    // print(token);
    // Make Dio client with bad-cert callback
    final dioClient = dio.Dio();
    (dioClient.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (
      HttpClient client,
    ) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // Prepare query parameters
    final Map<String, dynamic> params = Map<String, dynamic>.from(body);
    params['logged_in_user_id'] = u.id.toString();
    params['platform_type'] = Platform.isIOS ? 'ios' : 'android';

    try {
      final response = await dioClient.get(
        addBase ? "${AppConfig.API_BASE_URL}/$path" : path,
        queryParameters: params,
        options: dio.Options(
          headers: {
            "Authorization": "Bearer $token",
            "Tok": "Bearer $token",
            "logged_in_user_id": u.id.toString(),
            "Content-Type": "application/json; charset=UTF-8",
            "Accept": "application/json",
          },
        ),
      );


      print("${AppConfig.API_BASE_URL}/$path" .toString());
      return response.data;
    } on dio.DioException catch (e) {

      // If the server returned a JSON map, forward it
      if (e.response?.data != null &&
          e.response?.data is Map<String, dynamic>) {
        return e.response?.data;
      }
      // Otherwise, wrap in our standard error shape
      return {
        'status': 0,
        'code': 0,
        'message': e.response?.data ?? e.message,
        'data': null,
      };
    } catch (e) {
      // Unexpected errors
      return {
        'status': 0,
        'code': 0,
        'message': 'Unexpected error: $e',
        'data': null,
      };
    }
  }

  static Future<dynamic> http_delete(
    String path,
    Map<String, dynamic> body, {
    bool addBase = true,
  }) async {
    // Check connectivity
    if (!await Utils.is_connected()) {
      return {
        'code': 0,
        'message': 'You are not connected to internet.',
        'data': null,
      };
    }

    // Load current user and token using new token management system
    final String token = await LoggedInUserModel.getToken();

    // Make Dio client with bad-cert callback
    final dioClient = dio.Dio();
    (dioClient.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      HttpClient client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    // Set timeout
    dioClient.options.connectTimeout = const Duration(seconds: 30);
    dioClient.options.receiveTimeout = const Duration(seconds: 30);

    // Prepare headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Prepare URL
    String url = '';
    if (addBase) {
      url = '${AppConfig.API_BASE_URL}/$path';
    } else {
      url = path;
    }

    try {
      // Make DELETE request
      final response = await dioClient.delete(
        url,
        data: body.isNotEmpty ? jsonEncode(body) : null,
        options: dio.Options(
          headers: headers,
          validateStatus: (status) {
            return status != null &&
                status < 500; // Accept all non-server error responses
          },
        ),
      );

      // Handle response
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String) {
        try {
          return jsonDecode(response.data);
        } catch (e) {
          return {
            'status': 0,
            'code': 0,
            'message': 'Invalid JSON response from server',
            'data': response.data,
          };
        }
      } else {
        return {
          'status': 1,
          'code': 1,
          'message': 'Success',
          'data': response.data,
        };
      }
    } on dio.DioException catch (e) {
      print("DioException in http_delete: ${e.toString()}");
      print("Response data: ${e.response?.data}");

      // If the response has structured data, return it as is
      if (e.response?.data != null &&
          e.response?.data is Map<String, dynamic>) {
        return e.response?.data;
      }
      // Otherwise, wrap in our standard error shape
      return {
        'status': 0,
        'code': 0,
        'message': e.response?.data ?? e.message,
        'data': null,
      };
    } catch (e) {
      // Unexpected errors
      print("Unexpected error in http_delete: $e");
      return {
        'status': 0,
        'code': 0,
        'message': 'Unexpected error occurred. Please try again.',
        'data': null,
      };
    }
  }

  static Future<bool> is_connected() async {
    return true;
    /*//check using internet_connection_checker
    final connectionChecker = InternetConnectionChecker.instance;
    bool isConnected = await connectionChecker.hasConnection;
    if (isConnected) {
      return true;
    } else {
      return false;
    }
    // bool is_connected = false;
    // var connectivityResult = await (Connectivity().checkConnectivity());
    //
    // if (connectivityResult == ConnectivityResult.mobile) {
    //   // I am connected to a mobile network.
    //   is_connected = true;
    // } else if (connectivityResult == ConnectivityResult.wifi) {
    //   // I am connected to a wifi network.
    //   is_connected = true;
    // }
    //
    // return is_connected;*/
  }

  static log(String message) {
    debugPrint(message, wrapWidth: 1200);
  }

  static void toast2(
    String message, {
    Color background_color = CustomTheme.primary,
    color = Colors.white,
    bool is_long = false,
  }) {
    if (Colors.green == color) {
      color = CustomTheme.primary;
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: is_long ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: background_color,
      textColor: color,
      fontSize: 16.0,
    );
  }

  static toast(
    String message, {
    Color color = Colors.green,
    bool isLong = false,
  }) {
    Utils.toast2(message, is_long: isLong);
    return;

    Get.snackbar(
      'Alert',
      message,
      dismissDirection: DismissDirection.down,
      colorText: Colors.white,
      backgroundColor: color,
      margin: EdgeInsets.zero,
      duration:
          isLong ? const Duration(seconds: 3) : const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
      snackStyle: SnackStyle.GROUNDED,
    );
  }

  /// Show loading indicator
  static void showLoading({String? message}) {
    EasyLoading.show(status: message ?? 'Loading...');
  }

  /// Hide loading indicator
  static void hideLoading() {
    EasyLoading.dismiss();
  }

  /// JSON encode with type preservation for complex objects
  static String jsonEncodeWithTypes(dynamic object) {
    try {
      return jsonEncode(object);
    } catch (e) {
      // Fallback for non-serializable objects
      return jsonEncode({
        'error': 'serialization_failed',
        'type': object.runtimeType.toString(),
      });
    }
  }

  /// JSON decode with type preservation for complex objects
  static dynamic jsonDecodeWithTypes(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      // Return null for invalid JSON
      return null;
    }
  }

  /// HTTP POST method with file upload support for multimedia preview
  static Future<dynamic> http_post_with_files(
    String path, {
    Map<String, dynamic> data = const {},
    Map<String, String> files = const {},
  }) async {
    if (!await Utils.is_connected()) {
      return {
        'code': 0,
        'message': 'You are not connected to internet.',
        'data': null,
      };
    }

    // Make a mutable copy of the incoming data
    final Map<String, dynamic> payload = Map<String, dynamic>.from(data);

    dynamic response;
    var dioClient = dio.Dio();

    // Enhanced iPad compatibility configuration
    (dioClient.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (
      HttpClient client,
    ) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      client.connectionTimeout = const Duration(
        seconds: 60,
      ); // Longer timeout for file uploads
      client.idleTimeout = const Duration(seconds: 60);
      client.userAgent = 'UGFlix-iOS/${Platform.operatingSystemVersion}';
      return client;
    };

    dioClient.options
      ..connectTimeout = const Duration(seconds: 60)
      ..receiveTimeout = const Duration(seconds: 60)
      ..sendTimeout = const Duration(seconds: 60);

    // Retrieve token
    final prefs = await SharedPreferences.getInstance();

    String token = await LoggedInUserModel.get_token();

    // Add logged‐in user ID
    LoggedInUserModel userModel = await LoggedInUserModel.getLoggedInUser();
    payload['logged_in_user_id'] = userModel.id.toString();

    // Platform info
    String platform_type;
    String device_info;
    if (Platform.isIOS) {
      platform_type = 'ios';
      device_info = 'iOS/${Platform.operatingSystemVersion}';
    } else {
      platform_type = 'android';
      device_info = 'Android/${Platform.operatingSystemVersion}';
    }
    payload['platform_type'] = platform_type;
    payload['device_info'] = device_info;

    // Create FormData with files
    var formData = dio.FormData.fromMap(payload);

    // Add file uploads
    for (String fieldName in files.keys) {
      String filePath = files[fieldName]!;
      String fileName = filePath.split('/').last;

      formData.files.add(
        MapEntry(
          fieldName,
          await dio.MultipartFile.fromFile(filePath, filename: fileName),
        ),
      );
    }

    try {
      response = await dioClient.post(
        "${AppConfig.API_BASE_URL}/$path",
        data: formData,
        options: dio.Options(
          headers: <String, String>{
            "Accept": "application/json",
            "Authorization": "Bearer $token",
            "Tok": "Bearer $token",
            "logged_in_user_id": userModel.id.toString(),
            "User-Agent": "UGFlix-$device_info",
            "X-Platform": platform_type,
            "X-App-Version": "1.0.0",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        return {
          'code': 0,
          'message': 'Server returned status ${response.statusCode}',
          'data': null,
        };
      }
    } on dio.DioException catch (e) {
      print("============FILE UPLOAD ERROR==============");
      print("${AppConfig.API_BASE_URL}/$path");
      print("Error Type: ${e.type}");
      print("Error Message: ${e.message}");
      if (e.response != null) {
        print("Response Status: ${e.response?.statusCode}");
        print("Response Data: ${e.response?.data}");
      }
      print("==========================");

      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout ||
          e.type == dio.DioExceptionType.sendTimeout) {
        return {
          'code': 0,
          'message':
              'Upload timeout. Please check your connection and try again.',
          'data': null,
        };
      }

      if (e.type == dio.DioExceptionType.connectionError) {
        return {
          'code': 0,
          'message': 'Unable to connect to server for file upload.',
          'data': null,
        };
      }

      if (e.response?.data != null &&
          e.response?.data.runtimeType.toString() == '_Map<String, dynamic>') {
        return e.response?.data;
      }

      return {
        'code': 0,
        'message':
            "File upload error: ${e.message ?? 'Unknown error occurred'}",
        'data': null,
      };
    } catch (e) {
      print("Unexpected error in http_post_with_files: $e");
      return {
        'code': 0,
        'message': 'File upload failed. Please try again.',
        'data': null,
      };
    }
  }
}
