// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosProduct _$PosProductFromJson(Map<String, dynamic> json) => PosProduct(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  categoryId: (json['category_id'] as num?)?.toInt(),
  name: json['name'] as String?,
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  sellPrice: (json['sell_price'] as num?)?.toInt(),
  costPrice: (json['cost_price'] as num?)?.toInt(),
  taxPercent: json['tax_percent'] as String?,
  isAvailable: json['is_available'] as bool?,
  isFeatured: json['is_featured'] as bool?,
  trackStock: json['track_stock'] as bool?,
  inventoryItemId: (json['inventory_item_id'] as num?)?.toInt(),
  sortOrder: (json['sort_order'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$PosProductToJson(PosProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'category_id': instance.categoryId,
      'name': instance.name,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'sell_price': instance.sellPrice,
      'cost_price': instance.costPrice,
      'tax_percent': instance.taxPercent,
      'is_available': instance.isAvailable,
      'is_featured': instance.isFeatured,
      'track_stock': instance.trackStock,
      'inventory_item_id': instance.inventoryItemId,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
