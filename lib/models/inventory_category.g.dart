// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryCategory _$InventoryCategoryFromJson(Map<String, dynamic> json) =>
    InventoryCategory(
      id: (json['id'] as num).toInt(),
      hotelId: (json['hotel_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      categoryType: json['category_type'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$InventoryCategoryToJson(InventoryCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'name': instance.name,
      'category_type': instance.categoryType,
      'description': instance.description,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
