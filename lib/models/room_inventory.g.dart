// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_inventory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomInventory _$RoomInventoryFromJson(Map<String, dynamic> json) =>
    RoomInventory(
      id: (json['id'] as num).toInt(),
      hotelId: (json['hotel_id'] as num?)?.toInt(),
      roomId: (json['room_id'] as num?)?.toInt(),
      itemId: (json['item_id'] as num?)?.toInt(),
      parLevel: json['par_level'] as num?,
      currentQuantity: json['current_quantity'] as num?,
      lastChecked: json['last_checked'] as String?,
      lastCheckedBy: (json['last_checked_by'] as num?)?.toInt(),
      lastRestocked: json['last_restocked'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$RoomInventoryToJson(RoomInventory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'room_id': instance.roomId,
      'item_id': instance.itemId,
      'par_level': instance.parLevel,
      'current_quantity': instance.currentQuantity,
      'last_checked': instance.lastChecked,
      'last_checked_by': instance.lastCheckedBy,
      'last_restocked': instance.lastRestocked,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
