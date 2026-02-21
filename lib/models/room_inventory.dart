import 'package:json_annotation/json_annotation.dart';

part 'room_inventory.g.dart';

@JsonSerializable()
class RoomInventory {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'room_id')
  final int? roomId;
  @JsonKey(name: 'item_id')
  final int? itemId;
  @JsonKey(name: 'par_level')
  final num? parLevel;
  @JsonKey(name: 'current_quantity')
  final num? currentQuantity;
  @JsonKey(name: 'last_checked')
  final String? lastChecked;
  @JsonKey(name: 'last_checked_by')
  final int? lastCheckedBy;
  @JsonKey(name: 'last_restocked')
  final String? lastRestocked;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const RoomInventory({
    required this.id,
    this.hotelId,
    this.roomId,
    this.itemId,
    this.parLevel,
    this.currentQuantity,
    this.lastChecked,
    this.lastCheckedBy,
    this.lastRestocked,
    this.createdAt,
    this.updatedAt,
  });

  factory RoomInventory.fromJson(Map<String, dynamic> json) => _$RoomInventoryFromJson(json);
  Map<String, dynamic> toJson() => _$RoomInventoryToJson(this);
}
