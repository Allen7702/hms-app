import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/local_db/app_database.dart';
import 'package:hms_app/local_db/extensions/local_to_model.dart';
import 'package:hms_app/local_db/mappers/local_mappers.dart';
import 'package:hms_app/models/room.dart';
import 'package:hms_app/models/room_type.dart';
import 'package:hms_app/services/connectivity_service.dart';

class RoomRepository {
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final _client = SupabaseConfig.client;

  RoomRepository(this._db, this._connectivity);

  static const _selectWithRelations = '*, room_types(*)';

  Future<List<Room>> getAll({String? status, String? floor, int? roomTypeId}) async {
    var rows = await _db.coreDao.getAllRooms();
    if (status != null) rows = rows.where((r) => r.status == status).toList();
    if (floor != null) rows = rows.where((r) => r.floor == floor).toList();
    if (roomTypeId != null) rows = rows.where((r) => r.roomTypeId == roomTypeId).toList();
    rows.sort((a, b) => (a.roomNumber ?? '').compareTo(b.roomNumber ?? ''));
    return rows.map((r) => r.toModel()).toList();
  }

  Future<Room?> getById(int id) async {
    final row = await _db.coreDao.getRoomById(id);
    return row?.toModel();
  }

  Future<Room> updateStatus(int id, String status) async {
    final now = DateTime.now().toIso8601String();
    final data = {'id': id, 'status': status, 'updated_at': now};

    await _db.coreDao.upsertRoom(roomFromMap(data));

    if (_connectivity.isOnline) {
      final response = await _client
          .from('rooms')
          .update({'status': status, 'updated_at': now})
          .eq('id', id)
          .select(_selectWithRelations)
          .single();
      return Room.fromJson(response);
    } else {
      await _enqueue('rooms', 'update', id, data);
      return (await _db.coreDao.getRoomById(id))!.toModel();
    }
  }

  Future<Map<String, int>> getStatusCounts() async {
    final rows = await _db.coreDao.getAllRooms();
    final counts = <String, int>{};
    for (final r in rows) {
      final s = r.status ?? 'Unknown';
      counts[s] = (counts[s] ?? 0) + 1;
    }
    return counts;
  }

  Future<List<RoomType>> getRoomTypes() async {
    final rows = await _db.coreDao.getAllRoomTypes();
    if (rows.isNotEmpty) return rows.map((r) => r.toModel()).toList();
    // fallback to network on first load
    final response = await _client.from('room_types').select().order('name');
    return (response as List).map((e) => RoomType.fromJson(e)).toList();
  }

  Future<RoomType> createRoomType(Map<String, dynamic> data) async {
    _requireOnline();
    final response = await _client.from('room_types').insert(data).select().single();
    await _db.coreDao.upsertRoomType(roomTypeFromMap(response));
    return RoomType.fromJson(response);
  }

  Future<RoomType> updateRoomType(int id, Map<String, dynamic> data) async {
    _requireOnline();
    final response = await _client.from('room_types').update(data).eq('id', id).select().single();
    await _db.coreDao.upsertRoomType(roomTypeFromMap(response));
    return RoomType.fromJson(response);
  }

  Future<List<String>> getFloors() async {
    final rows = await _db.coreDao.getAllRooms();
    return rows.map((r) => r.floor).whereType<String>().toSet().toList()..sort();
  }

  Stream<List<Map<String, dynamic>>> subscribe() =>
      _client.from('rooms').stream(primaryKey: ['id']).order('room_number');

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
