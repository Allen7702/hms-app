import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/local_db/app_database.dart';
import 'package:hms_app/local_db/extensions/local_to_model.dart';
import 'package:hms_app/local_db/mappers/local_mappers.dart';
import 'package:hms_app/models/guest.dart';
import 'package:hms_app/services/connectivity_service.dart';

class GuestRepository {
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final _client = SupabaseConfig.client;

  GuestRepository(this._db, this._connectivity);

  Future<List<Guest>> getAll({String? search}) async {
    var rows = await _db.coreDao.getAllGuests();
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      rows = rows.where((g) =>
          (g.name?.toLowerCase().contains(q) ?? false) ||
          (g.email?.toLowerCase().contains(q) ?? false) ||
          (g.phone?.contains(q) ?? false)).toList();
    }
    rows.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    return rows.map((r) => r.toModel()).toList();
  }

  Future<Guest?> getById(int id) async {
    final row = await _db.coreDao.getGuestById(id);
    return row?.toModel();
  }

  Future<Guest> create(Map<String, dynamic> data) async {
    _requireOnline();
    final response = await _client.from('guests').insert(data).select().single();
    await _db.coreDao.upsertGuest(guestFromMap(response));
    return Guest.fromJson(response);
  }

  Future<Guest> update(int id, Map<String, dynamic> data) async {
    final now = DateTime.now().toIso8601String();
    final payload = {...data, 'id': id, 'updated_at': now};

    await _db.coreDao.upsertGuest(guestFromMap(payload));

    if (_connectivity.isOnline) {
      final response =
          await _client.from('guests').update(data).eq('id', id).select().single();
      return Guest.fromJson(response);
    } else {
      await _enqueue('guests', 'update', id, payload);
      return (await _db.coreDao.getGuestById(id))!.toModel();
    }
  }

  Future<List<Guest>> searchByName(String name) async {
    final rows = await _db.coreDao.getAllGuests();
    final q = name.toLowerCase();
    return rows
        .where((g) => g.name?.toLowerCase().contains(q) ?? false)
        .take(10)
        .map((r) => r.toModel())
        .toList();
  }

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
