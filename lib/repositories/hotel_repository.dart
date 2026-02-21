import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/models/hotel.dart';

class HotelRepository {
  final _client = SupabaseConfig.client;

  /// Get the first (primary) hotel
  Future<Hotel?> getPrimary() async {
    final response = await _client
        .from('hotels')
        .select()
        .eq('is_active', true)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return Hotel.fromJson(response);
  }

  /// Update hotel settings
  Future<Hotel> updateSettings(int id, Map<String, dynamic> settings) async {
    final response = await _client
        .from('hotels')
        .update({'settings': settings})
        .eq('id', id)
        .select()
        .single();

    return Hotel.fromJson(response);
  }

  /// Update hotel info
  Future<Hotel> update(int id, Map<String, dynamic> data) async {
    final response = await _client
        .from('hotels')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return Hotel.fromJson(response);
  }
}
