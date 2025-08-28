import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart' show immutable;
part 'create_user_forma_data.g.dart';

@immutable
@JsonSerializable()
class CreateUserFormData {
  const CreateUserFormData({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  final String name;
  final String email;
  final String phoneNumber;
  final String password;

  factory CreateUserFormData.fromJson(Map<String, dynamic> json) => _$CreateUserFormDataFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUserFormDataToJson(this);
}
