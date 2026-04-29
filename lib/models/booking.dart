import 'package:json_annotation/json_annotation.dart';
import 'package:hms_app/models/guest.dart';
import 'package:hms_app/models/room.dart';

part 'booking.g.dart';

@JsonSerializable()
class Booking {
  final int id;
  @JsonKey(name: 'guest_id')
  final int? guestId;
  @JsonKey(name: 'room_id')
  final int? roomId;
  @JsonKey(name: 'check_in')
  final String? checkIn;
  @JsonKey(name: 'check_out')
  final String? checkOut;
  final String? status;
  final String? source;
  @JsonKey(name: 'rate_applied')
  final num? rateApplied;
  final int? adults;
  final int? children;
  @JsonKey(name: 'special_requests')
  final String? specialRequests;
  final String? notes;
  @JsonKey(name: 'modification_reason')
  final String? modificationReason;
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  // Joined data
  @JsonKey(name: 'guests')
  final Guest? guest;
  @JsonKey(name: 'rooms')
  final Room? room;

  const Booking({
    required this.id,
    this.guestId,
    this.roomId,
    this.checkIn,
    this.checkOut,
    this.status,
    this.source,
    this.rateApplied,
    this.adults,
    this.children,
    this.specialRequests,
    this.notes,
    this.modificationReason,
    this.paymentStatus,
    this.createdAt,
    this.updatedAt,
    this.guest,
    this.room,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
  Map<String, dynamic> toJson() => _$BookingToJson(this);
}
