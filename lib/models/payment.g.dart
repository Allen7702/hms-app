// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: (json['id'] as num).toInt(),
  invoiceId: (json['invoice_id'] as num?)?.toInt(),
  amount: json['amount'] as num?,
  status: json['status'] as String?,
  method: json['method'] as String?,
  transactionId: json['transaction_id'] as String?,
  processedAt: json['processed_at'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'invoice_id': instance.invoiceId,
  'amount': instance.amount,
  'status': instance.status,
  'method': instance.method,
  'transaction_id': instance.transactionId,
  'processed_at': instance.processedAt,
  'created_at': instance.createdAt,
};
