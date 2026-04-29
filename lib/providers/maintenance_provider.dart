import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/maintenance.dart';
import 'package:hms_app/providers/sync_provider.dart';
import 'package:hms_app/repositories/maintenance_repository.dart';
import 'package:hms_app/services/connectivity_service.dart';

final maintenanceRepositoryProvider = Provider((ref) =>
    MaintenanceRepository(ref.watch(appDatabaseProvider), ConnectivityService()));

final maintenanceProvider = FutureProvider<List<Maintenance>>((ref) async {
  final repo = ref.read(maintenanceRepositoryProvider);
  return repo.getAll();
});
