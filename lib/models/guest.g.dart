// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Guest _$GuestFromJson(Map<String, dynamic> json) => Guest(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  nationality: json['nationality'] as String?,
  idNumber: json['id_number'] as String?,
  preferences: json['preferences'] as Map<String, dynamic>?,
  loyaltyPoints: (json['loyalty_points'] as num?)?.toInt(),
  loyaltyTier: json['loyalty_tier'] as String?,
  gdprConsent: json['gdpr_consent'] as bool?,
  userId: (json['user_id'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$GuestToJson(Guest instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'address': instance.address,
  'nationality': instance.nationality,
  'id_number': instance.idNumber,
  'preferences': instance.preferences,
  'loyalty_points': instance.loyaltyPoints,
  'loyalty_tier': instance.loyaltyTier,
  'gdpr_consent': instance.gdprConsent,
  'user_id': instance.userId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
