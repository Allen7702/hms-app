import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'full_name')
  final String? fullName;
  final String? username;
  final String? email;
  final String? phone;
  final String? role;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const User({
    required this.id,
    this.hotelId,
    this.fullName,
    this.username,
    this.email,
    this.phone,
    this.role,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
