// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomType _$RoomTypeFromJson(Map<String, dynamic> json) => RoomType(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  name: json['name'] as String?,
  description: json['description'] as String?,
  capacity: (json['capacity'] as num?)?.toInt(),
  price: json['price'] as num?,
  priceModifier: json['price_modifier'] as num?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$RoomTypeToJson(RoomType instance) => <String, dynamic>{
  'id': instance.id,
  'hotel_id': instance.hotelId,
  'name': instance.name,
  'description': instance.description,
  'capacity': instance.capacity,
  'price': instance.price,
  'price_modifier': instance.priceModifier,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
