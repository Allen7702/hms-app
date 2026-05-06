import 'package:hms_app/local_db/app_database.dart';
import 'package:hms_app/local_db/extensions/local_to_model.dart';
import 'package:hms_app/models/audit_log.dart';
import 'package:hms_app/services/connectivity_service.dart';

class AuditRepository {
  final AppDatabase _db;
  // ignore: unused_field
  final ConnectivityService _connectivity;

  AuditRepository(this._db, this._connectivity);

  Future<List<AuditLog>> getAll({
    int? hotelId,
    String? entityType,
    String? action,
    int? userId,
    int limit = 50,
    int offset = 0,
  }) async {
    var rows = await _db.notificationDao.getAllAuditLogs();
    if (hotelId != null) rows = rows.where((r) => r.hotelId == hotelId).toList();
    if (entityType != null) rows = rows.where((r) => r.entityType == entityType).toList();
    if (action != null) rows = rows.where((r) => r.action == action).toList();
    if (userId != null) rows = rows.where((r) => r.userId == userId).toList();
    rows.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    return rows.skip(offset).take(limit).map((r) => r.toModel()).toList();
  }
}
