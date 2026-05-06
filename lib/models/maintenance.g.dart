// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Maintenance _$MaintenanceFromJson(Map<String, dynamic> json) => Maintenance(
  id: (json['id'] as num).toInt(),
  hotelId: (json['hotel_id'] as num?)?.toInt(),
  roomId: (json['room_id'] as num?)?.toInt(),
  description: json['description'] as String?,
  status: json['status'] as String?,
  priority: json['priority'] as String?,
  assigneeId: (json['assignee_id'] as num?)?.toInt(),
  estimatedCost: json['estimated_cost'] as num?,
  actualCost: json['actual_cost'] as num?,
  costNotes: json['cost_notes'] as String?,
  laborCost: json['labor_cost'] as num?,
  materialsCost: json['materials_cost'] as num?,
  contractorCost: json['contractor_cost'] as num?,
  costBreakdown: json['cost_breakdown'] as Map<String, dynamic>?,
  costApprovedBy: (json['cost_approved_by'] as num?)?.toInt(),
  requiresApproval: json['requires_approval'] as bool?,
  history: json['history'] as List<dynamic>?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$MaintenanceToJson(Maintenance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'room_id': instance.roomId,
      'description': instance.description,
      'status': instance.status,
      'priority': instance.priority,
      'assignee_id': instance.assigneeId,
      'estimated_cost': instance.estimatedCost,
      'actual_cost': instance.actualCost,
      'cost_notes': instance.costNotes,
      'labor_cost': instance.laborCost,
      'materials_cost': instance.materialsCost,
      'contractor_cost': instance.contractorCost,
      'cost_breakdown': instance.costBreakdown,
      'cost_approved_by': instance.costApprovedBy,
      'requires_approval': instance.requiresApproval,
      'history': instance.history,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
