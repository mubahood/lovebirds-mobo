import 'package:json_annotation/json_annotation.dart';

part 'resource_model.g.dart';

@JsonSerializable()
class Resource {
  final String id;
  final String heading;
  final int order;
  final int status;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'organisation_id')
  final String organisationId;
  @JsonKey(name: 'training_id')
  final String trainingId;
  final String type;
  final String body;
  final String? file;
  final String? photo;
  final String? audio;
  final String? video;
  final String? youtube;
  Resource({
    required this.id,
    required this.heading,
    required this.order,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.organisationId,
    required this.trainingId,
    required this.type,
    required this.body,
    this.file,
    this.photo,
    this.video,
    this.youtube,
    this.audio


  });

  factory Resource.fromJson(Map<String, dynamic> json) =>
      _$ResourceFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceToJson(this);
}
