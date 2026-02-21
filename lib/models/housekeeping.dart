import 'package:json_annotation/json_annotation.dart';

part 'housekeeping.g.dart';

@JsonSerializable()
class Housekeeping {
  final int id;
  @JsonKey(name: 'room_id')
  final int? roomId;
  final String? status;
  @JsonKey(name: 'assignee_id')
  final int? assigneeId;
  @JsonKey(name: 'scheduled_date')
  final String? scheduledDate;
  @JsonKey(name: 'completed_at')
  final String? completedAt;
  final String? notes;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const Housekeeping({
    required this.id,
    this.roomId,
    this.status,
    this.assigneeId,
    this.scheduledDate,
    this.completedAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Housekeeping.fromJson(Map<String, dynamic> json) => _$HousekeepingFromJson(json);
  Map<String, dynamic> toJson() => _$HousekeepingToJson(this);
}
