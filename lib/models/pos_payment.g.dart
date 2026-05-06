// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosPayment _$PosPaymentFromJson(Map<String, dynamic> json) => PosPayment(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  orderId: (json['order_id'] as num?)?.toInt(),
  shiftId: (json['shift_id'] as num?)?.toInt(),
  method: json['method'] as String?,
  amount: (json['amount'] as num?)?.toInt(),
  reference: json['reference'] as String?,
  receivedBy: (json['received_by'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PosPaymentToJson(PosPayment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'order_id': instance.orderId,
      'shift_id': instance.shiftId,
      'method': instance.method,
      'amount': instance.amount,
      'reference': instance.reference,
      'received_by': instance.receivedBy,
      'created_at': instance.createdAt,
    };
