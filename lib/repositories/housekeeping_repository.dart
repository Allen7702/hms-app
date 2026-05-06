import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/local_db/app_database.dart';
import 'package:hms_app/local_db/extensions/local_to_model.dart';
import 'package:hms_app/local_db/mappers/local_mappers.dart';
import 'package:hms_app/models/housekeeping.dart';
import 'package:hms_app/services/connectivity_service.dart';

class HousekeepingRepository {
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final _client = SupabaseConfig.client;

  HousekeepingRepository(this._db, this._connectivity);

  Future<List<Housekeeping>> getAll({int? hotelId, String? status}) async {
    var rows = status != null
        ? await _db.operationsDao.getHousekeepingByStatus(status)
        : await _db.operationsDao.getAllHousekeeping();
    if (hotelId != null) rows = rows.where((r) => r.hotelId == hotelId).toList();
    rows.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    return rows.map((r) => r.toModel()).toList();
  }

  Future<Housekeeping> create(Map<String, dynamic> data) async {
    _requireOnline();
    final response =
        await _client.from('housekeepings').insert(data).select().single();
    await _db.operationsDao.upsertHousekeeping(housekeepingFromMap(response));
    return Housekeeping.fromJson(response);
  }

  Future<Housekeeping> update(int id, Map<String, dynamic> data) async {
    final now = DateTime.now().toIso8601String();
    final payload = {...data, 'id': id, 'updated_at': now};

    await _db.operationsDao.upsertHousekeeping(housekeepingFromMap(payload));

    if (_connectivity.isOnline) {
      final response = await _client
          .from('housekeepings')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return Housekeeping.fromJson(response);
    } else {
      await _enqueue('housekeepings', 'update', id, payload);
      final row = await _db.operationsDao.getHousekeepingByRoom(id);
      return row.first.toModel();
    }
  }

  Future<Housekeeping> complete(int id) => update(id, {
        'status': 'Completed',
        'completed_at': DateTime.now().toIso8601String(),
      });

  Future<Map<String, int>> getStatusCounts() async {
    final rows = await _db.operationsDao.getAllHousekeeping();
    final counts = <String, int>{};
    for (final r in rows) {
      final s = r.status ?? 'Unknown';
      counts[s] = (counts[s] ?? 0) + 1;
    }
    return counts;
  }

  Stream<List<Map<String, dynamic>>> subscribe() =>
      _client.from('housekeepings').stream(primaryKey: ['id']).order('created_at', ascending: false);

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
