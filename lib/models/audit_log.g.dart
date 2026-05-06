// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditLog _$AuditLogFromJson(Map<String, dynamic> json) => AuditLog(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  action: json['action'] as String?,
  userId: (json['user_id'] as num?)?.toInt(),
  entityType: json['entity_type'] as String?,
  entityId: (json['entity_id'] as num?)?.toInt(),
  details: json['details'] as Map<String, dynamic>?,
  dataBefore: json['data_before'] as Map<String, dynamic>?,
  dataAfter: json['data_after'] as Map<String, dynamic>?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$AuditLogToJson(AuditLog instance) => <String, dynamic>{
  'id': instance.id,
  'hotel_id': instance.hotelId,
  'action': instance.action,
  'user_id': instance.userId,
  'entity_type': instance.entityType,
  'entity_id': instance.entityId,
  'details': instance.details,
  'data_before': instance.dataBefore,
  'data_after': instance.dataAfter,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
