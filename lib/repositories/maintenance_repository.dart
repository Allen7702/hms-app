import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/models/maintenance.dart';

class MaintenanceRepository {
  final _client = SupabaseConfig.client;

  /// Get all maintenance requests
  Future<List<Maintenance>> getAll({String? status, String? priority}) async {
    var query = _client.from('maintenances').select();

    if (status != null) {
      query = query.eq('status', status);
    }
    if (priority != null) {
      query = query.eq('priority', priority);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((e) => Maintenance.fromJson(e)).toList();
  }

  /// Get maintenance by ID
  Future<Maintenance?> getById(int id) async {
    final response = await _client
        .from('maintenances')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Maintenance.fromJson(response);
  }

  /// Create maintenance request
  Future<Maintenance> create(Map<String, dynamic> data) async {
    final response = await _client
        .from('maintenances')
        .insert(data)
        .select()
        .single();

    return Maintenance.fromJson(response);
  }

  /// Update maintenance request
  Future<Maintenance> update(int id, Map<String, dynamic> data) async {
    final response = await _client
        .from('maintenances')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return Maintenance.fromJson(response);
  }

  /// Resolve maintenance request
  Future<Maintenance> resolve(int id) async {
    return update(id, {'status': 'Resolved'});
  }

  /// Subscribe to maintenance changes
  Stream<List<Map<String, dynamic>>> subscribe() {
    return _client
        .from('maintenances')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }
}
