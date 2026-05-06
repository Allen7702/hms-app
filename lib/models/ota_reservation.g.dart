// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ota_reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtaReservation _$OtaReservationFromJson(Map<String, dynamic> json) =>
    OtaReservation(
      id: (json['id'] as num).toInt(),
      hotelId: (json['hotel_id'] as num?)?.toInt(),
      bookingId: (json['booking_id'] as num?)?.toInt(),
      otaId: json['ota_id'] as String?,
      otaName: json['ota_name'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$OtaReservationToJson(OtaReservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'booking_id': instance.bookingId,
      'ota_id': instance.otaId,
      'ota_name': instance.otaName,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
