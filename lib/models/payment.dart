import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'invoice_id')
  final int? invoiceId;
  final num? amount;
  final String? status;
  final String? method;
  @JsonKey(name: 'transaction_id')
  final String? transactionId;
  @JsonKey(name: 'processed_at')
  final String? processedAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const Payment({
    required this.id,
    this.hotelId,
    this.invoiceId,
    this.amount,
    this.status,
    this.method,
    this.transactionId,
    this.processedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
