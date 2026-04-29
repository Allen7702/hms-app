// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosOrderItem _$PosOrderItemFromJson(Map<String, dynamic> json) => PosOrderItem(
  id: (json['id'] as num).toInt(),
  orderId: (json['order_id'] as num?)?.toInt(),
  productId: (json['product_id'] as num?)?.toInt(),
  productName: json['product_name'] as String?,
  unitPrice: (json['unit_price'] as num?)?.toInt(),
  costPrice: (json['cost_price'] as num?)?.toInt(),
  quantity: (json['quantity'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  status: json['status'] as String?,
  isVoided: json['is_voided'] as bool?,
  voidReason: json['void_reason'] as String?,
  voidedBy: (json['voided_by'] as num?)?.toInt(),
  voidedAt: json['voided_at'] as String?,
  sentAt: json['sent_at'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PosOrderItemToJson(PosOrderItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'unit_price': instance.unitPrice,
      'cost_price': instance.costPrice,
      'quantity': instance.quantity,
      'notes': instance.notes,
      'status': instance.status,
      'is_voided': instance.isVoided,
      'void_reason': instance.voidReason,
      'voided_by': instance.voidedBy,
      'voided_at': instance.voidedAt,
      'sent_at': instance.sentAt,
      'created_at': instance.createdAt,
    };
