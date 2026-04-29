// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringExpense _$RecurringExpenseFromJson(Map<String, dynamic> json) =>
    RecurringExpense(
      id: (json['id'] as num).toInt(),
      hotelId: (json['hotel_id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      title: json['title'] as String?,
      amount: (json['amount'] as num?)?.toInt(),
      frequency: json['frequency'] as String?,
      dayOfMonth: (json['day_of_month'] as num?)?.toInt(),
      paymentMethod: json['payment_method'] as String?,
      vendor: json['vendor'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool?,
      lastApplied: json['last_applied'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$RecurringExpenseToJson(RecurringExpense instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'category_id': instance.categoryId,
      'title': instance.title,
      'amount': instance.amount,
      'frequency': instance.frequency,
      'day_of_month': instance.dayOfMonth,
      'payment_method': instance.paymentMethod,
      'vendor': instance.vendor,
      'notes': instance.notes,
      'is_active': instance.isActive,
      'last_applied': instance.lastApplied,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
