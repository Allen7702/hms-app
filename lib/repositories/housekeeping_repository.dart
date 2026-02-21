import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/models/housekeeping.dart';

class HousekeepingRepository {
  final _client = SupabaseConfig.client;

  /// Get all housekeeping tasks
  Future<List<Housekeeping>> getAll({String? status}) async {
    var query = _client.from('housekeepings').select();

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((e) => Housekeeping.fromJson(e)).toList();
  }

  /// Create housekeeping task
  Future<Housekeeping> create(Map<String, dynamic> data) async {
    final response = await _client
        .from('housekeepings')
        .insert(data)
        .select()
        .single();

    return Housekeeping.fromJson(response);
  }

  /// Update housekeeping task
  Future<Housekeeping> update(int id, Map<String, dynamic> data) async {
    final response = await _client
        .from('housekeepings')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return Housekeeping.fromJson(response);
  }

  /// Mark task as complete
  Future<Housekeeping> complete(int id) async {
    return update(id, {
      'status': 'Completed',
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get status counts
  Future<Map<String, int>> getStatusCounts() async {
    final response = await _client.from('housekeepings').select('status');
    final tasks = response as List;
    final counts = <String, int>{};
    for (final task in tasks) {
      final status = task['status'] as String;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  /// Subscribe to housekeeping changes
  Stream<List<Map<String, dynamic>>> subscribe() {
    return _client
        .from('housekeepings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }
}
