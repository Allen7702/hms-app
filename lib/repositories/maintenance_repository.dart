import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/local_db/app_database.dart';
import 'package:hms_app/local_db/extensions/local_to_model.dart';
import 'package:hms_app/local_db/mappers/local_mappers.dart';
import 'package:hms_app/models/maintenance.dart';
import 'package:hms_app/services/connectivity_service.dart';

class MaintenanceRepository {
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final _client = SupabaseConfig.client;

  MaintenanceRepository(this._db, this._connectivity);

  Future<List<Maintenance>> getAll({int? hotelId, String? status, String? priority}) async {
    List<LocalMaintenance> rows;
    if (status != null) {
      rows = await _db.operationsDao.getMaintenanceByStatus(status);
    } else if (priority != null) {
      rows = await _db.operationsDao.getMaintenanceByPriority(priority);
    } else {
      rows = await _db.operationsDao.getAllMaintenance();
    }
    if (hotelId != null) rows = rows.where((r) => r.hotelId == hotelId).toList();
    rows.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    return rows.map((r) => r.toModel()).toList();
  }

  Future<Maintenance?> getById(int id) async {
    final rows = await _db.operationsDao.getAllMaintenance();
    final match = rows.where((r) => r.id == id).toList();
    return match.isEmpty ? null : match.first.toModel();
  }

  Future<Maintenance> create(Map<String, dynamic> data) async {
    _requireOnline();
    final response =
        await _client.from('maintenances').insert(data).select().single();
    await _db.operationsDao.upsertMaintenance(maintenanceFromMap(response));
    return Maintenance.fromJson(response);
  }

  Future<Maintenance> update(int id, Map<String, dynamic> data) async {
    final now = DateTime.now().toIso8601String();
    final payload = {...data, 'id': id, 'updated_at': now};

    await _db.operationsDao.upsertMaintenance(maintenanceFromMap(payload));

    if (_connectivity.isOnline) {
      final response = await _client
          .from('maintenances')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return Maintenance.fromJson(response);
    } else {
      await _enqueue('maintenances', 'update', id, payload);
      final rows = await _db.operationsDao.getAllMaintenance();
      return rows.firstWhere((r) => r.id == id).toModel();
    }
  }

  Future<Maintenance> resolve(int id) => update(id, {'status': 'Resolved'});

  Stream<List<Map<String, dynamic>>> subscribe() =>
      _client.from('maintenances').stream(primaryKey: ['id']).order('created_at', ascending: false);

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
