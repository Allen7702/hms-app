import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final int id;
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

  const Payment({
    required this.id,
    this.invoiceId,
    this.amount,
    this.status,
    this.method,
    this.transactionId,
    this.processedAt,
    this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
