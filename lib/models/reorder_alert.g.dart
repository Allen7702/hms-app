// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reorder_alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReorderAlert _$ReorderAlertFromJson(Map<String, dynamic> json) => ReorderAlert(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  itemId: (json['item_id'] as num?)?.toInt(),
  currentStock: json['current_stock'] as num?,
  minimumStock: json['minimum_stock'] as num?,
  suggestedQuantity: json['suggested_quantity'] as num?,
  status: json['status'] as String?,
  acknowledgedBy: (json['acknowledged_by'] as num?)?.toInt(),
  acknowledgedAt: json['acknowledged_at'] as String?,
  resolvedBy: (json['resolved_by'] as num?)?.toInt(),
  resolvedAt: json['resolved_at'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ReorderAlertToJson(ReorderAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'item_id': instance.itemId,
      'current_stock': instance.currentStock,
      'minimum_stock': instance.minimumStock,
      'suggested_quantity': instance.suggestedQuantity,
      'status': instance.status,
      'acknowledged_by': instance.acknowledgedBy,
      'acknowledged_at': instance.acknowledgedAt,
      'resolved_by': instance.resolvedBy,
      'resolved_at': instance.resolvedAt,
      'notes': instance.notes,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
