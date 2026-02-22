// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String?,
      guestId: (json['guest_id'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      recipient: json['recipient'] as String?,
      message: json['message'] as String?,
      status: json['status'] as String?,
      relatedEntityId: (json['related_entity_id'] as num?)?.toInt(),
      entityType: json['entity_type'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'guest_id': instance.guestId,
      'user_id': instance.userId,
      'recipient': instance.recipient,
      'message': instance.message,
      'status': instance.status,
      'related_entity_id': instance.relatedEntityId,
      'entity_type': instance.entityType,
      'created_at': instance.createdAt,
    };
