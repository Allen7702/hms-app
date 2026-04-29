import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/local_db/app_database.dart';
import 'package:hms_app/local_db/extensions/local_to_model.dart';
import 'package:hms_app/local_db/mappers/local_mappers.dart';
import 'package:hms_app/models/hotel.dart';
import 'package:hms_app/services/connectivity_service.dart';

class HotelRepository {
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final _client = SupabaseConfig.client;

  HotelRepository(this._db, this._connectivity);

  Future<Hotel?> getPrimary() async {
    final rows = await _db.coreDao.getAllHotels();
    final active = rows.where((h) => h.isActive == true).toList();
    if (active.isNotEmpty) return active.first.toModel();
    if (rows.isNotEmpty) return rows.first.toModel();
    // fallback to network if local DB is empty
    if (_connectivity.isOnline) {
      final response = await _client
          .from('hotels')
          .select()
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();
      if (response == null) return null;
      await _db.coreDao.upsertHotel(hotelFromMap(response));
      return Hotel.fromJson(response);
    }
    return null;
  }

  Future<Hotel> updateSettings(int id, Map<String, dynamic> settings) async {
    if (!_connectivity.isOnline) throw Exception('This action requires an internet connection.');
    final response = await _client
        .from('hotels')
        .update({'settings': settings})
        .eq('id', id)
        .select()
        .single();
    await _db.coreDao.upsertHotel(hotelFromMap(response));
    return Hotel.fromJson(response);
  }

  Future<Hotel> update(int id, Map<String, dynamic> data) async {
    if (!_connectivity.isOnline) throw Exception('This action requires an internet connection.');
    final response = await _client
        .from('hotels')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    await _db.coreDao.upsertHotel(hotelFromMap(response));
    return Hotel.fromJson(response);
  }
}
