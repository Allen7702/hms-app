import 'package:json_annotation/json_annotation.dart';

part 'pos_payment.g.dart';

@JsonSerializable()
class PosPayment {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'order_id')
  final int? orderId;
  @JsonKey(name: 'shift_id')
  final int? shiftId;
  final String? method;
  final int? amount;
  final String? reference;
  @JsonKey(name: 'received_by')
  final int? receivedBy;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const PosPayment({
    required this.id,
    this.hotelId,
    this.orderId,
    this.shiftId,
    this.method,
    this.amount,
    this.reference,
    this.receivedBy,
    this.createdAt,
  });

  factory PosPayment.fromJson(Map<String, dynamic> json) =>
      _$PosPaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PosPaymentToJson(this);
}
