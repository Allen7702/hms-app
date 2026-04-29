import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// ─── Tables ───────────────────────────────────────────────────────────────────
import 'tables/core_tables.dart';
import 'tables/booking_tables.dart';
import 'tables/billing_tables.dart';
import 'tables/operations_tables.dart';
import 'tables/inventory_tables.dart';
import 'tables/expense_tables.dart';
import 'tables/pos_tables.dart';
import 'tables/notification_tables.dart';
import 'tables/sync_tables.dart';

// ─── DAOs ─────────────────────────────────────────────────────────────────────
import 'daos/core_dao.dart';
import 'daos/booking_dao.dart';
import 'daos/billing_dao.dart';
import 'daos/operations_dao.dart';
import 'daos/inventory_dao.dart';
import 'daos/expense_dao.dart';
import 'daos/pos_dao.dart';
import 'daos/notification_dao.dart';
import 'daos/sync_dao.dart';

export 'tables/core_tables.dart';
export 'tables/booking_tables.dart';
export 'tables/billing_tables.dart';
export 'tables/operations_tables.dart';
export 'tables/inventory_tables.dart';
export 'tables/expense_tables.dart';
export 'tables/pos_tables.dart';
export 'tables/notification_tables.dart';
export 'tables/sync_tables.dart';

export 'daos/core_dao.dart';
export 'daos/booking_dao.dart';
export 'daos/billing_dao.dart';
export 'daos/operations_dao.dart';
export 'daos/inventory_dao.dart';
export 'daos/expense_dao.dart';
export 'daos/pos_dao.dart';
export 'daos/notification_dao.dart';
export 'daos/sync_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    // Core
    UsersTable,
    HotelsTable,
    RoomTypesTable,
    RoomsTable,
    GuestsTable,
    // Bookings
    BookingsTable,
    OtaReservationsTable,
    // Billing
    InvoicesTable,
    PaymentsTable,
    ChargesTable,
    // Operations
    HousekeepingsTable,
    MaintenancesTable,
    // Inventory
    InventoryCategoriesTable,
    InventoryItemsTable,
    InventoryTransactionsTable,
    RoomInventoryTable,
    ReorderAlertsTable,
    // Expenses
    ExpenseCategoriesTable,
    ExpensesTable,
    RecurringExpensesTable,
    // POS
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
    // Notifications & Audit
    NotificationsTable,
    AuditLogsTable,
    // Sync
    SyncQueueTable,
    SyncMetaTable,
  ],
  daos: [
    CoreDao,
    BookingDao,
    BillingDao,
    OperationsDao,
    InventoryDao,
    ExpenseDao,
    PosDao,
    NotificationDao,
    SyncDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // For testing — inject a custom executor
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Future migrations go here
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'hms.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
