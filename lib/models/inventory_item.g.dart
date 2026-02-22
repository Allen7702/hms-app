// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) =>
    InventoryItem(
      id: (json['id'] as num).toInt(),
      hotelId: (json['hotel_id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      sku: json['sku'] as String?,
      unit: json['unit'] as String?,
      currentStock: json['current_stock'] as num?,
      minimumStock: json['minimum_stock'] as num?,
      maximumStock: json['maximum_stock'] as num?,
      reorderQuantity: json['reorder_quantity'] as num?,
      unitCost: json['unit_cost'] as num?,
      sellingPrice: json['selling_price'] as num?,
      storageLocation: json['storage_location'] as String?,
      isPerishable: json['is_perishable'] as bool?,
      expirationDays: (json['expiration_days'] as num?)?.toInt(),
      lastRestockDate: json['last_restock_date'] as String?,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$InventoryItemToJson(InventoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'category_id': instance.categoryId,
      'name': instance.name,
      'sku': instance.sku,
      'unit': instance.unit,
      'current_stock': instance.currentStock,
      'minimum_stock': instance.minimumStock,
      'maximum_stock': instance.maximumStock,
      'reorder_quantity': instance.reorderQuantity,
      'unit_cost': instance.unitCost,
      'selling_price': instance.sellingPrice,
      'storage_location': instance.storageLocation,
      'is_perishable': instance.isPerishable,
      'expiration_days': instance.expirationDays,
      'last_restock_date': instance.lastRestockDate,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
