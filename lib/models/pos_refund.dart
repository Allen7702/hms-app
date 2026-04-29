import 'package:json_annotation/json_annotation.dart';

part 'pos_refund.g.dart';

@JsonSerializable()
class PosRefund {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'order_id')
  final int? orderId;
  @JsonKey(name: 'shift_id')
  final int? shiftId;
  final int? amount;
  final String? method;
  final String? reason;
  final String? reference;
  @JsonKey(name: 'refunded_by')
  final int? refundedBy;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const PosRefund({
    required this.id,
    this.hotelId,
    this.orderId,
    this.shiftId,
    this.amount,
    this.method,
    this.reason,
    this.reference,
    this.refundedBy,
    this.createdAt,
  });

  factory PosRefund.fromJson(Map<String, dynamic> json) =>
      _$PosRefundFromJson(json);
  Map<String, dynamic> toJson() => _$PosRefundToJson(this);
}
