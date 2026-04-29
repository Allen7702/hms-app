// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_refund.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosRefund _$PosRefundFromJson(Map<String, dynamic> json) => PosRefund(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  orderId: (json['order_id'] as num?)?.toInt(),
  shiftId: (json['shift_id'] as num?)?.toInt(),
  amount: (json['amount'] as num?)?.toInt(),
  method: json['method'] as String?,
  reason: json['reason'] as String?,
  reference: json['reference'] as String?,
  refundedBy: (json['refunded_by'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PosRefundToJson(PosRefund instance) => <String, dynamic>{
  'id': instance.id,
  'hotel_id': instance.hotelId,
  'order_id': instance.orderId,
  'shift_id': instance.shiftId,
  'amount': instance.amount,
  'method': instance.method,
  'reason': instance.reason,
  'reference': instance.reference,
  'refunded_by': instance.refundedBy,
  'created_at': instance.createdAt,
};
