import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? photo;
  final String? createdBy;
  final String? status;
  final int? verified;

  @JsonKey(name: 'country_id')
  final String? countryId;

  @JsonKey(name: 'organisation_id')
  final String? organisationId;

  @JsonKey(name: 'microfinance_id')
  final String? microfinanceId;

  @JsonKey(name: 'distributor_id')
  final String? distributorId;

  @JsonKey(name: 'buyer_id')
  final String? buyerId;

  @JsonKey(name: 'two_auth_method')
  final String? twoAuthMethod;

  final String? userHash;
  final String? username;
  final String? rolesText;
  final List<Role>? roles;

  UserModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.photo,
    this.createdBy,
    this.status,
    this.verified,
    this.countryId,
    this.organisationId,
    this.microfinanceId,
    this.distributorId,
    this.buyerId,
    this.twoAuthMethod,
    this.userHash,
    this.username,
    this.rolesText,
    this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class Role {
  final int? id;
  final String? name;
  final String? slug;
  final Pivot? pivot;

  Role({
    this.id,
    this.name,
    this.slug,
    this.pivot,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);
}

@JsonSerializable()
class Pivot {
  @JsonKey(name: 'user_id')
  final int? userId;

  @JsonKey(name: 'role_id')
  final int? roleId;

  Pivot({
    this.userId,
    this.roleId,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) => _$PivotFromJson(json);

  Map<String, dynamic> toJson() => _$PivotToJson(this);
}
