import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/models/app_notification.dart';

class NotificationRepository {
  final _client = SupabaseConfig.client;

  /// Get notifications for a user
  Future<List<AppNotification>> getByUserId(int userId) async {
    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => AppNotification.fromJson(e)).toList();
  }

  /// Get all notifications
  Future<List<AppNotification>> getAll() async {
    final response = await _client
        .from('notifications')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => AppNotification.fromJson(e)).toList();
  }

  /// Create notification
  Future<AppNotification> create(Map<String, dynamic> data) async {
    final response = await _client
        .from('notifications')
        .insert(data)
        .select()
        .single();

    return AppNotification.fromJson(response);
  }

  /// Subscribe to notification changes
  Stream<List<Map<String, dynamic>>> subscribe() {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }
}
