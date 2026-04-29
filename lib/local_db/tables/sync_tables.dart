import 'package:drift/drift.dart';

// ─── Sync Queue ───────────────────────────────────────────────────────────────
// Tracks every local mutation that hasn't been pushed to Supabase yet.

@DataClassName('SyncQueueItem')
class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  // autoIncrement → local-only PK, not from Supabase
  IntColumn get id => integer().autoIncrement()();
  // The Supabase table name (e.g. 'bookings')
  TextColumn get entityTable => text().named('entity_table')();
  // create | update | delete
  TextColumn get operation => text()();
  // The record's server ID (null for new offline creates until synced)
  IntColumn get recordId => integer().nullable().named('record_id')();
  // Full JSON payload of the record at time of mutation
  TextColumn get payload => text()();
  TextColumn get createdAt => text().named('created_at')();
  IntColumn get retryCount => integer().named('retry_count').withDefault(const Constant(0))();
  // null = pending, non-null = failed with message
  TextColumn get lastError => text().nullable().named('last_error')();
}

// ─── Sync Meta ────────────────────────────────────────────────────────────────
// One row per table — tracks the last successful sync timestamp.

@DataClassName('SyncMeta')
class SyncMetaTable extends Table {
  @override
  String get tableName => 'sync_meta';

  // Table name is the PK
  TextColumn get entityTable => text().named('entity_table')();
  TextColumn get lastSyncedAt => text().nullable().named('last_synced_at')();

  @override
  Set<Column> get primaryKey => {entityTable};
}
