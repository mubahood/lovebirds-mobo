import 'package:json_annotation/json_annotation.dart';

part 'roles_model.g.dart';

@JsonSerializable()
class Role {
  @JsonKey(name: 'role_id')
  int? roleId;
  @JsonKey(name: 'role_name')
  String? roleName;

  Role(this.roleId, this.roleName);

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
