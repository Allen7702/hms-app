import 'package:json_annotation/json_annotation.dart';

part 'inventory_transaction.g.dart';

@JsonSerializable()
class InventoryTransaction {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'item_id')
  final int? itemId;
  @JsonKey(name: 'transaction_type')
  final String? transactionType;
  final num? quantity;
  @JsonKey(name: 'previous_stock')
  final num? previousStock;
  @JsonKey(name: 'new_stock')
  final num? newStock;
  @JsonKey(name: 'reference_type')
  final String? referenceType;
  @JsonKey(name: 'reference_id')
  final int? referenceId;
  @JsonKey(name: 'room_id')
  final int? roomId;
  @JsonKey(name: 'booking_id')
  final int? bookingId;
  @JsonKey(name: 'unit_cost_at_time')
  final num? unitCostAtTime;
  final String? notes;
  @JsonKey(name: 'performed_by')
  final int? performedBy;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const InventoryTransaction({
    required this.id,
    this.hotelId,
    this.itemId,
    this.transactionType,
    this.quantity,
    this.previousStock,
    this.newStock,
    this.referenceType,
    this.referenceId,
    this.roomId,
    this.bookingId,
    this.unitCostAtTime,
    this.notes,
    this.performedBy,
    this.createdAt,
  });

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) =>
      _$InventoryTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryTransactionToJson(this);
}
