import 'package:drift/drift.dart';
import '../app_database.dart';

part 'expense_dao.g.dart';

@DriftAccessor(tables: [ExpenseCategoriesTable, ExpensesTable, RecurringExpensesTable])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  ExpenseDao(super.db);

  // ─── Categories ────────────────────────────────────────────────────────────

  Future<List<LocalExpenseCategory>> getAllCategories() =>
      select(expenseCategoriesTable).get();
  Future<void> upsertCategory(ExpenseCategoriesTableCompanion c) =>
      into(expenseCategoriesTable).insertOnConflictUpdate(c);
  Future<void> upsertAllCategories(List<ExpenseCategoriesTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(expenseCategoriesTable, rows));
  Future<void> clearCategories() => delete(expenseCategoriesTable).go();

  // ─── Expenses ──────────────────────────────────────────────────────────────

  Stream<List<LocalExpense>> watchAllExpenses() =>
      (select(expensesTable)..orderBy([(t) => OrderingTerm.desc(t.expenseDate)])).watch();
  Future<List<LocalExpense>> getAllExpenses() => select(expensesTable).get();
  Future<LocalExpense?> getExpenseById(int id) =>
      (select(expensesTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> upsertExpense(ExpensesTableCompanion c) =>
      into(expensesTable).insertOnConflictUpdate(c);
  Future<void> upsertAllExpenses(List<ExpensesTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(expensesTable, rows));
  Future<int> deleteExpense(int id) =>
      (delete(expensesTable)..where((t) => t.id.equals(id))).go();
  Future<void> clearExpenses() => delete(expensesTable).go();

  // ─── Recurring Expenses ────────────────────────────────────────────────────

  Future<List<LocalRecurringExpense>> getAllRecurring() =>
      select(recurringExpensesTable).get();
  Future<List<LocalRecurringExpense>> getActiveRecurring() =>
      (select(recurringExpensesTable)..where((t) => t.isActive.equals(true))).get();
  Future<void> upsertRecurring(RecurringExpensesTableCompanion c) =>
      into(recurringExpensesTable).insertOnConflictUpdate(c);
  Future<void> upsertAllRecurring(List<RecurringExpensesTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(recurringExpensesTable, rows));
  Future<void> clearRecurring() => delete(recurringExpensesTable).go();
}
