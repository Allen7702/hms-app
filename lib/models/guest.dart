import 'package:json_annotation/json_annotation.dart';

part 'guest.g.dart';

@JsonSerializable()
class Guest {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'name')
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? nationality;
  @JsonKey(name: 'id_number')
  final String? idNumber;
  final Map<String, dynamic>? preferences;
  @JsonKey(name: 'loyalty_points')
  final int? loyaltyPoints;
  @JsonKey(name: 'loyalty_tier')
  final String? loyaltyTier;
  @JsonKey(name: 'gdpr_consent')
  final bool? gdprConsent;
  @JsonKey(name: 'total_stays')
  final int? totalStays;
  @JsonKey(name: 'total_spent')
  final int? totalSpent;
  @JsonKey(name: 'last_stay_date')
  final String? lastStayDate;
  @JsonKey(name: 'preferred_room_type')
  final String? preferredRoomType;
  final String? notes;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const Guest({
    required this.id,
    this.hotelId,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.nationality,
    this.idNumber,
    this.preferences,
    this.loyaltyPoints,
    this.loyaltyTier,
    this.gdprConsent,
    this.totalStays,
    this.totalSpent,
    this.lastStayDate,
    this.preferredRoomType,
    this.notes,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Guest.fromJson(Map<String, dynamic> json) => _$GuestFromJson(json);
  Map<String, dynamic> toJson() => _$GuestToJson(this);
}
