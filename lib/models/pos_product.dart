import 'package:json_annotation/json_annotation.dart';

part 'pos_product.g.dart';

@JsonSerializable()
class PosProduct {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  final String? name;
  final String? description;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'sell_price')
  final int? sellPrice;
  @JsonKey(name: 'cost_price')
  final int? costPrice;
  @JsonKey(name: 'tax_percent')
  final String? taxPercent;
  @JsonKey(name: 'is_available')
  final bool? isAvailable;
  @JsonKey(name: 'is_featured')
  final bool? isFeatured;
  @JsonKey(name: 'track_stock')
  final bool? trackStock;
  @JsonKey(name: 'inventory_item_id')
  final int? inventoryItemId;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const PosProduct({
    required this.id,
    this.hotelId,
    this.categoryId,
    this.name,
    this.description,
    this.imageUrl,
    this.sellPrice,
    this.costPrice,
    this.taxPercent,
    this.isAvailable,
    this.isFeatured,
    this.trackStock,
    this.inventoryItemId,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  factory PosProduct.fromJson(Map<String, dynamic> json) =>
      _$PosProductFromJson(json);
  Map<String, dynamic> toJson() => _$PosProductToJson(this);
}
