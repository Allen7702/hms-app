import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/hotel.dart';
import 'package:hms_app/providers/sync_provider.dart';
import 'package:hms_app/repositories/hotel_repository.dart';
import 'package:hms_app/services/connectivity_service.dart';

final hotelRepositoryProvider = Provider((ref) =>
    HotelRepository(ref.watch(appDatabaseProvider), ConnectivityService()));

final hotelProvider = FutureProvider<Hotel?>((ref) async {
  final repo = ref.read(hotelRepositoryProvider);
  return repo.getPrimary();
});
