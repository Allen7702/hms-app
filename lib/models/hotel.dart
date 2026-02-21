import 'package:json_annotation/json_annotation.dart';

part 'hotel.g.dart';

@JsonSerializable()
class Hotel {
  final int id;
  final String? name;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final Map<String, dynamic>? settings;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const Hotel({
    required this.id,
    this.name,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.settings,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) => _$HotelFromJson(json);
  Map<String, dynamic> toJson() => _$HotelToJson(this);

  // Convenience getters for settings
  String get currency => settings?['currency'] as String? ?? 'TZS';
  String get timezone => settings?['timezone'] as String? ?? 'Africa/Dar_es_Salaam';
  double get taxRate => (settings?['taxRate'] as num?)?.toDouble() ?? 0.0;
  double get serviceChargeRate => (settings?['serviceChargeRate'] as num?)?.toDouble() ?? 0.0;
  String get checkInTime => settings?['checkInTime'] as String? ?? '14:00';
  String get checkOutTime => settings?['checkOutTime'] as String? ?? '10:00';
  Map<String, dynamic>? get policies => settings?['policies'] as Map<String, dynamic>?;
}
