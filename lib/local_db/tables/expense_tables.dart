import 'package:drift/drift.dart';

// ─── Expense Categories ───────────────────────────────────────────────────────

@DataClassName('LocalExpenseCategory')
class ExpenseCategoriesTable extends Table {
  @override
  String get tableName => 'expense_categories';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  TextColumn get name => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── Expenses ─────────────────────────────────────────────────────────────────

@DataClassName('LocalExpense')
class ExpensesTable extends Table {
  @override
  String get tableName => 'expenses';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  IntColumn get categoryId => integer().nullable().named('category_id')();
  IntColumn get recurringId => integer().nullable().named('recurring_id')();
  IntColumn get maintenanceId => integer().nullable().named('maintenance_id')();
  TextColumn get title => text().nullable()();
  IntColumn get amount => integer().nullable()();
  TextColumn get expenseDate => text().nullable().named('expense_date')();
  TextColumn get paymentMethod => text().nullable().named('payment_method')();
  TextColumn get vendor => text().nullable()();
  TextColumn get reference => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get recordedBy => integer().nullable().named('recorded_by')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── Recurring Expenses ───────────────────────────────────────────────────────

@DataClassName('LocalRecurringExpense')
class RecurringExpensesTable extends Table {
  @override
  String get tableName => 'recurring_expenses';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  IntColumn get categoryId => integer().nullable().named('category_id')();
  TextColumn get title => text().nullable()();
  IntColumn get amount => integer().nullable()();
  TextColumn get frequency => text().nullable()();
  IntColumn get dayOfMonth => integer().nullable().named('day_of_month')();
  TextColumn get paymentMethod => text().nullable().named('payment_method')();
  TextColumn get vendor => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().nullable().named('is_active')();
  TextColumn get lastApplied => text().nullable().named('last_applied')();
  TextColumn get startDate => text().nullable().named('start_date')();
  TextColumn get endDate => text().nullable().named('end_date')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}
