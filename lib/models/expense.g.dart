// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  categoryId: (json['category_id'] as num?)?.toInt(),
  recurringId: (json['recurring_id'] as num?)?.toInt(),
  maintenanceId: (json['maintenance_id'] as num?)?.toInt(),
  title: json['title'] as String?,
  amount: (json['amount'] as num?)?.toInt(),
  expenseDate: json['expense_date'] as String?,
  paymentMethod: json['payment_method'] as String?,
  vendor: json['vendor'] as String?,
  reference: json['reference'] as String?,
  notes: json['notes'] as String?,
  recordedBy: (json['recorded_by'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'hotel_id': instance.hotelId,
  'category_id': instance.categoryId,
  'recurring_id': instance.recurringId,
  'maintenance_id': instance.maintenanceId,
  'title': instance.title,
  'amount': instance.amount,
  'expense_date': instance.expenseDate,
  'payment_method': instance.paymentMethod,
  'vendor': instance.vendor,
  'reference': instance.reference,
  'notes': instance.notes,
  'recorded_by': instance.recordedBy,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
