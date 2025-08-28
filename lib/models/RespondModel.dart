import 'dart:convert';

import 'package:get/get.dart';

import '../screens/auth/login_screen.dart';
import '../utils/Utilities.dart';

class RespondModel {
  dynamic raw = null;
  late int code = 0;
  String message = "";
  dynamic data = null;

  RespondModel(this.raw) {
    // sensible defaults
    code = 0;
    message =
        "Failed to connect to internet. Check your connection and try again";
    data = null;

    try {
      // 1) Pull out a Map<String, dynamic> however raw arrived:
      late Map<String, dynamic> map;

      if (raw is String) {
        map = jsonDecode(raw) as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        try {
          // already a Map<String, dynamic>
          map = raw;
        } catch (e) {
          throw Exception(
            "Failed to cast Map to Map<String, dynamic>: $e\nRaw data: $raw",
          );
        }
      } else if (raw is Map) {
        try {
          // try to convert Map to Map<String, dynamic>
          map = raw.cast<String, dynamic>();
        } catch (e) {
          throw Exception(
            "Failed to cast Map to Map<String, dynamic>: $e\nRaw data: $raw",
          );
        }
      } else {
        throw Exception(
          "Unsupported type for raw data: ${raw.runtimeType}. Expected String or Map<String, dynamic>.",
        );
      }

      // 2) Handle unauthorized
      if (map['message'] == 'Unauthenticated') {
        Utils.toast("You are not logged in.");
        Utils.logout();
        Get.off(const LoginScreen());
        return;
      }

      // 3) Parse code & message
      code = int.tryParse(map['code']?.toString() ?? '') ?? 0;
      message = map['message']?.toString() ?? message;

      // 4) Preserve data exactly as sent
      data = map['data'];
    } catch (e) {
      //throw an error with the raw data and reason
      throw Exception("Failed to parse response: $e\nRaw data: $raw");
    }
  }
}
