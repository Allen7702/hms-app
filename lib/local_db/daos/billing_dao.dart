import 'package:drift/drift.dart';
import '../app_database.dart';

part 'billing_dao.g.dart';

@DriftAccessor(tables: [InvoicesTable, PaymentsTable, ChargesTable])
class BillingDao extends DatabaseAccessor<AppDatabase> with _$BillingDaoMixin {
  BillingDao(super.db);

  // ─── Invoices ──────────────────────────────────────────────────────────────

  Stream<List<LocalInvoice>> watchAllInvoices() => select(invoicesTable).watch();
  Future<List<LocalInvoice>> getAllInvoices() => select(invoicesTable).get();

  Future<LocalInvoice?> getInvoiceById(int id) =>
      (select(invoicesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<LocalInvoice>> getInvoicesByBooking(int bookingId) =>
      (select(invoicesTable)..where((t) => t.bookingId.equals(bookingId))).get();

  Future<void> upsertInvoice(InvoicesTableCompanion c) =>
      into(invoicesTable).insertOnConflictUpdate(c);

  Future<void> upsertAllInvoices(List<InvoicesTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(invoicesTable, rows));

  Future<int> deleteInvoice(int id) =>
      (delete(invoicesTable)..where((t) => t.id.equals(id))).go();

  Future<void> clearInvoices() => delete(invoicesTable).go();

  // ─── Payments ──────────────────────────────────────────────────────────────

  Future<List<LocalPayment>> getAllPayments() => select(paymentsTable).get();

  Future<List<LocalPayment>> getPaymentsByInvoice(int invoiceId) =>
      (select(paymentsTable)..where((t) => t.invoiceId.equals(invoiceId))).get();

  Future<void> upsertPayment(PaymentsTableCompanion c) =>
      into(paymentsTable).insertOnConflictUpdate(c);

  Future<void> upsertAllPayments(List<PaymentsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(paymentsTable, rows));

  Future<void> clearPayments() => delete(paymentsTable).go();

  // ─── Charges ───────────────────────────────────────────────────────────────

  Stream<List<LocalCharge>> watchAllCharges() => select(chargesTable).watch();
  Future<List<LocalCharge>> getAllCharges() => select(chargesTable).get();

  Future<List<LocalCharge>> getChargesByBooking(int bookingId) =>
      (select(chargesTable)..where((t) => t.bookingId.equals(bookingId))).get();

  Future<void> upsertCharge(ChargesTableCompanion c) =>
      into(chargesTable).insertOnConflictUpdate(c);

  Future<void> upsertAllCharges(List<ChargesTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(chargesTable, rows));

  Future<int> deleteCharge(int id) =>
      (delete(chargesTable)..where((t) => t.id.equals(id))).go();

  Future<void> clearCharges() => delete(chargesTable).go();
}
