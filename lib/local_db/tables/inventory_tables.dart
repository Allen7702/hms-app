import 'package:drift/drift.dart';

// ─── Inventory Categories ─────────────────────────────────────────────────────

@DataClassName('LocalInventoryCategory')
class InventoryCategoriesTable extends Table {
  @override
  String get tableName => 'inventory_categories';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  TextColumn get name => text().nullable()();
  TextColumn get categoryType => text().nullable().named('category_type')();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().nullable().named('is_active')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── Inventory Items ──────────────────────────────────────────────────────────

@DataClassName('LocalInventoryItem')
class InventoryItemsTable extends Table {
  @override
  String get tableName => 'inventory_items';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  IntColumn get categoryId => integer().nullable().named('category_id')();
  TextColumn get name => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get unit => text().nullable()();
  IntColumn get currentStock => integer().nullable().named('current_stock')();
  IntColumn get minimumStock => integer().nullable().named('minimum_stock')();
  IntColumn get maximumStock => integer().nullable().named('maximum_stock')();
  IntColumn get reorderQuantity => integer().nullable().named('reorder_quantity')();
  IntColumn get unitCost => integer().nullable().named('unit_cost')();
  IntColumn get sellingPrice => integer().nullable().named('selling_price')();
  TextColumn get storageLocation => text().nullable().named('storage_location')();
  BoolColumn get isPerishable => boolean().nullable().named('is_perishable')();
  IntColumn get expirationDays => integer().nullable().named('expiration_days')();
  TextColumn get lastRestockDate => text().nullable().named('last_restock_date')();
  BoolColumn get isActive => boolean().nullable().named('is_active')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── Inventory Transactions ───────────────────────────────────────────────────

@DataClassName('LocalInventoryTransaction')
class InventoryTransactionsTable extends Table {
  @override
  String get tableName => 'inventory_transactions';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  IntColumn get itemId => integer().nullable().named('item_id')();
  TextColumn get transactionType => text().nullable().named('transaction_type')();
  IntColumn get quantity => integer().nullable()();
  IntColumn get previousStock => integer().nullable().named('previous_stock')();
  IntColumn get newStock => integer().nullable().named('new_stock')();
  TextColumn get referenceType => text().nullable().named('reference_type')();
  IntColumn get referenceId => integer().nullable().named('reference_id')();
  IntColumn get roomId => integer().nullable().named('room_id')();
  IntColumn get bookingId => integer().nullable().named('booking_id')();
  IntColumn get unitCostAtTime => integer().nullable().named('unit_cost_at_time')();
  TextColumn get notes => text().nullable()();
  IntColumn get performedBy => integer().nullable().named('performed_by')();
  TextColumn get createdAt => text().nullable().named('created_at')();
}

// ─── Room Inventory ───────────────────────────────────────────────────────────

@DataClassName('LocalRoomInventory')
class RoomInventoryTable extends Table {
  @override
  String get tableName => 'room_inventory';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  IntColumn get roomId => integer().nullable().named('room_id')();
  IntColumn get itemId => integer().nullable().named('item_id')();
  IntColumn get parLevel => integer().nullable().named('par_level')();
  IntColumn get currentQuantity => integer().nullable().named('current_quantity')();
  TextColumn get lastChecked => text().nullable().named('last_checked')();
  IntColumn get lastCheckedBy => integer().nullable().named('last_checked_by')();
  TextColumn get lastRestocked => text().nullable().named('last_restocked')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── Reorder Alerts ───────────────────────────────────────────────────────────

@DataClassName('LocalReorderAlert')
class ReorderAlertsTable extends Table {
  @override
  String get tableName => 'reorder_alerts';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  IntColumn get itemId => integer().nullable().named('item_id')();
  IntColumn get currentStock => integer().nullable().named('current_stock')();
  IntColumn get minimumStock => integer().nullable().named('minimum_stock')();
  IntColumn get suggestedQuantity => integer().nullable().named('suggested_quantity')();
  TextColumn get status => text().nullable()();
  IntColumn get acknowledgedBy => integer().nullable().named('acknowledged_by')();
  TextColumn get acknowledgedAt => text().nullable().named('acknowledged_at')();
  IntColumn get resolvedBy => integer().nullable().named('resolved_by')();
  TextColumn get resolvedAt => text().nullable().named('resolved_at')();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}
