// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: (json['id'] as num).toInt(),
  guestId: (json['guest_id'] as num?)?.toInt(),
  roomId: (json['room_id'] as num?)?.toInt(),
  checkIn: json['check_in'] as String?,
  checkOut: json['check_out'] as String?,
  status: json['status'] as String?,
  source: json['source'] as String?,
  rateApplied: json['rate_applied'] as num?,
  adults: (json['adults'] as num?)?.toInt(),
  children: (json['children'] as num?)?.toInt(),
  specialRequests: json['special_requests'] as String?,
  notes: json['notes'] as String?,
  modificationReason: json['modification_reason'] as String?,
  paymentStatus: json['payment_status'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  guest: json['guests'] == null
      ? null
      : Guest.fromJson(json['guests'] as Map<String, dynamic>),
  room: json['rooms'] == null
      ? null
      : Room.fromJson(json['rooms'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  'id': instance.id,
  'guest_id': instance.guestId,
  'room_id': instance.roomId,
  'check_in': instance.checkIn,
  'check_out': instance.checkOut,
  'status': instance.status,
  'source': instance.source,
  'rate_applied': instance.rateApplied,
  'adults': instance.adults,
  'children': instance.children,
  'special_requests': instance.specialRequests,
  'notes': instance.notes,
  'modification_reason': instance.modificationReason,
  'payment_status': instance.paymentStatus,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'guests': instance.guest,
  'rooms': instance.room,
};
