import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/maintenance.dart';
import 'package:hms_app/repositories/maintenance_repository.dart';

final maintenanceRepositoryProvider = Provider((ref) => MaintenanceRepository());

final maintenanceProvider = FutureProvider<List<Maintenance>>((ref) async {
  final repo = ref.read(maintenanceRepositoryProvider);
  return repo.getAll();
});
