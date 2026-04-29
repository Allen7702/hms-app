// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_cash_movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosCashMovement _$PosCashMovementFromJson(Map<String, dynamic> json) =>
    PosCashMovement(
      id: (json['id'] as num).toInt(),
      shiftId: (json['shift_id'] as num?)?.toInt(),
      hotelId: (json['hotel_id'] as num?)?.toInt(),
      type: json['type'] as String?,
      amount: (json['amount'] as num?)?.toInt(),
      reason: json['reason'] as String?,
      performedBy: (json['performed_by'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$PosCashMovementToJson(PosCashMovement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shift_id': instance.shiftId,
      'hotel_id': instance.hotelId,
      'type': instance.type,
      'amount': instance.amount,
      'reason': instance.reason,
      'performed_by': instance.performedBy,
      'created_at': instance.createdAt,
    };
