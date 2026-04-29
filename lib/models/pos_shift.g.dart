// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosShift _$PosShiftFromJson(Map<String, dynamic> json) => PosShift(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  openedBy: (json['opened_by'] as num?)?.toInt(),
  closedBy: (json['closed_by'] as num?)?.toInt(),
  openedAt: json['opened_at'] as String?,
  closedAt: json['closed_at'] as String?,
  openingCash: (json['opening_cash'] as num?)?.toInt(),
  closingCash: (json['closing_cash'] as num?)?.toInt(),
  expectedCash: (json['expected_cash'] as num?)?.toInt(),
  cashVariance: (json['cash_variance'] as num?)?.toInt(),
  totalSales: (json['total_sales'] as num?)?.toInt(),
  totalVoids: (json['total_voids'] as num?)?.toInt(),
  totalOrders: (json['total_orders'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  status: json['status'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PosShiftToJson(PosShift instance) => <String, dynamic>{
  'id': instance.id,
  'hotel_id': instance.hotelId,
  'opened_by': instance.openedBy,
  'closed_by': instance.closedBy,
  'opened_at': instance.openedAt,
  'closed_at': instance.closedAt,
  'opening_cash': instance.openingCash,
  'closing_cash': instance.closingCash,
  'expected_cash': instance.expectedCash,
  'cash_variance': instance.cashVariance,
  'total_sales': instance.totalSales,
  'total_voids': instance.totalVoids,
  'total_orders': instance.totalOrders,
  'notes': instance.notes,
  'status': instance.status,
  'created_at': instance.createdAt,
};
