import 'package:drift/drift.dart';
import '../app_database.dart';

part 'sync_dao.g.dart';

@DriftAccessor(tables: [SyncQueueTable, SyncMetaTable])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  // ─── Sync Queue ────────────────────────────────────────────────────────────

  Stream<List<SyncQueueItem>> watchPendingQueue() =>
      (select(syncQueueTable)
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Future<List<SyncQueueItem>> getPendingQueue() =>
      (select(syncQueueTable)
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<int> getPendingCount() async {
    final rows = await select(syncQueueTable).get();
    return rows.length;
  }

  Future<int> enqueue(SyncQueueTableCompanion entry) =>
      into(syncQueueTable).insert(entry);

  Future<void> markFailed(int id, String error) =>
      (update(syncQueueTable)..where((t) => t.id.equals(id))).write(
        SyncQueueTableCompanion(
          retryCount: Value(0), // will be incremented by caller
          lastError: Value(error),
        ),
      );

  Future<int> dequeue(int id) =>
      (delete(syncQueueTable)..where((t) => t.id.equals(id))).go();

  Future<void> clearQueue() => delete(syncQueueTable).go();

  // ─── Sync Meta ─────────────────────────────────────────────────────────────

  Future<SyncMeta?> getMetaForTable(String entityTable) =>
      (select(syncMetaTable)
            ..where((t) => t.entityTable.equals(entityTable)))
          .getSingleOrNull();

  Future<String?> getLastSyncedAt(String entityTable) async {
    final meta = await getMetaForTable(entityTable);
    return meta?.lastSyncedAt;
  }

  Future<void> updateLastSyncedAt(String entityTable, String isoTimestamp) =>
      into(syncMetaTable).insertOnConflictUpdate(
        SyncMetaTableCompanion(
          entityTable: Value(entityTable),
          lastSyncedAt: Value(isoTimestamp),
        ),
      );

  Future<void> clearMeta() => delete(syncMetaTable).go();
}
