import 'package:json_annotation/json_annotation.dart';

part 'inventory_item.g.dart';

@JsonSerializable()
class InventoryItem {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  final String? name;
  final String? sku;
  final String? unit;
  @JsonKey(name: 'current_stock')
  final num? currentStock;
  @JsonKey(name: 'minimum_stock')
  final num? minimumStock;
  @JsonKey(name: 'maximum_stock')
  final num? maximumStock;
  @JsonKey(name: 'reorder_quantity')
  final num? reorderQuantity;
  @JsonKey(name: 'unit_cost')
  final num? unitCost;
  @JsonKey(name: 'selling_price')
  final num? sellingPrice;
  @JsonKey(name: 'storage_location')
  final String? storageLocation;
  @JsonKey(name: 'is_perishable')
  final bool? isPerishable;
  @JsonKey(name: 'expiration_days')
  final int? expirationDays;
  @JsonKey(name: 'last_restock_date')
  final String? lastRestockDate;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const InventoryItem({
    required this.id,
    this.hotelId,
    this.categoryId,
    this.name,
    this.sku,
    this.unit,
    this.currentStock,
    this.minimumStock,
    this.maximumStock,
    this.reorderQuantity,
    this.unitCost,
    this.sellingPrice,
    this.storageLocation,
    this.isPerishable,
    this.expirationDays,
    this.lastRestockDate,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => _$InventoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryItemToJson(this);
}
