// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosCategory _$PosCategoryFromJson(Map<String, dynamic> json) => PosCategory(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  name: json['name'] as String?,
  color: json['color'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
  isActive: json['is_active'] as bool?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$PosCategoryToJson(PosCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'name': instance.name,
      'color': instance.color,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
