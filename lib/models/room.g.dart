// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  roomNumber: Room._stringFromAny(json['room_number']),
  floor: Room._stringFromAny(json['floor']),
  roomTypeId: (json['room_type_id'] as num?)?.toInt(),
  status: json['status'] as String?,
  features: json['features'] as Map<String, dynamic>?,
  lastCleaned: json['last_cleaned'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  roomType: json['room_types'] == null
      ? null
      : RoomType.fromJson(json['room_types'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
  'id': instance.id,
  'hotel_id': instance.hotelId,
  'room_number': instance.roomNumber,
  'floor': instance.floor,
  'room_type_id': instance.roomTypeId,
  'status': instance.status,
  'features': instance.features,
  'last_cleaned': instance.lastCleaned,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'room_types': instance.roomType,
};
