// import 'dart:convert';
// import 'package:json_annotation/json_annotation.dart';

class UserProfile {
  String? name;
  String? phone;
  String? email;
  String? photo; // Use a base64-encoded string for the photo
  String? password;

  UserProfile({this.name, this.phone, this.email, this.photo, this.password});

  // factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  // Map<String, dynamic> toJson() => _$UserProfileToJson(this);
  //
  // // Helper method to convert File to base64-encoded string
  // static String fileToBase64(File file) {
  //   List<int> imageBytes = file.readAsBytesSync();
  //   return base64Encode(imageBytes);
  // }
}
