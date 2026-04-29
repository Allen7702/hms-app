import 'package:json_annotation/json_annotation.dart';

part 'pos_wastage_log.g.dart';

@JsonSerializable()
class PosWastageLog {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'shift_id')
  final int? shiftId;
  @JsonKey(name: 'product_id')
  final int? productId;
  @JsonKey(name: 'product_name')
  final String? productName;
  @JsonKey(name: 'cost_price')
  final int? costPrice;
  final int? quantity;
  final String? reason;
  @JsonKey(name: 'recorded_by')
  final int? recordedBy;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const PosWastageLog({
    required this.id,
    this.hotelId,
    this.shiftId,
    this.productId,
    this.productName,
    this.costPrice,
    this.quantity,
    this.reason,
    this.recordedBy,
    this.createdAt,
  });

  factory PosWastageLog.fromJson(Map<String, dynamic> json) =>
      _$PosWastageLogFromJson(json);
  Map<String, dynamic> toJson() => _$PosWastageLogToJson(this);
}
