import 'package:json_annotation/json_annotation.dart';

part 'pos_shift.g.dart';

@JsonSerializable()
class PosShift {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'opened_by')
  final int? openedBy;
  @JsonKey(name: 'closed_by')
  final int? closedBy;
  @JsonKey(name: 'opened_at')
  final String? openedAt;
  @JsonKey(name: 'closed_at')
  final String? closedAt;
  @JsonKey(name: 'opening_cash')
  final int? openingCash;
  @JsonKey(name: 'closing_cash')
  final int? closingCash;
  @JsonKey(name: 'expected_cash')
  final int? expectedCash;
  @JsonKey(name: 'cash_variance')
  final int? cashVariance;
  @JsonKey(name: 'total_sales')
  final int? totalSales;
  @JsonKey(name: 'total_voids')
  final int? totalVoids;
  @JsonKey(name: 'total_orders')
  final int? totalOrders;
  final String? notes;
  final String? status;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const PosShift({
    required this.id,
    this.hotelId,
    this.openedBy,
    this.closedBy,
    this.openedAt,
    this.closedAt,
    this.openingCash,
    this.closingCash,
    this.expectedCash,
    this.cashVariance,
    this.totalSales,
    this.totalVoids,
    this.totalOrders,
    this.notes,
    this.status,
    this.createdAt,
  });

  factory PosShift.fromJson(Map<String, dynamic> json) =>
      _$PosShiftFromJson(json);
  Map<String, dynamic> toJson() => _$PosShiftToJson(this);
}
