import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/models/guest.dart';

class GuestRepository {
  final _client = SupabaseConfig.client;

  /// Get all guests
  Future<List<Guest>> getAll({String? search}) async {
    var query = _client.from('guests').select();

    if (search != null && search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,email.ilike.%$search%,phone.ilike.%$search%');
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((e) => Guest.fromJson(e)).toList();
  }

  /// Get guest by ID
  Future<Guest?> getById(int id) async {
    final response = await _client
        .from('guests')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Guest.fromJson(response);
  }

  /// Create guest
  Future<Guest> create(Map<String, dynamic> data) async {
    final response = await _client
        .from('guests')
        .insert(data)
        .select()
        .single();

    return Guest.fromJson(response);
  }

  /// Update guest
  Future<Guest> update(int id, Map<String, dynamic> data) async {
    final response = await _client
        .from('guests')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return Guest.fromJson(response);
  }

  /// Search guests by name
  Future<List<Guest>> searchByName(String name) async {
    final response = await _client
        .from('guests')
        .select()
        .ilike('name', '%$name%')
        .limit(10);

    return (response as List).map((e) => Guest.fromJson(e)).toList();
  }
}
