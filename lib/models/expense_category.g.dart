// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseCategory _$ExpenseCategoryFromJson(Map<String, dynamic> json) =>
    ExpenseCategory(
      id: (json['id'] as num).toInt(),
      hotelId: (json['hotel_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      color: json['color'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ExpenseCategoryToJson(ExpenseCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'name': instance.name,
      'description': instance.description,
      'color': instance.color,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
