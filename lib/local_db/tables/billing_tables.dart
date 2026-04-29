import 'package:drift/drift.dart';

// ─── Invoices ─────────────────────────────────────────────────────────────────

@DataClassName('LocalInvoice')
class InvoicesTable extends Table {
  @override
  String get tableName => 'invoices';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get bookingId => integer().nullable().named('booking_id')();
  IntColumn get amount => integer().nullable()();
  IntColumn get tax => integer().nullable()();
  TextColumn get invoiceNumber => text().nullable().named('invoice_number')();
  TextColumn get status => text().nullable()();
  TextColumn get issueDate => text().nullable().named('issue_date')();
  TextColumn get dueDate => text().nullable().named('due_date')();
  TextColumn get paidAt => text().nullable().named('paid_at')();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── Payments ─────────────────────────────────────────────────────────────────

@DataClassName('LocalPayment')
class PaymentsTable extends Table {
  @override
  String get tableName => 'payments';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get invoiceId => integer().nullable().named('invoice_id')();
  IntColumn get amount => integer().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get method => text().nullable()();
  TextColumn get transactionId => text().nullable().named('transaction_id')();
  TextColumn get processedAt => text().nullable().named('processed_at')();
  TextColumn get createdAt => text().nullable().named('created_at')();
}

// ─── Charges ──────────────────────────────────────────────────────────────────

@DataClassName('LocalCharge')
class ChargesTable extends Table {
  @override
  String get tableName => 'charges';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get bookingId => integer().nullable().named('booking_id')();
  IntColumn get invoiceId => integer().nullable().named('invoice_id')();
  TextColumn get chargeType => text().nullable().named('charge_type')();
  TextColumn get description => text().nullable()();
  IntColumn get amount => integer().nullable()();
  IntColumn get quantity => integer().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get paymentMethod => text().nullable().named('payment_method')();
  TextColumn get paymentReference => text().nullable().named('payment_reference')();
  TextColumn get paidAt => text().nullable().named('paid_at')();
  IntColumn get paidAmount => integer().nullable().named('paid_amount')();
  TextColumn get addedBy => text().nullable().named('added_by')();
  TextColumn get serviceDate => text().nullable().named('service_date')();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}
