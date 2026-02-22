import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/models/inventory_item.dart';
import 'package:hms_app/models/inventory_category.dart';
import 'package:hms_app/models/inventory_transaction.dart';
import 'package:hms_app/models/reorder_alert.dart';
import 'package:hms_app/models/room_inventory.dart';

class InventoryRepository {
  final _client = SupabaseConfig.client;

  // Categories
  Future<List<InventoryCategory>> getCategories() async {
    final response = await _client.from('inventory_categories').select().order('name');
    return (response as List).map((e) => InventoryCategory.fromJson(e)).toList();
  }

  // Items
  Future<List<InventoryItem>> getItems({int? categoryId}) async {
    var query = _client.from('inventory_items').select();
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    final response = await query.order('name');
    return (response as List).map((e) => InventoryItem.fromJson(e)).toList();
  }

  Future<InventoryItem> createItem(Map<String, dynamic> data) async {
    final response = await _client.from('inventory_items').insert(data).select().single();
    return InventoryItem.fromJson(response);
  }

  Future<InventoryItem> updateItem(int id, Map<String, dynamic> data) async {
    final response = await _client.from('inventory_items').update(data).eq('id', id).select().single();
    return InventoryItem.fromJson(response);
  }

  // Transactions
  Future<List<InventoryTransaction>> getTransactions({int? itemId}) async {
    var query = _client.from('inventory_transactions').select();
    if (itemId != null) {
      query = query.eq('item_id', itemId);
    }
    final response = await query.order('created_at', ascending: false);
    return (response as List).map((e) => InventoryTransaction.fromJson(e)).toList();
  }

  Future<InventoryTransaction> createTransaction(Map<String, dynamic> data) async {
    final response = await _client.from('inventory_transactions').insert(data).select().single();
    return InventoryTransaction.fromJson(response);
  }

  // Reorder Alerts
  Future<List<ReorderAlert>> getReorderAlerts() async {
    final response = await _client.from('reorder_alerts').select().order('created_at', ascending: false);
    return (response as List).map((e) => ReorderAlert.fromJson(e)).toList();
  }

  // Room Inventory
  Future<List<RoomInventory>> getRoomInventory({int? roomId}) async {
    var query = _client.from('room_inventory').select();
    if (roomId != null) {
      query = query.eq('room_id', roomId);
    }
    final response = await query.order('created_at', ascending: false);
    return (response as List).map((e) => RoomInventory.fromJson(e)).toList();
  }
}
