import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/models/room.dart';
import 'package:hms_app/models/room_type.dart';

class RoomRepository {
  final _client = SupabaseConfig.client;

  static const _selectWithRelations = '*, room_types(*)';

  /// Get all rooms with room type
  Future<List<Room>> getAll({String? status, String? floor, int? roomTypeId}) async {
    var query = _client.from('rooms').select(_selectWithRelations);

    if (status != null) {
      query = query.eq('status', status);
    }
    if (floor != null) {
      query = query.eq('floor', floor);
    }
    if (roomTypeId != null) {
      query = query.eq('room_type_id', roomTypeId);
    }

    final response = await query.order('room_number');
    return (response as List).map((e) => Room.fromJson(e)).toList();
  }

  /// Get room by ID
  Future<Room?> getById(int id) async {
    final response = await _client
        .from('rooms')
        .select(_selectWithRelations)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Room.fromJson(response);
  }

  /// Update room status
  Future<Room> updateStatus(int id, String status) async {
    final response = await _client
        .from('rooms')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .select(_selectWithRelations)
        .single();

    return Room.fromJson(response);
  }

  /// Get room status counts
  Future<Map<String, int>> getStatusCounts() async {
    final response = await _client.from('rooms').select('status');
    final rooms = response as List;
    final counts = <String, int>{};
    for (final room in rooms) {
      final status = room['status'] as String;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  /// Get all room types
  Future<List<RoomType>> getRoomTypes() async {
    final response = await _client
        .from('room_types')
        .select()
        .order('name');

    return (response as List).map((e) => RoomType.fromJson(e)).toList();
  }

  /// Create room type
  Future<RoomType> createRoomType(Map<String, dynamic> data) async {
    final response = await _client
        .from('room_types')
        .insert(data)
        .select()
        .single();

    return RoomType.fromJson(response);
  }

  /// Update room type
  Future<RoomType> updateRoomType(int id, Map<String, dynamic> data) async {
    final response = await _client
        .from('room_types')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return RoomType.fromJson(response);
  }

  /// Get distinct floors
  Future<List<String>> getFloors() async {
    final response = await _client.from('rooms').select('floor').order('floor');
    final floors = (response as List)
        .map((e) => e['floor'] as String?)
        .where((f) => f != null)
        .cast<String>()
        .toSet()
        .toList();
    return floors;
  }

  /// Subscribe to room changes
  Stream<List<Map<String, dynamic>>> subscribe() {
    return _client
        .from('rooms')
        .stream(primaryKey: ['id'])
        .order('room_number');
  }
}
