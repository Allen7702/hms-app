import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/housekeeping.dart';
import 'package:hms_app/providers/sync_provider.dart';
import 'package:hms_app/repositories/housekeeping_repository.dart';
import 'package:hms_app/services/connectivity_service.dart';

final housekeepingRepositoryProvider = Provider((ref) =>
    HousekeepingRepository(ref.watch(appDatabaseProvider), ConnectivityService()));

final housekeepingProvider = FutureProvider<List<Housekeeping>>((ref) async {
  final repo = ref.read(housekeepingRepositoryProvider);
  return repo.getAll();
});

final housekeepingStatusCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.read(housekeepingRepositoryProvider);
  return repo.getStatusCounts();
});
