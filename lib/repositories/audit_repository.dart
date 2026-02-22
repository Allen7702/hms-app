import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/models/audit_log.dart';

class AuditRepository {
  final _client = SupabaseConfig.client;

  /// Get audit logs
  Future<List<AuditLog>> getAll({
    String? entityType,
    String? action,
    int? userId,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = _client.from('audit_logs').select();

    if (entityType != null) {
      query = query.eq('entity_type', entityType);
    }
    if (action != null) {
      query = query.eq('action', action);
    }
    if (userId != null) {
      query = query.eq('user_id', userId);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((e) => AuditLog.fromJson(e)).toList();
  }
}
