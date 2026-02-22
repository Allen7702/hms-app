// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
  id: (json['id'] as num).toInt(),
  bookingId: (json['booking_id'] as num?)?.toInt(),
  amount: json['amount'] as num?,
  tax: json['tax'] as num?,
  invoiceNumber: json['invoice_number'] as String?,
  status: json['status'] as String?,
  issueDate: json['issue_date'] as String?,
  dueDate: json['due_date'] as String?,
  paidAt: json['paid_at'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'booking_id': instance.bookingId,
  'amount': instance.amount,
  'tax': instance.tax,
  'invoice_number': instance.invoiceNumber,
  'status': instance.status,
  'issue_date': instance.issueDate,
  'due_date': instance.dueDate,
  'paid_at': instance.paidAt,
  'notes': instance.notes,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
