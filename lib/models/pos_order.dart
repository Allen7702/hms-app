import 'package:json_annotation/json_annotation.dart';

part 'pos_order.g.dart';

@JsonSerializable()
class PosOrder {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'shift_id')
  final int? shiftId;
  @JsonKey(name: 'table_id')
  final int? tableId;
  @JsonKey(name: 'booking_id')
  final int? bookingId;
  @JsonKey(name: 'room_id')
  final int? roomId;
  @JsonKey(name: 'order_number')
  final String? orderNumber;
  @JsonKey(name: 'order_type')
  final String? orderType;
  final String? status;
  @JsonKey(name: 'guest_name')
  final String? guestName;
  @JsonKey(name: 'guest_count')
  final int? guestCount;
  @JsonKey(name: 'waiter_id')
  final int? waiterId;
  @JsonKey(name: 'cashier_id')
  final int? cashierId;
  final int? subtotal;
  @JsonKey(name: 'tax_amount')
  final int? taxAmount;
  @JsonKey(name: 'discount_amount')
  final int? discountAmount;
  final int? total;
  final String? notes;
  @JsonKey(name: 'void_reason')
  final String? voidReason;
  @JsonKey(name: 'voided_by')
  final int? voidedBy;
  @JsonKey(name: 'voided_at')
  final String? voidedAt;
  @JsonKey(name: 'kitchen_sent_at')
  final String? kitchenSentAt;
  @JsonKey(name: 'settled_at')
  final String? settledAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const PosOrder({
    required this.id,
    this.hotelId,
    this.shiftId,
    this.tableId,
    this.bookingId,
    this.roomId,
    this.orderNumber,
    this.orderType,
    this.status,
    this.guestName,
    this.guestCount,
    this.waiterId,
    this.cashierId,
    this.subtotal,
    this.taxAmount,
    this.discountAmount,
    this.total,
    this.notes,
    this.voidReason,
    this.voidedBy,
    this.voidedAt,
    this.kitchenSentAt,
    this.settledAt,
    this.createdAt,
    this.updatedAt,
  });

  factory PosOrder.fromJson(Map<String, dynamic> json) =>
      _$PosOrderFromJson(json);
  Map<String, dynamic> toJson() => _$PosOrderToJson(this);
}
