// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_wastage_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosWastageLog _$PosWastageLogFromJson(Map<String, dynamic> json) =>
    PosWastageLog(
      id: (json['id'] as num).toInt(),
      hotelId: (json['hotel_id'] as num?)?.toInt(),
      shiftId: (json['shift_id'] as num?)?.toInt(),
      productId: (json['product_id'] as num?)?.toInt(),
      productName: json['product_name'] as String?,
      costPrice: (json['cost_price'] as num?)?.toInt(),
      quantity: (json['quantity'] as num?)?.toInt(),
      reason: json['reason'] as String?,
      recordedBy: (json['recorded_by'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$PosWastageLogToJson(PosWastageLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'shift_id': instance.shiftId,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'cost_price': instance.costPrice,
      'quantity': instance.quantity,
      'reason': instance.reason,
      'recorded_by': instance.recordedBy,
      'created_at': instance.createdAt,
    };
