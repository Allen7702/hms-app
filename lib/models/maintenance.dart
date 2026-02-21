import 'package:json_annotation/json_annotation.dart';

part 'maintenance.g.dart';

@JsonSerializable()
class Maintenance {
  final int id;
  @JsonKey(name: 'room_id')
  final int? roomId;
  final String? description;
  final String? status;
  final String? priority;
  @JsonKey(name: 'assignee_id')
  final int? assigneeId;
  @JsonKey(name: 'estimated_cost')
  final num? estimatedCost;
  @JsonKey(name: 'actual_cost')
  final num? actualCost;
  @JsonKey(name: 'labor_cost')
  final num? laborCost;
  @JsonKey(name: 'materials_cost')
  final num? materialsCost;
  @JsonKey(name: 'contractor_cost')
  final num? contractorCost;
  @JsonKey(name: 'cost_breakdown')
  final Map<String, dynamic>? costBreakdown;
  @JsonKey(name: 'cost_approved_by')
  final int? costApprovedBy;
  @JsonKey(name: 'requires_approval')
  final bool? requiresApproval;
  final List<dynamic>? history;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const Maintenance({
    required this.id,
    this.roomId,
    this.description,
    this.status,
    this.priority,
    this.assigneeId,
    this.estimatedCost,
    this.actualCost,
    this.laborCost,
    this.materialsCost,
    this.contractorCost,
    this.costBreakdown,
    this.costApprovedBy,
    this.requiresApproval,
    this.history,
    this.createdAt,
    this.updatedAt,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) => _$MaintenanceFromJson(json);
  Map<String, dynamic> toJson() => _$MaintenanceToJson(this);
}
