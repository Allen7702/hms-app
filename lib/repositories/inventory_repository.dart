import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/local_db/app_database.dart';
import 'package:hms_app/local_db/extensions/local_to_model.dart';
import 'package:hms_app/local_db/mappers/local_mappers.dart';
import 'package:hms_app/models/inventory_category.dart';
import 'package:hms_app/models/inventory_item.dart';
import 'package:hms_app/models/inventory_transaction.dart';
import 'package:hms_app/models/reorder_alert.dart';
import 'package:hms_app/models/room_inventory.dart';
import 'package:hms_app/services/connectivity_service.dart';

class InventoryRepository {
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final _client = SupabaseConfig.client;

  InventoryRepository(this._db, this._connectivity);

  // ─── Categories ────────────────────────────────────────────────────────────

  Future<List<InventoryCategory>> getCategories() async {
    final rows = await _db.inventoryDao.getAllCategories();
    return rows.map((r) => r.toModel()).toList();
  }

  // ─── Items ─────────────────────────────────────────────────────────────────

  Future<List<InventoryItem>> getItems({int? categoryId}) async {
    var rows = await _db.inventoryDao.getAllItems();
    if (categoryId != null) rows = rows.where((r) => r.categoryId == categoryId).toList();
    rows.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    return rows.map((r) => r.toModel()).toList();
  }

  Future<InventoryItem> createItem(Map<String, dynamic> data) async {
    _requireOnline();
    final response = await _client.from('inventory_items').insert(data).select().single();
    await _db.inventoryDao.upsertItem(inventoryItemFromMap(response));
    return InventoryItem.fromJson(response);
  }

  Future<InventoryItem> updateItem(int id, Map<String, dynamic> data) async {
    final now = DateTime.now().toIso8601String();
    final payload = {...data, 'id': id, 'updated_at': now};

    await _db.inventoryDao.upsertItem(inventoryItemFromMap(payload));

    if (_connectivity.isOnline) {
      final response = await _client
          .from('inventory_items')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return InventoryItem.fromJson(response);
    } else {
      await _enqueue('inventory_items', 'update', id, payload);
      return (await _db.inventoryDao.getItemById(id))!.toModel();
    }
  }

  // ─── Transactions ──────────────────────────────────────────────────────────

  Future<List<InventoryTransaction>> getTransactions({int? itemId}) async {
    final rows = itemId != null
        ? await _db.inventoryDao.getTransactionsByItem(itemId)
        : await _db.inventoryDao.getAllTransactions();
    return rows.map((r) => r.toModel()).toList();
  }

  Future<InventoryTransaction> createTransaction(Map<String, dynamic> data) async {
    _requireOnline();
    final response =
        await _client.from('inventory_transactions').insert(data).select().single();
    await _db.inventoryDao.upsertTransaction(inventoryTransactionFromMap(response));
    return InventoryTransaction.fromJson(response);
  }

  // ─── Reorder Alerts ────────────────────────────────────────────────────────

  Future<List<ReorderAlert>> getReorderAlerts() async {
    final rows = await _db.inventoryDao.getAllAlerts();
    rows.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    return rows.map((r) => r.toModel()).toList();
  }

  // ─── Room Inventory ────────────────────────────────────────────────────────

  Future<List<RoomInventory>> getRoomInventory({int? roomId}) async {
    final rows = roomId != null
        ? await _db.inventoryDao.getRoomInventoryByRoom(roomId)
        : await _db.inventoryDao.getAllRoomInventory();
    return rows.map((r) => r.toModel()).toList();
  }

  Future<void> _enqueue(String table, String op, int id, Map<String, dynamic> payload) =>
      _db.syncDao.enqueue(SyncQueueTableCompanion(
        entityTable: Value(table),
        operation: Value(op),
        recordId: Value(id),
        payload: Value(jsonEncode(payload)),
        createdAt: Value(DateTime.now().toIso8601String()),
      ));

  void _requireOnline() {
    if (!_connectivity.isOnline) {
      throw Exception('This action requires an internet connection.');
    }
  }
}
