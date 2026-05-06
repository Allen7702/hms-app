// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Guest _$GuestFromJson(Map<String, dynamic> json) => Guest(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
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
  totalStays: (json['total_stays'] as num?)?.toInt(),
  totalSpent: (json['total_spent'] as num?)?.toInt(),
  lastStayDate: json['last_stay_date'] as String?,
  preferredRoomType: json['preferred_room_type'] as String?,
  notes: json['notes'] as String?,
  userId: (json['user_id'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$GuestToJson(Guest instance) => <String, dynamic>{
  'id': instance.id,
  'hotel_id': instance.hotelId,
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
  'total_stays': instance.totalStays,
  'total_spent': instance.totalSpent,
  'last_stay_date': instance.lastStayDate,
  'preferred_room_type': instance.preferredRoomType,
  'notes': instance.notes,
  'user_id': instance.userId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
