import 'package:json_annotation/json_annotation.dart';

part 'training.g.dart';

@JsonSerializable()
class TrainingSession {
  final String id;
  @JsonKey(name: 'village_agent_id')
  final String villageAgentId;
  @JsonKey(name: 'extension_officer_id')
  final String extensionOfficerId;
  @JsonKey(name: 'user_id')
  final String userId;
  final String? details;
  final String date;
  final String time;
  final String? venue;
  final String status;
  @JsonKey(name: 'organisation_id')
  final String organisationId;
  @JsonKey(name: 'subtopic_id')
  final String? subtopicId;
  final String name;
  TrainingSession({
    required this.id,
    required this.villageAgentId,
    required this.extensionOfficerId,
    required this.userId,
     this.details,
    required this.date,
    required this.time,
    required  this.name,
     this.venue,
    required this.status,
    required this.organisationId,
    this.subtopicId,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingSessionToJson(this);
}
