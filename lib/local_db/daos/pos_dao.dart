import 'package:drift/drift.dart';
import '../app_database.dart';

part 'pos_dao.g.dart';

@DriftAccessor(tables: [
  PosCategoriesTable,
  PosProductsTable,
  PosTablesTable,
  PosShiftsTable,
  PosOrdersTable,
  PosOrderItemsTable,
  PosPaymentsTable,
  PosCashMovementsTable,
  PosRefundsTable,
  PosWastageLogsTable,
])
class PosDao extends DatabaseAccessor<AppDatabase> with _$PosDaoMixin {
  PosDao(super.db);

  // ─── Categories ────────────────────────────────────────────────────────────

  Future<List<LocalPosCategory>> getAllCategories() =>
      (select(posCategoriesTable)..where((t) => t.isActive.equals(true))).get();
  Future<void> upsertCategory(PosCategoriesTableCompanion c) =>
      into(posCategoriesTable).insertOnConflictUpdate(c);
  Future<void> upsertAllCategories(List<PosCategoriesTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(posCategoriesTable, rows));
  Future<void> clearCategories() => delete(posCategoriesTable).go();

  // ─── Products ──────────────────────────────────────────────────────────────

  Stream<List<LocalPosProduct>> watchAllProducts() =>
      select(posProductsTable).watch();
  Future<List<LocalPosProduct>> getAllProducts() =>
      select(posProductsTable).get();
  Future<List<LocalPosProduct>> getProductsByCategory(int categoryId) =>
      (select(posProductsTable)
            ..where((t) =>
                t.categoryId.equals(categoryId) & t.isAvailable.equals(true)))
          .get();
  Future<void> upsertProduct(PosProductsTableCompanion c) =>
      into(posProductsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllProducts(List<PosProductsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(posProductsTable, rows));
  Future<void> clearProducts() => delete(posProductsTable).go();

  // ─── Tables ────────────────────────────────────────────────────────────────

  Stream<List<LocalPosTable>> watchAllTables() =>
      select(posTablesTable).watch();
  Future<List<LocalPosTable>> getAllTables() => select(posTablesTable).get();
  Future<void> upsertTable(PosTablesTableCompanion c) =>
      into(posTablesTable).insertOnConflictUpdate(c);
  Future<void> upsertAllTables(List<PosTablesTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(posTablesTable, rows));
  Future<void> clearTables() => delete(posTablesTable).go();

  // ─── Shifts ────────────────────────────────────────────────────────────────

  Future<List<LocalPosShift>> getAllShifts() => select(posShiftsTable).get();
  Future<LocalPosShift?> getOpenShift() =>
      (select(posShiftsTable)..where((t) => t.status.equals('open')))
          .getSingleOrNull();
  Future<void> upsertShift(PosShiftsTableCompanion c) =>
      into(posShiftsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllShifts(List<PosShiftsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(posShiftsTable, rows));
  Future<void> clearShifts() => delete(posShiftsTable).go();

  // ─── Orders ────────────────────────────────────────────────────────────────

  Stream<List<LocalPosOrder>> watchAllOrders() =>
      select(posOrdersTable).watch();
  Future<List<LocalPosOrder>> getAllOrders() => select(posOrdersTable).get();
  Future<LocalPosOrder?> getOrderById(int id) =>
      (select(posOrdersTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
  Future<List<LocalPosOrder>> getOpenOrders() =>
      (select(posOrdersTable)..where((t) => t.status.equals('open'))).get();
  Future<void> upsertOrder(PosOrdersTableCompanion c) =>
      into(posOrdersTable).insertOnConflictUpdate(c);
  Future<void> upsertAllOrders(List<PosOrdersTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(posOrdersTable, rows));
  Future<void> clearOrders() => delete(posOrdersTable).go();

  // ─── Order Items ───────────────────────────────────────────────────────────

  Future<List<LocalPosOrderItem>> getItemsByOrder(int orderId) =>
      (select(posOrderItemsTable)..where((t) => t.orderId.equals(orderId)))
          .get();
  Future<void> upsertOrderItem(PosOrderItemsTableCompanion c) =>
      into(posOrderItemsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllOrderItems(List<PosOrderItemsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(posOrderItemsTable, rows));
  Future<void> clearOrderItems() => delete(posOrderItemsTable).go();

  // ─── Payments ──────────────────────────────────────────────────────────────

  Future<List<LocalPosPayment>> getPaymentsByOrder(int orderId) =>
      (select(posPaymentsTable)..where((t) => t.orderId.equals(orderId))).get();
  Future<void> upsertPosPayment(PosPaymentsTableCompanion c) =>
      into(posPaymentsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllPosPayments(List<PosPaymentsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(posPaymentsTable, rows));
  Future<void> clearPosPayments() => delete(posPaymentsTable).go();

  // ─── Cash Movements ────────────────────────────────────────────────────────

  Future<List<LocalPosCashMovement>> getCashMovementsByShift(int shiftId) =>
      (select(posCashMovementsTable)
            ..where((t) => t.shiftId.equals(shiftId)))
          .get();
  Future<void> upsertCashMovement(PosCashMovementsTableCompanion c) =>
      into(posCashMovementsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllCashMovements(
          List<PosCashMovementsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(posCashMovementsTable, rows));
  Future<void> clearCashMovements() => delete(posCashMovementsTable).go();

  // ─── Refunds ───────────────────────────────────────────────────────────────

  Future<List<LocalPosRefund>> getRefundsByOrder(int orderId) =>
      (select(posRefundsTable)..where((t) => t.orderId.equals(orderId))).get();
  Future<void> upsertRefund(PosRefundsTableCompanion c) =>
      into(posRefundsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllRefunds(List<PosRefundsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(posRefundsTable, rows));
  Future<void> clearRefunds() => delete(posRefundsTable).go();

  // ─── Wastage ───────────────────────────────────────────────────────────────

  Future<List<LocalPosWastageLog>> getAllWastage() =>
      select(posWastageLogsTable).get();
  Future<void> upsertWastage(PosWastageLogsTableCompanion c) =>
      into(posWastageLogsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllWastage(List<PosWastageLogsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(posWastageLogsTable, rows));
  Future<void> clearWastage() => delete(posWastageLogsTable).go();
}
