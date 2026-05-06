import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/local_db/app_database.dart';
import 'package:hms_app/local_db/extensions/local_to_model.dart';
import 'package:hms_app/local_db/mappers/local_mappers.dart';
import 'package:hms_app/models/booking.dart';
import 'package:hms_app/services/connectivity_service.dart';

class BookingRepository {
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final _client = SupabaseConfig.client;

  BookingRepository(this._db, this._connectivity);

  static const _selectWithRelations = '*, guests(*), rooms(*, room_types(*))';

  Future<List<Booking>> getAll({int? hotelId, String? status, String? search}) async {
    var rows = await _db.bookingDao.getAllBookings();
    if (hotelId != null) rows = rows.where((b) => b.hotelId == hotelId).toList();
    if (status != null && status != 'All') {
      rows = rows.where((b) => b.status == status).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      rows = rows.where((b) =>
          b.id.toString().contains(q) ||
          (b.notes?.toLowerCase().contains(q) ?? false)).toList();
    }
    rows.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    return rows.map((r) => r.toModel()).toList();
  }

  Future<Booking?> getById(int id) async {
    final row = await _db.bookingDao.getBookingById(id);
    return row?.toModel();
  }

  Future<List<Booking>> getTodayArrivals() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final rows = await _db.bookingDao.getTodayArrivals(today);
    return rows.map((r) => r.toModel()).toList();
  }

  Future<List<Booking>> getTodayDepartures() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final rows = await _db.bookingDao.getAllBookings();
    return rows
        .where((b) =>
            (b.checkOut?.startsWith(today) ?? false) && b.status == 'CheckedIn')
        .map((r) => r.toModel())
        .toList();
  }

  Future<Booking> create(Map<String, dynamic> data) async {
    _requireOnline();
    final response = await _client
        .from('bookings')
        .insert(data)
        .select(_selectWithRelations)
        .single();
    await _db.bookingDao.upsertBooking(bookingFromMap(response));
    return Booking.fromJson(response);
  }

  Future<Booking> update(int id, Map<String, dynamic> data) async {
    final now = DateTime.now().toIso8601String();
    final payload = {...data, 'id': id, 'updated_at': now};

    await _db.bookingDao.upsertBooking(bookingFromMap(payload));

    if (_connectivity.isOnline) {
      final response = await _client
          .from('bookings')
          .update(data)
          .eq('id', id)
          .select(_selectWithRelations)
          .single();
      return Booking.fromJson(response);
    } else {
      await _enqueue('bookings', 'update', id, payload);
      return (await _db.bookingDao.getBookingById(id))!.toModel();
    }
  }

  Future<Booking> checkIn(int id) => update(id, {'status': 'CheckedIn'});
  Future<Booking> checkOut(int id) => update(id, {'status': 'CheckedOut'});
  Future<Booking> cancel(int id) => update(id, {'status': 'Cancelled'});

  Future<List<Booking>> getByGuestId(int guestId) async {
    final rows = await _db.bookingDao.getAllBookings();
    return rows
        .where((b) => b.guestId == guestId)
        .map((r) => r.toModel())
        .toList();
  }

  Stream<List<Map<String, dynamic>>> subscribe() =>
      _client.from('bookings').stream(primaryKey: ['id']).order('created_at', ascending: false);

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
