import 'package:drift/drift.dart';

// ─── POS Categories ───────────────────────────────────────────────────────────

@DataClassName('LocalPosCategory')
class PosCategoriesTable extends Table {
  @override
  String get tableName => 'pos_categories';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  TextColumn get name => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer().nullable().named('sort_order')();
  BoolColumn get isActive => boolean().nullable().named('is_active')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── POS Products ─────────────────────────────────────────────────────────────

@DataClassName('LocalPosProduct')
class PosProductsTable extends Table {
  @override
  String get tableName => 'pos_products';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  IntColumn get categoryId => integer().nullable().named('category_id')();
  TextColumn get name => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable().named('image_url')();
  IntColumn get sellPrice => integer().nullable().named('sell_price')();
  IntColumn get costPrice => integer().nullable().named('cost_price')();
  TextColumn get taxPercent => text().nullable().named('tax_percent')();
  BoolColumn get isAvailable => boolean().nullable().named('is_available')();
  BoolColumn get isFeatured => boolean().nullable().named('is_featured')();
  BoolColumn get trackStock => boolean().nullable().named('track_stock')();
  IntColumn get inventoryItemId => integer().nullable().named('inventory_item_id')();
  IntColumn get sortOrder => integer().nullable().named('sort_order')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── POS Tables (floor plan) ──────────────────────────────────────────────────

@DataClassName('LocalPosTable')
class PosTablesTable extends Table {
  @override
  String get tableName => 'pos_tables';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  TextColumn get name => text().nullable()();
  IntColumn get capacity => integer().nullable()();
  TextColumn get floor => text().nullable()();
  TextColumn get status => text().nullable()();
  IntColumn get currentOrderId => integer().nullable().named('current_order_id')();
  IntColumn get sortOrder => integer().nullable().named('sort_order')();
  BoolColumn get isActive => boolean().nullable().named('is_active')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── POS Shifts ───────────────────────────────────────────────────────────────

@DataClassName('LocalPosShift')
class PosShiftsTable extends Table {
  @override
  String get tableName => 'pos_shifts';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  IntColumn get openedBy => integer().nullable().named('opened_by')();
  IntColumn get closedBy => integer().nullable().named('closed_by')();
  TextColumn get openedAt => text().nullable().named('opened_at')();
  TextColumn get closedAt => text().nullable().named('closed_at')();
  IntColumn get openingCash => integer().nullable().named('opening_cash')();
  IntColumn get closingCash => integer().nullable().named('closing_cash')();
  IntColumn get expectedCash => integer().nullable().named('expected_cash')();
  IntColumn get cashVariance => integer().nullable().named('cash_variance')();
  IntColumn get totalSales => integer().nullable().named('total_sales')();
  IntColumn get totalVoids => integer().nullable().named('total_voids')();
  IntColumn get totalOrders => integer().nullable().named('total_orders')();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get createdAt => text().nullable().named('created_at')();
}

// ─── POS Orders ───────────────────────────────────────────────────────────────

@DataClassName('LocalPosOrder')
class PosOrdersTable extends Table {
  @override
  String get tableName => 'pos_orders';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  IntColumn get shiftId => integer().nullable().named('shift_id')();
  IntColumn get tableId => integer().nullable().named('table_id')();
  IntColumn get bookingId => integer().nullable().named('booking_id')();
  IntColumn get roomId => integer().nullable().named('room_id')();
  TextColumn get orderNumber => text().nullable().named('order_number')();
  TextColumn get orderType => text().nullable().named('order_type')();
  TextColumn get status => text().nullable()();
  TextColumn get guestName => text().nullable().named('guest_name')();
  IntColumn get guestCount => integer().nullable().named('guest_count')();
  IntColumn get waiterId => integer().nullable().named('waiter_id')();
  IntColumn get cashierId => integer().nullable().named('cashier_id')();
  IntColumn get subtotal => integer().nullable()();
  IntColumn get taxAmount => integer().nullable().named('tax_amount')();
  IntColumn get discountAmount => integer().nullable().named('discount_amount')();
  IntColumn get total => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get voidReason => text().nullable().named('void_reason')();
  IntColumn get voidedBy => integer().nullable().named('voided_by')();
  TextColumn get voidedAt => text().nullable().named('voided_at')();
  TextColumn get kitchenSentAt => text().nullable().named('kitchen_sent_at')();
  TextColumn get settledAt => text().nullable().named('settled_at')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── POS Order Items ──────────────────────────────────────────────────────────

@DataClassName('LocalPosOrderItem')
class PosOrderItemsTable extends Table {
  @override
  String get tableName => 'pos_order_items';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get orderId => integer().nullable().named('order_id')();
  IntColumn get productId => integer().nullable().named('product_id')();
  TextColumn get productName => text().nullable().named('product_name')();
  IntColumn get unitPrice => integer().nullable().named('unit_price')();
  IntColumn get costPrice => integer().nullable().named('cost_price')();
  IntColumn get quantity => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().nullable()();
  BoolColumn get isVoided => boolean().nullable().named('is_voided')();
  TextColumn get voidReason => text().nullable().named('void_reason')();
  IntColumn get voidedBy => integer().nullable().named('voided_by')();
  TextColumn get voidedAt => text().nullable().named('voided_at')();
  TextColumn get sentAt => text().nullable().named('sent_at')();
  TextColumn get createdAt => text().nullable().named('created_at')();
}

// ─── POS Payments ─────────────────────────────────────────────────────────────

@DataClassName('LocalPosPayment')
class PosPaymentsTable extends Table {
  @override
  String get tableName => 'pos_payments';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get orderId => integer().nullable().named('order_id')();
  IntColumn get shiftId => integer().nullable().named('shift_id')();
  TextColumn get method => text().nullable()();
  IntColumn get amount => integer().nullable()();
  TextColumn get reference => text().nullable()();
  IntColumn get receivedBy => integer().nullable().named('received_by')();
  TextColumn get createdAt => text().nullable().named('created_at')();
}

// ─── POS Cash Movements ───────────────────────────────────────────────────────

@DataClassName('LocalPosCashMovement')
class PosCashMovementsTable extends Table {
  @override
  String get tableName => 'pos_cash_movements';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get shiftId => integer().nullable().named('shift_id')();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  TextColumn get type => text().nullable()();
  IntColumn get amount => integer().nullable()();
  TextColumn get reason => text().nullable()();
  IntColumn get performedBy => integer().nullable().named('performed_by')();
  TextColumn get createdAt => text().nullable().named('created_at')();
}

// ─── POS Refunds ──────────────────────────────────────────────────────────────

@DataClassName('LocalPosRefund')
class PosRefundsTable extends Table {
  @override
  String get tableName => 'pos_refunds';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  IntColumn get orderId => integer().nullable().named('order_id')();
  IntColumn get shiftId => integer().nullable().named('shift_id')();
  IntColumn get amount => integer().nullable()();
  TextColumn get method => text().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get reference => text().nullable()();
  IntColumn get refundedBy => integer().nullable().named('refunded_by')();
  TextColumn get createdAt => text().nullable().named('created_at')();
}

// ─── POS Wastage Log ──────────────────────────────────────────────────────────

@DataClassName('LocalPosWastageLog')
class PosWastageLogsTable extends Table {
  @override
  String get tableName => 'pos_wastage_log';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  IntColumn get shiftId => integer().nullable().named('shift_id')();
  IntColumn get productId => integer().nullable().named('product_id')();
  TextColumn get productName => text().nullable().named('product_name')();
  IntColumn get costPrice => integer().nullable().named('cost_price')();
  IntColumn get quantity => integer().nullable()();
  TextColumn get reason => text().nullable()();
  IntColumn get recordedBy => integer().nullable().named('recorded_by')();
  TextColumn get createdAt => text().nullable().named('created_at')();
}
