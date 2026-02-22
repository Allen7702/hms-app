// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Charge _$ChargeFromJson(Map<String, dynamic> json) => Charge(
  id: (json['id'] as num).toInt(),
  bookingId: (json['booking_id'] as num?)?.toInt(),
  invoiceId: (json['invoice_id'] as num?)?.toInt(),
  chargeType: json['charge_type'] as String?,
  description: json['description'] as String?,
  amount: json['amount'] as num?,
  quantity: (json['quantity'] as num?)?.toInt(),
  status: json['status'] as String?,
  paymentMethod: json['payment_method'] as String?,
  paymentReference: json['payment_reference'] as String?,
  paidAt: json['paid_at'] as String?,
  addedBy: (json['added_by'] as num?)?.toInt(),
  serviceDate: json['service_date'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$ChargeToJson(Charge instance) => <String, dynamic>{
  'id': instance.id,
  'booking_id': instance.bookingId,
  'invoice_id': instance.invoiceId,
  'charge_type': instance.chargeType,
  'description': instance.description,
  'amount': instance.amount,
  'quantity': instance.quantity,
  'status': instance.status,
  'payment_method': instance.paymentMethod,
  'payment_reference': instance.paymentReference,
  'paid_at': instance.paidAt,
  'added_by': instance.addedBy,
  'service_date': instance.serviceDate,
  'notes': instance.notes,
  'created_at': instance.createdAt,
};
