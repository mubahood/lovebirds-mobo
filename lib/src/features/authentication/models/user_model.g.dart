// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      photo: json['photo'] as String?,
      createdBy: json['createdBy'] as String?,
      status: json['status'] as String?,
      verified: json['verified'] as int?,
      countryId: json['country_id'] as String?,
      organisationId: json['organisation_id'] as String?,
      microfinanceId: json['microfinance_id'] as String?,
      distributorId: json['distributor_id'] as String?,
      buyerId: json['buyer_id'] as String?,
      twoAuthMethod: json['two_auth_method'] as String?,
      userHash: json['userHash'] as String?,
      username: json['username'] as String?,
      rolesText: json['rolesText'] as String?,
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'photo': instance.photo,
      'createdBy': instance.createdBy,
      'status': instance.status,
      'verified': instance.verified,
      'country_id': instance.countryId,
      'organisation_id': instance.organisationId,
      'microfinance_id': instance.microfinanceId,
      'distributor_id': instance.distributorId,
      'buyer_id': instance.buyerId,
      'two_auth_method': instance.twoAuthMethod,
      'userHash': instance.userHash,
      'username': instance.username,
      'rolesText': instance.rolesText,
      'roles': instance.roles,
    };

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
      id: json['id'] as int?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      pivot: json['pivot'] == null
          ? null
          : Pivot.fromJson(json['pivot'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'pivot': instance.pivot,
    };

Pivot _$PivotFromJson(Map<String, dynamic> json) => Pivot(
      userId: json['user_id'] as int?,
      roleId: json['role_id'] as int?,
    );

Map<String, dynamic> _$PivotToJson(Pivot instance) => <String, dynamic>{
      'user_id': instance.userId,
      'role_id': instance.roleId,
    };
