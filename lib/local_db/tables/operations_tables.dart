import 'package:drift/drift.dart';

// ─── Housekeeping ─────────────────────────────────────────────────────────────

@DataClassName('LocalHousekeeping')
class HousekeepingsTable extends Table {
  @override
  String get tableName => 'housekeepings';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get roomId => integer().nullable().named('room_id')();
  TextColumn get status => text().nullable()();
  IntColumn get assigneeId => integer().nullable().named('assignee_id')();
  TextColumn get scheduledDate => text().nullable().named('scheduled_date')();
  TextColumn get completedAt => text().nullable().named('completed_at')();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── Maintenance ──────────────────────────────────────────────────────────────

@DataClassName('LocalMaintenance')
class MaintenancesTable extends Table {
  @override
  String get tableName => 'maintenances';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get roomId => integer().nullable().named('room_id')();
  TextColumn get description => text().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get priority => text().nullable()();
  IntColumn get assigneeId => integer().nullable().named('assignee_id')();
  RealColumn get estimatedCost => real().nullable().named('estimated_cost')();
  RealColumn get actualCost => real().nullable().named('actual_cost')();
  TextColumn get costNotes => text().nullable().named('cost_notes')();
  RealColumn get laborCost => real().nullable().named('labor_cost')();
  RealColumn get materialsCost => real().nullable().named('materials_cost')();
  RealColumn get contractorCost => real().nullable().named('contractor_cost')();
  TextColumn get costBreakdown => text().nullable().named('cost_breakdown')(); // JSON
  IntColumn get costApprovedBy => integer().nullable().named('cost_approved_by')();
  BoolColumn get requiresApproval => boolean().nullable().named('requires_approval')();
  TextColumn get history => text().nullable()(); // JSON array
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}
