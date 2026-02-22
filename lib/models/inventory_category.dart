import 'package:json_annotation/json_annotation.dart';

part 'inventory_category.g.dart';

@JsonSerializable()
class InventoryCategory {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  final String? name;
  @JsonKey(name: 'category_type')
  final String? categoryType;
  final String? description;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const InventoryCategory({
    required this.id,
    this.hotelId,
    this.name,
    this.categoryType,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryCategory.fromJson(Map<String, dynamic> json) =>
      _$InventoryCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryCategoryToJson(this);
}
