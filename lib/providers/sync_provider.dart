import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/local_db/app_database.dart';
import 'package:hms_app/services/connectivity_service.dart';
import 'package:hms_app/services/sync_service.dart';

export 'package:hms_app/services/sync_service.dart' show SyncState, SyncStatus;

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final syncNotifierProvider =
    StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return SyncNotifier(db, connectivity);
});

final syncStatusProvider = Provider<SyncStatus>((ref) {
  return ref.watch(syncNotifierProvider).status;
});

final pendingCountProvider = Provider<int>((ref) {
  return ref.watch(syncNotifierProvider).pendingCount;
});

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).isOnline;
});

/// True when the local DB has no rooms yet (first-launch, never synced).
final isLocalDbEmptyProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final rooms = await db.coreDao.getAllRooms();
  return rooms.isEmpty;
});
