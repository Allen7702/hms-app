// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosOrder _$PosOrderFromJson(Map<String, dynamic> json) => PosOrder(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  shiftId: (json['shift_id'] as num?)?.toInt(),
  tableId: (json['table_id'] as num?)?.toInt(),
  bookingId: (json['booking_id'] as num?)?.toInt(),
  roomId: (json['room_id'] as num?)?.toInt(),
  orderNumber: json['order_number'] as String?,
  orderType: json['order_type'] as String?,
  status: json['status'] as String?,
  guestName: json['guest_name'] as String?,
  guestCount: (json['guest_count'] as num?)?.toInt(),
  waiterId: (json['waiter_id'] as num?)?.toInt(),
  cashierId: (json['cashier_id'] as num?)?.toInt(),
  subtotal: (json['subtotal'] as num?)?.toInt(),
  taxAmount: (json['tax_amount'] as num?)?.toInt(),
  discountAmount: (json['discount_amount'] as num?)?.toInt(),
  total: (json['total'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  voidReason: json['void_reason'] as String?,
  voidedBy: (json['voided_by'] as num?)?.toInt(),
  voidedAt: json['voided_at'] as String?,
  kitchenSentAt: json['kitchen_sent_at'] as String?,
  settledAt: json['settled_at'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$PosOrderToJson(PosOrder instance) => <String, dynamic>{
  'id': instance.id,
  'hotel_id': instance.hotelId,
  'shift_id': instance.shiftId,
  'table_id': instance.tableId,
  'booking_id': instance.bookingId,
  'room_id': instance.roomId,
  'order_number': instance.orderNumber,
  'order_type': instance.orderType,
  'status': instance.status,
  'guest_name': instance.guestName,
  'guest_count': instance.guestCount,
  'waiter_id': instance.waiterId,
  'cashier_id': instance.cashierId,
  'subtotal': instance.subtotal,
  'tax_amount': instance.taxAmount,
  'discount_amount': instance.discountAmount,
  'total': instance.total,
  'notes': instance.notes,
  'void_reason': instance.voidReason,
  'voided_by': instance.voidedBy,
  'voided_at': instance.voidedAt,
  'kitchen_sent_at': instance.kitchenSentAt,
  'settled_at': instance.settledAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
