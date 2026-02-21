import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/housekeeping.dart';
import 'package:hms_app/repositories/housekeeping_repository.dart';

final housekeepingRepositoryProvider = Provider((ref) => HousekeepingRepository());

final housekeepingProvider = FutureProvider<List<Housekeeping>>((ref) async {
  final repo = ref.read(housekeepingRepositoryProvider);
  return repo.getAll();
});

final housekeepingStatusCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.read(housekeepingRepositoryProvider);
  return repo.getStatusCounts();
});
