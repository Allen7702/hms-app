import 'package:json_annotation/json_annotation.dart';

part 'pos_order_item.g.dart';

@JsonSerializable()
class PosOrderItem {
  final int id;
  @JsonKey(name: 'order_id')
  final int? orderId;
  @JsonKey(name: 'product_id')
  final int? productId;
  @JsonKey(name: 'product_name')
  final String? productName;
  @JsonKey(name: 'unit_price')
  final int? unitPrice;
  @JsonKey(name: 'cost_price')
  final int? costPrice;
  final int? quantity;
  final String? notes;
  final String? status;
  @JsonKey(name: 'is_voided')
  final bool? isVoided;
  @JsonKey(name: 'void_reason')
  final String? voidReason;
  @JsonKey(name: 'voided_by')
  final int? voidedBy;
  @JsonKey(name: 'voided_at')
  final String? voidedAt;
  @JsonKey(name: 'sent_at')
  final String? sentAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const PosOrderItem({
    required this.id,
    this.orderId,
    this.productId,
    this.productName,
    this.unitPrice,
    this.costPrice,
    this.quantity,
    this.notes,
    this.status,
    this.isVoided,
    this.voidReason,
    this.voidedBy,
    this.voidedAt,
    this.sentAt,
    this.createdAt,
  });

  factory PosOrderItem.fromJson(Map<String, dynamic> json) =>
      _$PosOrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$PosOrderItemToJson(this);
}
