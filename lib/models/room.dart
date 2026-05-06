import 'package:json_annotation/json_annotation.dart';
import 'package:hms_app/models/room_type.dart';

part 'room.g.dart';

@JsonSerializable()
class Room {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'room_number', fromJson: Room._stringFromAny)
  final String? roomNumber;
  @JsonKey(fromJson: Room._stringFromAny)
  final String? floor;
  @JsonKey(name: 'room_type_id')
  final int? roomTypeId;
  final String? status;
  final Map<String, dynamic>? features;
  @JsonKey(name: 'last_cleaned')
  final String? lastCleaned;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  // Joined data
  @JsonKey(name: 'room_types')
  final RoomType? roomType;

  const Room({
    required this.id,
    this.hotelId,
    this.roomNumber,
    this.floor,
    this.roomTypeId,
    this.status,
    this.features,
    this.lastCleaned,
    this.createdAt,
    this.updatedAt,
    this.roomType,
  });

  static String? _stringFromAny(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int || value is double) return value.toString();
    return value.toString();
  }

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);
}
