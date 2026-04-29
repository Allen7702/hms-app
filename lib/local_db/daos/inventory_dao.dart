import 'package:drift/drift.dart';
import '../app_database.dart';

part 'inventory_dao.g.dart';

@DriftAccessor(tables: [
  InventoryCategoriesTable,
  InventoryItemsTable,
  InventoryTransactionsTable,
  RoomInventoryTable,
  ReorderAlertsTable,
])
class InventoryDao extends DatabaseAccessor<AppDatabase>
    with _$InventoryDaoMixin {
  InventoryDao(super.db);

  // ─── Categories ────────────────────────────────────────────────────────────

  Stream<List<LocalInventoryCategory>> watchAllCategories() =>
      select(inventoryCategoriesTable).watch();
  Future<List<LocalInventoryCategory>> getAllCategories() =>
      select(inventoryCategoriesTable).get();
  Future<void> upsertCategory(InventoryCategoriesTableCompanion c) =>
      into(inventoryCategoriesTable).insertOnConflictUpdate(c);
  Future<void> upsertAllCategories(
          List<InventoryCategoriesTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(inventoryCategoriesTable, rows));
  Future<void> clearCategories() => delete(inventoryCategoriesTable).go();

  // ─── Items ─────────────────────────────────────────────────────────────────

  Stream<List<LocalInventoryItem>> watchAllItems() =>
      select(inventoryItemsTable).watch();
  Future<List<LocalInventoryItem>> getAllItems() =>
      select(inventoryItemsTable).get();
  Future<LocalInventoryItem?> getItemById(int id) =>
      (select(inventoryItemsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
  Future<List<LocalInventoryItem>> getLowStockItems() =>
      (select(inventoryItemsTable)
            ..where((t) => t.isActive.equals(true)))
          .get();
  Future<void> upsertItem(InventoryItemsTableCompanion c) =>
      into(inventoryItemsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllItems(List<InventoryItemsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(inventoryItemsTable, rows));
  Future<int> deleteItem(int id) =>
      (delete(inventoryItemsTable)..where((t) => t.id.equals(id))).go();
  Future<void> clearItems() => delete(inventoryItemsTable).go();

  // ─── Transactions ──────────────────────────────────────────────────────────

  Future<List<LocalInventoryTransaction>> getAllTransactions() =>
      select(inventoryTransactionsTable).get();
  Future<List<LocalInventoryTransaction>> getTransactionsByItem(int itemId) =>
      (select(inventoryTransactionsTable)
            ..where((t) => t.itemId.equals(itemId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();
  Future<void> upsertTransaction(InventoryTransactionsTableCompanion c) =>
      into(inventoryTransactionsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllTransactions(
          List<InventoryTransactionsTableCompanion> rows) =>
      batch((b) =>
          b.insertAllOnConflictUpdate(inventoryTransactionsTable, rows));
  Future<void> clearTransactions() => delete(inventoryTransactionsTable).go();

  // ─── Room Inventory ────────────────────────────────────────────────────────

  Future<List<LocalRoomInventory>> getAllRoomInventory() =>
      select(roomInventoryTable).get();
  Future<List<LocalRoomInventory>> getRoomInventoryByRoom(int roomId) =>
      (select(roomInventoryTable)..where((t) => t.roomId.equals(roomId))).get();
  Future<void> upsertRoomInventory(RoomInventoryTableCompanion c) =>
      into(roomInventoryTable).insertOnConflictUpdate(c);
  Future<void> upsertAllRoomInventory(List<RoomInventoryTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(roomInventoryTable, rows));
  Future<void> clearRoomInventory() => delete(roomInventoryTable).go();

  // ─── Reorder Alerts ────────────────────────────────────────────────────────

  Stream<List<LocalReorderAlert>> watchActiveAlerts() =>
      (select(reorderAlertsTable)
            ..where((t) => t.status.equals('Active')))
          .watch();
  Future<List<LocalReorderAlert>> getAllAlerts() =>
      select(reorderAlertsTable).get();
  Future<void> upsertAlert(ReorderAlertsTableCompanion c) =>
      into(reorderAlertsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllAlerts(List<ReorderAlertsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(reorderAlertsTable, rows));
  Future<void> clearAlerts() => delete(reorderAlertsTable).go();
}
