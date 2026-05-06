import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/local_db/app_database.dart';
import 'package:hms_app/local_db/mappers/local_mappers.dart';
import 'connectivity_service.dart';

// ─── State ────────────────────────────────────────────────────────────────────

enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus status;
  final String? errorMessage;
  final DateTime? lastSyncedAt;
  final int pendingCount;

  const SyncState({
    this.status = SyncStatus.idle,
    this.errorMessage,
    this.lastSyncedAt,
    this.pendingCount = 0,
  });

  SyncState copyWith({
    SyncStatus? status,
    String? errorMessage,
    DateTime? lastSyncedAt,
    int? pendingCount,
  }) =>
      SyncState(
        status: status ?? this.status,
        errorMessage: errorMessage,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        pendingCount: pendingCount ?? this.pendingCount,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class SyncNotifier extends StateNotifier<SyncState> {
  final AppDatabase _db;
  final ConnectivityService _connectivity;

  StreamSubscription<bool>? _connectivitySub;
  Timer? _periodicTimer;

  SyncNotifier(this._db, this._connectivity) : super(const SyncState()) {
    _init();
  }

  Future<void> _init() async {
    await _refreshPendingCount();

    if (_connectivity.isOnline) {
      unawaited(triggerSync());
    }

    _connectivitySub = _connectivity.onConnectivityChanged.listen((online) {
      if (online) unawaited(triggerSync());
    });

    _periodicTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) {
        if (_connectivity.isOnline) unawaited(triggerSync());
      },
    );
  }

  Future<void> triggerSync() async {
    if (state.status == SyncStatus.syncing) return;
    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);

    try {
      await _pushQueue();
      await _pullAll();
      await _refreshPendingCount();
      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ─── Push ──────────────────────────────────────────────────────────────────

  Future<void> _pushQueue() async {
    final queue = await _db.syncDao.getPendingQueue();
    if (queue.isEmpty) return;

    final client = SupabaseConfig.client;

    for (final item in queue) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;

        switch (item.operation) {
          case 'create':
            await client.from(item.entityTable).upsert(payload);
          case 'update':
            await client
                .from(item.entityTable)
                .update(payload)
                .eq('id', payload['id']);
          case 'delete':
            if (item.recordId != null) {
              await client
                  .from(item.entityTable)
                  .delete()
                  .eq('id', item.recordId!);
            }
        }

        await _db.syncDao.dequeue(item.id);
      } catch (e) {
        await _db.syncDao.markFailed(item.id, e.toString());
      }
    }
  }

  // ─── Pull ──────────────────────────────────────────────────────────────────

  Future<void> _pullAll() async {
    await Future.wait([
      _pullTable('users', userFromMap, _db.coreDao.upsertAllUsers),
      _pullTable('hotels', hotelFromMap, _db.coreDao.upsertAllHotels),
      _pullTable('room_types', roomTypeFromMap, _db.coreDao.upsertAllRoomTypes),
      _pullTable('rooms', roomFromMap, _db.coreDao.upsertAllRooms),
      _pullTable('guests', guestFromMap, _db.coreDao.upsertAllGuests),
      _pullTable(
          'bookings', bookingFromMap, _db.bookingDao.upsertAllBookings),
      _pullTable('ota_reservations', otaReservationFromMap,
          _db.bookingDao.upsertAllOtaReservations),
      _pullTable(
          'invoices', invoiceFromMap, _db.billingDao.upsertAllInvoices),
      _pullTable('payments', paymentFromMap, _db.billingDao.upsertAllPayments),
      _pullTable('charges', chargeFromMap, _db.billingDao.upsertAllCharges),
      _pullTable('housekeepings', housekeepingFromMap,
          _db.operationsDao.upsertAllHousekeeping),
      _pullTable('maintenances', maintenanceFromMap,
          _db.operationsDao.upsertAllMaintenance),
      _pullTable('inventory_categories', inventoryCategoryFromMap,
          _db.inventoryDao.upsertAllCategories),
      _pullTable('inventory_items', inventoryItemFromMap,
          _db.inventoryDao.upsertAllItems),
      _pullTable('inventory_transactions', inventoryTransactionFromMap,
          _db.inventoryDao.upsertAllTransactions,
          timestampColumn: 'created_at'),
      _pullTable('room_inventory', roomInventoryFromMap,
          _db.inventoryDao.upsertAllRoomInventory),
      _pullTable('reorder_alerts', reorderAlertFromMap,
          _db.inventoryDao.upsertAllAlerts),
      _pullTable('expense_categories', expenseCategoryFromMap,
          _db.expenseDao.upsertAllCategories),
      _pullTable(
          'expenses', expenseFromMap, _db.expenseDao.upsertAllExpenses),
      _pullTable('recurring_expenses', recurringExpenseFromMap,
          _db.expenseDao.upsertAllRecurring),
      _pullTable('pos_categories', posCategoryFromMap,
          _db.posDao.upsertAllCategories),
      _pullTable(
          'pos_products', posProductFromMap, _db.posDao.upsertAllProducts),
      _pullTable(
          'pos_tables', posTableFromMap, _db.posDao.upsertAllTables),
      _pullTable('pos_shifts', posShiftFromMap, _db.posDao.upsertAllShifts),
      _pullTable('pos_orders', posOrderFromMap, _db.posDao.upsertAllOrders),
      _pullTable('pos_order_items', posOrderItemFromMap,
          _db.posDao.upsertAllOrderItems),
      _pullTable('pos_payments', posPaymentFromMap,
          _db.posDao.upsertAllPosPayments,
          timestampColumn: 'created_at'),
      _pullTable('pos_cash_movements', posCashMovementFromMap,
          _db.posDao.upsertAllCashMovements,
          timestampColumn: 'created_at'),
      _pullTable('pos_refunds', posRefundFromMap, _db.posDao.upsertAllRefunds,
          timestampColumn: 'created_at'),
      _pullTable('pos_wastage_log', posWastageLogFromMap,
          _db.posDao.upsertAllWastage,
          timestampColumn: 'created_at'),
      _pullTable('notifications', notificationFromMap,
          _db.notificationDao.upsertAllNotifications),
      _pullTable('audit_logs', auditLogFromMap,
          _db.notificationDao.upsertAllAuditLogs),
      _pullTable('device_tokens', deviceTokenFromMap,
          _db.notificationDao.upsertAllDeviceTokens),
    ]);
  }

  Future<void> _pullTable<C extends UpdateCompanion<dynamic>>(
    String tableName,
    C Function(Map<String, dynamic>) fromMap,
    Future<void> Function(List<C>) upsertAll, {
    String timestampColumn = 'updated_at',
  }) async {
    final lastSyncedAt = await _db.syncDao.getLastSyncedAt(tableName);
    final client = SupabaseConfig.client;

    List<dynamic> rows;
    if (lastSyncedAt != null) {
      rows = await client
          .from(tableName)
          .select()
          .gte(timestampColumn, lastSyncedAt);
    } else {
      rows = await client.from(tableName).select();
    }

    if (rows.isEmpty) return;

    final companions =
        rows.map((r) => fromMap(r as Map<String, dynamic>)).toList();
    await upsertAll(companions);

    await _db.syncDao.updateLastSyncedAt(
      tableName,
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> _refreshPendingCount() async {
    final count = await _db.syncDao.getPendingCount();
    state = state.copyWith(pendingCount: count);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _periodicTimer?.cancel();
    super.dispose();
  }
}
