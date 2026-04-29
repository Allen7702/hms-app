import 'package:json_annotation/json_annotation.dart';

part 'ota_reservation.g.dart';

@JsonSerializable()
class OtaReservation {
  final int id;
  @JsonKey(name: 'booking_id')
  final int? bookingId;
  @JsonKey(name: 'ota_id')
  final String? otaId;
  @JsonKey(name: 'ota_name')
  final String? otaName;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const OtaReservation({
    required this.id,
    this.bookingId,
    this.otaId,
    this.otaName,
    this.createdAt,
    this.updatedAt,
  });

  factory OtaReservation.fromJson(Map<String, dynamic> json) =>
      _$OtaReservationFromJson(json);
  Map<String, dynamic> toJson() => _$OtaReservationToJson(this);
}
