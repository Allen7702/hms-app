// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'housekeeping.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Housekeeping _$HousekeepingFromJson(Map<String, dynamic> json) => Housekeeping(
  id: (json['id'] as num).toInt(),
  roomId: (json['room_id'] as num?)?.toInt(),
  status: json['status'] as String?,
  assigneeId: (json['assignee_id'] as num?)?.toInt(),
  scheduledDate: json['scheduled_date'] as String?,
  completedAt: json['completed_at'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$HousekeepingToJson(Housekeeping instance) =>
    <String, dynamic>{
      'id': instance.id,
      'room_id': instance.roomId,
      'status': instance.status,
      'assignee_id': instance.assigneeId,
      'scheduled_date': instance.scheduledDate,
      'completed_at': instance.completedAt,
      'notes': instance.notes,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
