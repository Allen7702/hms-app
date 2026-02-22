import 'package:json_annotation/json_annotation.dart';

part 'reorder_alert.g.dart';

@JsonSerializable()
class ReorderAlert {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'item_id')
  final int? itemId;
  @JsonKey(name: 'current_stock')
  final num? currentStock;
  @JsonKey(name: 'minimum_stock')
  final num? minimumStock;
  @JsonKey(name: 'suggested_quantity')
  final num? suggestedQuantity;
  final String? status;
  @JsonKey(name: 'acknowledged_by')
  final int? acknowledgedBy;
  @JsonKey(name: 'resolved_by')
  final int? resolvedBy;
  final String? notes;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const ReorderAlert({
    required this.id,
    this.hotelId,
    this.itemId,
    this.currentStock,
    this.minimumStock,
    this.suggestedQuantity,
    this.status,
    this.acknowledgedBy,
    this.resolvedBy,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory ReorderAlert.fromJson(Map<String, dynamic> json) => _$ReorderAlertFromJson(json);
  Map<String, dynamic> toJson() => _$ReorderAlertToJson(this);
}
