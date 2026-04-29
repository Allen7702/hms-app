// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosTable _$PosTableFromJson(Map<String, dynamic> json) => PosTable(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  name: json['name'] as String?,
  capacity: (json['capacity'] as num?)?.toInt(),
  floor: json['floor'] as String?,
  status: json['status'] as String?,
  currentOrderId: (json['current_order_id'] as num?)?.toInt(),
  sortOrder: (json['sort_order'] as num?)?.toInt(),
  isActive: json['is_active'] as bool?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$PosTableToJson(PosTable instance) => <String, dynamic>{
  'id': instance.id,
  'hotel_id': instance.hotelId,
  'name': instance.name,
  'capacity': instance.capacity,
  'floor': instance.floor,
  'status': instance.status,
  'current_order_id': instance.currentOrderId,
  'sort_order': instance.sortOrder,
  'is_active': instance.isActive,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
