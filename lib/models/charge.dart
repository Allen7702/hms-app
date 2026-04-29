import 'package:json_annotation/json_annotation.dart';

part 'charge.g.dart';

@JsonSerializable()
class Charge {
  final int id;
  @JsonKey(name: 'booking_id')
  final int? bookingId;
  @JsonKey(name: 'invoice_id')
  final int? invoiceId;
  @JsonKey(name: 'charge_type')
  final String? chargeType;
  final String? description;
  final num? amount;
  final int? quantity;
  final String? status;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'payment_reference')
  final String? paymentReference;
  @JsonKey(name: 'paid_at')
  final String? paidAt;
  @JsonKey(name: 'paid_amount')
  final int? paidAmount;
  @JsonKey(name: 'added_by')
  final String? addedBy;
  @JsonKey(name: 'service_date')
  final String? serviceDate;
  final String? notes;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const Charge({
    required this.id,
    this.bookingId,
    this.invoiceId,
    this.chargeType,
    this.description,
    this.amount,
    this.quantity,
    this.status,
    this.paymentMethod,
    this.paymentReference,
    this.paidAt,
    this.paidAmount,
    this.addedBy,
    this.serviceDate,
    this.notes,
    this.createdAt,
  });

  factory Charge.fromJson(Map<String, dynamic> json) => _$ChargeFromJson(json);
  Map<String, dynamic> toJson() => _$ChargeToJson(this);
}
