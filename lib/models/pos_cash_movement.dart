import 'package:json_annotation/json_annotation.dart';

part 'pos_cash_movement.g.dart';

@JsonSerializable()
class PosCashMovement {
  final int id;
  @JsonKey(name: 'shift_id')
  final int? shiftId;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  final String? type;
  final int? amount;
  final String? reason;
  @JsonKey(name: 'performed_by')
  final int? performedBy;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const PosCashMovement({
    required this.id,
    this.shiftId,
    this.hotelId,
    this.type,
    this.amount,
    this.reason,
    this.performedBy,
    this.createdAt,
  });

  factory PosCashMovement.fromJson(Map<String, dynamic> json) =>
      _$PosCashMovementFromJson(json);
  Map<String, dynamic> toJson() => _$PosCashMovementToJson(this);
}
