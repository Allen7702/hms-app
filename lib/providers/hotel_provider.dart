import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/hotel.dart';
import 'package:hms_app/repositories/hotel_repository.dart';

final hotelRepositoryProvider = Provider((ref) => HotelRepository());

final hotelProvider = FutureProvider<Hotel?>((ref) async {
  final repo = ref.read(hotelRepositoryProvider);
  return repo.getPrimary();
});
