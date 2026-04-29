import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/local_db/app_database.dart';
import 'package:hms_app/local_db/extensions/local_to_model.dart';
import 'package:hms_app/local_db/mappers/local_mappers.dart';
import 'package:hms_app/models/app_notification.dart';
import 'package:hms_app/services/connectivity_service.dart';

class NotificationRepository {
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final _client = SupabaseConfig.client;

  NotificationRepository(this._db, this._connectivity);

  Future<List<AppNotification>> getByUserId(int userId) async {
    final rows = await _db.notificationDao.getAll();
    return rows
        .where((r) => r.userId == userId)
        .map((r) => r.toModel())
        .toList();
  }

  Future<List<AppNotification>> getAll() async {
    final rows = await _db.notificationDao.getAll();
    return rows.map((r) => r.toModel()).toList();
  }

  Future<AppNotification> create(Map<String, dynamic> data) async {
    if (!_connectivity.isOnline) throw Exception('This action requires an internet connection.');
    final response =
        await _client.from('notifications').insert(data).select().single();
    await _db.notificationDao.upsertNotification(notificationFromMap(response));
    return AppNotification.fromJson(response);
  }

  Stream<List<Map<String, dynamic>>> subscribe() =>
      _client.from('notifications').stream(primaryKey: ['id']).order('created_at', ascending: false);
}
