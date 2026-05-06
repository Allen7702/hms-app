import 'package:json_annotation/json_annotation.dart';

part 'app_notification.g.dart';

@JsonSerializable()
class AppNotification {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  final String? type;
  @JsonKey(name: 'guest_id')
  final int? guestId;
  @JsonKey(name: 'user_id')
  final int? userId;
  final String? recipient;
  final String? message;
  final String? status;
  @JsonKey(name: 'related_entity_id')
  final int? relatedEntityId;
  @JsonKey(name: 'entity_type')
  final String? entityType;
  @JsonKey(name: 'read_at')
  final String? readAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const AppNotification({
    required this.id,
    this.hotelId,
    this.type,
    this.guestId,
    this.userId,
    this.recipient,
    this.message,
    this.status,
    this.relatedEntityId,
    this.entityType,
    this.readAt,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);
}
