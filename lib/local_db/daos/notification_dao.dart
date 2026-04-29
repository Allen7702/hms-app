import 'package:drift/drift.dart';
import '../app_database.dart';

part 'notification_dao.g.dart';

@DriftAccessor(tables: [NotificationsTable, AuditLogsTable])
class NotificationDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationDaoMixin {
  NotificationDao(super.db);

  // ─── Notifications ─────────────────────────────────────────────────────────

  Stream<List<LocalNotification>> watchAll() =>
      (select(notificationsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();
  Future<List<LocalNotification>> getAll() => select(notificationsTable).get();
  Future<List<LocalNotification>> getUnread() =>
      (select(notificationsTable)..where((t) => t.status.equals('Pending')))
          .get();
  Future<void> upsertNotification(NotificationsTableCompanion c) =>
      into(notificationsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllNotifications(List<NotificationsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(notificationsTable, rows));
  Future<int> deleteNotification(int id) =>
      (delete(notificationsTable)..where((t) => t.id.equals(id))).go();
  Future<void> clearNotifications() => delete(notificationsTable).go();

  // ─── Audit Logs ────────────────────────────────────────────────────────────

  Stream<List<LocalAuditLog>> watchAuditLogs() =>
      (select(auditLogsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();
  Future<List<LocalAuditLog>> getAllAuditLogs() => select(auditLogsTable).get();
  Future<List<LocalAuditLog>> getAuditLogsByEntity(
          String entityType, int entityId) =>
      (select(auditLogsTable)
            ..where((t) =>
                t.entityType.equals(entityType) &
                t.entityId.equals(entityId)))
          .get();
  Future<void> upsertAuditLog(AuditLogsTableCompanion c) =>
      into(auditLogsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllAuditLogs(List<AuditLogsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(auditLogsTable, rows));
  Future<void> clearAuditLogs() => delete(auditLogsTable).go();
}
