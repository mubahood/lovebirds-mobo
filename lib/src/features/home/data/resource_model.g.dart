// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Resource _$ResourceFromJson(Map<String, dynamic> json) => Resource(
      id: json['id'] as String,
      heading: json['heading'] as String,
      order: json['order'] as int,
      status: json['status'] as int,
      userId: json['user_id'] as String,
      createdAt: json['created_at'] as String,
      organisationId: json['organisation_id'] as String,
      trainingId: json['training_id'] as String,
      type: json['type'] as String,
      body: json['body'] as String,
      file: json['file'] as String?,
      photo: json['photo'] as String?,
      video: json['video'] as String?,
      youtube: json['youtube'] as String?,
      audio: json['audio'] as String?,
    );

Map<String, dynamic> _$ResourceToJson(Resource instance) => <String, dynamic>{
      'id': instance.id,
      'heading': instance.heading,
      'order': instance.order,
      'status': instance.status,
      'user_id': instance.userId,
      'created_at': instance.createdAt,
      'organisation_id': instance.organisationId,
      'training_id': instance.trainingId,
      'type': instance.type,
      'body': instance.body,
      'file': instance.file,
      'photo': instance.photo,
      'audio': instance.audio,
      'video': instance.video,
      'youtube': instance.youtube,
    };
