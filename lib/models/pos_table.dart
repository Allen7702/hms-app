import 'package:json_annotation/json_annotation.dart';

part 'pos_table.g.dart';

@JsonSerializable()
class PosTable {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  final String? name;
  final int? capacity;
  final String? floor;
  final String? status;
  @JsonKey(name: 'current_order_id')
  final int? currentOrderId;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const PosTable({
    required this.id,
    this.hotelId,
    this.name,
    this.capacity,
    this.floor,
    this.status,
    this.currentOrderId,
    this.sortOrder,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory PosTable.fromJson(Map<String, dynamic> json) =>
      _$PosTableFromJson(json);
  Map<String, dynamic> toJson() => _$PosTableToJson(this);
}
