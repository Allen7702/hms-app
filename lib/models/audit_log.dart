import 'package:json_annotation/json_annotation.dart';

part 'audit_log.g.dart';

@JsonSerializable()
class AuditLog {
  final int id;
  final String? action;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'entity_type')
  final String? entityType;
  @JsonKey(name: 'entity_id')
  final int? entityId;
  final Map<String, dynamic>? details;
  @JsonKey(name: 'data_before')
  final Map<String, dynamic>? dataBefore;
  @JsonKey(name: 'data_after')
  final Map<String, dynamic>? dataAfter;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const AuditLog({
    required this.id,
    this.action,
    this.userId,
    this.entityType,
    this.entityId,
    this.details,
    this.dataBefore,
    this.dataAfter,
    this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) => _$AuditLogFromJson(json);
  Map<String, dynamic> toJson() => _$AuditLogToJson(this);
}
