// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_forma_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUserFormData _$CreateUserFormDataFromJson(Map<String, dynamic> json) =>
    CreateUserFormData(
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$CreateUserFormDataToJson(CreateUserFormData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'password': instance.password,
    };
