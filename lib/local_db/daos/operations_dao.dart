import 'package:drift/drift.dart';
import '../app_database.dart';

part 'operations_dao.g.dart';

@DriftAccessor(tables: [HousekeepingsTable, MaintenancesTable])
class OperationsDao extends DatabaseAccessor<AppDatabase>
    with _$OperationsDaoMixin {
  OperationsDao(super.db);

  // ─── Housekeeping ──────────────────────────────────────────────────────────

  Stream<List<LocalHousekeeping>> watchAllHousekeeping() =>
      select(housekeepingsTable).watch();
  Future<List<LocalHousekeeping>> getAllHousekeeping() =>
      select(housekeepingsTable).get();

  Future<List<LocalHousekeeping>> getHousekeepingByStatus(String status) =>
      (select(housekeepingsTable)..where((t) => t.status.equals(status))).get();

  Future<List<LocalHousekeeping>> getHousekeepingByRoom(int roomId) =>
      (select(housekeepingsTable)..where((t) => t.roomId.equals(roomId))).get();

  Future<void> upsertHousekeeping(HousekeepingsTableCompanion c) =>
      into(housekeepingsTable).insertOnConflictUpdate(c);

  Future<void> upsertAllHousekeeping(List<HousekeepingsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(housekeepingsTable, rows));

  Future<int> deleteHousekeeping(int id) =>
      (delete(housekeepingsTable)..where((t) => t.id.equals(id))).go();

  Future<void> clearHousekeeping() => delete(housekeepingsTable).go();

  // ─── Maintenance ───────────────────────────────────────────────────────────

  Stream<List<LocalMaintenance>> watchAllMaintenance() =>
      select(maintenancesTable).watch();
  Future<List<LocalMaintenance>> getAllMaintenance() =>
      select(maintenancesTable).get();

  Future<List<LocalMaintenance>> getMaintenanceByStatus(String status) =>
      (select(maintenancesTable)..where((t) => t.status.equals(status))).get();

  Future<List<LocalMaintenance>> getMaintenanceByPriority(String priority) =>
      (select(maintenancesTable)
            ..where((t) => t.priority.equals(priority)))
          .get();

  Future<void> upsertMaintenance(MaintenancesTableCompanion c) =>
      into(maintenancesTable).insertOnConflictUpdate(c);

  Future<void> upsertAllMaintenance(List<MaintenancesTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(maintenancesTable, rows));

  Future<int> deleteMaintenance(int id) =>
      (delete(maintenancesTable)..where((t) => t.id.equals(id))).go();

  Future<void> clearMaintenance() => delete(maintenancesTable).go();
}
