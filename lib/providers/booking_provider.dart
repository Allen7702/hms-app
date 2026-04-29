import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/booking.dart';
import 'package:hms_app/providers/sync_provider.dart';
import 'package:hms_app/repositories/booking_repository.dart';
import 'package:hms_app/services/connectivity_service.dart';

final bookingRepositoryProvider = Provider((ref) =>
    BookingRepository(ref.watch(appDatabaseProvider), ConnectivityService()));

final bookingsProvider = FutureProvider.family<List<Booking>, String?>((ref, status) async {
  final repo = ref.read(bookingRepositoryProvider);
  return repo.getAll(status: status);
});

final bookingDetailProvider = FutureProvider.family<Booking?, int>((ref, id) async {
  final repo = ref.read(bookingRepositoryProvider);
  return repo.getById(id);
});

final todayArrivalsProvider = FutureProvider<List<Booking>>((ref) async {
  final repo = ref.read(bookingRepositoryProvider);
  return repo.getTodayArrivals();
});

final todayDeparturesProvider = FutureProvider<List<Booking>>((ref) async {
  final repo = ref.read(bookingRepositoryProvider);
  return repo.getTodayDepartures();
});
