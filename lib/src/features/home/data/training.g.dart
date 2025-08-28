// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingSession _$TrainingSessionFromJson(Map<String, dynamic> json) =>
    TrainingSession(
      id: json['id'] as String,
      villageAgentId: json['village_agent_id'] as String,
      extensionOfficerId: json['extension_officer_id'] as String,
      userId: json['user_id'] as String,
      details: json['details'] as String?,
      date: json['date'] as String,
      time: json['time'] as String,
      name: json['name'] as String,
      venue: json['venue'] as String?,
      status: json['status'] as String,
      organisationId: json['organisation_id'] as String,
      subtopicId: json['subtopic_id'] as String?,
    );

Map<String, dynamic> _$TrainingSessionToJson(TrainingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'village_agent_id': instance.villageAgentId,
      'extension_officer_id': instance.extensionOfficerId,
      'user_id': instance.userId,
      'details': instance.details,
      'date': instance.date,
      'time': instance.time,
      'venue': instance.venue,
      'status': instance.status,
      'organisation_id': instance.organisationId,
      'subtopic_id': instance.subtopicId,
      'name': instance.name,
    };
