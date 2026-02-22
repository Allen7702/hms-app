// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryTransaction _$InventoryTransactionFromJson(
  Map<String, dynamic> json,
) => InventoryTransaction(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  itemId: (json['item_id'] as num?)?.toInt(),
  transactionType: json['transaction_type'] as String?,
  quantity: json['quantity'] as num?,
  previousStock: json['previous_stock'] as num?,
  newStock: json['new_stock'] as num?,
  referenceType: json['reference_type'] as String?,
  referenceId: (json['reference_id'] as num?)?.toInt(),
  roomId: (json['room_id'] as num?)?.toInt(),
  bookingId: (json['booking_id'] as num?)?.toInt(),
  unitCostAtTime: json['unit_cost_at_time'] as num?,
  notes: json['notes'] as String?,
  performedBy: (json['performed_by'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$InventoryTransactionToJson(
  InventoryTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'hotel_id': instance.hotelId,
  'item_id': instance.itemId,
  'transaction_type': instance.transactionType,
  'quantity': instance.quantity,
  'previous_stock': instance.previousStock,
  'new_stock': instance.newStock,
  'reference_type': instance.referenceType,
  'reference_id': instance.referenceId,
  'room_id': instance.roomId,
  'booking_id': instance.bookingId,
  'unit_cost_at_time': instance.unitCostAtTime,
  'notes': instance.notes,
  'performed_by': instance.performedBy,
  'created_at': instance.createdAt,
};
